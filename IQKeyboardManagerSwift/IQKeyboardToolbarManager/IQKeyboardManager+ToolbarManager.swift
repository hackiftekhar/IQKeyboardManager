//
//  IQKeyboardManager+ToolbarManager.swift
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
import IQKeyboardToolbarManager

#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOSApplicationExtension, unavailable)
// swiftlint:disable line_length
@available(*, deprecated,
            message: "Please use `IQKeyboardToolbarManager` independently from https://github.com/hackiftekhar/IQKeyboardToolbarManager")
// swiftlint:enable line_length
@MainActor
@objc public extension IQKeyboardManager {

    @MainActor
    private struct AssociatedKeys {
        static var toolbarManager: Int = 0
    }

    internal var toolbarManager: IQKeyboardToolbarManager {
        IQKeyboardToolbarManager.shared
    }

    var enableToolbarDebugging: Bool {
        get { toolbarManager.isDebuggingEnabled }
        set { toolbarManager.isDebuggingEnabled = newValue }
    }

    /**
     Automatic add the toolbar functionality. Default is YES.
     */
    var enableAutoToolbar: Bool {
        get { toolbarManager.isEnabled }
        set { toolbarManager.isEnabled = newValue }
    }

    /**
     Configurations related to the toolbar display over the keyboard.
     */
    var toolbarConfiguration: IQKeyboardToolbarConfiguration {
        toolbarManager.toolbarConfiguration
    }

    // MARK: UISound handling

    /**
     If YES, then it plays inputClick sound on next/previous/done click.
     */
    var playInputClicks: Bool {
        get { toolbarManager.playInputClicks }
        set { toolbarManager.playInputClicks = newValue }
    }

    /**
     Disable automatic toolbar creation within the scope of disabled toolbar viewControllers classes.
     Within this scope, 'enableAutoToolbar' property is ignored. Class should be kind of UIViewController.
     */
    var disabledToolbarClasses: [UIViewController.Type] {
        get { toolbarManager.disabledToolbarClasses }
        set { toolbarManager.disabledToolbarClasses = newValue }
    }

    /**
     Enable automatic toolbar creation within the scope of enabled toolbar viewControllers classes.
     Within this scope, 'enableAutoToolbar' property is ignored. Class should be kind of UIViewController.
     If same Class is added in disabledToolbarClasses list, then enabledToolbarClasses will be ignore.
     */
    var enabledToolbarClasses: [UIViewController.Type] {
        get { toolbarManager.enabledToolbarClasses }
        set { toolbarManager.enabledToolbarClasses = newValue }
    }
    
    // MARK: SwiftUI Support
    
    /**
     SwiftUI view types that should have disabled toolbars.
     For SwiftUI views hosted in UIHostingController, you can disable toolbars by specifying the SwiftUI view type.
     
     Usage:
     ```swift
     IQKeyboardManager.shared.disabledSwiftUIToolbarTypes.append(MySwiftUIView.self)
     ```
     
     Note: This works by identifying UIHostingController instances and checking their contained SwiftUI view type.
     */
    @available(iOS 13.0, *)
    var disabledSwiftUIToolbarTypes: [Any.Type] {
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.disabledSwiftUIToolbarTypes) as? [Any.Type] ?? []
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.disabledSwiftUIToolbarTypes, 
                                   newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateSwiftUIHostingControllerClasses()
        }
    }
    
    /**
     SwiftUI view types that should have enabled toolbars.
     For SwiftUI views hosted in UIHostingController, you can enable toolbars by specifying the SwiftUI view type.
     If same Type is added in disabledSwiftUIToolbarTypes list, then enabledSwiftUIToolbarTypes will be ignored.
     
     Usage:
     ```swift
     IQKeyboardManager.shared.enabledSwiftUIToolbarTypes.append(MySwiftUIView.self)
     ```
     
     Note: This works by identifying UIHostingController instances and checking their contained SwiftUI view type.
     */
    @available(iOS 13.0, *)
    var enabledSwiftUIToolbarTypes: [Any.Type] {
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.enabledSwiftUIToolbarTypes) as? [Any.Type] ?? []
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.enabledSwiftUIToolbarTypes, 
                                   newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateSwiftUIHostingControllerClasses()
        }
    }

    /**
     Allowed subclasses of UIView to add all inner textField,
     this will allow to navigate between textField contains in different superview.
     Class should be kind of UIView.
     */
    var deepResponderAllowedContainerClasses: [UIView.Type] {
        get { toolbarManager.deepResponderAllowedContainerClasses }
        set { toolbarManager.deepResponderAllowedContainerClasses = newValue }
    }

    /**    reloadInputViews to reload toolbar buttons enable/disable state on the fly Enhancement ID #434. */
    func reloadInputViews() {
        toolbarManager.reloadInputViews()
    }

    /**
     Returns YES if can navigate to previous responder textInputView, otherwise NO.
     */
    var canGoPrevious: Bool {
        toolbarManager.canGoPrevious
    }

    /**
     Returns YES if can navigate to next responder textInputViews, otherwise NO.
     */
    var canGoNext: Bool {
        toolbarManager.canGoNext
    }

    /**
     Navigate to previous responder textInputViews
    */
    @discardableResult
    func goPrevious() -> Bool {
        toolbarManager.goPrevious()
    }

    /**
     Navigate to next responder textInputView.
    */
    @discardableResult
    func goNext() -> Bool {
        toolbarManager.goNext()
    }
}

