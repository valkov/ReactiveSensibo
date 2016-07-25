//
//  AppDelegate.m
//  ReactiveSensibo
//
//  Created by valentinkovalski on 7/25/16.
//  Copyright © 2016 valentinkovalski. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginModel.h"
#import "LoginViewController.h"

@interface AppDelegate ()
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    //TODO: check cookies and show pods list if already logged in
    
    ((LoginViewController*)self.window.rootViewController).viewModel = [LoginModel new];
    
    return YES;
}

@end
