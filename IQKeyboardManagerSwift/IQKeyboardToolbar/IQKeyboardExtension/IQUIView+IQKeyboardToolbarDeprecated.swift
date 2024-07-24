//
//  IQUIView+IQKeyboardToolbarDeprecated.swift
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

// swiftlint:disable unused_setter_value
// swiftlint:disable line_length
// swiftlint:disable function_parameter_count
@available(iOSApplicationExtension, unavailable)
@MainActor
@objc public extension UIView {

    @available(*, unavailable, renamed: "iq.toolbar")
    var keyboardToolbar: IQToolbar {
        get { fatalError() }
        set {}
    }

    @available(*, unavailable, renamed: "iq.hidePlaceholder")
    var shouldHideToolbarPlaceholder: Bool {
        get { false }
        set {}
    }

    @available(*, unavailable, renamed: "iq.placeholder")
    var toolbarPlaceholder: String? {
        get { nil }
        set {}
    }

    @available(*, unavailable, renamed: "iq.drawingPlaceholder")
    var drawingToolbarPlaceholder: String? {
        get { nil }
        set {}
    }

    @available(*, unavailable, renamed: "iq.addToolbar(target:previousConfiguration:nextConfiguration:rightConfiguration:title:titleAccessibilityLabel:)")
    func addKeyboardToolbarWithTarget(target: AnyObject?,
                                      titleText: String?,
                                      titleAccessibilityLabel: String? = nil,
                                      rightBarButtonConfiguration: IQBarButtonItemConfiguration?,
                                      previousBarButtonConfiguration: IQBarButtonItemConfiguration? = nil,
                                      nextBarButtonConfiguration: IQBarButtonItemConfiguration? = nil) {
    }

    @available(*, unavailable, renamed: "iq.addDone(target:action:showPlaceholder:titleAccessibilityLabel:)")
    func addDoneOnKeyboardWithTarget(_ target: AnyObject?,
                                     action: Selector,
                                     shouldShowPlaceholder: Bool = false,
                                     titleAccessibilityLabel: String? = nil) {
    }

    @available(*, unavailable, renamed: "iq.addDone(target:action:title:titleAccessibilityLabel:)")
    func addDoneOnKeyboardWithTarget(_ target: AnyObject?,
                                     action: Selector,
                                     titleText: String?,
                                     titleAccessibilityLabel: String? = nil) {
    }

    @available(*, unavailable, renamed: "iq.addRightButton(target:configuration:showPlaceholder:titleAccessibilityLabel:)")
    func addRightButtonOnKeyboardWithImage(_ image: UIImage,
                                           target: AnyObject?,
                                           action: Selector,
                                           shouldShowPlaceholder: Bool = false,
                                           titleAccessibilityLabel: String? = nil) {
    }

    @available(*, unavailable, renamed: "iq.addRightButton(target:configuration:title:titleAccessibilityLabel:)")
    func addRightButtonOnKeyboardWithImage(_ image: UIImage,
                                           target: AnyObject?,
                                           action: Selector,
                                           titleText: String?,
                                           titleAccessibilityLabel: String? = nil) {
    }

    @available(*, unavailable, renamed: "iq.addRightButton(target:configuration:showPlaceholder:titleAccessibilityLabel:)")
    func addRightButtonOnKeyboardWithText(_ text: String,
                                          target: AnyObject?,
                                          action: Selector,
                                          shouldShowPlaceholder: Bool = false,
                                          titleAccessibilityLabel: String? = nil) {
    }

    @available(*, unavailable, renamed: "iq.addRightButton(target:configuration:title:titleAccessibilityLabel:)")
    func addRightButtonOnKeyboardWithText(_ text: String,
                                          target: AnyObject?,
                                          action: Selector,
                                          titleText: String?,
                                          titleAccessibilityLabel: String? = nil) {
    }

    @available(*, unavailable, renamed: "iq.addRightLeft(target:rightConfiguration:leftConfiguration:showPlaceholder:titleAccessibilityLabel:)")
    func addCancelDoneOnKeyboardWithTarget(_ target: AnyObject?,
                                           cancelAction: Selector,
                                           doneAction: Selector,
                                           shouldShowPlaceholder: Bool = false,
                                           titleAccessibilityLabel: String? = nil) {
    }

    @available(*, unavailable, renamed: "iq.addRightLeft(target:rightConfiguration:leftConfiguration:showPlaceholder:titleAccessibilityLabel:)")
    func addRightLeftOnKeyboardWithTarget(_ target: AnyObject?,
                                          leftButtonTitle: String,
                                          rightButtonTitle: String,
                                          leftButtonAction: Selector,
                                          rightButtonAction: Selector,
                                          shouldShowPlaceholder: Bool = false,
                                          titleAccessibilityLabel: String? = nil) {
    }

