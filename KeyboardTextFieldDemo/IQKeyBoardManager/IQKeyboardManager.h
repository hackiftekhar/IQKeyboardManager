//
// KeyboardManager.h
// https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013-14 Iftekhar Qurashi.
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

#import <Foundation/NSObject.h>
#import <CoreGraphics/CGBase.h>

#import "IQKeyboardManagerConstants.h"

/*!
    @author Iftekhar Qurashi
 
	@related hack.iftekhar@gmail.com
 
    @class IQKeyboardManager
 
	@abstract Keyboard TextField/TextView Manager
 */
@interface IQKeyboardManager : NSObject

/*!
    @method sharedManager
 
    @return Returns the default singleton instance.
 */
+ (IQKeyboardManager*)sharedManager;

/*!
	@property keyboardDistanceFromTextField

	@abstract To set keyboard distance from textField. can't be less than zero. Default is 10.0.
 */
@property(nonatomic, assign) CGFloat keyboardDistanceFromTextField;

/*!
	@property enable

	@abstract enable/disable the keyboard manager. Default is NO.
 */
@property(nonatomic, assign, getter = isEnabled) BOOL enable;

/*!
    @property enableAutoToolbar

    @abstract Automatic add the IQToolbar functionality. Default is NO.
 */
@property(nonatomic, assign, getter = isEnableAutoToolbar) BOOL enableAutoToolbar;

/*!
    @property canAdjustTextView

    @abstract Adjust textView's frame when it is too big in height. Default is NO.
 */
@property(nonatomic, assign) BOOL canAdjustTextView;

/*!
    @property resignOnTouchOutside

    @abstract Resigns Keyboard on touching outside of UITextField/View. Default is NO.
 */
@property(nonatomic, assign) BOOL shouldResignOnTouchOutside;

/*!
    @property shouldShowTextFieldPlaceholder

    @abstract If YES, then it add the textField's placeholder text on IQToolbar. Default is NO.
 */
@property(nonatomic, assign) BOOL shouldShowTextFieldPlaceholder;

/*!
	@property toolbarManageStyle

	@abstract AutoToolbar managing behaviour. Default is IQAutoToolbarBySubviews.
 */
@property(nonatomic, assign) IQAutoToolbarManageBehaviour toolbarManageBehaviour;

/*!
	@method resignFirstResponder
 
	@abstract Resigns currently first responder field.
 */
- (void)resignFirstResponder;

/*!
    @method init
 
    @abstract Should create only one instance of class. Should not call init.
 */
- (id)init	__attribute__((unavailable("init is not available in IQKeyboardManager, Use sharedManager")));

/*!
    @method init
 
    @abstract Should create only one instance of class. Should not call new.
 */
+ (id)new	__attribute__((unavailable("new is not available in IQKeyboardManager, Use sharedManager")));


@end




