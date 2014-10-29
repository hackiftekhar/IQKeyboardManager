//
//  IQKeyboardReturnKeyHandler.h
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

#import <Foundation/NSObject.h>
#import <Foundation/NSObjCRuntime.h>

#import <UIKit/UITextField.h>
#import <UIKit/UITextView.h>

@class UITextField,UIView, UIViewController;

/*!
    @author Iftekhar Qurashi
 
	@related hack.iftekhar@gmail.com
 
    @class IQKeyboardReturnKeyHandler
 
	@abstract Manages the return key to work like next/done in a view hierarchy.
 */
@interface IQKeyboardReturnKeyHandler : NSObject

/*!
    @method initWithViewController
 
    @abstract Add all the textFields available in UIViewController's view.
 */
-(instancetype)initWithViewController:(UIViewController*)controller NS_DESIGNATED_INITIALIZER;

/*!
    @method delegate
 
    @abstract textField's delegates.
 */
@property(nonatomic, weak) id<UITextFieldDelegate,UITextViewDelegate> delegate;

/*!
    @property toolbarManageBehaviour
 
    @abstract It help to choose the lastTextField instance from sibling responderViews. Default is IQAutoToolbarBySubviews.
 */
@property(nonatomic, assign) IQAutoToolbarManageBehaviour toolbarManageBehaviour;

/*!
    @property lastTextFieldReturnKeyType
 
    @abstract Set the last textfield return key type. Default is UIReturnKeyDefault.
 */
@property(nonatomic, assign) UIReturnKeyType lastTextFieldReturnKeyType;

/*!
    @method addTextFieldView
 
    @abstract Should pass UITextField/UITextView intance. Assign textFieldView delegate to self, change it's returnKeyType.
 */
-(void)addTextFieldView:(UIView*)textFieldView;

/*!
    @method removeTextFieldView
 
    @abstract Should pass UITextField/UITextView intance. Restore it's textFieldView delegate and it's returnKeyType.
 */
-(void)removeTextFieldView:(UIView*)textFieldView;

/*!
    @method addResponderFromView
 
    @abstract Add all the UITextField/UITextView responderView's.
 */
-(void)addResponderFromView:(UIView*)view;

/*!
    @method removeResponderFromView
 
    @abstract Remove all the UITextField/UITextView responderView's.
 */
-(void)removeResponderFromView:(UIView*)view;

@end