    @available(*, unavailable, renamed: "iq.addRightLeft(target:rightConfiguration:leftConfiguration:showPlaceholder:titleAccessibilityLabel:)")
    func addRightLeftOnKeyboardWithTarget(_ target: AnyObject?,
                                          leftButtonImage: UIImage,
                                          rightButtonImage: UIImage,
                                          leftButtonAction: Selector,
                                          rightButtonAction: Selector,
                                          shouldShowPlaceholder: Bool = false,
                                          titleAccessibilityLabel: String? = nil) {
    }

    @available(*, unavailable, renamed: "iq.addRightLeft(target:rightConfiguration:leftConfiguration:title:titleAccessibilityLabel:)")
    func addCancelDoneOnKeyboardWithTarget(_ target: AnyObject?,
                                           cancelAction: Selector,
                                           doneAction: Selector,
                                           titleText: String?,
                                           titleAccessibilityLabel: String? = nil) {
    }

    @available(*, unavailable, renamed: "iq.addRightLeft(target:rightConfiguration:leftConfiguration:title:titleAccessibilityLabel:)")
    func addRightLeftOnKeyboardWithTarget(_ target: AnyObject?,
                                          leftButtonTitle: String,
                                          rightButtonTitle: String,
                                          leftButtonAction: Selector,
                                          rightButtonAction: Selector,
                                          titleText: String?,
                                          titleAccessibilityLabel: String? = nil) {
    }

    @available(*, unavailable, renamed: "iq.addRightLeft(target:rightConfiguration:leftConfiguration:title:titleAccessibilityLabel:)")
    func addRightLeftOnKeyboardWithTarget(_ target: AnyObject?,
                                          leftButtonImage: UIImage,
                                          rightButtonImage: UIImage,
                                          leftButtonAction: Selector,
                                          rightButtonAction: Selector,
                                          titleText: String?,
                                          titleAccessibilityLabel: String? = nil) {
    }

    @available(*, unavailable, renamed: "iq.addPreviousNextDone(target:previousAction:nextAction:doneAction:showPlaceholder:titleAccessibilityLabel:)")
    func addPreviousNextDone(_ target: AnyObject?,
                             previousAction: Selector,
                             nextAction: Selector,
                             doneAction: Selector,
                             shouldShowPlaceholder: Bool = false,
                             titleAccessibilityLabel: String? = nil) {
    }

    @available(*, unavailable, renamed: "iq.addPreviousNextDone(target:previousAction:nextAction:doneAction:title:titleAccessibilityLabel:)")
    func addPreviousNextDoneOnKeyboardWithTarget(_ target: AnyObject?,
                                                 previousAction: Selector,
                                                 nextAction: Selector,
                                                 doneAction: Selector,
                                                 titleText: String?,
                                                 titleAccessibilityLabel: String? = nil) {
    }

    @available(*, unavailable, renamed: "iq.addPreviousNextRight(target:previousConfiguration:nextConfiguration:rightConfiguration:showPlaceholder:titleAccessibilityLabel:)")
    func addPreviousNextRightOnKeyboardWithTarget(_ target: AnyObject?,
                                                  rightButtonImage: UIImage,
                                                  previousAction: Selector,
                                                  nextAction: Selector,
                                                  rightButtonAction: Selector,
                                                  shouldShowPlaceholder: Bool = false,
                                                  titleAccessibilityLabel: String? = nil) {
    }

    @available(*, unavailable, renamed: "iq.addPreviousNextRight(target:previousConfiguration:nextConfiguration:rightConfiguration:showPlaceholder:titleAccessibilityLabel:)")
    func addPreviousNextRightOnKeyboardWithTarget(_ target: AnyObject?,
                                                  rightButtonTitle: String,
                                                  previousAction: Selector,
                                                  nextAction: Selector,
                                                  rightButtonAction: Selector,
                                                  shouldShowPlaceholder: Bool = false,
                                                  titleAccessibilityLabel: String? = nil) {
    }

    @available(*, unavailable, renamed: "iq.addPreviousNextRight(target:previousConfiguration:nextConfiguration:rightConfiguration:title:titleAccessibilityLabel:)")
    func addPreviousNextRightOnKeyboardWithTarget(_ target: AnyObject?,
                                                  rightButtonImage: UIImage,
                                                  previousAction: Selector,
                                                  nextAction: Selector,
                                                  rightButtonAction: Selector,
                                                  titleText: String?,
                                                  titleAccessibilityLabel: String? = nil) {
    }

    @available(*, unavailable, renamed: "iq.addPreviousNextRight(target:previousConfiguration:nextConfiguration:rightConfiguration:title:titleAccessibilityLabel:)")
    func addPreviousNextRightOnKeyboardWithTarget(_ target: AnyObject?,
                                                  rightButtonTitle: String,
                                                  previousAction: Selector,
                                                  nextAction: Selector,
                                                  rightButtonAction: Selector,
                                                  titleText: String?,
                                                  titleAccessibilityLabel: String? = nil) {
    }
}
// swiftlint:enable unused_setter_value
// swiftlint:enable line_length
// swiftlint:enable function_parameter_count
