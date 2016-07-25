//
//  PodsModelTests.m
//  ReactiveSensibo
//
//  Created by valentinkovalski on 7/25/16.
//  Copyright © 2016 valentinkovalski. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PodsModel.h"

@interface PodsModelTests : XCTestCase
@property (nonatomic, strong) PodsModel *podsModel;
@end

@implementation PodsModelTests

- (void)setUp {
    [super setUp];
    self.podsModel = [PodsModel defaultPodsModel];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFetchInitialInfoAndSaveToTheRealm {
    XCTestExpectation *expectation = [self expectationWithDescription:@"WaitUntiRefreshed"];
    
    [self.podsModel.realm beginWriteTransaction];
    [self.podsModel.pods removeAllObjects];
    [self.podsModel.realm commitWriteTransaction];
    
    [[self.podsModel.refreshCommand.executionSignals concat] subscribeNext:^(id x) {
        
        //wait a bit as it takes some time to save json to the realm
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            XCTAssert(self.podsModel.pods.count == 2, @"There should be two pods");
            [expectation fulfill];
        });
    }];
    
    [self.podsModel.refreshCommand execute:nil];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}


@end
