//
//  LoginViewController.m
//  ReactiveSensibo
//
//  Created by valentinkovalski on 7/25/16.
//  Copyright © 2016 valentinkovalski. All rights reserved.
//

#import "LoginViewController.h"
#import "UITextField+RACKeyboardSupport.h"
#import "SUtils.h"
#import "PodsTableViewController.h"
#import "PodsModel.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.emailTextField.layer.borderWidth = 0.5;
    self.passwordTextField.layer.borderWidth = 0.5;
    self.emailTextField.layer.cornerRadius = self.passwordTextField.layer.cornerRadius = 5;
    
    [self bindViewModel];
    
    [self.emailTextField becomeFirstResponder];
    
//#warning test code
//    self.emailTextField.text = @"valentinkovalski@gmail.com";
//    self.passwordTextField.text = @"pascal70";
}

- (void)bindViewModel {
    
    RAC(self.viewModel, email) = self.emailTextField.rac_textSignal;
    RAC(self.viewModel, password) = self.passwordTextField.rac_textSignal;
    RAC(self.viewModel, online) = RACObserve([AFNetworkReachabilityManager sharedManager], networkReachabilityStatus);
    
    self.loginButton.rac_command = self.viewModel.loginCommand;
    
    [self.viewModel.loginCommand.executing subscribeNext:^(NSNumber *value) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = value.boolValue;
    }];
    
    RAC(self.activityIndicator, hidden) = [self.viewModel.loginCommand.executing not];
    RAC(self.loginButton, hidden) = self.viewModel.loginCommand.executing;
    
    @weakify(self);
    [RACObserve(self.viewModel, online) subscribeNext:^(NSNumber *value) {
        @strongify(self);
        [self.loginButton setTitle:value.boolValue ? NSLocalizedString(@"Login", @"") : NSLocalizedString(@"You are offline", @"") forState:UIControlStateNormal];
    }];
    
    [self.viewModel.validEmailSignal subscribeNext:^(NSNumber *value) {
        @strongify(self);
        self.emailTextField.layer.borderColor = value.boolValue ? [[[UIColor greenColor] colorWithAlphaComponent:0.5] CGColor] : [[UIColor grayColor] CGColor];
    }];
    
    [self.viewModel.validPasswordSignal subscribeNext:^(NSNumber *value) {
        @strongify(self);
        self.passwordTextField.layer.borderColor = value.boolValue ? [[[UIColor greenColor] colorWithAlphaComponent:0.5] CGColor] : [[UIColor grayColor] CGColor];
    }];
    
    [self.emailTextField.rac_keyboardReturnSignal subscribeNext:^(id x) {
        @strongify(self);
        [self.passwordTextField becomeFirstResponder];
    }];
    
    [self.passwordTextField.rac_keyboardReturnSignal subscribeNext:^(id x) {
        @strongify(self);
        if(self.loginButton.enabled) {
            [self.viewModel login];
        }
    }];

    //handle error
    [self.viewModel.loginCommand.errors subscribeNext:^(NSError *error) {
        DLog(@"An error occured during login");
        [SUtils showErrorAlertFromHTMLData:error.userInfo[kAFNetworkingResponseErrorKey]];
    }];
    
    //handle successfull login
    [[self.viewModel.loginCommand.executionSignals concat] subscribeNext:^(id _) {
        DLog(@"login successfull");
        
        UINavigationController *navController = (UINavigationController*)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PodsNavigationControllerID"];
        PodsTableViewController *podsController = (PodsTableViewController*)navController.topViewController;
        
        podsController.podsModel = [PodsModel defaultPodsModel];
        [SUtils changeRootViewController:navController withCompletion:nil];

    }];
}


@end
