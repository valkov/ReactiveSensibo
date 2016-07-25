//
//  RLMObject+Background.h
//  Yaga
//
//  Created by valentinkovalski on 11/24/15.
//  Copyright © 2015 Raj Vir. All rights reserved.
//
#import <Realm/Realm.h>

@interface RLMObject (Background)
- (void)transactionOnBackgroundWithBlock:(void (^)(id backgroundSelf))block;
@end
