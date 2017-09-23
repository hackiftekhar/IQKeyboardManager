//
// IQUIView+IQKeyboardToolbar.h
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

#import "IQToolbar.h"

#import <UIKit/UIView.h>

/**
 UIView category methods to add IQToolbar on UIKeyboard.
 */
@interface UIView (IQToolbarAddition)

///-------------------------
/// @name Toolbar Title
///-------------------------

/**
 IQToolbar references for better customization control.
 */
@property (readonly, nonatomic, nonnull) IQToolbar *keyboardToolbar;

/**
 If `shouldHideToolbarPlaceholder` is YES, then title will not be added to the toolbar. Default to NO.
 */
@property (assign, nonatomic) BOOL shouldHideToolbarPlaceholder;
@property (assign, nonatomic) BOOL shouldHidePlaceholderText __attribute__((deprecated("This is renamed to `shouldHideToolbarPlaceholder` for more clear naming.")));

/**
 `toolbarPlaceholder` to override default `placeholder` text when drawing text on toolbar.
 */
@property (nullable, strong, nonatomic) NSString* toolbarPlaceholder;
@property (nullable, strong, nonatomic) NSString* placeholderText __attribute__((deprecated("This is renamed to `toolbarPlaceholder` for more clear naming.")));

/**
 `drawingToolbarPlaceholder` will be actual text used to draw on toolbar. This would either `placeholder` or `toolbarPlaceholder`.
 */
@property (nullable, strong, nonatomic, readonly) NSString* drawingToolbarPlaceholder;
@property (nullable, strong, nonatomic, readonly) NSString* drawingPlaceholderText __attribute__((deprecated("This is renamed to `drawingToolbarPlaceholder` for more clear naming.")));

///------------
/// @name Done
///------------

/**
 Helper function to add Done button on keyboard.
 
 @param target Target object for selector.
 @param action Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 */
- (void)addDoneOnKeyboardWithTarget:(nullable id)target action:(nullable SEL)action;

/**
 Helper function to add Done button on keyboard.
 
 @param target Target object for selector.
 @param action Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 @param titleText text to show as title in IQToolbar'.
 */
- (void)addDoneOnKeyboardWithTarget:(nullable id)target action:(nullable SEL)action titleText:(nullable NSString*)titleText;

/**
 Helper function to add Done button on keyboard.
 
 @param target Target object for selector.
 @param action Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 @param shouldShowPlaceholder A boolean to indicate whether to show textField placeholder on IQToolbar'.
 */
- (void)addDoneOnKeyboardWithTarget:(nullable id)target action:(nullable SEL)action shouldShowPlaceholder:(BOOL)shouldShowPlaceholder;

///------------
/// @name Right
///------------

/**
 Helper function to add Right button on keyboard.
 
 @param text Title for rightBarButtonItem, usually 'Done'.
 @param target Target object for selector.
 @param action Right button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 */
- (void)addRightButtonOnKeyboardWithText:(nullable NSString*)text target:(nullable id)target action:(nullable SEL)action;

/**
 Helper function to add Right button on keyboard.
 
 @param text Title for rightBarButtonItem, usually 'Done'.
 @param target Target object for selector.
 @param action Right button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 @param titleText text to show as title in IQToolbar'.
 */
- (void)addRightButtonOnKeyboardWithText:(nullable NSString*)text target:(nullable id)target action:(nullable SEL)action titleText:(nullable NSString*)titleText;

/**
 Helper function to add Right button on keyboard.
 
 @param text Title for rightBarButtonItem, usually 'Done'.
 @param target Target object for selector.
 @param action Right button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 @param shouldShowPlaceholder A boolean to indicate whether to show textField placeholder on IQToolbar'.
 */
- (void)addRightButtonOnKeyboardWithText:(nullable NSString*)text target:(nullable id)target action:(nullable SEL)action shouldShowPlaceholder:(BOOL)shouldShowPlaceholder;

/**
 Helper function to add Right button on keyboard.
 
 @param image Image icon to use as right button.
 @param target Target object for selector.
 @param action Right button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 @param shouldShowPlaceholder A boolean to indicate whether to show textField placeholder on IQToolbar'.
 */
- (void)addRightButtonOnKeyboardWithImage:(nullable UIImage*)image target:(nullable id)target action:(nullable SEL)action shouldShowPlaceholder:(BOOL)shouldShowPlaceholder;

/**
 Helper function to add Right button on keyboard.
 
 @param image Image icon to use as right button.
 @param target Target object for selector.
 @param action Right button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 @param titleText text to show as title in IQToolbar'.
 */
- (void)addRightButtonOnKeyboardWithImage:(nullable UIImage*)image target:(nullable id)target action:(nullable SEL)action titleText:(nullable NSString*)titleText;

///------------------
/// @name Cancel/Done
///------------------

