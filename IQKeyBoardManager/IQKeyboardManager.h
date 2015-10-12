//
// IQKeyboardManager.h
// https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013-15 Iftekhar Qurashi.
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
#import <UIKit/UIView.h>

#if !(__has_feature(objc_instancetype))
#define instancetype id
#endif

@class UIFont;

///---------------------
/// @name IQToolbar tags
///---------------------

/**
 Default tag for toolbar with Done button   -1002.
 */
extern NSInteger const kIQDoneButtonToolbarTag;

/**
 Default tag for toolbar with Previous/Next buttons -1005.
 */
extern NSInteger const kIQPreviousNextButtonToolbarTag;



/**
 Codeless drop-in universal library allows to prevent issues of keyboard sliding up and cover UITextField/UITextView. Neither need to write any code nor any setup required and much more. A generic version of KeyboardManagement. https://developer.apple.com/Library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html
 */
@interface IQKeyboardManager : NSObject

///--------------------------
/// @name UIKeyboard handling
///--------------------------

/**
 Returns the default singleton instance.
 */
+ (nonnull instancetype)sharedManager;

/**
 Enable/disable managing distance between keyboard and textField. Default is YES(Enabled when class loads in `+(void)load` method).
 */
@property(nonatomic, assign, getter = isEnabled) BOOL enable;

/**
 To set keyboard distance from textField. can't be less than zero. Default is 10.0.
 */
@property(nonatomic, assign) CGFloat keyboardDistanceFromTextField;

/**
 Prevent keyboard manager to slide up the rootView to more than keyboard height. Default is YES.
 */
@property(nonatomic, assign) BOOL preventShowingBottomBlankSpace;

///-------------------------
/// @name IQToolbar handling
///-------------------------

/**
 Automatic add the IQToolbar functionality. Default is YES.
 */
@property(nonatomic, assign, getter = isEnableAutoToolbar) BOOL enableAutoToolbar;

/**
 AutoToolbar managing behaviour. Default is IQAutoToolbarBySubviews.
 */
@property(nonatomic, assign) IQAutoToolbarManageBehaviour toolbarManageBehaviour;

#ifdef NSFoundationVersionNumber_iOS_6_1
/**
 If YES, then uses textField's tintColor property for IQToolbar, otherwise tint color is black. Default is NO.
 */
@property(nonatomic, assign) BOOL shouldToolbarUsesTextFieldTintColor;
#endif

/**
 If YES, then it add the textField's placeholder text on IQToolbar. Default is YES.
 */
@property(nonatomic, assign) BOOL shouldShowTextFieldPlaceholder;

/**
 Placeholder Font. Default is nil.
 */
@property(nullable, nonatomic, strong) UIFont *placeholderFont;

///--------------------------
/// @name UITextView handling
///--------------------------

/**
 Adjust textView's frame when it is too big in height. Default is NO.
 */
@property(nonatomic, assign) BOOL canAdjustTextView;

#ifdef NSFoundationVersionNumber_iOS_6_1
/**
 Adjust textView's contentInset to fix a bug. for iOS 7.0.x - http://stackoverflow.com/questions/18966675/uitextview-in-ios7-clips-the-last-line-of-text-string Default is YES.
 */
@property(nonatomic, assign) BOOL shouldFixTextViewClip;
#endif

///---------------------------------------
/// @name UIKeyboard appearance overriding
///---------------------------------------

/**
 Override the keyboardAppearance for all textField/textView. Default is NO.
 */
@property(nonatomic, assign) BOOL overrideKeyboardAppearance;

/**
 If overrideKeyboardAppearance is YES, then all the textField keyboardAppearance is set using this property.
 */
@property(nonatomic, assign) UIKeyboardAppearance keyboardAppearance;

///---------------------------------------------
/// @name UITextField/UITextView Next/Previous/Resign handling
///---------------------------------------------

/**
 Resigns Keyboard on touching outside of UITextField/View. Default is NO.
 */
@property(nonatomic, assign) BOOL shouldResignOnTouchOutside;

/**
 Resigns currently first responder field.
 */
- (BOOL)resignFirstResponder;

/**
 Returns YES if can navigate to previous responder textField/textView, otherwise NO.
 */
@property (nonatomic, readonly) BOOL canGoPrevious;

/**
 Returns YES if can navigate to next responder textField/textView, otherwise NO.
 */
