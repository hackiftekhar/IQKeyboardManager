//
//  IQUITextFieldView+Additions.swift
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

import Foundation
import UIKit

/**
Uses default keyboard distance for textField.
*/
public let kIQUseDefaultKeyboardDistance = CGFloat.greatestFiniteMagnitude

private var kIQKeyboardDistanceFromTextField = "kIQKeyboardDistanceFromTextField"
//private var kIQKeyboardEnableMode = "kIQKeyboardEnableMode"
private var kIQKeyboardShouldResignOnTouchOutsideMode = "kIQKeyboardShouldResignOnTouchOutsideMode"
private var kIQIgnoreSwitchingByNextPrevious = "kIQIgnoreSwitchingByNextPrevious"

/**
UIView category for managing UITextField/UITextView
*/
@objc public extension UIView {

    /**
     To set customized distance from keyboard for textField/textView. Can't be less than zero
     */
    @objc var keyboardDistanceFromTextField: CGFloat {
        get {
            
            if let aValue = objc_getAssociatedObject(self, &kIQKeyboardDistanceFromTextField) as? CGFloat {
                return aValue
            } else {
                return kIQUseDefaultKeyboardDistance
            }
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kIQKeyboardDistanceFromTextField, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /**
     If shouldIgnoreSwitchingByNextPrevious is true then library will ignore this textField/textView while moving to other textField/textView using keyboard toolbar next previous buttons. Default is false
     */
    @objc var ignoreSwitchingByNextPrevious: Bool {
        get {
            
            if let aValue = objc_getAssociatedObject(self, &kIQIgnoreSwitchingByNextPrevious) as? Bool {
                return aValue
            } else {
                return false
            }
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kIQIgnoreSwitchingByNextPrevious, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
//    /**
//     Override Enable/disable managing distance between keyboard and textField behaviour for this particular textField.
//     */
//    @objc public var enableMode: IQEnableMode {
//        get {
//            
//            if let savedMode = objc_getAssociatedObject(self, &kIQKeyboardEnableMode) as? IQEnableMode {
//                return savedMode
//            } else {
//                return .Default
//            }
//        }
//        set(newValue) {
//            objc_setAssociatedObject(self, &kIQKeyboardEnableMode, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//    }
    
    /**
     Override resigns Keyboard on touching outside of UITextField/View behaviour for this particular textField.
     */
    @objc var shouldResignOnTouchOutsideMode: IQEnableMode {
        get {
            
            if let savedMode = objc_getAssociatedObject(self, &kIQKeyboardShouldResignOnTouchOutsideMode) as? IQEnableMode {
                return savedMode
            } else {
                return .Default
            }
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kIQKeyboardShouldResignOnTouchOutsideMode, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

