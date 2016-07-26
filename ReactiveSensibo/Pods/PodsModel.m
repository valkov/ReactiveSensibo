//
//  PodsModel.m
//  ReactiveSensibo
//
//  Created by valentinkovalski on 7/25/16.
//  Copyright © 2016 valentinkovalski. All rights reserved.
//

#import "PodsModel.h"
#import "NetworkingManager.h"
#import "RLMObject+Background.h"
#import "RLMArray+LongestCommonSubsequence.h"
#import "SUtils.h"

#define kPodUid @"uid"
#define kPodValue @"value"
#define kPodState @"currentState"

@implementation PodsModel

+ (NSString *)primaryKey {
    return @"name";
}

+ (PodsModel*)defaultPodsModel {
    NSString *defaultPodsModelName = @"default";
    
    PodsModel *result = (PodsModel*)[PodsModel objectForPrimaryKey:defaultPodsModelName];
    
    if(!result) {
        result = [PodsModel new];
        result.name = defaultPodsModelName;
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm transactionWithBlock:^{
            [realm addObject:result];
        }];
    }
    
    [result initialize];
    
    return result;
}

+ (NSArray*)ignoredProperties {
    return @[@"refreshCommand"];
}

- (void)initialize {
    _refreshCommand = [[RACCommand alloc] initWithEnabled:nil
                                              signalBlock:^RACSignal *(id input) {
                                                  return [[NetworkingManager sharedManager] signalForInitialInfo];
                                              }];
    
    [self.refreshCommand.executing subscribeNext:^(NSNumber *value) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = value.boolValue;
    }];
    
    //handle successfull refresh
    @weakify(self);
    [[self.refreshCommand.executionSignals concat] subscribeNext:^(NSDictionary *info) {
        @strongify(self);
        
        DLog(@"refresh successfull");
        
        NSArray *podsArray = info[@"pods"];
        
        [self transactionOnBackgroundWithBlock:^(PodsModel *backgroundSelf) {
            
            NSArray *newAndUpdated = [Pod createOrUpdateInRealm:[RLMRealm defaultRealm] withJSONArray:podsArray];
            
            NSIndexSet *addedIndexes, *removedIndexes;
            [backgroundSelf.pods indexesOfCommonElementsWithArray:newAndUpdated addedIndexes:&addedIndexes removedIndexes:&removedIndexes];
            
            //remove
            for (NSUInteger index = [removedIndexes lastIndex]; index != NSNotFound; index = [removedIndexes indexLessThanIndex:index]) {
                if (index >= backgroundSelf.pods.count) {
                    NSAssert(NO, @"can't be");
                }
                [backgroundSelf.pods removeObjectAtIndex:index];
            }
            
            //insert
            [addedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                [backgroundSelf.pods insertObject:newAndUpdated[idx] atIndex:idx];
            }];
        }];
    }];
    
    //handle error
    [self.refreshCommand.errors subscribeNext:^(NSError *error) {
        DLog(@"An error occured during refresh");
        if([AFNetworkReachabilityManager sharedManager].isReachable) {
            [SUtils showErrorAlertFromHTMLData:error.userInfo[kAFNetworkingResponseErrorKey]];
        }
        else {
            [SUtils showNoConnectionError];
        }
    }];
}

@end

@implementation PodLocationTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (nullable id)transformedValue:(nullable id)value {
    NSString *result = @"";
    
    if([value isKindOfClass:[NSDictionary class]])
        return [value[@"address"] componentsJoinedByString:@" "];
    
    return result;
}
@end

@implementation Pod

+ (NSString *)primaryKey {
    return @"uid";
}

+ (NSDictionary *)defaultPropertyValues {
    return @{@"location": @"",
             @"on": @0};
}

+ (NSArray*)ignoredProperties {
    return @[@"toggleACStateCommand"];
}

#pragma mark - RLMObject+JSON
+ (NSDictionary *)JSONInboundMappingDictionary {
    return @{
             @"podUid": @"uid",
             @"location" : @"location",
             @"acState.on" : @"on",
             @"acState.fanLevel": @"fanLevel",
             @"acState.mode": @"mode",
             @"acState.temperatureUnit": @"temperatureUnit",
             @"acState.targetTemperature": @"targetTemperature",
             };
}

+ (NSValueTransformer *)locationJSONTransformer {
    return [PodLocationTransformer new];
}

- (void)turnOn:(BOOL)on {
    
    [self.toggleACStateCommand execute:@{kPodUid:self.uid, kPodValue:@(on), kPodState:[self currentACState]}];
    
    [self transactionOnBackgroundWithBlock:^(Pod *backgroundSelf) {
        backgroundSelf.on = on;
    }];
}

- (NSDictionary*)currentACState {
    return @{@"fanLevel": self.fanLevel,
             @"mode": self.mode,
             @"temperatureUnit":self.temperatureUnit,
             @"on":[NSNumber numberWithBool:self.on],
             @"targetTemperature": @(self.targetTemperature)};
}

- (RACCommand*)createToggleCommandIfNeeded {
    if(!self.toggleACStateCommand) {
        self.toggleACStateCommand = [[RACCommand alloc] initWithEnabled:nil
                                                                   signalBlock:^RACSignal *(id input) {
                                                                       return [[NetworkingManager sharedManager] signalForUpdateACStateForPodUId:input[kPodUid] stateCommand:@"on" stateValue:input[kPodValue] currentState:input[kPodState]];
                                                                   }];
        
        [self.toggleACStateCommand.executing subscribeNext:^(NSNumber *value) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = value.boolValue;
        }];
        
        //handle successfull refresh
        [[self.toggleACStateCommand.executionSignals concat] subscribeNext:^(NSDictionary *info) {
            [SUtils showSuccess];
        }];
        
        //handle error
        @weakify(self);
        [self.toggleACStateCommand.errors subscribeNext:^(NSError *error) {
            @strongify(self);
            [self transactionOnBackgroundWithBlock:^(Pod *backgroundSelf) {
                backgroundSelf.on = !backgroundSelf.on;
            }];
            
            DLog(@"An error occured during updateACState");
            if([AFNetworkReachabilityManager sharedManager].isReachable) {
                [SUtils showErrorAlertFromHTMLData:error.userInfo[kAFNetworkingResponseErrorKey]];
            }
            else {
                [SUtils showNoConnectionError];
            }
        }];
    }
    return self.toggleACStateCommand;
}
@end
