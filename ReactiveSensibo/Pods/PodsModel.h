//
//  PodsModel.h
//  ReactiveSensibo
//
//  Created by valentinkovalski on 7/25/16.
//  Copyright © 2016 valentinkovalski. All rights reserved.
//


#import <RLMObject+JSON.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface PodLocationTransformer : NSValueTransformer
@end

RLM_ARRAY_TYPE(Pod)

@interface Pod : RLMObject
@property NSString *uid;
@property NSString *location;
@property NSString *fanLevel;
@property NSString *mode;
@property NSString *temperatureUnit;

@property int on;
@property int targetTemperature;

- (void)turnOn:(BOOL)on;

@property (nonatomic, strong) RACCommand *toggleACStateCommand;
- (RACCommand*)createToggleCommandIfNeeded;
@end

@interface PodsModel : RLMObject
@property NSString *name;
@property RLMArray<Pod> *pods;

@property (nonatomic, strong) RACCommand *refreshCommand;

+ (PodsModel*)defaultPodsModel;
@end


