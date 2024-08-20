//
//  UIView+IQKeyboardToolbarObjc.swift
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

// MARK: For ObjectiveC Compatibility

// swiftlint:disable identifier_name
@objc public extension UITextField {

    var iq_toolbar: IQToolbar { iq.toolbar }

    var iq_hidePlaceholder: Bool {
        get { iq.hidePlaceholder }
        set(newValue) { iq.hidePlaceholder = newValue }
    }

    var iq_placeholder: String? {
        get { iq.placeholder }
        set(newValue) { iq.placeholder = newValue }
    }

    var iq_drawingPlaceholder: String? { iq.drawingPlaceholder }

    func iq_addToolbar(target: AnyObject?,
                       previousConfiguration: IQBarButtonItemConfiguration? = nil,
                       nextConfiguration: IQBarButtonItemConfiguration? = nil,
                       rightConfiguration: IQBarButtonItemConfiguration? = nil,
                       title: String?,
                       titleAccessibilityLabel: String? = nil) {
        iq.addToolbar(target: target, previousConfiguration: previousConfiguration,
                      nextConfiguration: nextConfiguration,
                      rightConfiguration: rightConfiguration,
                      title: title, titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func iq_addDone(target: AnyObject?,
                    action: Selector,
                    showPlaceholder: Bool = false, titleAccessibilityLabel: String? = nil) {
        iq.addDone(target: target, action: action, showPlaceholder: showPlaceholder,
                   titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func iq_addDone(target: AnyObject?,
                    action: Selector,
                    title: String?, titleAccessibilityLabel: String? = nil) {
        iq.addDone(target: target, action: action, title: title, titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func iq_addRightButton(target: AnyObject?,
                           configuration: IQBarButtonItemConfiguration,
                           showPlaceholder: Bool = false, titleAccessibilityLabel: String? = nil) {
        iq.addRightButton(target: target, configuration: configuration, showPlaceholder: showPlaceholder,
                          titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func iq_addRightButton(target: AnyObject?,
                           configuration: IQBarButtonItemConfiguration,
                           title: String?, titleAccessibilityLabel: String? = nil) {
        iq.addRightButton(target: target, configuration: configuration, title: title,
                          titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func iq_addRightLeft(target: AnyObject?,
                         rightConfiguration: IQBarButtonItemConfiguration,
                         leftConfiguration: IQBarButtonItemConfiguration,
                         showPlaceholder: Bool = false, titleAccessibilityLabel: String? = nil) {
        iq.addRightLeft(target: target, rightConfiguration: rightConfiguration,
                        leftConfiguration: leftConfiguration, showPlaceholder: showPlaceholder,
                        titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func iq_addRightLeft(target: AnyObject?,
                         rightConfiguration: IQBarButtonItemConfiguration,
                         leftConfiguration: IQBarButtonItemConfiguration,
                         title: String?, titleAccessibilityLabel: String? = nil) {
        iq.addRightLeft(target: target, rightConfiguration: rightConfiguration,
                        leftConfiguration: leftConfiguration, title: title,
                        titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func iq_addPreviousNextRight(target: AnyObject?,
                                 previousConfiguration: IQBarButtonItemConfiguration? = nil,
                                 nextConfiguration: IQBarButtonItemConfiguration? = nil,
                                 rightConfiguration: IQBarButtonItemConfiguration?,
                                 showPlaceholder: Bool = false, titleAccessibilityLabel: String? = nil) {
        iq.addPreviousNextRight(target: target, previousConfiguration: previousConfiguration,
                                nextConfiguration: nextConfiguration, rightConfiguration: rightConfiguration,
                                showPlaceholder: showPlaceholder, titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func iq_addPreviousNextRight(target: AnyObject?,
                                 previousConfiguration: IQBarButtonItemConfiguration? = nil,
                                 nextConfiguration: IQBarButtonItemConfiguration? = nil,
                                 rightConfiguration: IQBarButtonItemConfiguration?,
                                 title: String?, titleAccessibilityLabel: String? = nil) {
        iq.addPreviousNextRight(target: target, previousConfiguration: previousConfiguration,
                                nextConfiguration: nextConfiguration,
                                rightConfiguration: rightConfiguration,
                                title: title, titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func iq_addPreviousNextDone(target: AnyObject?, previousAction: Selector,
                                nextAction: Selector, doneAction: Selector,
                                showPlaceholder: Bool = false,
                                titleAccessibilityLabel: String? = nil) {
        iq.addPreviousNextDone(target: target, previousAction: previousAction,
                               nextAction: nextAction, doneAction: doneAction,
                               showPlaceholder: showPlaceholder,
                               titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func iq_addPreviousNextDone(target: AnyObject?,
                                previousAction: Selector, nextAction: Selector, doneAction: Selector,
                                title: String?, titleAccessibilityLabel: String? = nil) {
        iq.addPreviousNextDone(target: target, previousAction: previousAction,
                               nextAction: nextAction, doneAction: doneAction,
                               title: title, titleAccessibilityLabel: titleAccessibilityLabel)
    }
}

@objc public extension UITextView {

    var iq_toolbar: IQToolbar { iq.toolbar }

    var iq_hidePlaceholder: Bool {
        get { iq.hidePlaceholder }
        set(newValue) { iq.hidePlaceholder = newValue }
    }

    var iq_placeholder: String? {
        get { iq.placeholder }
        set(newValue) { iq.placeholder = newValue }
    }

    var iq_drawingPlaceholder: String? { iq.drawingPlaceholder }

    func iq_addToolbar(target: AnyObject?,
                       previousConfiguration: IQBarButtonItemConfiguration? = nil,
                       nextConfiguration: IQBarButtonItemConfiguration? = nil,
                       rightConfiguration: IQBarButtonItemConfiguration? = nil,
                       title: String?,
                       titleAccessibilityLabel: String? = nil) {
        iq.addToolbar(target: target, previousConfiguration: previousConfiguration,
                      nextConfiguration: nextConfiguration, rightConfiguration: rightConfiguration,
                      title: title, titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func iq_addDone(target: AnyObject?,
                    action: Selector,
                    showPlaceholder: Bool = false, titleAccessibilityLabel: String? = nil) {
        iq.addDone(target: target, action: action, showPlaceholder: showPlaceholder,
                   titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func iq_addDone(target: AnyObject?,
                    action: Selector,
                    title: String?, titleAccessibilityLabel: String? = nil) {
        iq.addDone(target: target, action: action, title: title,
                   titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func iq_addRightButton(target: AnyObject?,
                           configuration: IQBarButtonItemConfiguration,
                           showPlaceholder: Bool = false, titleAccessibilityLabel: String? = nil) {
        iq.addRightButton(target: target, configuration: configuration,
                          showPlaceholder: showPlaceholder, titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func iq_addRightButton(target: AnyObject?,
                           configuration: IQBarButtonItemConfiguration,
                           title: String?, titleAccessibilityLabel: String? = nil) {
        iq.addRightButton(target: target, configuration: configuration,
                          title: title, titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func iq_addRightLeft(target: AnyObject?,
                         rightConfiguration: IQBarButtonItemConfiguration,
                         leftConfiguration: IQBarButtonItemConfiguration,
                         showPlaceholder: Bool = false, titleAccessibilityLabel: String? = nil) {
        iq.addRightLeft(target: target, rightConfiguration: rightConfiguration,
                        leftConfiguration: leftConfiguration, showPlaceholder: showPlaceholder,
                        titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func iq_addRightLeft(target: AnyObject?,
                         rightConfiguration: IQBarButtonItemConfiguration,
                         leftConfiguration: IQBarButtonItemConfiguration,
                         title: String?, titleAccessibilityLabel: String? = nil) {
        iq.addRightLeft(target: target, rightConfiguration: rightConfiguration,
                        leftConfiguration: leftConfiguration, title: title,
                        titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func iq_addPreviousNextRight(target: AnyObject?,
                                 previousConfiguration: IQBarButtonItemConfiguration? = nil,
                                 nextConfiguration: IQBarButtonItemConfiguration? = nil,
                                 rightConfiguration: IQBarButtonItemConfiguration?,
                                 showPlaceholder: Bool = false, titleAccessibilityLabel: String? = nil) {
        iq.addPreviousNextRight(target: target, previousConfiguration: previousConfiguration,
                                nextConfiguration: nextConfiguration, rightConfiguration: rightConfiguration,
                                showPlaceholder: showPlaceholder, titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func iq_addPreviousNextRight(target: AnyObject?,
                                 previousConfiguration: IQBarButtonItemConfiguration? = nil,
                                 nextConfiguration: IQBarButtonItemConfiguration? = nil,
                                 rightConfiguration: IQBarButtonItemConfiguration?,
                                 title: String?, titleAccessibilityLabel: String? = nil) {
        iq.addPreviousNextRight(target: target, previousConfiguration: previousConfiguration,
                                nextConfiguration: nextConfiguration,
                                rightConfiguration: rightConfiguration,
                                title: title, titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func iq_addPreviousNextDone(target: AnyObject?, previousAction: Selector, nextAction: Selector,
                                doneAction: Selector, showPlaceholder: Bool = false,
                                titleAccessibilityLabel: String? = nil) {
        iq.addPreviousNextDone(target: target, previousAction: previousAction,
                               nextAction: nextAction,
                               doneAction: doneAction, showPlaceholder: showPlaceholder,
                               titleAccessibilityLabel: titleAccessibilityLabel)
    }

    func iq_addPreviousNextDone(target: AnyObject?,
                                previousAction: Selector, nextAction: Selector, doneAction: Selector,
                                title: String?, titleAccessibilityLabel: String? = nil) {
        iq.addPreviousNextDone(target: target, previousAction: previousAction,
                               nextAction: nextAction,
                               doneAction: doneAction, title: title,
                               titleAccessibilityLabel: titleAccessibilityLabel)
    }
}
// swiftlint:enable identifier_name
