//
//  IQKeyboardManagerConstantsInternal.swift
// https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013-20 Iftekhar Qurashi.
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

import UIKit

#if swift(>=4.2)
internal let UIKeyboardWillShowNotification  = UIResponder.keyboardWillShowNotification
internal let UIKeyboardDidShowNotification   = UIResponder.keyboardDidShowNotification
internal let UIKeyboardWillHideNotification  = UIResponder.keyboardWillHideNotification
internal let UIKeyboardDidHideNotification   = UIResponder.keyboardDidHideNotification

internal let UIKeyboardAnimationCurveUserInfoKey    = UIResponder.keyboardAnimationCurveUserInfoKey
internal let UIKeyboardAnimationDurationUserInfoKey = UIResponder.keyboardAnimationDurationUserInfoKey
internal let UIKeyboardFrameEndUserInfoKey = UIResponder.keyboardFrameEndUserInfoKey

internal let UITextFieldTextDidBeginEditingNotification  = UITextField.textDidBeginEditingNotification
internal let UITextFieldTextDidEndEditingNotification    = UITextField.textDidEndEditingNotification

internal let UITextViewTextDidBeginEditingNotification   = UITextView.textDidBeginEditingNotification
internal let UITextViewTextDidEndEditingNotification     = UITextView.textDidEndEditingNotification

internal let UIApplicationWillChangeStatusBarOrientationNotification = UIApplication.willChangeStatusBarOrientationNotification

internal let UITextViewTextDidChangeNotification = UITextView.textDidChangeNotification

#else
internal let UIKeyboardWillShowNotification  = Notification.Name.UIKeyboardWillShow
internal let UIKeyboardDidShowNotification   = Notification.Name.UIKeyboardDidShow
internal let UIKeyboardWillHideNotification  = Notification.Name.UIKeyboardWillHide
internal let UIKeyboardDidHideNotification   = Notification.Name.UIKeyboardDidHide

internal let UITextFieldTextDidBeginEditingNotification  = Notification.Name.UITextFieldTextDidBeginEditing
internal let UITextFieldTextDidEndEditingNotification    = Notification.Name.UITextFieldTextDidEndEditing

internal let UITextViewTextDidBeginEditingNotification   = Notification.Name.UITextViewTextDidBeginEditing
internal let UITextViewTextDidEndEditingNotification     = Notification.Name.UITextViewTextDidEndEditing

internal let UIApplicationWillChangeStatusBarOrientationNotification = Notification.Name.UIApplicationWillChangeStatusBarOrientation

internal let UITextViewTextDidChangeNotification = Notification.Name.UITextViewTextDidChange
#endif
