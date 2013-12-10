//
//  KeyBoardManager.h
//	https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013 Iftekhar Qurashi.
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

/*!
    @author Iftekhar Qurashi | https://github.com/hackiftekhar | hack.iftekhar@gmail.com
 
    @see https://github.com/hackiftekhar/IQKeyboardManager
 
    @since iOS (5.0 and later), ARC Required
 
    @class IQKeyBoardManager
 
    @abstract Keyboard TextField/TextView Manager
 */
@interface IQKeyboardManager : NSObject
{
	/*! Boolean to maintain keyboard is showing or it is hide. To solve rootViewController.view.frame calculations. */
    BOOL isKeyboardShowing;
    
	/*! To save rootViewController.view.frame. */
    CGRect topViewBeginRect;
    
	/*! TextField or TextView object. */
    UIView *textFieldView;
    
	/*! To save keyboard animation duration. */
    CGFloat animationDuration;
    
    /*! To save keyboard size */
    CGSize kbSize;
}

/*!
    @method installKeyboardManager
 
    @abstract Call it on your AppDelegate to initialize keyboardManager.
 */
+ (void)installKeyboardManager;

/*!
    @method setTextFieldDistanceFromKeyboard:
 
    @abstract To set keyboard distance from textField. can't be less than zero. Default is 10.0.
 */
+ (void)setTextFieldDistanceFromKeyboard:(CGFloat)distance;

/*!
    @method enableKeyboardManger
 
    @abstract Enable the keyboard manager. Default is enabled.
 */
+ (void)enableKeyboardManger;

/*!
    @method disableKeyboardManager
 
    @abstract Desable the keyboard manager. Default is enabled.
 */
+ (void)disableKeyboardManager;

/*!
    @return Return YES if keyboard manager is enabled, otherwise NO.
 */
+ (BOOL)isEnabled;

/*!
    @method init
 
    @abstract Should create only one instance of class. Should not call init.
 */
- (id)init	__attribute__((unavailable("init is not available in IQKeyboardManager, Use class methods")));

/*!
    @method init
 
    @abstract Should create only one instance of class. Should not call new.
 */
+ (id)new	__attribute__((unavailable("new is not available in IQKeyboardManager, Use class methods")));

@end


/*!
    @category IQKeyboardToolbar
 
    @since iOS (5.0 and later), ARC Required

    @abstract UIView category methods to add UIToolbar on UIKeyboard.
 */
@interface UIView (IQKeyboardToolbar)

/*!
    @method addDoneOnKeyboardWithTarget:action:
 
    @abstract Helper functions to add Done button on keyboard.
 
    @param target: Target object for selector. Usually 'self'.
 
    @param action: Done button action name. Usually 'doneAction:(UIBarButtonItem*)item'.
 */
- (void)addDoneOnKeyboardWithTarget:(id)target action:(SEL)action;


/*!
    @method addCancelDoneOnKeyboardWithTarget:cancelAction:doneAction:
 
    @abstract Helper function to add Cancel and Done button on keyboard.
 
    @param target: Target object for selector. Usually 'self'.
 
    @param cancelAction: Crevious button action name. Usually 'cancelAction:(UIBarButtonItem*)item'.
 
    @param doneAction: Done button action name. Usually 'doneAction:(UIBarButtonItem*)item'.
 */
- (void)addCancelDoneOnKeyboardWithTarget:(id)target cancelAction:(SEL)cancelAction doneAction:(SEL)doneAction;

/*!
    @method addPreviousNextDoneOnKeyboardWithTarget:previousAction:nextAction:doneAction
 
    @abstract Helper function to add SegmentedNextPrevious and Done button on keyboard.
 
    @param target: Target object for selector. Usually 'self'.
 
    @param previousAction: Previous button action name. Usually 'previousAction:(IQSegmentedNextPrevious*)segmentedControl'.
 
    @param nextAction: Next button action name. Usually 'nextAction:(IQSegmentedNextPrevious*)segmentedControl'.
 
    @param doneAction: Done button action name. Usually 'doneAction:(UIBarButtonItem*)item'.
 */
- (void)addPreviousNextDoneOnKeyboardWithTarget:(id)target previousAction:(SEL)previousAction nextAction:(SEL)nextAction doneAction:(SEL)doneAction;

/*!
    @method setEnablePrevious:next:
 
    @abstract Helper function to enable and desable previous next buttons.
 
    @param isPreviousEnabled: BOOL to enable/disable previous button on keyboard.
 
    @param isNextEnabled:  BOOL to enable/disable next button on keyboard..
 */
- (void)setEnablePrevious:(BOOL)isPreviousEnabled next:(BOOL)isNextEnabled;

@end


/*!
    @class IQSegmentedNextPrevious
 
    @since iOS (5.0 and later)
 
    @abstract Custom SegmentedControl for Previous/Next button.
 */
@interface IQSegmentedNextPrevious : UISegmentedControl
{
    id buttonTarget;
    SEL previousSelector;
    SEL nextSelector;
}

/*!
    @method initWithTarget:previousAction:nextAction:
 
    @abstract initialization function for IQSegmentedNextPrevious.
 
    @param target: Target object for selector. Usually 'self'.
 
    @param previousAction: Previous button action name. Usually 'previousAction:(IQSegmentedNextPrevious*)segmentedControl'.
 
    @param nextAction: Next button action name. Usually 'nextAction:(IQSegmentedNextPrevious*)segmentedControl'.
 */
-(id)initWithTarget:(id)target previousAction:(SEL)previousAction nextAction:(SEL)nextAction;

/*!
    @method init
 
    @abstract initWithTarget:previousAction:nextAction should be used.
 */
-(id)init	__attribute__((unavailable("init is not available, should use initWithTarget:previousAction:nextAction instead")));

/*!
    @method init
 
    @abstract initWithTarget:previousAction:nextAction should be used.
 */
+(id)new	__attribute__((unavailable("new is not available, should use initWithTarget:previousAction:nextAction instead")));

@end

