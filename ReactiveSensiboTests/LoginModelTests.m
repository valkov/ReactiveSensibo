//
//  ReactiveSensiboTests.m
//  ReactiveSensiboTests
//
//  Created by valentinkovalski on 7/25/16.
//  Copyright © 2016 valentinkovalski. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LoginModel.h"

@interface LoginModelTests : XCTestCase
@property (nonatomic, strong) LoginModel *loginModel;
@end

@implementation LoginModelTests

- (void)setUp {
    [super setUp];
    
    self.loginModel = [LoginModel new];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testValidEmail {
    self.loginModel.email = @"myemail@gmail.com";
    [self.loginModel.validEmailSignal subscribeNext:^(NSNumber *valid) {
        XCTAssert(valid.boolValue);
    }];
}

- (void)testInvalidEmailNoAt {
    self.loginModel.email = @"email_without_at.com";
    [self.loginModel.validEmailSignal subscribeNext:^(NSNumber *valid) {
        XCTAssert(!valid.boolValue);
    }];
}

- (void)testInvalidEmailNoDomainName {
    self.loginModel.email = @"email_without_domainm@";
    [self.loginModel.validEmailSignal subscribeNext:^(NSNumber *valid) {
        XCTAssert(!valid.boolValue);
    }];
}

- (void)testShortEmail {
    self.loginModel.email = @"em";
    [self.loginModel.validEmailSignal subscribeNext:^(NSNumber *valid) {
        XCTAssert(!valid.boolValue);
    }];
}

- (void)testNilEmail {
    self.loginModel.email = nil;
    [self.loginModel.validEmailSignal subscribeNext:^(NSNumber *valid) {
        XCTAssert(!valid.boolValue);
    }];
}

- (void)testValidPassword{
    self.loginModel.password = @"password";
    [self.loginModel.validPasswordSignal subscribeNext:^(NSNumber *valid) {
        XCTAssert(valid.boolValue);
    }];
}

- (void)testInvalidPassword{
    self.loginModel.password = @"pa";
    [self.loginModel.validPasswordSignal subscribeNext:^(NSNumber *valid) {
        XCTAssert(!valid.boolValue);
    }];
}

- (void)testValidLoginData {
    self.loginModel.email = @"myemail@gmail.com";
    self.loginModel.password = @"password";
    self.loginModel.online = YES;
    
    [self.loginModel.validSignal subscribeNext:^(NSNumber *valid) {
        XCTAssert(valid.boolValue);
    }];
}

- (void)testInValidLoginDataWrongEmail {
    self.loginModel.email = @"myemail";
    self.loginModel.password = @"password";
    self.loginModel.online = YES;
    
    [self.loginModel.validSignal subscribeNext:^(NSNumber *valid) {
        XCTAssert(!valid.boolValue);
    }];
}

- (void)testInValidLoginDataNoPassword {
    self.loginModel.email = @"myemail@gmail.com";
    self.loginModel.password = @"";
    self.loginModel.online = YES;
    
    [self.loginModel.validSignal subscribeNext:^(NSNumber *valid) {
        XCTAssert(!valid.boolValue);
    }];
}

- (void)testInValidLoginOffline {
    self.loginModel.email = @"myemail@gmail.com";
    self.loginModel.password = @"password";
    self.loginModel.online = NO;
    
    [self.loginModel.validSignal subscribeNext:^(NSNumber *valid) {
        XCTAssert(!valid.boolValue);
    }];
}

- (void)testLoginFailed {
    self.loginModel.email = @"valentinkovalski@gmail.com";
    self.loginModel.password = @"pascal";
    self.loginModel.online = YES;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"WaitLogin"];
    
    [self.loginModel.loginCommand.errors subscribeNext:^(NSError *error) {
        XCTAssertNotNil(error);
        
        [expectation fulfill];
    }];
    
    [self.loginModel.loginCommand execute:nil];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testLoginSuccessfulCookiesCreated {
    self.loginModel.email = @"valentinkovalski@gmail.com";
    self.loginModel.password = @"pascal70";
    self.loginModel.online = YES;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"WaitLogin"];
   
    [[self.loginModel.loginCommand.executionSignals concat] subscribeNext:^(id x) {
        XCTAssert([x isKindOfClass:[NSDictionary class]]);
        XCTAssertNotNil([[NSUserDefaults standardUserDefaults] dictionaryForKey:kSensiboCookie]);
        
        [expectation fulfill];
    }];
    
    [self.loginModel.loginCommand execute:nil];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

@end
