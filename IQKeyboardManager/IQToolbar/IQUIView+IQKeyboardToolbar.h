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
#import <UIKit/UIImage.h>

@interface IQBarButtonItemConfiguration : NSObject

-(instancetype)initWithBarButtonSystemItem:(UIBarButtonSystemItem)barButtonSystemItem action:(nullable SEL)action;
-(instancetype)initWithImage:(nonnull UIImage*)image action:(nullable SEL)action;
-(instancetype)initWithTitle:(nonnull NSString*)title action:(nullable SEL)action;

@property (readonly, nonatomic) UIBarButtonSystemItem barButtonSystemItem; //System Item to be used to instantiate bar button
@property (readonly, nonatomic, nullable) UIImage *image;    //Image to show on bar button item if it's not a system item.
@property (readonly, nonatomic, nullable) NSString *title; //Title to show on bar button item if it's not a system item.
@property (readonly, nonatomic, nullable) SEL action;  //action for bar button item. Usually 'doneAction:(IQBarButtonItem*)item'.

@end

@interface UIImage (IQKeyboardToolbarNextPreviousImage)

+(UIImage*)iq_keyboardPreviousiOS9Image;
+(UIImage*)iq_keyboardNextiOS9Image;
+(UIImage*)iq_keyboardPreviousiOS10Image;
+(UIImage*)iq_keyboardNextiOS10Image;

+(UIImage*)iq_keyboardPreviousImage;
+(UIImage*)iq_keyboardNextImage;

@end

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
@property (readonly, nonatomic, nonnull) IQToolbar *iq_keyboardToolbar;

/**
 If `shouldHideToolbarPlaceholder` is YES, then title will not be added to the toolbar. Default to NO.
 */
@property (assign, nonatomic) BOOL iq_shouldHideToolbarPlaceholder;

/**
 `toolbarPlaceholder` to override default `placeholder` text when drawing text on toolbar.
 */
@property (nullable, strong, nonatomic) NSString* iq_toolbarPlaceholder;

/**
 `drawingToolbarPlaceholder` will be actual text used to draw on toolbar.
 */
@property (nullable, strong, nonatomic, readonly) NSString* iq_drawingToolbarPlaceholder;

///-------------
/// MARK: Common
///-------------

- (void)iq_addKeyboardToolbarWithTarget:(nullable id)target titleText:(nullable NSString*)titleText rightBarButtonConfiguration:(nullable IQBarButtonItemConfiguration*)rightBarButtonConfiguration previousBarButtonConfiguration:(nullable IQBarButtonItemConfiguration*)previousBarButtonConfiguration nextBarButtonConfiguration:(nullable IQBarButtonItemConfiguration*)nextBarButtonConfiguration;

///------------
/// @name Done
///------------

- (void)iq_addDoneOnKeyboardWithTarget:(nullable id)target action:(nullable SEL)action;
- (void)iq_addDoneOnKeyboardWithTarget:(nullable id)target action:(nullable SEL)action shouldShowPlaceholder:(BOOL)shouldShowPlaceholder;
- (void)iq_addDoneOnKeyboardWithTarget:(nullable id)target action:(nullable SEL)action titleText:(nullable NSString*)titleText;

///------------
/// @name Right
///------------

- (void)iq_addRightButtonOnKeyboardWithText:(nullable NSString*)text target:(nullable id)target action:(nullable SEL)action;
- (void)iq_addRightButtonOnKeyboardWithText:(nullable NSString*)text target:(nullable id)target action:(nullable SEL)action shouldShowPlaceholder:(BOOL)shouldShowPlaceholder;
- (void)iq_addRightButtonOnKeyboardWithText:(nullable NSString*)text target:(nullable id)target action:(nullable SEL)action titleText:(nullable NSString*)titleText;

- (void)iq_addRightButtonOnKeyboardWithImage:(nullable UIImage*)image target:(nullable id)target action:(nullable SEL)action;
- (void)iq_addRightButtonOnKeyboardWithImage:(nullable UIImage*)image target:(nullable id)target action:(nullable SEL)action shouldShowPlaceholder:(BOOL)shouldShowPlaceholder;
- (void)iq_addRightButtonOnKeyboardWithImage:(nullable UIImage*)image target:(nullable id)target action:(nullable SEL)action titleText:(nullable NSString*)titleText;

///------------------
/// @name Cancel/Done
///------------------

