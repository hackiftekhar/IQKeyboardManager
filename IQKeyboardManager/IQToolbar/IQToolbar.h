//
// IQToolbar.h
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

#import <UIKit/UIToolbar.h>

/**
 IQToolbar for IQKeyboardManager.
 */
@interface IQToolbar : UIToolbar <UIInputViewAudioFeedback>

/**
 Title font for toolbar.
 */
@property(nullable, nonatomic, strong) UIFont *titleFont;

/**
 Toolbar done title
 */
@property(nullable, nonatomic, strong) NSString *doneTitle;

/**
 Toolbar done image
 */
@property(nullable, nonatomic, strong) UIImage *doneImage;

/**
 Toolbar title
 */
@property(nullable, nonatomic, strong) NSString *title;

/**
 Optional target & action to behave toolbar title button as clickable button
 
 @param target Target object.
 @param action Target Selector.
 */
-(void)setTitleTarget:(nullable id)target action:(nullable SEL)action;

/**
 Customized Invocation to be called on title button action. titleInvocation is internally created using setTitleTarget:action: method.
 */
@property (nullable, strong, nonatomic) NSInvocation *titleInvocation;

@end

