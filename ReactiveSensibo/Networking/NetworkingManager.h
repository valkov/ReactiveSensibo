//
//  NetworkingManager.h
//  ReactiveSensibo
//
//  Created by valentinkovalski on 7/25/16.
//  Copyright © 2016 valentinkovalski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

typedef void (^success) (id JSON);
typedef void (^failure) (NSError *error, id JSON);

@interface NetworkingManager : NSObject
+ (instancetype)sharedManager;

@property (nonatomic, strong) AFHTTPRequestOperationManager *operationsManager;

- (RACSignal*)signalForLoginWithEmail:(NSString*)email andPassword:(NSString*)password;
- (RACSignal*)signalForInitialInfo;
- (RACSignal*)signalForUpdateACStateForPodUId:(NSString*)podUid stateCommand:(NSString*)stateCommand stateValue:(NSNumber *)stateValue currentState:(NSDictionary*)currentState;

- (void)logout;
@end