/**
 Helper function to add Cancel and Done button on keyboard.
 
 @param target Target object for selector.
 @param cancelAction Cancel button action name. Usually 'cancelAction:(IQBarButtonItem*)item'.
 @param doneAction Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 */
- (void)addCancelDoneOnKeyboardWithTarget:(nullable id)target cancelAction:(nullable SEL)cancelAction doneAction:(nullable SEL)doneAction;

/**
 Helper function to add Cancel and Done button on keyboard.
 
 @param target Target object for selector.
 @param cancelAction Cancel button action name. Usually 'cancelAction:(IQBarButtonItem*)item'.
 @param doneAction Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 @param titleText text to show as title in IQToolbar'.
 */
- (void)addCancelDoneOnKeyboardWithTarget:(nullable id)target cancelAction:(nullable SEL)cancelAction doneAction:(nullable SEL)doneAction titleText:(nullable NSString*)titleText;

/**
 Helper function to add Cancel and Done button on keyboard.
 
 @param target Target object for selector.
 @param cancelAction Cancel button action name. Usually 'cancelAction:(IQBarButtonItem*)item'.
 @param doneAction Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 @param shouldShowPlaceholder A boolean to indicate whether to show textField placeholder on IQToolbar'.
 */
- (void)addCancelDoneOnKeyboardWithTarget:(nullable id)target cancelAction:(nullable SEL)cancelAction doneAction:(nullable SEL)doneAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder;

///-----------------
/// @name Right/Left
///-----------------

/**
 Helper function to add Left and Right button on keyboard.
 
 @param target Target object for selector.
 @param leftButtonTitle Title for leftBarButtonItem, usually 'Cancel'.
 @param rightButtonTitle Title for rightBarButtonItem, usually 'Done'.
 @param leftButtonAction Left button action name. Usually 'cancelAction:(IQBarButtonItem*)item'.
 @param rightButtonAction Right button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 */
- (void)addLeftRightOnKeyboardWithTarget:(nullable id)target leftButtonTitle:(nullable NSString*)leftButtonTitle rightButtonTitle:(nullable NSString*)rightButtonTitle leftButtonAction:(nullable SEL)leftButtonAction rightButtonAction:(nullable SEL)rightButtonAction;

/**
 Helper function to add Left and Right button on keyboard.
 
 @param target Target object for selector.
 @param leftButtonTitle Title for leftBarButtonItem, usually 'Cancel'.
 @param rightButtonTitle Title for rightBarButtonItem, usually 'Done'.
 @param leftButtonAction Left button action name. Usually 'cancelAction:(IQBarButtonItem*)item'.
 @param rightButtonAction Right button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 @param titleText text to show as title in IQToolbar'.
 */
- (void)addLeftRightOnKeyboardWithTarget:(nullable id)target leftButtonTitle:(nullable NSString*)leftButtonTitle rightButtonTitle:(nullable NSString*)rightButtonTitle leftButtonAction:(nullable SEL)leftButtonAction rightButtonAction:(nullable SEL)rightButtonAction titleText:(nullable NSString*)titleText;

/**
 Helper function to add Left and Right button on keyboard.
 
 @param target Target object for selector.
 @param leftButtonTitle Title for leftBarButtonItem, usually 'Cancel'.
 @param rightButtonTitle Title for rightBarButtonItem, usually 'Done'.
 @param leftButtonAction Left button action name. Usually 'cancelAction:(IQBarButtonItem*)item'.
 @param rightButtonAction Right button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 @param shouldShowPlaceholder A boolean to indicate whether to show textField placeholder on IQToolbar'.
 */
- (void)addLeftRightOnKeyboardWithTarget:(nullable id)target leftButtonTitle:(nullable NSString*)leftButtonTitle rightButtonTitle:(nullable NSString*)rightButtonTitle leftButtonAction:(nullable SEL)leftButtonAction rightButtonAction:(nullable SEL)rightButtonAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder;

///-------------------------
/// @name Previous/Next/Done
///-------------------------

/**
 Helper function to add ArrowNextPrevious and Done button on keyboard.
 
 @param target Target object for selector.
 @param previousAction Previous button action name. Usually 'previousAction:(id)item'.
 @param nextAction Next button action name. Usually 'nextAction:(id)item'.
 @param doneAction Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 */
- (void)addPreviousNextDoneOnKeyboardWithTarget:(nullable id)target previousAction:(nullable SEL)previousAction nextAction:(nullable SEL)nextAction doneAction:(nullable SEL)doneAction;

/**
 Helper function to add ArrowNextPrevious and Done button on keyboard.
 
 @param target Target object for selector.
 @param previousAction Previous button action name. Usually 'previousAction:(id)item'.
 @param nextAction Next button action name. Usually 'nextAction:(id)item'.
 @param doneAction Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 @param titleText text to show as title in IQToolbar'.
 */