- (void)iq_addCancelDoneOnKeyboardWithTarget:(nullable id)target cancelAction:(nullable SEL)cancelAction doneAction:(nullable SEL)doneAction;
- (void)iq_addCancelDoneOnKeyboardWithTarget:(nullable id)target cancelAction:(nullable SEL)cancelAction doneAction:(nullable SEL)doneAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder;
- (void)iq_addCancelDoneOnKeyboardWithTarget:(nullable id)target cancelAction:(nullable SEL)cancelAction doneAction:(nullable SEL)doneAction titleText:(nullable NSString*)titleText;

///-----------------
/// @name Right/Left
///-----------------

- (void)iq_addLeftRightOnKeyboardWithTarget:(nullable id)target leftButtonTitle:(nullable NSString*)leftButtonTitle rightButtonTitle:(nullable NSString*)rightButtonTitle leftButtonAction:(nullable SEL)leftButtonAction rightButtonAction:(nullable SEL)rightButtonAction;
- (void)iq_addLeftRightOnKeyboardWithTarget:(nullable id)target leftButtonTitle:(nullable NSString*)leftButtonTitle rightButtonTitle:(nullable NSString*)rightButtonTitle leftButtonAction:(nullable SEL)leftButtonAction rightButtonAction:(nullable SEL)rightButtonAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder;
- (void)iq_addLeftRightOnKeyboardWithTarget:(nullable id)target leftButtonTitle:(nullable NSString*)leftButtonTitle rightButtonTitle:(nullable NSString*)rightButtonTitle leftButtonAction:(nullable SEL)leftButtonAction rightButtonAction:(nullable SEL)rightButtonAction titleText:(nullable NSString*)titleText;

///-------------------------
/// @name Previous/Next/Done
///-------------------------

- (void)iq_addPreviousNextDoneOnKeyboardWithTarget:(nullable id)target previousAction:(nullable SEL)previousAction nextAction:(nullable SEL)nextAction doneAction:(nullable SEL)doneAction;
- (void)iq_addPreviousNextDoneOnKeyboardWithTarget:(nullable id)target previousAction:(nullable SEL)previousAction nextAction:(nullable SEL)nextAction doneAction:(nullable SEL)doneAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder;
- (void)iq_addPreviousNextDoneOnKeyboardWithTarget:(nullable id)target previousAction:(nullable SEL)previousAction nextAction:(nullable SEL)nextAction doneAction:(nullable SEL)doneAction titleText:(nullable NSString*)titleText;

///--------------------------
/// @name Previous/Next/Right
///--------------------------

- (void)iq_addPreviousNextRightOnKeyboardWithTarget:(nullable id)target rightButtonTitle:(nullable NSString*)rightButtonTitle previousAction:(nullable SEL)previousAction nextAction:(nullable SEL)nextAction rightButtonAction:(nullable SEL)rightButtonAction;
- (void)iq_addPreviousNextRightOnKeyboardWithTarget:(nullable id)target rightButtonTitle:(nullable NSString*)rightButtonTitle previousAction:(nullable SEL)previousAction nextAction:(nullable SEL)nextAction rightButtonAction:(nullable SEL)rightButtonAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder;
- (void)iq_addPreviousNextRightOnKeyboardWithTarget:(nullable id)target rightButtonTitle:(nullable NSString*)rightButtonTitle previousAction:(nullable SEL)previousAction nextAction:(nullable SEL)nextAction rightButtonAction:(nullable SEL)rightButtonAction titleText:(nullable NSString*)titleText;

- (void)iq_addPreviousNextRightOnKeyboardWithTarget:(nullable id)target rightButtonImage:(nullable UIImage*)rightButtonImage previousAction:(nullable SEL)previousAction nextAction:(nullable SEL)nextAction rightButtonAction:(nullable SEL)rightButtonAction;
- (void)iq_addPreviousNextRightOnKeyboardWithTarget:(nullable id)target rightButtonImage:(nullable UIImage*)rightButtonImage previousAction:(nullable SEL)previousAction nextAction:(nullable SEL)nextAction rightButtonAction:(nullable SEL)rightButtonAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder;
- (void)iq_addPreviousNextRightOnKeyboardWithTarget:(nullable id)target rightButtonImage:(nullable UIImage*)rightButtonImage previousAction:(nullable SEL)previousAction nextAction:(nullable SEL)nextAction rightButtonAction:(nullable SEL)rightButtonAction titleText:(nullable NSString*)titleText;

@end


