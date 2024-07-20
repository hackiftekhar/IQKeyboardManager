//
//  IQKeyboardManager.swift
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

import UIKit
import CoreGraphics
import QuartzCore
import IQKeyboardManagerCore

// swiftlint:disable line_length
// A generic version of KeyboardManagement. (OLD DOCUMENTATION) LINK
// https://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html
// https://developer.apple.com/documentation/uikit/keyboards_and_input/adjusting_your_layout_with_keyboard_layout_guide
// swiftlint:enable line_length

/**
Code-less drop-in universal library allows to prevent issues of keyboard sliding up and cover UITextField/UITextView.
 Neither need to write any code nor any setup required and much more.
*/
@available(iOSApplicationExtension, unavailable)
@MainActor
@objc public final class IQKeyboardManager: NSObject {

    /**
    Returns the default singleton instance.
    */
    @MainActor
    @objc public static let shared: IQKeyboardManager = .init()

    // MARK: UIKeyboard handling

    /**
    Enable/disable managing distance between keyboard and textField.
     Default is YES(Enabled when class loads in `+(void)load` method).
    */
    @objc public var enable: Bool = false {

        didSet {
            guard enable != oldValue else { return }
            // If not enable, enable it.
            if enable {
                // If keyboard is currently showing.
                if activeConfiguration.keyboardInfo.isVisible {
                    adjustPosition()
                } else {
                    restorePosition()
                }
                IQKeyboardManagerDebug.showLog("Enabled")
            } else {   // If not disable, disable it.
                restorePosition()
                IQKeyboardManagerDebug.showLog("Disabled")
            }
        }
    }

    /**
    To set keyboard distance from textField. can't be less than zero. Default is 10.0.
    */
    @objc public var keyboardDistanceFromTextField: CGFloat = 10.0

    internal var activeConfiguration: IQActiveConfiguration = .init()

    /*******************************************/

    /**
    If YES, then calls 'setNeedsLayout' and 'layoutIfNeeded' on any frame update of to viewController's view.
    */
    @objc public var layoutIfNeededOnUpdate: Bool = false

    // MARK: Class Level disabling methods

    /**
     Disable distance handling within the scope of disabled distance handling viewControllers classes.
     Within this scope, 'enabled' property is ignored. Class should be kind of UIViewController.
     */
    @objc public var disabledDistanceHandlingClasses: [UIViewController.Type] = []

    /**
     Enable distance handling within the scope of enabled distance handling viewControllers classes.
     Within this scope, 'enabled' property is ignored. Class should be kind of UIViewController.
     If same Class is added in disabledDistanceHandlingClasses list,
     then enabledDistanceHandlingClasses will be ignored.
     */
    @objc public var enabledDistanceHandlingClasses: [UIViewController.Type] = []

    // MARK: Third Party Library support
    /// Add TextField/TextView Notifications customized Notifications.
    /// For example while using YYTextView https://github.com/ibireme/YYText

   /**************************************************************************************/

    // MARK: Initialization/De-initialization

    /*  Singleton Object Initialization. */
    private override init() {

        super.init()

        self.addActiveConfigurationObserver()

        disabledDistanceHandlingClasses.append(UITableViewController.self)
        disabledDistanceHandlingClasses.append(UIInputViewController.self)
        disabledDistanceHandlingClasses.append(UIAlertController.self)

        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    deinit {
        //  Disable the keyboard manager.
        enable = false
    }

    // MARK: Public Methods

    /*  Refreshes textField/textView position if any external changes is explicitly made by user.   */
    @objc public func reloadLayoutIfNeeded() {

        guard privateIsEnabled(),
              activeConfiguration.keyboardInfo.isVisible,
              activeConfiguration.isReady else {
                return
        }
        adjustPosition()
    }
}