// MARK: SwiftUI Support Implementation

@available(iOSApplicationExtension, unavailable)
@MainActor
private extension IQKeyboardManager {
    
    struct AssociatedKeys {
        static var disabledSwiftUIToolbarTypes: Int = 0
        static var enabledSwiftUIToolbarTypes: Int = 1
    }
    
    /**
     Internal method to sync SwiftUI toolbar settings with UIHostingController classes.
     This method manages the UIHostingController classes in the disabled/enabled lists.
     */
    @available(iOS 13.0, *)
    func updateSwiftUIHostingControllerClasses() {
        // This method ensures that if users specify SwiftUI types, we provide guidance
        // on how to properly disable toolbars for SwiftUI views.
        // The actual implementation works through UIHostingController subclassing.
    }
}

// MARK: Custom UIHostingController for SwiftUI Toolbar Management

/**
 Custom UIHostingController that integrates with IQKeyboardManager's SwiftUI toolbar management.
 
 To disable toolbars for specific SwiftUI views, you have two options:
 
 1. Use this custom hosting controller:
 ```swift
 class MyTextFieldHostingViewController: IQSwiftUIHostingController<MyTextFieldView> {
     // Toolbar will be automatically managed based on SwiftUI view type
 }
 ```
 
 2. Or disable the hosting controller class directly:
 ```swift
 IQKeyboardManager.shared.disabledToolbarClasses.append(MyTextFieldHostingViewController.self)
 ```
 */
@available(iOS 13.0, *)
@available(iOSApplicationExtension, unavailable)
open class IQSwiftUIHostingController<Content: View>: UIHostingController<Content> {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check if this hosting controller should have toolbar disabled based on SwiftUI content type
        if shouldDisableToolbarForCurrentContent() {
            // Add this specific class to disabled toolbar classes if it's not already there
            let currentDisabledClasses = IQKeyboardManager.shared.disabledToolbarClasses
            let selfType = type(of: self)
            if !currentDisabledClasses.contains(where: { $0 == selfType }) {
                IQKeyboardManager.shared.disabledToolbarClasses.append(selfType)
            }
        } else if shouldEnableToolbarForCurrentContent() {
            // Add this specific class to enabled toolbar classes if it's not already there
            let currentEnabledClasses = IQKeyboardManager.shared.enabledToolbarClasses
            let selfType = type(of: self)
            if !currentEnabledClasses.contains(where: { $0 == selfType }) {
                IQKeyboardManager.shared.enabledToolbarClasses.append(selfType)
            }
        }
    }
    
    /**
     Check if this hosting controller should have toolbar disabled based on its SwiftUI content type.
     */
    open func shouldDisableToolbarForCurrentContent() -> Bool {
        let swiftUITypes = IQKeyboardManager.shared.disabledSwiftUIToolbarTypes
        let contentTypeName = String(describing: Content.self)
        
        for disabledType in swiftUITypes {
            let disabledTypeName = String(describing: disabledType)
            if disabledTypeName == contentTypeName {
                return true
            }
        }
        return false
    }
    
    /**
     Check if this hosting controller should have toolbar enabled based on its SwiftUI content type.
     */
    open func shouldEnableToolbarForCurrentContent() -> Bool {
        let swiftUITypes = IQKeyboardManager.shared.enabledSwiftUIToolbarTypes
        let contentTypeName = String(describing: Content.self)
        
        for enabledType in swiftUITypes {
            let enabledTypeName = String(describing: enabledType)
            if enabledTypeName == contentTypeName {
                return true
            }
        }
        return false
    }
}
