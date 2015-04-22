//
//  UIView+IQToolbar.h
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


#import <UIKit/UIView.h>

@class UIBarButtonItem;

/**
 UIView category methods to add IQToolbar on UIKeyboard.
 */
@interface UIView (IQToolbarAddition)


///-------------------------
/// @name Title and Distance
///-------------------------

/**
 If shouldHideTitle is YES, then title will not be added to the toolbar. Default to NO.
 */
@property (assign, nonatomic) BOOL shouldHideTitle;


///-----------------------------------------
/// @name Customised Invocation Registration
///-----------------------------------------

/**
 Additional target & action to do get callback action. Note that setting custom `previous` selector doesn't affect native `previous` functionality, this is just used to notifiy user to do additional work according to need.
 
 @param target Target object.
 @param action Target Selector.
 */
-(void)setCustomPreviousTarget:(id)target action:(SEL)action;

/**
 Additional target & action to do get callback action. Note that setting custom `next` selector doesn't affect native `next` functionality, this is just used to notifiy user to do additional work according to need.
 
 @param target Target object.
 @param action Target Selector.
 */
-(void)setCustomNextTarget:(id)target action:(SEL)action;

/**
 Additional target & action to do get callback action. Note that setting custom `done` selector doesn't affect native `done` functionality, this is just used to notifiy user to do additional work according to need.
 
 @param target Target object.
 @param action Target Selector.
 */
-(void)setCustomDoneTarget:(id)target action:(SEL)action;

/**
 Customized Invocation to be called on previous arrow action. previousInvocation is internally created using setCustomPreviousTarget: method.
 */
@property (strong, nonatomic) NSInvocation *previousInvocation;

/**
 Customized Invocation to be called on next arrow action. nextInvocation is internally created using setCustomNextTarget: method.
 */
@property (strong, nonatomic) NSInvocation *nextInvocation;

/**
 Customized Invocation to be called on done action. doneInvocation is internally created using setCustomDoneTarget: method.
 */
@property (strong, nonatomic) NSInvocation *doneInvocation;

///------------
/// @name Done
///------------

/**
 Helper function to add Done button on keyboard.
 
 @param target Target object for selector.
 @param action Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 */
- (void)addDoneOnKeyboardWithTarget:(id)target action:(SEL)action;

/**
 Helper function to add Done button on keyboard.
 
 @param target Target object for selector.
 @param action Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 @param titleText text to show as title in IQToolbar'.
 */
- (void)addDoneOnKeyboardWithTarget:(id)target action:(SEL)action titleText:(NSString*)titleText;

/**
 Helper function to add Done button on keyboard.
 
 @param target Target object for selector.
 @param action Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 @param shouldShowPlaceholder A boolean to indicate whether to show textField placeholder on IQToolbar'.
 */
- (void)addDoneOnKeyboardWithTarget:(id)target action:(SEL)action shouldShowPlaceholder:(BOOL)shouldShowPlaceholder;

///------------
/// @name Right
///------------

/**
 Helper function to add Right button on keyboard.
 
 @param text Title for rightBarButtonItem, usually 'Done'.
 @param target Target object for selector.
 @param action Right button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 */
- (void)addRightButtonOnKeyboardWithText:(NSString*)text target:(id)target action:(SEL)action;

/**
 Helper function to add Right button on keyboard.
 
 @param text Title for rightBarButtonItem, usually 'Done'.
 @param target Target object for selector.
 @param action Right button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 @param titleText text to show as title in IQToolbar'.
 */
- (void)addRightButtonOnKeyboardWithText:(NSString*)text target:(id)target action:(SEL)action titleText:(NSString*)titleText;

/**
 Helper function to add Right button on keyboard.
 
 @param text Title for rightBarButtonItem, usually 'Done'.
 @param target Target object for selector.
 @param action Right button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 @param shouldShowPlaceholder A boolean to indicate whether to show textField placeholder on IQToolbar'.
 */
