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

import Foundation

public extension IQKeyboardManager {

    /**
    Default tag for toolbar with Done button   -1002.
    */
    private static let  kIQDoneButtonToolbarTag         =   -1002

    /**
    Default tag for toolbar with Previous/Next buttons -1005.
    */
    private static let  kIQPreviousNextButtonToolbarTag =   -1005

    /**    previousAction. */
    @objc internal func previousAction (_ barButton: IQBarButtonItem) {

        //If user wants to play input Click sound.
        if shouldPlayInputClicks == true {
            //Play Input Click Sound.
            UIDevice.current.playInputClick()
        }

        if canGoPrevious == true {

            if let textFieldRetain = textFieldView {
                let isAcceptAsFirstResponder = goPrevious()

                var invocation = barButton.invocation
                var sender = textFieldRetain

                //Handling search bar special case
                do {
                    if let searchBar = textFieldRetain.textFieldSearchBar() {
                        invocation = searchBar.keyboardToolbar.previousBarButton.invocation
                        sender = searchBar
                    }
                }

                if isAcceptAsFirstResponder {
                    invocation?.invoke(from: sender)
                }
            }
        }
    }

    /**    nextAction. */
    @objc internal func nextAction (_ barButton: IQBarButtonItem) {

        //If user wants to play input Click sound.
        if shouldPlayInputClicks == true {
            //Play Input Click Sound.
            UIDevice.current.playInputClick()
        }

        if canGoNext == true {

            if let textFieldRetain = textFieldView {
                let isAcceptAsFirstResponder = goNext()

                var invocation = barButton.invocation
                var sender = textFieldRetain

                //Handling search bar special case
                do {
                    if let searchBar = textFieldRetain.textFieldSearchBar() {
                        invocation = searchBar.keyboardToolbar.nextBarButton.invocation
                        sender = searchBar
                    }
                }

                if isAcceptAsFirstResponder {
                    invocation?.invoke(from: sender)
                }
            }
        }
    }

    /**    doneAction. Resigning current textField. */
    @objc internal func doneAction (_ barButton: IQBarButtonItem) {

        //If user wants to play input Click sound.
        if shouldPlayInputClicks == true {
            //Play Input Click Sound.
            UIDevice.current.playInputClick()
        }

        if let textFieldRetain = textFieldView {
            //Resign textFieldView.
            let isResignedFirstResponder = resignFirstResponder()

            var invocation = barButton.invocation
            var sender = textFieldRetain

            //Handling search bar special case
            do {
                if let searchBar = textFieldRetain.textFieldSearchBar() {
                    invocation = searchBar.keyboardToolbar.doneBarButton.invocation
                    sender = searchBar
                }
            }

            if isResignedFirstResponder {
                invocation?.invoke(from: sender)
            }
        }
    }

