//
//  UIView+IQKeyboardToolbar.swift
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
import IQKeyboardCore

@available(iOSApplicationExtension, unavailable)
@MainActor
private struct AssociatedKeys {
    static var toolbar: Int = 0
    static var hidePlaceholder: Int = 0
    static var placeholder: Int = 0
}

@available(iOSApplicationExtension, unavailable)
@MainActor
public extension IQKeyboardExtension where Base: IQTextInputView {

    // MARK: Toolbar

    /**
     Toolbar references for better customization control.
     */
    var toolbar: IQToolbar {
        var toolbar: IQToolbar? = base?.inputAccessoryView as? IQToolbar

        if toolbar == nil, let base = base {
            toolbar = objc_getAssociatedObject(base, &AssociatedKeys.toolbar) as? IQToolbar
        }

        if let toolbar: IQToolbar = toolbar {
            return toolbar
        } else {

            let width: CGFloat = base?.window?.windowScene?.screen.bounds.width ?? 0

            let frame = CGRect(origin: .zero, size: .init(width: width, height: 44))
            let newToolbar = IQToolbar(frame: frame)

            if let base = base {
                objc_setAssociatedObject(base, &AssociatedKeys.toolbar, newToolbar, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }

            return newToolbar
        }
    }

    // MARK: Toolbar title

    /**
     If `hideToolbarPlaceholder` is YES, then title will not be added to the toolbar. Default to NO.
     */
    var hidePlaceholder: Bool {
        get {
            if let base = base {
                return objc_getAssociatedObject(base, &AssociatedKeys.hidePlaceholder) as? Bool ?? false
            }
            return false
        }
        set(newValue) {
            if let base = base {
                objc_setAssociatedObject(base, &AssociatedKeys.hidePlaceholder,
                                         newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                toolbar.titleBarButton.title = drawingPlaceholder
            }
        }
    }

    /**
     `toolbarPlaceholder` to override default `placeholder` text when drawing text on toolbar.
     */
    var placeholder: String? {
        get {
            if let base = base {
                return objc_getAssociatedObject(base, &AssociatedKeys.placeholder) as? String
            }
            return nil
        }
        set(newValue) {
            if let base = base {
                // swiftlint:disable:next line_length
                objc_setAssociatedObject(base, &AssociatedKeys.placeholder, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                toolbar.titleBarButton.title = drawingPlaceholder
            }
        }
    }

    /**
     `drawingToolbarPlaceholder` will be actual text used to draw on toolbar. 
     This would either `placeholder` or `toolbarPlaceholder`.
     */
    var drawingPlaceholder: String? {

        guard !hidePlaceholder else { return nil }

        if let placeholder = placeholder,
              !placeholder.isEmpty {
            return placeholder
        }

        guard let placeholderable: any IQPlaceholderable = base as? (any IQPlaceholderable) else { return nil }

        if let placeholder = placeholderable.attributedPlaceholder?.string,
           !placeholder.isEmpty {
            return placeholder
        } else if let placeholder = placeholderable.placeholder {
            return placeholder
        } else {
            return nil
        }
    }

    // MARK: Common

    func addToolbar(target: AnyObject?,
                    previousConfiguration: IQBarButtonItemConfiguration? = nil,
                    nextConfiguration: IQBarButtonItemConfiguration? = nil,
                    rightConfiguration: IQBarButtonItemConfiguration? = nil,
                    title: String?,
                    titleAccessibilityLabel: String? = nil) {
        guard let base = base else { return }
        //  Creating a toolBar for phoneNumber keyboard
        let toolbar: IQToolbar = toolbar

        let items: [UIBarButtonItem] = Self.constructBarButtonItems(target: target, toolbar: toolbar,
                                                                    previousConfiguration: previousConfiguration,
                                                                    nextConfiguration: nextConfiguration,
                                                                    rightConfiguration: rightConfiguration,
                                                                    title: title,
                                                                    titleAccessibilityLabel: titleAccessibilityLabel)

        //  Adding button to toolBar.
        toolbar.items = items

        switch base.keyboardAppearance {
        case .dark:
            toolbar.barStyle = .black
        default:
            toolbar.barStyle = .default
        }

        //  Setting toolbar to keyboard.
        let reloadInputViews: Bool = base.inputAccessoryView != toolbar
        guard reloadInputViews else { return }

        base.inputAccessoryView = toolbar

        base.reloadInputViews()
    }

    // MARK: Right
    func addDone(target: AnyObject?,
                 action: Selector,
                 showPlaceholder: Bool = false, titleAccessibilityLabel: String? = nil) {

        let title: String? = showPlaceholder ? drawingPlaceholder : nil

        addDone(target: target, action: action,
                   title: title, titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func addDone(target: AnyObject?,
                 action: Selector,
                 title: String?, titleAccessibilityLabel: String? = nil) {

        let rightConfiguration = IQBarButtonItemConfiguration(systemItem: .done, action: action)

        addToolbar(target: target, rightConfiguration: rightConfiguration,
                   title: title, titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func addRightButton(target: AnyObject?,
                        configuration: IQBarButtonItemConfiguration,
                        showPlaceholder: Bool = false, titleAccessibilityLabel: String? = nil) {
        let title: String? = showPlaceholder ? drawingPlaceholder : nil
        addRightButton(target: target, configuration: configuration, title: title,
                       titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func addRightButton(target: AnyObject?,
                        configuration: IQBarButtonItemConfiguration,
                        title: String?, titleAccessibilityLabel: String? = nil) {
        addToolbar(target: target, rightConfiguration: configuration, title: title,
                   titleAccessibilityLabel: titleAccessibilityLabel)
    }

    // MARK: Right/Left
    func addRightLeft(target: AnyObject?,
                      rightConfiguration: IQBarButtonItemConfiguration, leftConfiguration: IQBarButtonItemConfiguration,
                      showPlaceholder: Bool = false, titleAccessibilityLabel: String? = nil) {
        let title: String? = showPlaceholder ? drawingPlaceholder : nil
        addRightLeft(target: target,
                     rightConfiguration: rightConfiguration, leftConfiguration: leftConfiguration,
                     title: title, titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func addRightLeft(target: AnyObject?,
                      rightConfiguration: IQBarButtonItemConfiguration, leftConfiguration: IQBarButtonItemConfiguration,
                      title: String?, titleAccessibilityLabel: String? = nil) {
        addToolbar(target: target,
                   previousConfiguration: leftConfiguration, rightConfiguration: rightConfiguration,
                   title: title, titleAccessibilityLabel: titleAccessibilityLabel)
    }

    // MARK: Previous/Next/Right

    func addPreviousNextRight(target: AnyObject?,
                              previousConfiguration: IQBarButtonItemConfiguration? = nil,
                              nextConfiguration: IQBarButtonItemConfiguration? = nil,
                              rightConfiguration: IQBarButtonItemConfiguration?,
                              showPlaceholder: Bool = false, titleAccessibilityLabel: String? = nil) {

        let title: String? = showPlaceholder ? drawingPlaceholder : nil
        addPreviousNextRight(target: target,
                             previousConfiguration: previousConfiguration, nextConfiguration: nextConfiguration,
                             rightConfiguration: rightConfiguration,
                             title: title, titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func addPreviousNextRight(target: AnyObject?,
                              previousConfiguration: IQBarButtonItemConfiguration? = nil,
                              nextConfiguration: IQBarButtonItemConfiguration? = nil,
                              rightConfiguration: IQBarButtonItemConfiguration?,
                              title: String?, titleAccessibilityLabel: String? = nil) {

        addToolbar(target: target,
                   previousConfiguration: previousConfiguration, nextConfiguration: nextConfiguration,
                   rightConfiguration: rightConfiguration,
                   title: title, titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func addPreviousNextDone(target: AnyObject?, previousAction: Selector, nextAction: Selector, doneAction: Selector,
                             showPlaceholder: Bool = false, titleAccessibilityLabel: String? = nil) {
        let title: String? = showPlaceholder ? drawingPlaceholder : nil
        addPreviousNextDone(target: target, previousAction: previousAction, nextAction: nextAction,
                            doneAction: doneAction,
                            title: title, titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func addPreviousNextDone(target: AnyObject?,
                             previousAction: Selector, nextAction: Selector, doneAction: Selector,
                             title: String?, titleAccessibilityLabel: String? = nil) {

        let chevronUp: UIImage = UIImage(systemName: "chevron.up") ?? UIImage()
        let chevronDown: UIImage = UIImage(systemName: "chevron.down") ?? UIImage()

        let previousConfiguration = IQBarButtonItemConfiguration(image: chevronUp,
                                                                 action: previousAction)
        let nextConfiguration = IQBarButtonItemConfiguration(image: chevronDown,
                                                             action: nextAction)
        let rightConfiguration = IQBarButtonItemConfiguration(systemItem: .done,
                                                              action: doneAction)

        addToolbar(target: target, previousConfiguration: previousConfiguration,
                   nextConfiguration: nextConfiguration, rightConfiguration: rightConfiguration,
                   title: title, titleAccessibilityLabel: titleAccessibilityLabel)
    }
}

@available(iOSApplicationExtension, unavailable)
@MainActor
private extension IQKeyboardExtension where Base: IQTextInputView {

    private static func constructBarButtonItems(target: AnyObject?,
                                                toolbar: IQToolbar,
                                                previousConfiguration: IQBarButtonItemConfiguration? = nil,
                                                nextConfiguration: IQBarButtonItemConfiguration? = nil,
                                                rightConfiguration: IQBarButtonItemConfiguration? = nil,
                                                title: String?,
                                                titleAccessibilityLabel: String? = nil) -> [UIBarButtonItem] {
        var items: [UIBarButtonItem] = []

        if let previousConfiguration: IQBarButtonItemConfiguration = previousConfiguration {
            let prev: IQBarButtonItem = previousConfiguration.apply(on: toolbar.previousBarButton, target: target)
            toolbar.previousBarButton = prev
            items.append(prev)
        }

        if previousConfiguration != nil, nextConfiguration != nil {
            items.append(toolbar.fixedSpaceBarButton)
        }

        if let nextConfiguration: IQBarButtonItemConfiguration = nextConfiguration {
            let next: IQBarButtonItem = nextConfiguration.apply(on: toolbar.nextBarButton, target: target)
            toolbar.nextBarButton = next
            items.append(next)
        }

        if !toolbar.additionalLeadingItems.isEmpty {
            items.append(contentsOf: toolbar.additionalLeadingItems)
        }

        // Title bar button item
        do {
            // Flexible space
            items.append(IQBarButtonItem.flexibleBarButtonItem)

            // Title button
            toolbar.titleBarButton.title = title
            toolbar.titleBarButton.accessibilityLabel = titleAccessibilityLabel
            toolbar.titleBarButton.accessibilityIdentifier = titleAccessibilityLabel

            toolbar.titleBarButton.customView?.frame = .zero

            items.append(toolbar.titleBarButton)

            // Flexible space
            items.append(IQBarButtonItem.flexibleBarButtonItem)
        }

        if !toolbar.additionalTrailingItems.isEmpty {
            items.append(contentsOf: toolbar.additionalTrailingItems)
        }

        if let rightConfiguration: IQBarButtonItemConfiguration = rightConfiguration {

            let done: IQBarButtonItem = rightConfiguration.apply(on: toolbar.doneBarButton, target: target)
            toolbar.doneBarButton = done
            items.append(done)
        }
        return items
    }
}