- (void)addPreviousNextDoneOnKeyboardWithTarget:(nullable id)target previousAction:(nullable SEL)previousAction nextAction:(nullable SEL)nextAction doneAction:(nullable SEL)doneAction titleText:(nullable NSString*)titleText;

/**
 Helper function to add ArrowNextPrevious and Done button on keyboard.
 
 @param target Target object for selector.
 @param previousAction Previous button action name. Usually 'previousAction:(id)item'.
 @param nextAction Next button action name. Usually 'nextAction:(id)item'.
 @param doneAction Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 @param shouldShowPlaceholder A boolean to indicate whether to show textField placeholder on IQToolbar'.
 */
- (void)addPreviousNextDoneOnKeyboardWithTarget:(nullable id)target previousAction:(nullable SEL)previousAction nextAction:(nullable SEL)nextAction doneAction:(nullable SEL)doneAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder;

///--------------------------
/// @name Previous/Next/Right
///--------------------------

/**
 Helper function to add ArrowNextPrevious and Right button on keyboard.
 
 @param target Target object for selector.
 @param rightButtonTitle Title for rightBarButtonItem, usually 'Done'.
 @param previousAction Previous button action name. Usually 'previousAction:(id)item'.
 @param nextAction Next button action name. Usually 'nextAction:(id)item'.
 @param rightButtonAction RightBarButton action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 */
- (void)addPreviousNextRightOnKeyboardWithTarget:(nullable id)target rightButtonTitle:(nullable NSString*)rightButtonTitle previousAction:(nullable SEL)previousAction nextAction:(nullable SEL)nextAction rightButtonAction:(nullable SEL)rightButtonAction;

/**
 Helper function to add ArrowNextPrevious and Right button on keyboard.
 
 @param target Target object for selector.
 @param rightButtonTitle Title for rightBarButtonItem, usually 'Done'.
 @param previousAction Previous button action name. Usually 'previousAction:(id)item'.
 @param nextAction Next button action name. Usually 'nextAction:(id)item'.
 @param rightButtonAction RightBarButton action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 @param titleText text to show as title in IQToolbar'.
 */
- (void)addPreviousNextRightOnKeyboardWithTarget:(nullable id)target rightButtonTitle:(nullable NSString*)rightButtonTitle previousAction:(nullable SEL)previousAction nextAction:(nullable SEL)nextAction rightButtonAction:(nullable SEL)rightButtonAction titleText:(nullable NSString*)titleText;

/**
 Helper function to add ArrowNextPrevious and Right button on keyboard.
 
 @param target Target object for selector.
 @param rightButtonTitle Title for rightBarButtonItem, usually 'Done'.
 @param previousAction Previous button action name. Usually 'previousAction:(id)item'.
 @param nextAction Next button action name. Usually 'nextAction:(id)item'.
 @param rightButtonAction RightBarButton action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 @param shouldShowPlaceholder A boolean to indicate whether to show textField placeholder on IQToolbar'.
 */
- (void)addPreviousNextRightOnKeyboardWithTarget:(nullable id)target rightButtonTitle:(nullable NSString*)rightButtonTitle previousAction:(nullable SEL)previousAction nextAction:(nullable SEL)nextAction rightButtonAction:(nullable SEL)rightButtonAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder;

/**
 Helper function to add ArrowNextPrevious and Right button on keyboard.
 
 @param target Target object for selector.
 @param rightButtonImage Image icon to use as rightBarButtonItem.
 @param previousAction Previous button action name. Usually 'previousAction:(id)item'.
 @param nextAction Next button action name. Usually 'nextAction:(id)item'.
 @param rightButtonAction RightBarButton action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 @param titleText text to show as title in IQToolbar'.
 */
- (void)addPreviousNextRightOnKeyboardWithTarget:(nullable id)target rightButtonImage:(nullable UIImage*)rightButtonImage previousAction:(nullable SEL)previousAction nextAction:(nullable SEL)nextAction rightButtonAction:(nullable SEL)rightButtonAction titleText:(nullable NSString*)titleText;

/**
 Helper function to add ArrowNextPrevious and Right button on keyboard.
 
 @param target Target object for selector.
 @param rightButtonImage Image icon to use as rightBarButtonItem.
 @param previousAction Previous button action name. Usually 'previousAction:(id)item'.
 @param nextAction Next button action name. Usually 'nextAction:(id)item'.
 @param rightButtonAction RightBarButton action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 @param shouldShowPlaceholder A boolean to indicate whether to show textField placeholder on IQToolbar'.
 */
- (void)addPreviousNextRightOnKeyboardWithTarget:(nullable id)target rightButtonImage:(nullable UIImage*)rightButtonImage previousAction:(nullable SEL)previousAction nextAction:(nullable SEL)nextAction rightButtonAction:(nullable SEL)rightButtonAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder;

@end


