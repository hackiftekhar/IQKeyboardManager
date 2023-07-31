//
// IQKeyboardReturnKeyHandler.h
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
#import <UIKit/UIKit.h>

#import "IQKeyboardManagerConstants.h"

@class UITextField, UIView, UIViewController;
@protocol UITextFieldDelegate, UITextViewDelegate;

/**
 Manages the return key to work like next/done in a view hierarchy.
 */
@interface IQKeyboardReturnKeyHandler : NSObject

///----------------------
/// @name Initializations
///----------------------

/**
 Add all the textFields available in UIViewController's view.
 */
-(nonnull instancetype)initWithViewController:(nullable UIViewController*)controller NS_DESIGNATED_INITIALIZER;

/**
 Unavailable. Please use initWithViewController: or init method
 */
-(nonnull instancetype)initWithCoder:(nullable NSCoder *)aDecoder NS_UNAVAILABLE;

///---------------
/// @name Settings
///---------------

/**
 Delegate of textField/textView.
 */
@property(nullable, nonatomic, weak) id<UITextFieldDelegate,UITextViewDelegate> delegate;

/**
 Set the last textfield return key type. Default is UIReturnKeyDefault.
 */
@property(nonatomic, assign) UIReturnKeyType lastTextFieldReturnKeyType;

///----------------------------------------------
/// @name Registering/Unregistering textFieldView
///----------------------------------------------

/**
 Should pass UITextField/UITextView instance. Assign textFieldView delegate to self, change it's returnKeyType.
 
 @param textFieldView UITextField/UITextView object to register.
 */
-(void)addTextFieldView:(nonnull UIView*)textFieldView;

/**
 Should pass UITextField/UITextView instance. Restore it's textFieldView delegate and it's returnKeyType.

 @param textFieldView UITextField/UITextView object to unregister.
 */
-(void)removeTextFieldView:(nonnull UIView*)textFieldView;

/**
 Add all the UITextField/UITextView responderView's.
 
 @param view object to register all it's responder subviews.
 */
-(void)addResponderFromView:(nonnull UIView*)view;

/**
 Remove all the UITextField/UITextView responderView's.
 
 @param view object to unregister all it's responder subviews.
 */
-(void)removeResponderFromView:(nonnull UIView*)view;

@end
