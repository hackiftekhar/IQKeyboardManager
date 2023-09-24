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

import UIKit

// MARK: Debugging & Developer options
@available(iOSApplicationExtension, unavailable)
public extension IQKeyboardManager {

    private struct AssociatedKeys {
        static var enableDebugging: Int = 0
    }

    @objc var enableDebugging: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.enableDebugging) as? Bool ?? false
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.enableDebugging, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /**
     @warning Use below methods to completely enable/disable notifications registered by library internally.
     Please keep in mind that library is totally dependent on NSNotification of UITextField, UITextField, Keyboard etc.
     If you do unregisterAllNotifications then library will not work at all. You should only use below methods if you want to completedly disable all library functions.
     You should use below methods at your own risk.
     */
    @objc func registerAllNotifications() {

        //  Registering for orientation changes notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.willChangeStatusBarOrientation(_:)), name: UIApplication.willChangeStatusBarOrientationNotification, object: UIApplication.shared)
    }

    @objc func unregisterAllNotifications() {

        //  Unregistering for orientation changes notification
        NotificationCenter.default.removeObserver(self, name: UIApplication.willChangeStatusBarOrientationNotification, object: UIApplication.shared)
    }

    struct Static {
        static var indentation = 0
    }

    internal func showLog(_ logString: String, indentation: Int = 0) {

        guard enableDebugging else {
            return
        }

        if indentation < 0 {
            Static.indentation = max(0, Static.indentation + indentation)
        }

        var preLog: String = "IQKeyboardManager"
        for _ in 0 ... Static.indentation {
            preLog += "|\t"
        }

        print(preLog + logString)

        if indentation > 0 {
            Static.indentation += indentation
        }
    }
}
