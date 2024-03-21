//
//  IQUITextFieldView+Additions.h
//  https://github.com/hackiftekhar/IQKeyboardManager
//  Copyright (c) 2013-24 Iftekhar Qurashi.
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

#import <UIKit/UIKit.h>

#import <IQKeyboardManager/IQKeyboardManagerConstants.h>
/**
 UIView category for managing UITextField/UITextView
 */

NS_EXTENSION_UNAVAILABLE_IOS("Unavailable in extension")
@interface UIView (Additions)

/**
 To set customized distance from keyboard for textField/textView. Can't be less than zero
 */
@property(nonatomic, assign) CGFloat keyboardDistanceFromTextField;

/**
 If shouldIgnoreSwitchingByNextPrevious is YES then library will ignore this textField/textView while moving to other textField/textView using keyboard toolbar next previous buttons. Default is NO
 */
@property(nonatomic, assign) BOOL ignoreSwitchingByNextPrevious;

///**
// Override Enable/disable managing distance between keyboard and textField behavior for this particular textField.
// */
@property(nonatomic, assign) IQEnableMode enableMode;

/**
 Override resigns Keyboard on touching outside of UITextField/View behavior for this particular textField.
 */
@property(nonatomic, assign) IQEnableMode shouldResignOnTouchOutsideMode;

@end

///-------------------------------------------
/// @name Custom KeyboardDistanceFromTextField
///-------------------------------------------

/**
 Uses default keyboard distance for textField.
 */
extern CGFloat const kIQUseDefaultKeyboardDistance;
