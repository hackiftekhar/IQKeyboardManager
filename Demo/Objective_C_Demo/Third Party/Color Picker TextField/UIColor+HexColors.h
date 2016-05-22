//
//  UIColor+HexColors.h
//  KiwiHarness
//
//  Created by Tim Duckett on 07/09/2012.
//  Copyright (c) 2012 Charismatic Megafauna Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexColors)

@property(nonatomic, readonly) NSString *hexValue;
@property(nonatomic, readonly) CGFloat alpha;
@property(nonatomic, readonly) CGFloat red;
@property(nonatomic, readonly) CGFloat green;
@property(nonatomic, readonly) CGFloat blue;

+(UIColor *)colorWithHexString:(NSString *)hexString;

@end
