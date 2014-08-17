//
//  IQKeyboardManager.swift
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


import Foundation
import UIKit

enum IQAutoToolbarManageBehaviour
{
    case IQAutoToolbarBySubviews
    case IQAutoToolbarByTag
    
}

class IQKeyboardManager{
    
    var enable = true
    var keyboardDistanceFromTextField = 10
    var enableAutoToolbar = true
    var toolbarManageBehaviour = IQAutoToolbarManageBehaviour.IQAutoToolbarBySubviews
    var shouldToolbarUsesTextFieldTintColor = false
    var shouldShowTextFieldPlaceholder = true
    var placeholderFont = UIFont();
    var canAdjustTextView = false
    var overrideKeyboardAppearance = false
    var keyboardAppearance = UIKeyboardAppearance.Default
    var shouldResignOnTouchOutside = false
    var shouldPlayInputClicks = false
    var shouldAdoptDefaultKeyboardAnimation = true

    init()
    {
    
    }
    
    func IQKeyboardManger()
    {
    
    }
    
    class func sharedManager()
    {
    
    }
    
    func resignFirstResponder()
    {
    
    }
}















