//
// IQTitleBarButtonItem.h
// https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013-16 Iftekhar Qurashi.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>

#import "IQKeyboardManagerConstants.h"
#import "IQBarButtonItem.h"


/**
 BarButtonItem with title text.
 */
@interface IQTitleBarButtonItem : IQBarButtonItem

/**
 Font to be used in bar button. Default is (system font 12.0 bold).
 */
@property(nullable, nonatomic, strong) UIFont *titleFont;

/**
 titleColor to be used for displaying button text when displaying title (disabled state).
 */
@property(nullable, nonatomic, strong) UIColor *titleColor;

/**
 selectableTitleColor to be used for displaying button text when button is enabled.
 */
@property(nullable, nonatomic, strong) UIColor *selectableTitleColor;

/**
 Initialize with frame and title.
 
 @param title Title of barButtonItem.
 */
-(nonnull instancetype)initWithTitle:(nullable NSString *)title NS_DESIGNATED_INITIALIZER;

/**
 Unavailable. Please use initWithFrame:title: method
 */
-(nonnull instancetype)init NS_UNAVAILABLE;

/**
 Unavailable. Please use initWithFrame:title: method
 */
-(nonnull instancetype)initWithCoder:(nullable NSCoder *)aDecoder NS_UNAVAILABLE;

/**
 Unavailable. Please use initWithFrame:title: method
 */
+ (nonnull instancetype)new NS_UNAVAILABLE;

@end
