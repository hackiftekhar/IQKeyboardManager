//
//  IQKeyboardManager.swift
//  https://github.com/hackiftekhar/IQKeyboardManager
//  Copyright (c) 2013-24 Iftekhar Qurashi.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

/**
Code-less drop-in universal library allows to prevent issues of keyboard sliding up and cover TextInputView.
 Neither need to write any code nor any setup required and much more.
*/
@available(iOSApplicationExtension, unavailable)
@MainActor
@objcMembers public final class IQKeyboardManager: NSObject {

    /**
    Returns the default singleton instance.
    */
    @MainActor
    public static let shared: IQKeyboardManager = .init()

    internal var activeConfiguration: IQActiveConfiguration = .init()

    // MARK: UIKeyboard handling

    /**
    Enable/disable managing distance between keyboard and textInputView.
     Default is YES(Enabled when class loads in `+(void)load` method).
    */
    public var isEnabled: Bool = false {
        didSet {
            guard isEnabled != oldValue else { return }
            // If not enable, enable it.
            if isEnabled {
                // If keyboard is currently showing.
                if activeConfiguration.keyboardInfo.isVisible {
                    adjustPosition()
                } else {
                    restorePosition()
                }
                showLog("Enabled")
            } else {   // If not disable, disable it.
                restorePosition()
                showLog("Disabled")
            }
        }
    }

    /**
    To set keyboard distance from textInputView. can't be less than zero. Default is 10.0.
    */
    public var keyboardDistance: CGFloat = 10.0

    /*******************************************/

    // MARK: UIAnimation handling

    /**
    If YES, then calls 'setNeedsLayout' and 'layoutIfNeeded' on any frame update of to viewController's view.
    */
    public var layoutIfNeededOnUpdate: Bool = false

    // MARK: Class Level disabling methods

    /**
     Disable distance handling within the scope of disabled distance handling viewControllers classes.
     Within this scope, 'enabled' property is ignored. Class should be kind of UIViewController.
     */
    public var disabledDistanceHandlingClasses: [UIViewController.Type] = [
        UITableViewController.self,
        UIInputViewController.self,
        UIAlertController.self
    ]

    /**
     Enable distance handling within the scope of enabled distance handling viewControllers classes.
     Within this scope, 'enabled' property is ignored. Class should be kind of UIViewController.
     If same Class is added in disabledDistanceHandlingClasses list,
     then enabledDistanceHandlingClasses will be ignored.
     */
    public var enabledDistanceHandlingClasses: [UIViewController.Type] = []

    /**************************************************************************************/

    // MARK: Initialization/De-initialization

    /*  Singleton Object Initialization. */
    private override init() {

        super.init()

        self.addActiveConfigurationObserver()

        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    deinit {
        //  Disable the keyboard manager.
        isEnabled = false
    }

    // MARK: Public Methods

    /*  Refreshes textInputView position if any external changes is explicitly made by user.   */
    public func reloadLayoutIfNeeded() {

        guard privateIsEnabled(),
              activeConfiguration.keyboardInfo.isVisible,
              activeConfiguration.isReady else {
                return
        }
        adjustPosition()
    }
}
