//
//  IQKeyboardManager+Debug.swift
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

import Foundation

private var kIQEnableDebugging      = "kIQEnableDebugging"

// MARK: Debugging & Developer options
public extension IQKeyboardManager {

    @objc var enableDebugging: Bool {
        get {
            return objc_getAssociatedObject(self, &kIQEnableDebugging) as? Bool ?? false
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kIQEnableDebugging, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /**
     @warning Use below methods to completely enable/disable notifications registered by library internally.
     Please keep in mind that library is totally dependent on NSNotification of UITextField, UITextField, Keyboard etc.
     If you do unregisterAllNotifications then library will not work at all. You should only use below methods if you want to completedly disable all library functions.
     You should use below methods at your own risk.
     */
    @objc func registerAllNotifications() {

        #if swift(>=4.2)
        let UIKeyboardWillShow  = UIResponder.keyboardWillShowNotification
        let UIKeyboardDidShow   = UIResponder.keyboardDidShowNotification
        let UIKeyboardWillHide  = UIResponder.keyboardWillHideNotification
        let UIKeyboardDidHide   = UIResponder.keyboardDidHideNotification

        let UITextFieldTextDidBeginEditing  = UITextField.textDidBeginEditingNotification
        let UITextFieldTextDidEndEditing    = UITextField.textDidEndEditingNotification

        let UITextViewTextDidBeginEditing   = UITextView.textDidBeginEditingNotification
        let UITextViewTextDidEndEditing     = UITextView.textDidEndEditingNotification

        let UIApplicationWillChangeStatusBarOrientation = UIApplication.willChangeStatusBarOrientationNotification
        #else
        let UIKeyboardWillShow  = Notification.Name.UIKeyboardWillShow
        let UIKeyboardDidShow   = Notification.Name.UIKeyboardDidShow
        let UIKeyboardWillHide  = Notification.Name.UIKeyboardWillHide
        let UIKeyboardDidHide   = Notification.Name.UIKeyboardDidHide

        let UITextFieldTextDidBeginEditing  = Notification.Name.UITextFieldTextDidBeginEditing
        let UITextFieldTextDidEndEditing    = Notification.Name.UITextFieldTextDidEndEditing

        let UITextViewTextDidBeginEditing   = Notification.Name.UITextViewTextDidBeginEditing
        let UITextViewTextDidEndEditing     = Notification.Name.UITextViewTextDidEndEditing

        let UIApplicationWillChangeStatusBarOrientation = Notification.Name.UIApplicationWillChangeStatusBarOrientation
        #endif

        //  Registering for keyboard notification.
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(_:)), name: UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide(_:)), name: UIKeyboardDidHide, object: nil)

        //  Registering for UITextField notification.
        registerTextFieldViewClass(UITextField.self, didBeginEditingNotificationName: UITextFieldTextDidBeginEditing.rawValue, didEndEditingNotificationName: UITextFieldTextDidEndEditing.rawValue)

        //  Registering for UITextView notification.
        registerTextFieldViewClass(UITextView.self, didBeginEditingNotificationName: UITextViewTextDidBeginEditing.rawValue, didEndEditingNotificationName: UITextViewTextDidEndEditing.rawValue)

        //  Registering for orientation changes notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.willChangeStatusBarOrientation(_:)), name: UIApplicationWillChangeStatusBarOrientation, object: UIApplication.shared)
    }

    @objc func unregisterAllNotifications() {

        #if swift(>=4.2)
        let UIKeyboardWillShow  = UIResponder.keyboardWillShowNotification
        let UIKeyboardDidShow   = UIResponder.keyboardDidShowNotification
        let UIKeyboardWillHide  = UIResponder.keyboardWillHideNotification
        let UIKeyboardDidHide   = UIResponder.keyboardDidHideNotification

        let UITextFieldTextDidBeginEditing  = UITextField.textDidBeginEditingNotification
        let UITextFieldTextDidEndEditing    = UITextField.textDidEndEditingNotification

        let UITextViewTextDidBeginEditing   = UITextView.textDidBeginEditingNotification
        let UITextViewTextDidEndEditing     = UITextView.textDidEndEditingNotification

        let UIApplicationWillChangeStatusBarOrientation = UIApplication.willChangeStatusBarOrientationNotification
        #else
        let UIKeyboardWillShow  = Notification.Name.UIKeyboardWillShow
        let UIKeyboardDidShow   = Notification.Name.UIKeyboardDidShow
        let UIKeyboardWillHide  = Notification.Name.UIKeyboardWillHide
        let UIKeyboardDidHide   = Notification.Name.UIKeyboardDidHide

        let UITextFieldTextDidBeginEditing  = Notification.Name.UITextFieldTextDidBeginEditing
        let UITextFieldTextDidEndEditing    = Notification.Name.UITextFieldTextDidEndEditing

        let UITextViewTextDidBeginEditing   = Notification.Name.UITextViewTextDidBeginEditing
        let UITextViewTextDidEndEditing     = Notification.Name.UITextViewTextDidEndEditing

        let UIApplicationWillChangeStatusBarOrientation = Notification.Name.UIApplicationWillChangeStatusBarOrientation
        #endif

        //  Unregistering for keyboard notification.
        NotificationCenter.default.removeObserver(self, name: UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIKeyboardDidHide, object: nil)

        //  Unregistering for UITextField notification.
        unregisterTextFieldViewClass(UITextField.self, didBeginEditingNotificationName: UITextFieldTextDidBeginEditing.rawValue, didEndEditingNotificationName: UITextFieldTextDidEndEditing.rawValue)

        //  Unregistering for UITextView notification.
        unregisterTextFieldViewClass(UITextView.self, didBeginEditingNotificationName: UITextViewTextDidBeginEditing.rawValue, didEndEditingNotificationName: UITextViewTextDidEndEditing.rawValue)

        //  Unregistering for orientation changes notification
        NotificationCenter.default.removeObserver(self, name: UIApplicationWillChangeStatusBarOrientation, object: UIApplication.shared)
    }

    internal func showLog(_ logString: String, indentation: Int = 0) {

        struct Static {
            static var indentation = 0
        }

        if indentation < 0 {
            Static.indentation = max(0, Static.indentation + indentation)
        }

        if enableDebugging {

            var preLog = "IQKeyboardManager"

            for _ in 0 ... Static.indentation {
                preLog += "|\t"
            }
            print(preLog + logString)
        }

        if indentation > 0 {
            Static.indentation += indentation
        }
    }
}
