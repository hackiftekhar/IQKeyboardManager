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
#import <UIKit/UITextInputTraits.h>
#import "IQKeyboardManagerConstants.h"

@class UIFont;


/*!
    @author Iftekhar Qurashi
 
	@related hack.iftekhar@gmail.com
 
    @class IQKeyboardManager
 
	@abstract Keyboard TextField/TextView Manager
 */
@interface IQKeyboardManager : NSObject




//UIKeyboard handling

/*!
    @method sharedManager
 
    @return Returns the default singleton instance.
 */
+ (IQKeyboardManager*)sharedManager;

/*!
    @property enable

    @abstract enable/disable the keyboard manager. Default is YES(Enabled when class loads in `+(void)load` method).
 */
@property(nonatomic, assign, getter = isEnabled) BOOL enable;

/*!
    @property keyboardDistanceFromTextField
 
    @abstract To set keyboard distance from textField. can't be less than zero. Default is 10.0.
 */
@property(nonatomic, assign) CGFloat keyboardDistanceFromTextField;




//IQToolbar handling

/*!
    @property enableAutoToolbar

    @abstract Automatic add the IQToolbar functionality. Default is YES.
 */
@property(nonatomic, assign, getter = isEnableAutoToolbar) BOOL enableAutoToolbar;

/*!
    @property toolbarManageStyle
 
    @abstract AutoToolbar managing behaviour. Default is IQAutoToolbarBySubviews.
 */
@property(nonatomic, assign) IQAutoToolbarManageBehaviour toolbarManageBehaviour;

/*!
    @property shouldToolbarUsesTextFieldTintColor
 
    @abstract If YES, then uses textField's tintColor property for IQToolbar, otherwise tint color is black. Default is NO.
 */
@property(nonatomic, assign) BOOL shouldToolbarUsesTextFieldTintColor   NS_AVAILABLE_IOS(7_0);

/*!
    @property shouldShowTextFieldPlaceholder
 
    @abstract If YES, then it add the textField's placeholder text on IQToolbar. Default is YES.
 */
@property(nonatomic, assign) BOOL shouldShowTextFieldPlaceholder;

/*!
    @property placeholderFont
 
    @abstract placeholder Font. Default is nil.
 */
@property(nonatomic, strong) UIFont *placeholderFont;




//TextView handling

/*!
    @property canAdjustTextView

    @abstract Adjust textView's frame when it is too big in height. Default is NO.
 */
@property(nonatomic, assign) BOOL canAdjustTextView;




//Keyboard appearance overriding

/*!
    @property overrideKeyboardAppearance
 
    @abstract override the keyboardAppearance for all textField/textView. Default is NO.
 */
@property(nonatomic, assign) BOOL overrideKeyboardAppearance;

/*!
    @property keyboardAppearance
 
    @abstract if overrideKeyboardAppearance is YES, then all the textField keyboardAppearance is set using this property.
 */
@property(nonatomic, assign) UIKeyboardAppearance keyboardAppearance;




//Resign handling

/*!
    @property shouldResignOnTouchOutside

    @abstract Resigns Keyboard on touching outside of UITextField/View. Default is NO.
 */
@property(nonatomic, assign) BOOL shouldResignOnTouchOutside;

/*!
    @method resignFirstResponder
 
    @abstract Resigns currently first responder field.
 */
- (void)resignFirstResponder;




//Sound handling

/*!
    @property shouldPlayInputClicks
 
    @abstract If YES, then it plays inputClick sound on next/previous/done click.
 */
@property(nonatomic, assign) BOOL shouldPlayInputClicks;




//Animation handling

/*!
    @property shouldAdoptDefaultKeyboardAnimation
 
    @abstract If YES, then uses keyboard default animation curve style to move view, otherwise uses UIViewAnimationOptionCurveEaseInOut animation style. Default is YES.
 
    @discussion Sometimes strange animations may be produced if uses default curve style animation in iOS 7 and changing the textFields very frequently.
 */
@property(nonatomic, assign) BOOL shouldAdoptDefaultKeyboardAnimation;




//@final. Must not be used for subclassing.

/*!
    @method init
 
    @abstract Should create only one instance of class. Should not call init.
 */
- (id)init	__attribute__((unavailable("init is not available in IQKeyboardManager, Use sharedManager")));

/*!
    @method new
 
    @abstract Should create only one instance of class. Should not call new.
 */
+ (id)new	__attribute__((unavailable("new is not available in IQKeyboardManager, Use sharedManager")));

@end




