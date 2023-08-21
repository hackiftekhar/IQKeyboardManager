//
//  IQUIView+IQKeyboardToolbar.swift
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

/**
UIView category methods to add IQToolbar on UIKeyboard.
*/
@available(iOSApplicationExtension, unavailable)
@objc public extension UIView {

    private struct AssociatedKeys {
        static var keyboardToolbar: Int = 0
        static var shouldHideToolbarPlaceholder: Int = 0
        static var toolbarPlaceholder: Int = 0
    }

    // MARK: Toolbar

    /**
     IQToolbar references for better customization control.
     */
    var keyboardToolbar: IQToolbar {
        var toolbar: IQToolbar? = inputAccessoryView as? IQToolbar

        if toolbar == nil {
            toolbar = objc_getAssociatedObject(self, &AssociatedKeys.keyboardToolbar) as? IQToolbar
        }

        if let unwrappedToolbar: IQToolbar = toolbar {
            return unwrappedToolbar
        } else {

            let frame: CGRect = CGRect(origin: .zero, size: .init(width: UIScreen.main.bounds.width, height: 44))
            let newToolbar: IQToolbar = IQToolbar(frame: frame)

            objc_setAssociatedObject(self, &AssociatedKeys.keyboardToolbar, newToolbar, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            return newToolbar
        }
    }

    // MARK: Toolbar title

    /**
    If `shouldHideToolbarPlaceholder` is YES, then title will not be added to the toolbar. Default to NO.
    */
    var shouldHideToolbarPlaceholder: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.shouldHideToolbarPlaceholder) as? Bool ?? false
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.shouldHideToolbarPlaceholder, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.keyboardToolbar.titleBarButton.title = self.drawingToolbarPlaceholder
        }
    }

    /**
     `toolbarPlaceholder` to override default `placeholder` text when drawing text on toolbar.
     */
    var toolbarPlaceholder: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.toolbarPlaceholder) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.toolbarPlaceholder, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.keyboardToolbar.titleBarButton.title = self.drawingToolbarPlaceholder
        }
    }

    /**
     `drawingToolbarPlaceholder` will be actual text used to draw on toolbar. This would either `placeholder` or `toolbarPlaceholder`.
     */
    var drawingToolbarPlaceholder: String? {

        if self.shouldHideToolbarPlaceholder {
            return nil
        } else if self.toolbarPlaceholder?.isEmpty == false {
            return self.toolbarPlaceholder
        } else if self.responds(to: #selector(getter: UITextField.placeholder)) {

            if let textField: UITextField = self as? UITextField {
                return textField.placeholder
            } else if let textView: IQTextView = self as? IQTextView {
                return textView.placeholder
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

    // MARK: Private helper

    // swiftlint:disable nesting
    private static func flexibleBarButtonItem () -> IQBarButtonItem {

        struct Static {

            static let nilButton: IQBarButtonItem = IQBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        }

        Static.nilButton.isSystemItem = true
        return Static.nilButton
    }

    // MARK: Common

    func addKeyboardToolbarWithTarget(target: AnyObject?,
                                      titleText: String?,
                                      titleAccessibilityLabel: String? = nil,
                                      rightBarButtonConfiguration: IQBarButtonItemConfiguration?,
                                      previousBarButtonConfiguration: IQBarButtonItemConfiguration? = nil,
                                      nextBarButtonConfiguration: IQBarButtonItemConfiguration? = nil) {

        // If can't set InputAccessoryView. Then return
        if self.responds(to: #selector(setter: UITextField.inputAccessoryView)) {

            //  Creating a toolBar for phoneNumber keyboard
            let toolbar: IQToolbar = self.keyboardToolbar

            var items: [IQBarButtonItem] = []

            if let prevConfig: IQBarButtonItemConfiguration = previousBarButtonConfiguration {

                var prev: IQBarButtonItem = toolbar.previousBarButton

                if prevConfig.systemItem == nil, !prev.isSystemItem {
                    prev.title = prevConfig.title
                    prev.accessibilityLabel = prevConfig.accessibilityLabel
                    prev.accessibilityIdentifier = prev.accessibilityLabel
                    prev.image = prevConfig.image
                    prev.target = target
                    prev.action = prevConfig.action
                } else {
                    if let systemItem: UIBarButtonItem.SystemItem = prevConfig.systemItem {
                        prev = IQBarButtonItem(barButtonSystemItem: systemItem, target: target, action: prevConfig.action)
                        prev.isSystemItem = true
                    } else if let image: UIImage = prevConfig.image {
                        prev = IQBarButtonItem(image: image, style: .plain, target: target, action: prevConfig.action)
                    } else {
                        prev = IQBarButtonItem(title: prevConfig.title, style: .plain, target: target, action: prevConfig.action)
                    }

                    prev.invocation = toolbar.previousBarButton.invocation
                    prev.accessibilityLabel = prevConfig.accessibilityLabel
                    prev.accessibilityIdentifier = prev.accessibilityLabel
                    prev.isEnabled = toolbar.previousBarButton.isEnabled
                    prev.tag = toolbar.previousBarButton.tag
                    toolbar.previousBarButton = prev
                }

                items.append(prev)
            }

            if previousBarButtonConfiguration != nil, nextBarButtonConfiguration != nil {

                items.append(toolbar.fixedSpaceBarButton)
            }

            if let nextConfig: IQBarButtonItemConfiguration = nextBarButtonConfiguration {

                var next: IQBarButtonItem = toolbar.nextBarButton

                if nextConfig.systemItem == nil, !next.isSystemItem {
                    next.title = nextConfig.title
                    next.accessibilityLabel = nextConfig.accessibilityLabel
                    next.accessibilityIdentifier = next.accessibilityLabel
                    next.image = nextConfig.image
                    next.target = target
                    next.action = nextConfig.action
                } else {
                    if let systemItem: UIBarButtonItem.SystemItem = nextConfig.systemItem {
                        next = IQBarButtonItem(barButtonSystemItem: systemItem, target: target, action: nextConfig.action)
                        next.isSystemItem = true
                    } else if let image: UIImage = nextConfig.image {
                        next = IQBarButtonItem(image: image, style: .plain, target: target, action: nextConfig.action)
                    } else {
                        next = IQBarButtonItem(title: nextConfig.title, style: .plain, target: target, action: nextConfig.action)
                    }

                    next.invocation = toolbar.nextBarButton.invocation
                    next.accessibilityLabel = nextConfig.accessibilityLabel
                    next.accessibilityIdentifier = next.accessibilityLabel
                    next.isEnabled = toolbar.nextBarButton.isEnabled
                    next.tag = toolbar.nextBarButton.tag
                    toolbar.nextBarButton = next
                }

                items.append(next)
            }

            // Title bar button item
            do {
                // Flexible space
                items.append(UIView.flexibleBarButtonItem())

                // Title button
                toolbar.titleBarButton.title = titleText
                toolbar.titleBarButton.accessibilityLabel = titleAccessibilityLabel
                toolbar.titleBarButton.accessibilityIdentifier = titleAccessibilityLabel

                toolbar.titleBarButton.customView?.frame = CGRect.zero

                items.append(toolbar.titleBarButton)

                // Flexible space
                items.append(UIView.flexibleBarButtonItem())
            }

            if let rightConfig: IQBarButtonItemConfiguration = rightBarButtonConfiguration {

                var done: IQBarButtonItem = toolbar.doneBarButton

                if rightConfig.systemItem == nil, !done.isSystemItem {
                    done.title = rightConfig.title
                    done.accessibilityLabel = rightConfig.accessibilityLabel
                    done.accessibilityIdentifier = done.accessibilityLabel
                    done.image = rightConfig.image
                    done.target = target
                    done.action = rightConfig.action
                } else {
                    if let systemItem: UIBarButtonItem.SystemItem = rightConfig.systemItem {
                        done = IQBarButtonItem(barButtonSystemItem: systemItem, target: target, action: rightConfig.action)
                        done.isSystemItem = true
                    } else if let image: UIImage = rightConfig.image {
                        done = IQBarButtonItem(image: image, style: .plain, target: target, action: rightConfig.action)
                    } else {
                        done = IQBarButtonItem(title: rightConfig.title, style: .plain, target: target, action: rightConfig.action)
                    }

                    done.invocation = toolbar.doneBarButton.invocation
                    done.accessibilityLabel = rightConfig.accessibilityLabel
                    done.accessibilityIdentifier = done.accessibilityLabel
                    done.isEnabled = toolbar.doneBarButton.isEnabled
                    done.tag = toolbar.doneBarButton.tag
                    toolbar.doneBarButton = done
                }

                items.append(done)
            }

            //  Adding button to toolBar.
            toolbar.items = items

            if let textInput: UITextInput = self as? UITextInput {
                switch textInput.keyboardAppearance {
                case .dark?:
                    toolbar.barStyle = .black
                default:
                    toolbar.barStyle = .default
                }
            }

            //  Setting toolbar to keyboard.
            if let textField: UITextField = self as? UITextField {
                textField.inputAccessoryView = toolbar
            } else if let textView: UITextView = self as? UITextView {
                textView.inputAccessoryView = toolbar
            }
        }
    }

    // MARK: Right

    func addDoneOnKeyboardWithTarget(_ target: AnyObject?, action: Selector, shouldShowPlaceholder: Bool = false, titleAccessibilityLabel: String? = nil) {

        addDoneOnKeyboardWithTarget(target, action: action, titleText: (shouldShowPlaceholder ? self.drawingToolbarPlaceholder: nil), titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func addDoneOnKeyboardWithTarget(_ target: AnyObject?, action: Selector, titleText: String?, titleAccessibilityLabel: String? = nil) {

        let rightConfiguration = IQBarButtonItemConfiguration(systemItem: .done, action: action)

        addKeyboardToolbarWithTarget(target: target, titleText: titleText, rightBarButtonConfiguration: rightConfiguration)
    }

    func addRightButtonOnKeyboardWithImage(_ image: UIImage, target: AnyObject?, action: Selector, shouldShowPlaceholder: Bool = false, titleAccessibilityLabel: String? = nil) {

        addRightButtonOnKeyboardWithImage(image, target: target, action: action, titleText: (shouldShowPlaceholder ? self.drawingToolbarPlaceholder: nil), titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func addRightButtonOnKeyboardWithImage(_ image: UIImage, target: AnyObject?, action: Selector, titleText: String?, titleAccessibilityLabel: String? = nil) {

        let rightConfiguration = IQBarButtonItemConfiguration(image: image, action: action)

        addKeyboardToolbarWithTarget(target: target, titleText: titleText, titleAccessibilityLabel: titleAccessibilityLabel, rightBarButtonConfiguration: rightConfiguration)
    }

    func addRightButtonOnKeyboardWithText(_ text: String, target: AnyObject?, action: Selector, shouldShowPlaceholder: Bool = false, titleAccessibilityLabel: String? = nil) {

        addRightButtonOnKeyboardWithText(text, target: target, action: action, titleText: (shouldShowPlaceholder ? self.drawingToolbarPlaceholder: nil), titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func addRightButtonOnKeyboardWithText(_ text: String, target: AnyObject?, action: Selector, titleText: String?, titleAccessibilityLabel: String? = nil) {

        let rightConfiguration = IQBarButtonItemConfiguration(title: text, action: action)

        addKeyboardToolbarWithTarget(target: target, titleText: titleText, titleAccessibilityLabel: titleAccessibilityLabel, rightBarButtonConfiguration: rightConfiguration)
    }

    // MARK: Right/Left

    func addCancelDoneOnKeyboardWithTarget(_ target: AnyObject?, cancelAction: Selector, doneAction: Selector, shouldShowPlaceholder: Bool = false, titleAccessibilityLabel: String? = nil) {

        addCancelDoneOnKeyboardWithTarget(target, cancelAction: cancelAction, doneAction: doneAction, titleText: (shouldShowPlaceholder ? self.drawingToolbarPlaceholder: nil), titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func addRightLeftOnKeyboardWithTarget(_ target: AnyObject?, leftButtonTitle: String, rightButtonTitle: String, leftButtonAction: Selector, rightButtonAction: Selector, shouldShowPlaceholder: Bool = false, titleAccessibilityLabel: String? = nil) {

        addRightLeftOnKeyboardWithTarget(target, leftButtonTitle: leftButtonTitle, rightButtonTitle: rightButtonTitle, leftButtonAction: leftButtonAction, rightButtonAction: rightButtonAction, titleText: (shouldShowPlaceholder ? self.drawingToolbarPlaceholder: nil), titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func addRightLeftOnKeyboardWithTarget(_ target: AnyObject?, leftButtonImage: UIImage, rightButtonImage: UIImage, leftButtonAction: Selector, rightButtonAction: Selector, shouldShowPlaceholder: Bool = false, titleAccessibilityLabel: String? = nil) {

        addRightLeftOnKeyboardWithTarget(target, leftButtonImage: leftButtonImage, rightButtonImage: rightButtonImage, leftButtonAction: leftButtonAction, rightButtonAction: rightButtonAction, titleText: (shouldShowPlaceholder ? self.drawingToolbarPlaceholder: nil), titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func addCancelDoneOnKeyboardWithTarget(_ target: AnyObject?, cancelAction: Selector, doneAction: Selector, titleText: String?, titleAccessibilityLabel: String? = nil) {

        let leftConfiguration = IQBarButtonItemConfiguration(systemItem: .cancel, action: cancelAction)
        let rightConfiguration = IQBarButtonItemConfiguration(systemItem: .done, action: doneAction)

        addKeyboardToolbarWithTarget(target: target, titleText: titleText, titleAccessibilityLabel: titleAccessibilityLabel, rightBarButtonConfiguration: rightConfiguration, previousBarButtonConfiguration: leftConfiguration)
    }

    func addRightLeftOnKeyboardWithTarget(_ target: AnyObject?, leftButtonTitle: String, rightButtonTitle: String, leftButtonAction: Selector, rightButtonAction: Selector, titleText: String?, titleAccessibilityLabel: String? = nil) {

        let leftConfiguration = IQBarButtonItemConfiguration(title: leftButtonTitle, action: leftButtonAction)
        let rightConfiguration = IQBarButtonItemConfiguration(title: rightButtonTitle, action: rightButtonAction)

        addKeyboardToolbarWithTarget(target: target, titleText: titleText, titleAccessibilityLabel: titleAccessibilityLabel, rightBarButtonConfiguration: rightConfiguration, previousBarButtonConfiguration: leftConfiguration)
    }

    func addRightLeftOnKeyboardWithTarget(_ target: AnyObject?, leftButtonImage: UIImage, rightButtonImage: UIImage, leftButtonAction: Selector, rightButtonAction: Selector, titleText: String?, titleAccessibilityLabel: String? = nil) {

        let leftConfiguration = IQBarButtonItemConfiguration(image: leftButtonImage, action: leftButtonAction)
        let rightConfiguration = IQBarButtonItemConfiguration(image: rightButtonImage, action: rightButtonAction)

        addKeyboardToolbarWithTarget(target: target, titleText: titleText, titleAccessibilityLabel: titleAccessibilityLabel, rightBarButtonConfiguration: rightConfiguration, previousBarButtonConfiguration: leftConfiguration)
    }

    // MARK: Previous/Next/Right

    func addPreviousNextDoneOnKeyboardWithTarget (_ target: AnyObject?, previousAction: Selector, nextAction: Selector, doneAction: Selector, shouldShowPlaceholder: Bool = false, titleAccessibilityLabel: String? = nil) {

        addPreviousNextDoneOnKeyboardWithTarget(target, previousAction: previousAction, nextAction: nextAction, doneAction: doneAction, titleText: (shouldShowPlaceholder ? self.drawingToolbarPlaceholder: nil), titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func addPreviousNextRightOnKeyboardWithTarget(_ target: AnyObject?, rightButtonImage: UIImage, previousAction: Selector, nextAction: Selector, rightButtonAction: Selector, shouldShowPlaceholder: Bool = false, titleAccessibilityLabel: String? = nil) {

        addPreviousNextRightOnKeyboardWithTarget(target, rightButtonImage: rightButtonImage, previousAction: previousAction, nextAction: nextAction, rightButtonAction: rightButtonAction, titleText: (shouldShowPlaceholder ? self.drawingToolbarPlaceholder: nil), titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func addPreviousNextRightOnKeyboardWithTarget(_ target: AnyObject?, rightButtonTitle: String, previousAction: Selector, nextAction: Selector, rightButtonAction: Selector, shouldShowPlaceholder: Bool = false, titleAccessibilityLabel: String? = nil) {

        addPreviousNextRightOnKeyboardWithTarget(target, rightButtonTitle: rightButtonTitle, previousAction: previousAction, nextAction: nextAction, rightButtonAction: rightButtonAction, titleText: (shouldShowPlaceholder ? self.drawingToolbarPlaceholder: nil), titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func addPreviousNextDoneOnKeyboardWithTarget (_ target: AnyObject?, previousAction: Selector, nextAction: Selector, doneAction: Selector, titleText: String?, titleAccessibilityLabel: String? = nil) {

        let rightConfiguration: IQBarButtonItemConfiguration = IQBarButtonItemConfiguration(systemItem: .done, action: doneAction)
        let nextConfiguration: IQBarButtonItemConfiguration = IQBarButtonItemConfiguration(image: UIImage.keyboardNextImage() ?? UIImage(), action: nextAction)
        let prevConfiguration: IQBarButtonItemConfiguration = IQBarButtonItemConfiguration(image: UIImage.keyboardPreviousImage() ?? UIImage(), action: previousAction)

        addKeyboardToolbarWithTarget(target: target, titleText: titleText, titleAccessibilityLabel: titleAccessibilityLabel, rightBarButtonConfiguration: rightConfiguration, previousBarButtonConfiguration: prevConfiguration, nextBarButtonConfiguration: nextConfiguration)
    }

    func addPreviousNextRightOnKeyboardWithTarget(_ target: AnyObject?, rightButtonImage: UIImage, previousAction: Selector, nextAction: Selector, rightButtonAction: Selector, titleText: String?, titleAccessibilityLabel: String? = nil) {

        let rightConfiguration: IQBarButtonItemConfiguration = IQBarButtonItemConfiguration(image: rightButtonImage, action: rightButtonAction)
        let nextConfiguration: IQBarButtonItemConfiguration = IQBarButtonItemConfiguration(image: UIImage.keyboardNextImage() ?? UIImage(), action: nextAction)
        let prevConfiguration: IQBarButtonItemConfiguration = IQBarButtonItemConfiguration(image: UIImage.keyboardPreviousImage() ?? UIImage(), action: previousAction)

        addKeyboardToolbarWithTarget(target: target, titleText: titleText, titleAccessibilityLabel: titleAccessibilityLabel, rightBarButtonConfiguration: rightConfiguration, previousBarButtonConfiguration: prevConfiguration, nextBarButtonConfiguration: nextConfiguration)
    }

    func addPreviousNextRightOnKeyboardWithTarget(_ target: AnyObject?, rightButtonTitle: String, previousAction: Selector, nextAction: Selector, rightButtonAction: Selector, titleText: String?, titleAccessibilityLabel: String? = nil) {

        let rightConfiguration: IQBarButtonItemConfiguration = IQBarButtonItemConfiguration(title: rightButtonTitle, action: rightButtonAction)
        let nextConfiguration: IQBarButtonItemConfiguration = IQBarButtonItemConfiguration(image: UIImage.keyboardNextImage() ?? UIImage(), action: nextAction)
        let prevConfiguration: IQBarButtonItemConfiguration = IQBarButtonItemConfiguration(image: UIImage.keyboardPreviousImage() ?? UIImage(), action: previousAction)

        addKeyboardToolbarWithTarget(target: target, titleText: titleText, titleAccessibilityLabel: titleAccessibilityLabel, rightBarButtonConfiguration: rightConfiguration, previousBarButtonConfiguration: prevConfiguration, nextBarButtonConfiguration: nextConfiguration)
    }
}