    /** Add toolbar if it is required to add on textFields and it's siblings. */
    internal func addToolbarIfRequired() {

        let startTime = CACurrentMediaTime()
        showLog("****** \(#function) started ******", indentation: 1)

        //    Getting all the sibling textFields.
        if let siblings = responderViews(), !siblings.isEmpty {

            showLog("Found \(siblings.count) responder sibling(s)")

            if let textField = textFieldView {
                //Either there is no inputAccessoryView or if accessoryView is not appropriate for current situation(There is Previous/Next/Done toolbar).
                //setInputAccessoryView: check   (Bug ID: #307)
                if textField.responds(to: #selector(setter: UITextField.inputAccessoryView)) {

                    if textField.inputAccessoryView == nil ||
                        textField.inputAccessoryView?.tag == IQKeyboardManager.kIQPreviousNextButtonToolbarTag ||
                        textField.inputAccessoryView?.tag == IQKeyboardManager.kIQDoneButtonToolbarTag {

                        let rightConfiguration: IQBarButtonItemConfiguration

                        if let doneBarButtonItemImage = toolbarDoneBarButtonItemImage {
                            rightConfiguration = IQBarButtonItemConfiguration(image: doneBarButtonItemImage, action: #selector(self.doneAction(_:)))
                        } else if let doneBarButtonItemText = toolbarDoneBarButtonItemText {
                            rightConfiguration = IQBarButtonItemConfiguration(title: doneBarButtonItemText, action: #selector(self.doneAction(_:)))
                        } else {
                            rightConfiguration = IQBarButtonItemConfiguration(barButtonSystemItem: .done, action: #selector(self.doneAction(_:)))
                        }
                        rightConfiguration.accessibilityLabel = toolbarDoneBarButtonItemAccessibilityLabel ?? "Done"

                        //    If only one object is found, then adding only Done button.
                        if (siblings.count <= 1 && previousNextDisplayMode == .default) || previousNextDisplayMode == .alwaysHide {

                            textField.addKeyboardToolbarWithTarget(target: self, titleText: (shouldShowToolbarPlaceholder ? textField.drawingToolbarPlaceholder: nil), rightBarButtonConfiguration: rightConfiguration, previousBarButtonConfiguration: nil, nextBarButtonConfiguration: nil)

                            textField.inputAccessoryView?.tag = IQKeyboardManager.kIQDoneButtonToolbarTag //  (Bug ID: #78)

                        } else if previousNextDisplayMode == .default || previousNextDisplayMode == .alwaysShow {

                            let prevConfiguration: IQBarButtonItemConfiguration

                            if let doneBarButtonItemImage = toolbarPreviousBarButtonItemImage {
                                prevConfiguration = IQBarButtonItemConfiguration(image: doneBarButtonItemImage, action: #selector(self.previousAction(_:)))
                            } else if let doneBarButtonItemText = toolbarPreviousBarButtonItemText {
                                prevConfiguration = IQBarButtonItemConfiguration(title: doneBarButtonItemText, action: #selector(self.previousAction(_:)))
                            } else {
                                prevConfiguration = IQBarButtonItemConfiguration(image: (UIImage.keyboardPreviousImage() ?? UIImage()), action: #selector(self.previousAction(_:)))
                            }
                            prevConfiguration.accessibilityLabel = toolbarPreviousBarButtonItemAccessibilityLabel ?? "Previous"

                            let nextConfiguration: IQBarButtonItemConfiguration

                            if let doneBarButtonItemImage = toolbarNextBarButtonItemImage {
                                nextConfiguration = IQBarButtonItemConfiguration(image: doneBarButtonItemImage, action: #selector(self.nextAction(_:)))
                            } else if let doneBarButtonItemText = toolbarNextBarButtonItemText {
                                nextConfiguration = IQBarButtonItemConfiguration(title: doneBarButtonItemText, action: #selector(self.nextAction(_:)))
                            } else {
                                nextConfiguration = IQBarButtonItemConfiguration(image: (UIImage.keyboardNextImage() ?? UIImage()), action: #selector(self.nextAction(_:)))
                            }
                            nextConfiguration.accessibilityLabel = toolbarNextBarButtonItemAccessibilityLabel ?? "Next"

                            textField.addKeyboardToolbarWithTarget(target: self, titleText: (shouldShowToolbarPlaceholder ? textField.drawingToolbarPlaceholder: nil), rightBarButtonConfiguration: rightConfiguration, previousBarButtonConfiguration: prevConfiguration, nextBarButtonConfiguration: nextConfiguration)

                            textField.inputAccessoryView?.tag = IQKeyboardManager.kIQPreviousNextButtonToolbarTag //  (Bug ID: #78)
                        }

                        let toolbar = textField.keyboardToolbar

                        //Setting toolbar tintColor //  (Enhancement ID: #30)
                        if shouldToolbarUsesTextFieldTintColor {
                            toolbar.tintColor = textField.tintColor
                        } else if let tintColor = toolbarTintColor {
                            toolbar.tintColor = tintColor
                        } else {
                            toolbar.tintColor = nil
                        }

                        //  Setting toolbar to keyboard.
                        if let textFieldView = textField as? UITextInput {

                            //Bar style according to keyboard appearance
                            switch textFieldView.keyboardAppearance {

                            case .dark?:
                                toolbar.barStyle = .black
                                toolbar.barTintColor = nil
                            default:
                                toolbar.barStyle = .default
                                toolbar.barTintColor = toolbarBarTintColor
                            }
                        }

                        //Setting toolbar title font.   //  (Enhancement ID: #30)
                        if shouldShowToolbarPlaceholder == true &&
                            textField.shouldHideToolbarPlaceholder == false {

                            //Updating placeholder font to toolbar.     //(Bug ID: #148, #272)
                            if toolbar.titleBarButton.title == nil ||
                                toolbar.titleBarButton.title != textField.drawingToolbarPlaceholder {
                                toolbar.titleBarButton.title = textField.drawingToolbarPlaceholder
                            }

                            //Setting toolbar title font.   //  (Enhancement ID: #30)
                            if let font = placeholderFont {
                                toolbar.titleBarButton.titleFont = font
                            }

                            //Setting toolbar title color.   //  (Enhancement ID: #880)
                            if let color = placeholderColor {
                                toolbar.titleBarButton.titleColor = color
                            }

                            //Setting toolbar button title color.   //  (Enhancement ID: #880)
                            if let color = placeholderButtonColor {
                                toolbar.titleBarButton.selectableTitleColor = color
                            }

                        } else {

                            toolbar.titleBarButton.title = nil
                        }

                        //In case of UITableView (Special), the next/previous buttons has to be refreshed everytime.    (Bug ID: #56)
                        //    If firstTextField, then previous should not be enabled.
                        if siblings.first == textField {
                            if siblings.count == 1 {
                                textField.keyboardToolbar.previousBarButton.isEnabled = false
                                textField.keyboardToolbar.nextBarButton.isEnabled = false
                            } else {
                                textField.keyboardToolbar.previousBarButton.isEnabled = false
                                textField.keyboardToolbar.nextBarButton.isEnabled = true
                            }
                        } else if siblings.last  == textField {   //    If lastTextField then next should not be enaled.
                            textField.keyboardToolbar.previousBarButton.isEnabled = true
                            textField.keyboardToolbar.nextBarButton.isEnabled = false
                        } else {
                            textField.keyboardToolbar.previousBarButton.isEnabled = true
                            textField.keyboardToolbar.nextBarButton.isEnabled = true
                        }
                    }
                }
            }
        }

        let elapsedTime = CACurrentMediaTime() - startTime
        showLog("****** \(#function) ended: \(elapsedTime) seconds ******", indentation: -1)
    }

    /** Remove any toolbar if it is IQToolbar. */
    internal func removeToolbarIfRequired() {    //  (Bug ID: #18)

        let startTime = CACurrentMediaTime()
        showLog("****** \(#function) started ******", indentation: 1)

        //    Getting all the sibling textFields.
        if let siblings = responderViews() {

            showLog("Found \(siblings.count) responder sibling(s)")

            for view in siblings {

                if let toolbar = view.inputAccessoryView as? IQToolbar {

                    //setInputAccessoryView: check   (Bug ID: #307)
                    if view.responds(to: #selector(setter: UITextField.inputAccessoryView)) &&
                        (toolbar.tag == IQKeyboardManager.kIQDoneButtonToolbarTag || toolbar.tag == IQKeyboardManager.kIQPreviousNextButtonToolbarTag) {

                        if let textField = view as? UITextField {
                            textField.inputAccessoryView = nil
                        } else if let textView = view as? UITextView {
                            textView.inputAccessoryView = nil
                        }

                        view.reloadInputViews()
                    }
                }
            }
        }

        let elapsedTime = CACurrentMediaTime() - startTime
        showLog("****** \(#function) ended: \(elapsedTime) seconds ******", indentation: -1)
    }

    /**    reloadInputViews to reload toolbar buttons enable/disable state on the fly Enhancement ID #434. */
    @objc func reloadInputViews() {

        //If enabled then adding toolbar.
        if privateIsEnableAutoToolbar() == true {
            self.addToolbarIfRequired()
        } else {
            self.removeToolbarIfRequired()
        }
    }
}
