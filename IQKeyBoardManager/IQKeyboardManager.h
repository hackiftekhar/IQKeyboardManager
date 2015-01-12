//
// IQKeyboardManager.h
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

#import "IQKeyboardManagerConstants.h"

#import <CoreGraphics/CGBase.h>

#import <Foundation/NSObject.h>
#import <Foundation/NSObjCRuntime.h>

#import <UIKit/UITextInputTraits.h>


@class UIFont;

/*  @const kIQDoneButtonToolbarTag         Default tag for toolbar with Done button            -1002.   */
extern NSInteger const kIQDoneButtonToolbarTag;
/*  @const kIQPreviousNextButtonToolbarTag Default tag for toolbar with Previous/Next buttons  -1005.   */
extern NSInteger const kIQPreviousNextButtonToolbarTag;


/*!
    @author Iftekhar Qurashi
 
	@related hack.iftekhar@gmail.com
 
    @class IQKeyboardManager
 
	@abstract Keyboard TextField/TextView Manager. A generic version of KeyboardManagement. https://developer.apple.com/Library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html
 */
@interface IQKeyboardManager : NSObject


/*******************************************/


//UIKeyboard handling

/*!
    @method sharedManager
 
    @return Returns the default singleton instance.
 */
+ (instancetype)sharedManager;

/*!
    @property enable

    @abstract enable/disable managing distance between keyboard and textField. Default is YES(Enabled when class loads in `+(void)load` method).
 */
@property(nonatomic, assign, getter = isEnabled) BOOL enable;

/*!
    @property keyboardDistanceFromTextField
 
    @abstract To set keyboard distance from textField. can't be less than zero. Default is 10.0.
 */
@property(nonatomic, assign) CGFloat keyboardDistanceFromTextField;

/*!
    @property preventShowingBottomBlankSpace
 
    @abstract Prevent keyboard manager to slide up the rootView to more than keyboard height. Default is YES.
 */
@property(nonatomic, assign) BOOL preventShowingBottomBlankSpace;


/*******************************************/


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
 
    @abstract Placeholder Font. Default is nil.
 */
@property(nonatomic, strong) UIFont *placeholderFont;


/*******************************************/


//UITextView handling

/*!
    @property canAdjustTextView

    @abstract Adjust textView's frame when it is too big in height. Default is NO.
 */
@property(nonatomic, assign) BOOL canAdjustTextView;

/*!
    @property shouldFixTextViewClip
 
    @abstract Adjust textView's contentInset to fix fix for iOS 7.0.x - http://stackoverflow.com/questions/18966675/uitextview-in-ios7-clips-the-last-line-of-text-string Default is YES.
 */
@property(nonatomic, assign) BOOL shouldFixTextViewClip;


/*******************************************/


//UIKeyboard appearance overriding

/*!
    @property overrideKeyboardAppearance
 
    @abstract Override the keyboardAppearance for all textField/textView. Default is NO.
 */
@property(nonatomic, assign) BOOL overrideKeyboardAppearance;

/*!
    @property keyboardAppearance
 
    @abstract If overrideKeyboardAppearance is YES, then all the textField keyboardAppearance is set using this property.
 */
@property(nonatomic, assign) UIKeyboardAppearance keyboardAppearance;


/*******************************************/


//UITextField/UITextView Resign handling

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


/*******************************************/


//UISound handling

/*!
    @property shouldPlayInputClicks
 
    @abstract If YES, then it plays inputClick sound on next/previous/done click.
 */
@property(nonatomic, assign) BOOL shouldPlayInputClicks;


/*******************************************/


//UIAnimation handling

/*!
    @property shouldAdoptDefaultKeyboardAnimation
 
    @abstract If YES, then uses keyboard default animation curve style to move view, otherwise uses UIViewAnimationOptionCurveEaseInOut animation style. Default is YES.
 
    @discussion Sometimes strange animations may be produced if uses default curve style animation in iOS 7 and changing the textFields very frequently.
 */
@property(nonatomic, assign) BOOL shouldAdoptDefaultKeyboardAnimation;


/*******************************************/


//@final. Must not be used for subclassing.

/*!
    @method init
 
    @abstract Should create only one instance of class. Should not call init.
 */
- (instancetype)init	__attribute__((unavailable("init is not available in IQKeyboardManager, Use sharedManager"))) NS_DESIGNATED_INITIALIZER;

/*!
    @method new
 
    @abstract Should create only one instance of class. Should not call new.
 */
+ (instancetype)new	__attribute__((unavailable("new is not available in IQKeyboardManager, Use sharedManager")));


/*******************************************/


@end




