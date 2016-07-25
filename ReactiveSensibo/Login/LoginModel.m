//
//  LoginModel.m
//  ReactiveSensibo
//
//  Created by valentinkovalski on 7/25/16.
//  Copyright © 2016 valentinkovalski. All rights reserved.
//

#import "LoginModel.h"
#import "NetworkingManager.h"
#import "NSString+EmailValidation.h"

@implementation LoginModel

- (instancetype)init {
    self = [super init];
    
    if(self) {
        _validEmailSignal = [[RACObserve(self, email) map:^id(NSString *text) {
            return @(text.length >= 3 && text.isValidEmail);
        }] distinctUntilChanged];
        
        _validPasswordSignal = [[RACObserve(self, password) map:^id(NSString *text) {
            return @(text.length >= 3);
        }] distinctUntilChanged];
        
        _validSignal = [RACSignal combineLatest:@[self.validEmailSignal, self.validPasswordSignal, RACObserve(self, online)] reduce:^id(NSNumber *emailValid, NSNumber *passwordValid, NSNumber *online){
            return @(emailValid.boolValue && passwordValid.boolValue && online.boolValue);
        }];
        
        @weakify(self);
        _loginCommand = [[RACCommand alloc] initWithEnabled:_validSignal
                                                       signalBlock:^RACSignal *(id input) {
                                                           @strongify(self);
                                                           return [[NetworkingManager sharedManager] signalForLoginWithEmail:self.email andPassword:self.password];
                                                       }];
    }
    return self;
}

- (void)login {
    [self.loginCommand execute:nil];
}

@end