- (void)addRightButtonOnKeyboardWithText:(NSString*)text target:(id)target action:(SEL)action shouldShowPlaceholder:(BOOL)shouldShowPlaceholder;

///------------------
/// @name Cancel/Done
///------------------

/**
 Helper function to add Cancel and Done button on keyboard.
 
 @param target Target object for selector.
 @param cancelAction Cancel button action name. Usually 'cancelAction:(IQBarButtonItem*)item'.
 @param doneAction Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 */
- (void)addCancelDoneOnKeyboardWithTarget:(id)target cancelAction:(SEL)cancelAction doneAction:(SEL)doneAction;

/**
 Helper function to add Cancel and Done button on keyboard.
 
 @param target Target object for selector.
 @param cancelAction Cancel button action name. Usually 'cancelAction:(IQBarButtonItem*)item'.
 @param doneAction Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 @param titleText text to show as title in IQToolbar'.
 */
- (void)addCancelDoneOnKeyboardWithTarget:(id)target cancelAction:(SEL)cancelAction doneAction:(SEL)doneAction titleText:(NSString*)titleText;

/**
 Helper function to add Cancel and Done button on keyboard.
 
 @param target Target object for selector.
 @param cancelAction Cancel button action name. Usually 'cancelAction:(IQBarButtonItem*)item'.
 @param doneAction Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 @param shouldShowPlaceholder A boolean to indicate whether to show textField placeholder on IQToolbar'.
 */
- (void)addCancelDoneOnKeyboardWithTarget:(id)target cancelAction:(SEL)cancelAction doneAction:(SEL)doneAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder;

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
- (void)addLeftRightOnKeyboardWithTarget:(id)target leftButtonTitle:(NSString*)leftButtonTitle rightButtonTitle:(NSString*)rightButtonTitle leftButtonAction:(SEL)leftButtonAction rightButtonAction:(SEL)rightButtonAction;

/**
 Helper function to add Left and Right button on keyboard.
 
 @param target Target object for selector.
 @param leftButtonTitle Title for leftBarButtonItem, usually 'Cancel'.
 @param rightButtonTitle Title for rightBarButtonItem, usually 'Done'.
 @param leftButtonAction Left button action name. Usually 'cancelAction:(IQBarButtonItem*)item'.
 @param rightButtonAction Right button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 @param titleText text to show as title in IQToolbar'.
 */
- (void)addLeftRightOnKeyboardWithTarget:(id)target leftButtonTitle:(NSString*)leftButtonTitle rightButtonTitle:(NSString*)rightButtonTitle leftButtonAction:(SEL)leftButtonAction rightButtonAction:(SEL)rightButtonAction titleText:(NSString*)titleText;

/**
 Helper function to add Left and Right button on keyboard.
 
 @param target Target object for selector.
 @param leftButtonTitle Title for leftBarButtonItem, usually 'Cancel'.
 @param rightButtonTitle Title for rightBarButtonItem, usually 'Done'.
 @param leftButtonAction Left button action name. Usually 'cancelAction:(IQBarButtonItem*)item'.
 @param rightButtonAction Right button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 @param shouldShowPlaceholder A boolean to indicate whether to show textField placeholder on IQToolbar'.
 */
- (void)addLeftRightOnKeyboardWithTarget:(id)target leftButtonTitle:(NSString*)leftButtonTitle rightButtonTitle:(NSString*)rightButtonTitle leftButtonAction:(SEL)leftButtonAction rightButtonAction:(SEL)rightButtonAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder;

///-------------------------
/// @name Previous/Next/Done
///-------------------------

/**
 Helper function to add SegmentedNextPrevious/ArrowNextPrevious and Done button on keyboard.
 
 @param target Target object for selector.
 @param previousAction Previous button action name. Usually 'previousAction:(id)item'.
 @param nextAction Next button action name. Usually 'nextAction:(id)item'.
 @param doneAction Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 */
- (void)addPreviousNextDoneOnKeyboardWithTarget:(id)target previousAction:(SEL)previousAction nextAction:(SEL)nextAction doneAction:(SEL)doneAction;

