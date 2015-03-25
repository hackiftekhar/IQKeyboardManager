//
//  UIView+IQToolbar.h
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


#import <UIKit/UIView.h>

@class UIBarButtonItem;

/**
    @category UIView (IQToolbarAddition)
 
    @abstract UIView category methods to add IQToolbar on UIKeyboard.
 */
@interface UIView (IQToolbarAddition)

/**
    @property shouldHideTitle
 
    @abstract if shouldHideTitle is YES, then title will not be added to the toolbar. Default to NO.
 */
@property (assign, nonatomic) BOOL shouldHideTitle;

/**
    @method setCustomPreviousTarget:action:
    @method setCustomNextTarget:action:
    @method setCustomDoneTarget:action:
 
    @abstract Invoke action on target when the toolbar is created using IQKeyboardManager, you may add additional target & action to do get callback action. Note that setting custom previous/next/done selector doesn't affect native next/previous/done functionality, this is just used to notifiy user to do additional work according to your need.
 */
-(void)setCustomPreviousTarget:(id)target action:(SEL)action;
-(void)setCustomNextTarget:(id)target action:(SEL)action;
-(void)setCustomDoneTarget:(id)target action:(SEL)action;

/**
    @property previousInvocation
 
    @abstract customized Invocation to be called on previous arrow action. previousInvocation is internally created using setCustomPreviousTarget: method.
 */
@property (strong, nonatomic) NSInvocation *previousInvocation;

/**
    @property nextInvocation
 
    @abstract customized Invocation to be called on next arrow action. nextInvocation is internally created using setCustomNextTarget: method.
 */
@property (strong, nonatomic) NSInvocation *nextInvocation;

/**
    @property nextInvocation
 
    @abstract customized Invocation to be called on done action. doneInvocation is internally created using setCustomDoneTarget: method.
 */
@property (strong, nonatomic) NSInvocation *doneInvocation;

/**
    @method addDoneOnKeyboardWithTarget:action:
    @method addDoneOnKeyboardWithTarget:action:titleText:
    @method addDoneOnKeyboardWithTarget:action:shouldShowPlaceholder:
    @method addRightButtonOnKeyboardWithText:target:action:
    @method addRightButtonOnKeyboardWithText:target:action:titleText:
    @method addRightButtonOnKeyboardWithText:target:action:shouldShowPlaceholder:
 
    @abstract Helper functions to add Done button on keyboard.
 
    @param target: Target object for selector. Usually 'self'.
 
    @param action: Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 
    @param shouldShowPlaceholder: A boolean to indicate whether to show textField placeholder on IQToolbar'.
 
    @param titleText: text to show as title in IQToolbar'.
 */
- (void)addDoneOnKeyboardWithTarget:(id)target action:(SEL)action;
- (void)addDoneOnKeyboardWithTarget:(id)target action:(SEL)action titleText:(NSString*)titleText;
- (void)addDoneOnKeyboardWithTarget:(id)target action:(SEL)action shouldShowPlaceholder:(BOOL)showPlaceholder;
- (void)addRightButtonOnKeyboardWithText:(NSString*)text target:(id)target action:(SEL)action;
- (void)addRightButtonOnKeyboardWithText:(NSString*)text target:(id)target action:(SEL)action titleText:(NSString*)titleText;
- (void)addRightButtonOnKeyboardWithText:(NSString*)text target:(id)target action:(SEL)action shouldShowPlaceholder:(BOOL)showPlaceholder;

/**
    @method addCancelDoneOnKeyboardWithTarget:cancelAction:doneAction:
    @method addCancelDoneOnKeyboardWithTarget:cancelAction:doneAction:titleText:
    @method addCancelDoneOnKeyboardWithTarget:cancelAction:doneAction:shouldShowPlaceholder:
    @method addLeftRightOnKeyboardWithTarget:leftButtonTitle:rightButtonTitle:leftButtonAction:rightButtonAction
    @method addLeftRightOnKeyboardWithTarget:leftButtonTitle:rightButtonTitle:leftButtonAction:rightButtonAction:titleText:
    @method addLeftRightOnKeyboardWithTarget:leftButtonTitle:rightButtonTitle:leftButtonAction:rightButtonAction:shouldShowPlaceholder:
 
    @abstract Helper function to add Cancel and Done button on keyboard.
 
    @param target: Target object for selector. Usually 'self'.
 
    @param cancelAction: Crevious button action name. Usually 'cancelAction:(IQBarButtonItem*)item'.
 
    @param doneAction: Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 
    @param shouldShowPlaceholder: A boolean to indicate whether to show textField placeholder on IQToolbar'.
 
    @param titleText: text to show as title in IQToolbar'.
 */
