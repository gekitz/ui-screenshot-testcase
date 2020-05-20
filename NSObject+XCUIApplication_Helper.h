//
//  NSObject+XCUIApplication_Helper.h
//  InVoice
//
//  Created by Georg Kitz on 14.03.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//
#import <XCTest/XCUIApplication.h>
#import <XCTest/XCUIElement.h>

@interface XCUIApplication (Private)
- (id)initPrivateWithPath:(NSString *)path bundleID:(NSString *)bundleID;
- (void)resolve;
@end