/**
 Helper function to add SegmentedNextPrevious/ArrowNextPrevious and Done button on keyboard.
 
 @param target Target object for selector.
 @param previousAction Previous button action name. Usually 'previousAction:(id)item'.
 @param nextAction Next button action name. Usually 'nextAction:(id)item'.
 @param doneAction Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 @param titleText text to show as title in IQToolbar'.
 */
- (void)addPreviousNextDoneOnKeyboardWithTarget:(id)target previousAction:(SEL)previousAction nextAction:(SEL)nextAction doneAction:(SEL)doneAction titleText:(NSString*)titleText;

/**
 Helper function to add SegmentedNextPrevious/ArrowNextPrevious and Done button on keyboard.
 
 @param target Target object for selector.
 @param previousAction Previous button action name. Usually 'previousAction:(id)item'.
 @param nextAction Next button action name. Usually 'nextAction:(id)item'.
 @param doneAction Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 @param shouldShowPlaceholder A boolean to indicate whether to show textField placeholder on IQToolbar'.
 */
- (void)addPreviousNextDoneOnKeyboardWithTarget:(id)target previousAction:(SEL)previousAction nextAction:(SEL)nextAction doneAction:(SEL)doneAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder;

///--------------------------
/// @name Previous/Next/Right
///--------------------------

/**
 Helper function to add SegmentedNextPrevious/ArrowNextPrevious and Right button on keyboard.
 
 @param target Target object for selector.
 @param rightButtonTitle Title for rightBarButtonItem, usually 'Done'.
 @param previousAction Previous button action name. Usually 'previousAction:(id)item'.
 @param nextAction Next button action name. Usually 'nextAction:(id)item'.
 @param rightButtonAction RightBarButton action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 */
- (void)addPreviousNextRightOnKeyboardWithTarget:(id)target rightButtonTitle:(NSString*)rightButtonTitle previousAction:(SEL)previousAction nextAction:(SEL)nextAction rightButtonAction:(SEL)rightButtonAction;

/**
 Helper function to add SegmentedNextPrevious/ArrowNextPrevious and Right button on keyboard.
 
 @param target Target object for selector.
 @param rightButtonTitle Title for rightBarButtonItem, usually 'Done'.
 @param previousAction Previous button action name. Usually 'previousAction:(id)item'.
 @param nextAction Next button action name. Usually 'nextAction:(id)item'.
 @param rightButtonAction RightBarButton action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 @param titleText text to show as title in IQToolbar'.
 */
- (void)addPreviousNextRightOnKeyboardWithTarget:(id)target rightButtonTitle:(NSString*)rightButtonTitle previousAction:(SEL)previousAction nextAction:(SEL)nextAction rightButtonAction:(SEL)rightButtonAction titleText:(NSString*)titleText;

/**
 Helper function to add SegmentedNextPrevious/ArrowNextPrevious and Right button on keyboard.
 
 @param target Target object for selector.
 @param rightButtonTitle Title for rightBarButtonItem, usually 'Done'.
 @param previousAction Previous button action name. Usually 'previousAction:(id)item'.
 @param nextAction Next button action name. Usually 'nextAction:(id)item'.
 @param rightButtonAction RightBarButton action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 @param shouldShowPlaceholder A boolean to indicate whether to show textField placeholder on IQToolbar'.
 */
- (void)addPreviousNextRightOnKeyboardWithTarget:(id)target rightButtonTitle:(NSString*)rightButtonTitle previousAction:(SEL)previousAction nextAction:(SEL)nextAction rightButtonAction:(SEL)rightButtonAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder;

///-----------------------------------
/// @name Enable/Disable Previous/Next
///-----------------------------------

/**
 Helper function to enable and disable previous next buttons.
 
 @param isPreviousEnabled BOOL to enable/disable previous button on keyboard.
 @param isNextEnabled  BOOL to enable/disable next button on keyboard..
 */
- (void)setEnablePrevious:(BOOL)isPreviousEnabled next:(BOOL)isNextEnabled;

@end


