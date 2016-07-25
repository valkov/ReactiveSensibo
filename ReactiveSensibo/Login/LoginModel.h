//
//  LoginModel.h
//  ReactiveSensibo
//
//  Created by valentinkovalski on 7/25/16.
//  Copyright © 2016 valentinkovalski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginModel : NSObject

@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, assign) BOOL online;

@property (nonatomic, readonly, strong) RACCommand *loginCommand;

@property (nonatomic, readonly, strong) RACSignal *validEmailSignal;
@property (nonatomic, readonly, strong) RACSignal *validPasswordSignal;
@property (nonatomic, readonly, strong) RACSignal *validSignal;

- (void)login;
@end