- (void)addCancelDoneOnKeyboardWithTarget:(id)target cancelAction:(SEL)cancelAction doneAction:(SEL)doneAction;
- (void)addCancelDoneOnKeyboardWithTarget:(id)target cancelAction:(SEL)cancelAction doneAction:(SEL)doneAction titleText:(NSString*)titleText;
- (void)addCancelDoneOnKeyboardWithTarget:(id)target cancelAction:(SEL)cancelAction doneAction:(SEL)doneAction shouldShowPlaceholder:(BOOL)showPlaceholder;
- (void)addLeftRightOnKeyboardWithTarget:(id)target leftButtonTitle:(NSString*)leftTitle rightButtonTitle:(NSString*)rightTitle leftButtonAction:(SEL)leftAction rightButtonAction:(SEL)rightAction;
- (void)addLeftRightOnKeyboardWithTarget:(id)target leftButtonTitle:(NSString*)leftTitle rightButtonTitle:(NSString*)rightTitle leftButtonAction:(SEL)leftAction rightButtonAction:(SEL)rightAction titleText:(NSString*)titleText;
- (void)addLeftRightOnKeyboardWithTarget:(id)target leftButtonTitle:(NSString*)leftTitle rightButtonTitle:(NSString*)rightTitle leftButtonAction:(SEL)leftAction rightButtonAction:(SEL)rightAction shouldShowPlaceholder:(BOOL)showPlaceholder;

/**
    @method addPreviousNextDoneOnKeyboardWithTarget:previousAction:nextAction:doneAction
    @method addPreviousNextDoneOnKeyboardWithTarget:previousAction:nextAction:doneAction:titleText:
    @method addPreviousNextDoneOnKeyboardWithTarget:previousAction:nextAction:doneAction:shouldShowPlaceholder:
    @method addPreviousNextRightOnKeyboardWithTarget:rightButtonTitle:previousAction:nextAction:rightButtonAction
    @method addPreviousNextRightOnKeyboardWithTarget:rightButtonTitle:previousAction:nextAction:rightButtonAction:titleText:
    @method addPreviousNextRightOnKeyboardWithTarget:rightButtonTitle:previousAction:nextAction:rightButtonAction:shouldShowPlaceholder:
 
    @abstract Helper function to add SegmentedNextPrevious and Done button on keyboard.
 
    @param target: Target object for selector. Usually 'self'.
 
    @param previousAction: Previous button action name. Usually 'previousAction:(IQSegmentedNextPrevious*)segmentedControl'.
 
    @param nextAction: Next button action name. Usually 'nextAction:(IQSegmentedNextPrevious*)segmentedControl'.
 
    @param doneAction: Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
 
    @param shouldShowPlaceholder: A boolean to indicate whether to show textField placeholder on IQToolbar'.
 
    @param titleText: text to show as title in IQToolbar'.
 */
- (void)addPreviousNextDoneOnKeyboardWithTarget:(id)target previousAction:(SEL)previousAction nextAction:(SEL)nextAction doneAction:(SEL)doneAction;
- (void)addPreviousNextDoneOnKeyboardWithTarget:(id)target previousAction:(SEL)previousAction nextAction:(SEL)nextAction doneAction:(SEL)doneAction titleText:(NSString*)titleText;
- (void)addPreviousNextDoneOnKeyboardWithTarget:(id)target previousAction:(SEL)previousAction nextAction:(SEL)nextAction doneAction:(SEL)doneAction shouldShowPlaceholder:(BOOL)showPlaceholder;
- (void)addPreviousNextRightOnKeyboardWithTarget:(id)target rightButtonTitle:(NSString*)rightButtonTitle previousAction:(SEL)previousAction nextAction:(SEL)nextAction rightButtonAction:(SEL)rightButtonAction;
- (void)addPreviousNextRightOnKeyboardWithTarget:(id)target rightButtonTitle:(NSString*)rightButtonTitle previousAction:(SEL)previousAction nextAction:(SEL)nextAction rightButtonAction:(SEL)rightButtonAction titleText:(NSString*)titleText;
- (void)addPreviousNextRightOnKeyboardWithTarget:(id)target rightButtonTitle:(NSString*)rightButtonTitle previousAction:(SEL)previousAction nextAction:(SEL)nextAction rightButtonAction:(SEL)rightButtonAction shouldShowPlaceholder:(BOOL)showPlaceholder;

/**
    @method setEnablePrevious:next:
 
    @abstract Helper function to enable and disable previous next buttons.
 
    @param isPreviousEnabled: BOOL to enable/disable previous button on keyboard.
 
    @param isNextEnabled:  BOOL to enable/disable next button on keyboard..
 */
- (void)setEnablePrevious:(BOOL)isPreviousEnabled next:(BOOL)isNextEnabled;

@end