@property (nonatomic, readonly) BOOL canGoNext;

/**
 Navigate to previous responder textField/textView.
 */
- (BOOL)goPrevious;

/**
 Navigate to next responder textField/textView.
 */
- (BOOL)goNext;

///----------------------------
/// @name UIScrollView handling
///----------------------------

/**
 Restore scrollViewContentOffset when resigning from scrollView. Default is NO.
 */
@property(nonatomic, assign) BOOL shouldRestoreScrollViewContentOffset;

///------------------------------------------------
/// @name UISound handling
///------------------------------------------------

/**
 If YES, then it plays inputClick sound on next/previous/done click.
 */
@property(nonatomic, assign) BOOL shouldPlayInputClicks;

///---------------------------
/// @name UIAnimation handling
///---------------------------

/**
 If YES, then uses keyboard default animation curve style to move view, otherwise uses UIViewAnimationOptionCurveEaseInOut animation style. Default is YES.
 
 @warning Sometimes strange animations may be produced if uses default curve style animation in iOS 7 and changing the textFields very frequently.
 */
@property(nonatomic, assign) BOOL shouldAdoptDefaultKeyboardAnimation;

/**
 If YES, then calls 'setNeedsLayout' and 'layoutIfNeeded' on any frame update of to viewController's view.
 */
@property(nonatomic, assign) BOOL layoutIfNeededOnUpdate;

///------------------------------------
/// @name Class Level disabling methods
///------------------------------------

/**
 Disable adjusting view in disabledClass
 
 @param disabledClass Class in which library should not adjust view to show textField.
 */
-(void)disableInViewControllerClass:(nonnull Class)disabledClass;

/**
 Re-enable adjusting textField in disabledClass
 
 @param disabledClass Class in which library should re-enable adjust view to show textField.
 */
-(void)removeDisableInViewControllerClass:(nonnull Class)disabledClass;

/**
 Returns YES if ViewController class is disabled for library, otherwise returns NO.
 
 @param disabledClass Class which is to check for it's disability.
 */
-(BOOL)isDisableInViewControllerClass:(nonnull Class)disabledClass;

/**
 Disable automatic toolbar creation in in toolbarDisabledClass
 
 @param toolbarDisabledClass Class in which library should not add toolbar over textField.
 */
-(void)disableToolbarInViewControllerClass:(nonnull Class)toolbarDisabledClass;

/**
 Re-enable automatic toolbar creation in in toolbarDisabledClass
 
 @param toolbarDisabledClass Class in which library should re-enable automatic toolbar creation over textField.
 */
-(void)removeDisableToolbarInViewControllerClass:(nonnull Class)toolbarDisabledClass;

/**
 Returns YES if toolbar is disabled in ViewController class, otherwise returns NO.
 
 @param toolbarDisabledClass Class which is to check for toolbar disability.
 */
-(BOOL)isDisableToolbarInViewControllerClass:(nonnull Class)toolbarDisabledClass;

/**
 Consider provided customView class as superView of all inner textField for calculating next/previous button logic.
 
 @param toolbarPreviousNextConsideredClass Custom UIView subclass Class in which library should consider all inner textField as siblings and add next/previous accordingly.
 */
-(void)considerToolbarPreviousNextInViewClass:(nonnull Class)toolbarPreviousNextConsideredClass;

/**
 Remove Consideration for provided customView class as superView of all inner textField for calculating next/previous button logic.
 
 @param toolbarPreviousNextConsideredClass Custom UIView subclass Class in which library should remove consideration for all inner textField as superView.
 */
-(void)removeConsiderToolbarPreviousNextInViewClass:(nonnull Class)toolbarPreviousNextConsideredClass;

/**
 Returns YES if inner hierarchy is considered for previous/next in class, otherwise returns NO.
 
 @param toolbarPreviousNextConsideredClass Class which is to check for previous next consideration
 */
-(BOOL)isConsiderToolbarPreviousNextInViewClass:(nonnull Class)toolbarPreviousNextConsideredClass;


///----------------------------------------
/// @name Must not be used for subclassing.
///----------------------------------------

/**
 Unavailable. Please use sharedManager method
 */
-(nonnull instancetype)init NS_UNAVAILABLE;

/**
 Unavailable. Please use sharedManager method
 */
+ (nonnull instancetype)new NS_UNAVAILABLE;

@end

