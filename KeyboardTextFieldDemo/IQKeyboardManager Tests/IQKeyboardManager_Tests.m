//
//  IQKeyboardManager_Tests.m
//  IQKeyboardManager Tests
//
//  Created by Indresh on 22/03/15.
//  Copyright (c) 2015 Iftekhar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "IQKeyboardManager.h"

@interface IQKeyboardManager_Tests : XCTestCase

@end

@implementation IQKeyboardManager_Tests

- (void) setUp {
    NSLog(@"%@ setUp", self.name);
}

- (void) tearDown {
    NSLog(@"%@ tearDown", self.name);
}

- (void)testInitiateLibrary {

    IQKeyboardManager *kbManager = [IQKeyboardManager sharedManager];

    XCTAssertNotNil(kbManager, @"Did not initiate IQKeyboardManager");
}

@end
