//
//  NetworkingManager.m
//  ReactiveSensibo
//
//  Created by valentinkovalski on 7/25/16.
//  Copyright © 2016 valentinkovalski. All rights reserved.
//

#import "NetworkingManager.h"
#import "NSDictionary+ResponseObject.h"

@interface NetworkingManager ()
@property (nonatomic, copy) NSString *serverAddress;
@end

@implementation NetworkingManager

+ (instancetype)sharedManager {
    static NetworkingManager *instance = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.serverAddress = kHost;
        
        self.operationsManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:self.serverAddress]];
        self.operationsManager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        [self.operationsManager.requestSerializer setTimeoutInterval:40.];
        
        [self loadCookies];
    }
    
    return self;
}

#pragma mark - Reactive AFNetworking wrappers

- (RACSignal *)signalForPOST:(NSString *)methodPath parameters:(NSDictionary *)parameters {
    @weakify(self);
    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        
        @strongify(self);
        AFHTTPRequestOperation *op = [self.operationsManager POST:methodPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            @strongify(self);
            
            if([methodPath isEqualToString:kLoginMethodPath]) {
                [self saveCookies];
                [self saveUserData:[NSDictionary dictionaryFromResponseObject:responseObject withError:nil]];
            }
            
            [subscriber sendNext:responseObject];
            [subscriber sendCompleted];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSMutableDictionary *userInfo = [error.userInfo mutableCopy] ?: [NSMutableDictionary dictionary];
            userInfo[kSensiboNetworkOperationErrorKey] = operation;
            NSError *errorWithOperation = [NSError errorWithDomain:error.domain code:error.code userInfo:userInfo];
            
            [subscriber sendError:errorWithOperation];
        }];
        
        return [RACDisposable disposableWithBlock:^{
            [op cancel];
        }];
    }] replayLazily];
}

- (RACSignal *)signalForPATCH:(NSString *)methodPath parameters:(NSDictionary *)parameters {
    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        
        AFHTTPRequestOperation *op = [self.operationsManager PATCH:methodPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [subscriber sendNext:[NSDictionary dictionaryFromResponseObject:responseObject withError:nil]];
            [subscriber sendCompleted];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSMutableDictionary *userInfo = [error.userInfo mutableCopy] ?: [NSMutableDictionary dictionary];
            userInfo[kSensiboNetworkOperationErrorKey] = operation;
            NSError *errorWithOperation = [NSError errorWithDomain:error.domain code:error.code userInfo:userInfo];
            
            [subscriber sendError:errorWithOperation];
        }];
        
        return [RACDisposable disposableWithBlock:^{
            [op cancel];
        }];
    }] replayLazily];
}


- (RACSignal *)signalForGET:(NSString *)methodPath parameters:(NSDictionary *)parameters {
    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        
        AFHTTPRequestOperation *op = [self.operationsManager GET:methodPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [subscriber sendNext:[NSDictionary dictionaryFromResponseObject:responseObject withError:nil]];
            [subscriber sendCompleted];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSMutableDictionary *userInfo = [error.userInfo mutableCopy] ?: [NSMutableDictionary dictionary];
            userInfo[kSensiboNetworkOperationErrorKey] = operation;
            NSError *errorWithOperation = [NSError errorWithDomain:error.domain code:error.code userInfo:userInfo];
            
            [subscriber sendError:errorWithOperation];
        }];
        
        return [RACDisposable disposableWithBlock:^{
            [op cancel];
        }];
    }] replayLazily];
}

#pragma mark - Reactive API methods
- (RACSignal*)signalForLoginWithEmail:(NSString*)email andPassword:(NSString*)password {
    NSDictionary *params = @{@"email" : email,
                             @"password" : password};
    return [self signalForPOST:kLoginMethodPath parameters:params];
}

- (RACSignal*)signalForInitialInfo {
    return [self signalForGET:kInitialInfoMethodPath parameters:nil];
}

- (RACSignal*)signalForUpdateACStateForPodUId:(NSString*)podUid stateCommand:(NSString*)stateCommand stateValue:(NSNumber *)stateValue currentState:(NSDictionary*)currentState {
    
    NSDictionary *params = @{@"newValue":stateValue, @"currentAcState":currentState};
    
    NSString *methodPath = [NSString stringWithFormat:kUpdateACStateMethodPathTemplate, podUid, stateCommand];

    return [self signalForPATCH:methodPath parameters:params];
}

- (void)logout {
    [self deleteCookies];
}

#pragma mark - Helpers
- (void)saveCookies {
    NSArray* allCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:self.serverAddress]];
    for (NSHTTPCookie *cookie in allCookies) {
        NSMutableDictionary* cookieDictionary = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:kSensiboCookie]];
        [cookieDictionary setValue:cookie.properties forKey:self.serverAddress];
        [[NSUserDefaults standardUserDefaults] setObject:cookieDictionary forKey:kSensiboCookie];
    }
}

- (void)loadCookies {
    NSDictionary* cookieDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kSensiboCookie];
    NSDictionary* cookieProperties = [cookieDictionary valueForKey:self.serverAddress];
    if (cookieProperties) {
        NSHTTPCookie* cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
        NSArray* cookieArray = [NSArray arrayWithObject:cookie];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookieArray forURL:[NSURL URLWithString:self.serverAddress] mainDocumentURL:nil];
    }
}

- (void)deleteCookies {
    NSArray* allCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:self.serverAddress]];
    for (NSHTTPCookie *cookie in allCookies)
    {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kSensiboCookie])
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSensiboCookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveUserData:(NSDictionary*)userData {
    [[NSUserDefaults standardUserDefaults] setObject:userData[kUsername] forKey:kUsername];

}

@end
