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
 IQKeyboardManager is a code-less drop-in universal library that automatically prevents issues
 of the keyboard sliding up and covering UITextField/UITextView.
 
 ## Usage
 Simply enable the manager in your AppDelegate:
 ```swift
 IQKeyboardManager.shared.isEnabled = true
 ```
 
 ## Thread Safety
 All public APIs must be called from the main thread. The class is marked with @MainActor
 to enforce this at compile time.
 
 ## Example
 ```swift
 import IQKeyboardManagerSwift
 
 @main
 class AppDelegate: UIResponder, UIApplicationDelegate {
     func application(_ application: UIApplication,
                      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
         IQKeyboardManager.shared.isEnabled = true
         return true
     }
 }
 ```
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
     Sets the default distance between the keyboard and the active text input view.

     This distance is applied to all text inputs unless overridden by setting
     `view.iq.distanceFromKeyboard` for specific views.

     - Precondition: Value must be non-negative. Negative values will be logged as warnings.
     - Default: `10.0` points
     - Note: This is a global setting. Use `view.iq.distanceFromKeyboard` for per-view customization.

     ## Example
     ```swift
     // Set global distance
     IQKeyboardManager.shared.keyboardDistance = 20.0

     // Override for specific text field
     myTextField.iq.distanceFromKeyboard = 30.0
     ```

     - SeeAlso: `UIView.iq.distanceFromKeyboard` for per-view customization
     */
    public var keyboardDistance: CGFloat = 10.0 {
        didSet {
            if keyboardDistance < 0 {
                showLog("⚠️ keyboardDistance shouldn't be negative.")
            }
        }
    }

    /*******************************************/

    // MARK: UIAnimation handling

    /**
    If YES, then calls 'setNeedsLayout' and 'layoutIfNeeded' on any frame update of to viewController's view.
    */
    public var layoutIfNeededOnUpdate: Bool = false

    // MARK: Class Level disabling methods

    /**
     Classes that should have keyboard distance handling disabled.

     When a view controller is of one of these types, keyboard distance handling
     is disabled regardless of the `isEnabled` property.

     - Precondition: All classes must be subclasses of `UIViewController`
     - Default: `[UITableViewController.self, UIInputViewController.self, UIAlertController.self]`
     - Note: This takes precedence over `enabledDistanceHandlingClasses`. If a class appears
       in both arrays, it will be disabled.

     ## Example
     ```swift
     // Disable for custom view controller
     IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(MyCustomViewController.self)

     // Disable for multiple controllers
     IQKeyboardManager.shared.disabledDistanceHandlingClasses += [
         LoginViewController.self,
         SignupViewController.self
     ]
     ```

     - SeeAlso: `enabledDistanceHandlingClasses` for force-enabling specific classes
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
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Public Methods

    /**
     Manually triggers a position adjustment for the active text input view.

     Call this method when you've made external changes to the view hierarchy that
     might affect keyboard positioning (e.g., programmatically changing view frames,
     adding/removing views, changing constraints).

     This method is safe to call even when no text input is active or the keyboard
     is hidden - it will simply return early.

     ## When to Call
     - After programmatically modifying view frames
     - After adding or removing views from the hierarchy
     - After changing Auto Layout constraints that affect the active text field's position
     - When orientation changes occur outside the normal notification flow

     ## Example
     ```swift
     // After programmatic layout changes
     myView.frame = newFrame
     IQKeyboardManager.shared.reloadLayoutIfNeeded()

     // After constraint updates
     NSLayoutConstraint.activate(newConstraints)
     view.layoutIfNeeded()
     IQKeyboardManager.shared.reloadLayoutIfNeeded()
     ```

     - Note: This method only has an effect when:
       - `isEnabled` is `true`
       - A text input view is currently active
       - The keyboard is visible
       - The root configuration is ready
     - SeeAlso: `isEnabled` for enabling/disabling the manager
     */
   public func reloadLayoutIfNeeded() {

        guard privateIsEnabled(),
              activeConfiguration.keyboardInfo.isVisible,
              activeConfiguration.isReady else {
                return
        }
        adjustPosition()
    }
}
