//
//  RLMObject+Background.m
//  Yaga
//
//  Created by valentinkovalski on 11/24/15.
//  Copyright © 2015 Raj Vir. All rights reserved.
//

#import "RLMObject+Background.h"
#import "RLMObject+JSON.h"

@implementation RLMObject (Background)

- (void)transactionOnBackgroundWithBlock:(void (^)(id backgroundSelf))block {
    id pk = self.primaryKeyValue;
    NSAssert([pk length], @"primary Key value should not be empty");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        RLMObject *backgroundSelf = [self.class objectForPrimaryKey:pk];
        [backgroundSelf.realm transactionWithBlock:^{
            block(backgroundSelf);
        }];
    });
}

@end
