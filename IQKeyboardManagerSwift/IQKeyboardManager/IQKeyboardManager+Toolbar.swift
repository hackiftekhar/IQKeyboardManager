//
//  IQKeyboardManager+Toolbar.swift
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

@available(iOSApplicationExtension, unavailable)
public extension IQKeyboardManager {

    /**
    Default tag for toolbar with Done button   -1002.
    */
    private static let  kIQDoneButtonToolbarTag         =   -1002

    /**
    Default tag for toolbar with Previous/Next buttons -1005.
    */
    private static let  kIQPreviousNextButtonToolbarTag =   -1005

    /** Add toolbar if it is required to add on textFields and it's siblings. */
    internal func addToolbarIfRequired() {

        // Either there is no inputAccessoryView or if accessoryView is not appropriate for current situation(There is Previous/Next/Done toolbar).
        guard let siblings: [UIView] = responderViews(), !siblings.isEmpty,
              let textField: UIView = textFieldView,
              textField.responds(to: #selector(setter: UITextField.inputAccessoryView)),
              (textField.inputAccessoryView == nil ||
                textField.inputAccessoryView?.tag == IQKeyboardManager.kIQPreviousNextButtonToolbarTag ||
                textField.inputAccessoryView?.tag == IQKeyboardManager.kIQDoneButtonToolbarTag) else {
            return
        }

        let startTime: CFTimeInterval = CACurrentMediaTime()
        showLog(">>>>> \(#function) started >>>>>", indentation: 1)

        showLog("Found \(siblings.count) responder sibling(s)")

        let rightConfiguration: IQBarButtonItemConfiguration
        if let configuration: IQBarButtonItemConfiguration = toolbarDoneBarButtonItemConfiguration {
            rightConfiguration = configuration
            rightConfiguration.action = #selector(self.doneAction(_:))
        } else {
            rightConfiguration = IQBarButtonItemConfiguration(systemItem: .done, action: #selector(self.doneAction(_:)))
            rightConfiguration.accessibilityLabel = "Done"
        }

        let previousNextDisplayMode: IQPreviousNextDisplayMode = toolbarConfiguration.previousNextDisplayMode
        //    If only one object is found, then adding only Done button.
        if (siblings.count <= 1 && previousNextDisplayMode == .default) || previousNextDisplayMode == .alwaysHide {

            let titleText: String? = toolbarConfiguration.placeholderConfiguration.showPlaceholder ? textField.iq.drawingPlaceholder : nil
            textField.iq.addToolbar(target: self, rightConfiguration: rightConfiguration,
                                    title: titleText,
                                    titleAccessibilityLabel: toolbarConfiguration.placeholderConfiguration.accessibilityLabel)

            textField.inputAccessoryView?.tag = IQKeyboardManager.kIQDoneButtonToolbarTag //  (Bug ID: #78)

        } else if previousNextDisplayMode == .default || previousNextDisplayMode == .alwaysShow {

            let prevConfiguration: IQBarButtonItemConfiguration
            if let configuration: IQBarButtonItemConfiguration = toolbarPreviousBarButtonItemConfiguration {
                configuration.action = #selector(self.previousAction(_:))
                prevConfiguration = configuration
            } else {
                prevConfiguration = IQBarButtonItemConfiguration(image: (UIImage.keyboardPreviousImage() ?? UIImage()), action: #selector(self.previousAction(_:)))
                prevConfiguration.accessibilityLabel = "Previous"
            }

            let nextConfiguration: IQBarButtonItemConfiguration
            if let configuration: IQBarButtonItemConfiguration = toolbarNextBarButtonItemConfiguration {
                configuration.action = #selector(self.nextAction(_:))
                nextConfiguration = configuration
            } else {
                nextConfiguration = IQBarButtonItemConfiguration(image: (UIImage.keyboardNextImage() ?? UIImage()), action: #selector(self.nextAction(_:)))
                nextConfiguration.accessibilityLabel = "Next"
            }

            let titleText: String? = toolbarConfiguration.placeholderConfiguration.showPlaceholder ? textField.iq.drawingPlaceholder : nil
            textField.iq.addToolbar(target: self,
                                    previousConfiguration: prevConfiguration,
                                    nextConfiguration: nextConfiguration,
                                    rightConfiguration: rightConfiguration, title: titleText,
                                    titleAccessibilityLabel: toolbarConfiguration.placeholderConfiguration.accessibilityLabel)

            textField.inputAccessoryView?.tag = IQKeyboardManager.kIQPreviousNextButtonToolbarTag //  (Bug ID: #78)
        }

        let toolbar: IQToolbar = textField.iq.toolbar

        // Setting toolbar tintColor //  (Enhancement ID: #30)
        toolbar.tintColor = toolbarConfiguration.useTextFieldTintColor ? textField.tintColor : toolbarConfiguration.tintColor

        //  Setting toolbar to keyboard.
        if let textFieldView: UITextInput = textField as? UITextInput {

            // Bar style according to keyboard appearance
            switch textFieldView.keyboardAppearance {

            case .dark?:
                toolbar.barStyle = .black
                toolbar.barTintColor = nil
            default:
                toolbar.barStyle = .default
                toolbar.barTintColor = toolbarConfiguration.barTintColor
            }
        }

        // Setting toolbar title font.   //  (Enhancement ID: #30)
        if toolbarConfiguration.placeholderConfiguration.showPlaceholder,
            !textField.iq.hidePlaceholder {

            // Updating placeholder font to toolbar.     //(Bug ID: #148, #272)
            if toolbar.titleBarButton.title == nil ||
                toolbar.titleBarButton.title != textField.iq.drawingPlaceholder {
                toolbar.titleBarButton.title = textField.iq.drawingPlaceholder
            }

            // Setting toolbar title font.   //  (Enhancement ID: #30)
            toolbar.titleBarButton.titleFont = toolbarConfiguration.placeholderConfiguration.font

            // Setting toolbar title color.   //  (Enhancement ID: #880)
            toolbar.titleBarButton.titleColor = toolbarConfiguration.placeholderConfiguration.color

            // Setting toolbar button title color.   //  (Enhancement ID: #880)
            toolbar.titleBarButton.selectableTitleColor = toolbarConfiguration.placeholderConfiguration.buttonColor

        } else {
            toolbar.titleBarButton.title = nil
        }

        // In case of UITableView (Special), the next/previous buttons has to be refreshed everytime.    (Bug ID: #56)

        textField.iq.toolbar.previousBarButton.isEnabled = (siblings.first != textField)   //    If firstTextField, then previous should not be enabled.
        textField.iq.toolbar.nextBarButton.isEnabled = (siblings.last != textField)        //    If lastTextField then next should not be enaled.

        let elapsedTime: CFTimeInterval = CACurrentMediaTime() - startTime
        showLog("<<<<< \(#function) ended: \(elapsedTime) seconds <<<<<", indentation: -1)
    }

    /** Remove any toolbar if it is IQToolbar. */
    internal func removeToolbarIfRequired() {    //  (Bug ID: #18)

        guard let siblings: [UIView] = responderViews(), !siblings.isEmpty,
              let textField: UIView = textFieldView,
                textField.responds(to: #selector(setter: UITextField.inputAccessoryView)),
              (textField.inputAccessoryView == nil ||
               textField.inputAccessoryView?.tag == IQKeyboardManager.kIQPreviousNextButtonToolbarTag ||
               textField.inputAccessoryView?.tag == IQKeyboardManager.kIQDoneButtonToolbarTag) else {
            return
        }

        let startTime: CFTimeInterval = CACurrentMediaTime()
        showLog(">>>>> \(#function) started >>>>>", indentation: 1)

        showLog("Found \(siblings.count) responder sibling(s)")

        for view in siblings {
            if let toolbar: IQToolbar = view.inputAccessoryView as? IQToolbar {

                // setInputAccessoryView: check   (Bug ID: #307)
                if view.responds(to: #selector(setter: UITextField.inputAccessoryView)),
                    (toolbar.tag == IQKeyboardManager.kIQDoneButtonToolbarTag || toolbar.tag == IQKeyboardManager.kIQPreviousNextButtonToolbarTag) {

                    if let textField: UITextField = view as? UITextField {
                        textField.inputAccessoryView = nil
                    } else if let textView: UITextView = view as? UITextView {
                        textView.inputAccessoryView = nil
                    }

                    view.reloadInputViews()
                }
            }
        }

        let elapsedTime: CFTimeInterval = CACurrentMediaTime() - startTime
        showLog("<<<<< \(#function) ended: \(elapsedTime) seconds <<<<<", indentation: -1)
    }

    /**    reloadInputViews to reload toolbar buttons enable/disable state on the fly Enhancement ID #434. */
    @objc func reloadInputViews() {

        // If enabled then adding toolbar.
        if privateIsEnableAutoToolbar() {
            self.addToolbarIfRequired()
        } else {
            self.removeToolbarIfRequired()
        }
    }
}

// MARK: Previous next button actions
@available(iOSApplicationExtension, unavailable)
public extension IQKeyboardManager {

    /**
    Returns YES if can navigate to previous responder textField/textView, otherwise NO.
    */
    @objc var canGoPrevious: Bool {
        // If it is not first textField. then it's previous object canBecomeFirstResponder.
        guard let textFields: [UIView] = responderViews(),
              let textFieldRetain: UIView = textFieldView,
              let index: Int = textFields.firstIndex(of: textFieldRetain),
              index > 0 else {
            return false
        }
        return true
    }

    /**
    Returns YES if can navigate to next responder textField/textView, otherwise NO.
    */
    @objc var canGoNext: Bool {
        // If it is not first textField. then it's previous object canBecomeFirstResponder.
        guard let textFields: [UIView] = responderViews(),
              let textFieldRetain: UIView = textFieldView,
              let index: Int = textFields.firstIndex(of: textFieldRetain),
                index < textFields.count-1 else {
            return false
        }
        return true
    }

    /**
    Navigate to previous responder textField/textView.
    */
    @discardableResult
    @objc func goPrevious() -> Bool {

        // If it is not first textField. then it's previous object becomeFirstResponder.
        guard let textFields: [UIView] = responderViews(),
              let textFieldRetain: UIView = textFieldView,
              let index: Int = textFields.firstIndex(of: textFieldRetain),
              index > 0 else {
            return false
        }

        let nextTextField: UIView = textFields[index-1]

        let isAcceptAsFirstResponder: Bool = nextTextField.becomeFirstResponder()

        //  If it refuses then becoming previous textFieldView as first responder again.    (Bug ID: #96)
        if !isAcceptAsFirstResponder {
            showLog("Refuses to become first responder: \(nextTextField)")
        }

        return isAcceptAsFirstResponder
    }

    /**
    Navigate to next responder textField/textView.
    */
    @discardableResult
    @objc func goNext() -> Bool {

        // If it is not first textField. then it's previous object becomeFirstResponder.
        guard let textFields: [UIView] = responderViews(),
              let textFieldRetain: UIView = textFieldView,
              let index: Int = textFields.firstIndex(of: textFieldRetain),
                index < textFields.count-1 else {
            return false
        }

        let nextTextField: UIView = textFields[index+1]

        let isAcceptAsFirstResponder: Bool = nextTextField.becomeFirstResponder()

        //  If it refuses then becoming previous textFieldView as first responder again.    (Bug ID: #96)
        if !isAcceptAsFirstResponder {
            showLog("Refuses to become first responder: \(nextTextField)")
        }

        return isAcceptAsFirstResponder
    }

    /**    previousAction. */
    @objc internal func previousAction (_ barButton: IQBarButtonItem) {

        // If user wants to play input Click sound.
        if playInputClicks {
            // Play Input Click Sound.
            UIDevice.current.playInputClick()
        }

        guard canGoPrevious,
              let textFieldRetain: UIView = textFieldView else {
            return
        }

        let isAcceptAsFirstResponder: Bool = goPrevious()

        var invocation: IQInvocation? = barButton.invocation
        var sender: UIView = textFieldRetain

        // Handling search bar special case
        do {
            if let searchBar: UIView = textFieldRetain.iq.textFieldSearchBar() {
                invocation = searchBar.iq.toolbar.previousBarButton.invocation
                sender = searchBar
            }
        }

        if isAcceptAsFirstResponder {
            invocation?.invoke(from: sender)
        }
    }

    /**    nextAction. */
    @objc internal func nextAction (_ barButton: IQBarButtonItem) {

        // If user wants to play input Click sound.
        if playInputClicks {
            // Play Input Click Sound.
            UIDevice.current.playInputClick()
        }

        guard canGoNext,
                let textFieldRetain: UIView = textFieldView else {
            return
        }

        let isAcceptAsFirstResponder: Bool = goNext()

        var invocation: IQInvocation? = barButton.invocation
        var sender: UIView = textFieldRetain

        // Handling search bar special case
        do {
            if let searchBar: UIView = textFieldRetain.iq.textFieldSearchBar() {
                invocation = searchBar.iq.toolbar.nextBarButton.invocation
                sender = searchBar
            }
        }

        if isAcceptAsFirstResponder {
            invocation?.invoke(from: sender)
        }
    }

    /**    doneAction. Resigning current textField. */
    @objc internal func doneAction (_ barButton: IQBarButtonItem) {

        // If user wants to play input Click sound.
        if playInputClicks {
            // Play Input Click Sound.
            UIDevice.current.playInputClick()
        }

        guard let textFieldRetain: UIView = textFieldView else {
            return
        }

        // Resign textFieldView.
        let isResignedFirstResponder: Bool = resignFirstResponder()

        var invocation: IQInvocation? = barButton.invocation
        var sender: UIView = textFieldRetain

        // Handling search bar special case
        do {
            if let searchBar: UIView = textFieldRetain.iq.textFieldSearchBar() {
                invocation = searchBar.iq.toolbar.doneBarButton.invocation
                sender = searchBar
            }
        }

        if isResignedFirstResponder {
            invocation?.invoke(from: sender)
        }
    }
}
