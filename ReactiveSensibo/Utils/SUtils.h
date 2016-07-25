//
//  SUtils.h
//  ReactiveSensibo
//
//  Created by valentinkovalski on 7/25/16.
//  Copyright © 2016 valentinkovalski. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^emptyBlock)();
typedef void(^valueBlock)(id value);

@interface SUtils : NSObject

+ (void)changeRootViewController:(UIViewController*)viewController withCompletion:(emptyBlock)completion;

+ (void)showErrorAlertFromHTMLData:(NSData*)data;
+ (void)showNoConnectionError;
+ (void)showSuccess;

+ (NSArray *)indexSetToIndexPathArray:(NSIndexSet *)indexes section:(NSInteger)section;
@end
