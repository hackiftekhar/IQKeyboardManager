//
//  IQKeyboardManager+Toolbar.swift
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

    // swiftlint:disable function_body_length
    // swiftlint:disable cyclomatic_complexity
    /**
     Add toolbar if it is required to add on textFields and it's siblings.
     */
    internal func addToolbarIfRequired() {

        // Either there is no inputAccessoryView or
        // if accessoryView is not appropriate for current situation
        // (There is Previous/Next/Done toolbar)
        guard let siblings: [UIView] = responderViews(), !siblings.isEmpty,
              let textField: UIView = activeConfiguration.textFieldViewInfo?.textFieldView,
              textField.responds(to: #selector(setter: UITextField.inputAccessoryView)) else {
            return
        }

        if let inputAccessoryView: UIView = textField.inputAccessoryView {

            if inputAccessoryView.tag == IQKeyboardManager.kIQPreviousNextButtonToolbarTag ||
                inputAccessoryView.tag == IQKeyboardManager.kIQDoneButtonToolbarTag {
                // continue
            } else {
                let swiftUIAccessoryName: String = "InputAccessoryHost<InputAccessoryBar>"
                let classNameString: String = "\(type(of: inputAccessoryView.classForCoder))"

                // If it's SwiftUI accessory view but doesn't have a height (fake accessory view), then we should
                // add our own accessoryView otherwise, keep the SwiftUI accessoryView since user has added it from code
                guard classNameString.hasPrefix(swiftUIAccessoryName), inputAccessoryView.subviews.isEmpty else {
                    return
                }
            }
        }

        showLog(">>>>> \(#function) started >>>>>", indentation: 1)
        let startTime: CFTimeInterval = CACurrentMediaTime()

        showLog("Found \(siblings.count) responder sibling(s)")

        let rightConfiguration: IQBarButtonItemConfiguration
        if let configuration: IQBarButtonItemConfiguration = toolbarConfiguration.doneBarButtonConfiguration {
            rightConfiguration = configuration
            rightConfiguration.action = #selector(self.doneAction(_:))
        } else {
            rightConfiguration = IQBarButtonItemConfiguration(systemItem: .done, action: #selector(self.doneAction(_:)))
            rightConfiguration.accessibilityLabel = "Done"
        }

        let isTableCollectionView: Bool
        if textField.iq.superviewOf(type: UITableView.self) != nil ||
            textField.iq.superviewOf(type: UICollectionView.self) != nil {
            isTableCollectionView = true
        } else {
            isTableCollectionView = false
        }

        let previousNextDisplayMode: IQPreviousNextDisplayMode = toolbarConfiguration.previousNextDisplayMode

        let havePreviousNext: Bool
        switch previousNextDisplayMode {
        case .default:
            // If the textField is part of UITableView/UICollectionView then we should be exposing previous/next too
            // Because at this time we don't know the previous or next cell if it contains another textField to move.
            if isTableCollectionView {
                havePreviousNext = true
            } else if siblings.count <= 1 {
                //    If only one object is found, then adding only Done button.
                havePreviousNext = false
            } else {
                havePreviousNext = true
            }
        case .alwaysShow:
            havePreviousNext = true
        case .alwaysHide:
            havePreviousNext = false
        }

        let placeholderConfig: IQToolbarPlaceholderConfiguration = toolbarConfiguration.placeholderConfiguration
        if havePreviousNext {
            let prevConfiguration: IQBarButtonItemConfiguration
            if let configuration: IQBarButtonItemConfiguration = toolbarConfiguration.previousBarButtonConfiguration {
                configuration.action = #selector(self.previousAction(_:))
                prevConfiguration = configuration
            } else {
                prevConfiguration = IQBarButtonItemConfiguration(image: (UIImage.keyboardPreviousImage),
                                                                 action: #selector(self.previousAction(_:)))
                prevConfiguration.accessibilityLabel = "Previous"
            }

            let nextConfiguration: IQBarButtonItemConfiguration
            if let configuration: IQBarButtonItemConfiguration = toolbarConfiguration.nextBarButtonConfiguration {
                configuration.action = #selector(self.nextAction(_:))
                nextConfiguration = configuration
            } else {
                nextConfiguration = IQBarButtonItemConfiguration(image: (UIImage.keyboardNextImage),
                                                                 action: #selector(self.nextAction(_:)))
                nextConfiguration.accessibilityLabel = "Next"
            }

            let titleText: String? = placeholderConfig.showPlaceholder ? textField.iq.drawingPlaceholder : nil
            textField.iq.addToolbar(target: self,
                                    previousConfiguration: prevConfiguration,
                                    nextConfiguration: nextConfiguration,
                                    rightConfiguration: rightConfiguration, title: titleText,
                                    titleAccessibilityLabel: placeholderConfig.accessibilityLabel)

            // (Bug ID: #78)
            textField.inputAccessoryView?.tag = IQKeyboardManager.kIQPreviousNextButtonToolbarTag

            if isTableCollectionView {
                // (Bug ID: #56)
                // In case of UITableView, the next/previous buttons should always be enabled.
                textField.iq.toolbar.previousBarButton.isEnabled = true
                textField.iq.toolbar.nextBarButton.isEnabled = true
            } else {
                // If firstTextField, then previous should not be enabled.
                textField.iq.toolbar.previousBarButton.isEnabled = (siblings.first != textField)
                // If lastTextField then next should not be enabled.
                textField.iq.toolbar.nextBarButton.isEnabled = (siblings.last != textField)
            }

        } else {

            let titleText: String? = placeholderConfig.showPlaceholder ? textField.iq.drawingPlaceholder : nil
            textField.iq.addToolbar(target: self, rightConfiguration: rightConfiguration,
                                    title: titleText,
                                    titleAccessibilityLabel: placeholderConfig.accessibilityLabel)

            textField.inputAccessoryView?.tag = IQKeyboardManager.kIQDoneButtonToolbarTag //  (Bug ID: #78)
        }

        let toolbar: IQToolbar = textField.iq.toolbar

        // Setting toolbar tintColor //  (Enhancement ID: #30)
        if toolbarConfiguration.useTextFieldTintColor {
            toolbar.tintColor = textField.tintColor
        } else {
            toolbar.tintColor = toolbarConfiguration.tintColor
        }

        //  Setting toolbar to keyboard.
        if let textFieldView: any UITextInput = textField as? (any UITextInput) {

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

        // In case of UITableView (Special), the next/previous buttons has to be refreshed every-time.    (Bug ID: #56)

        // If firstTextField, then previous should not be enabled.
        textField.iq.toolbar.previousBarButton.isEnabled = (siblings.first != textField)

        // If lastTextField then next should not be enabled.
        textField.iq.toolbar.nextBarButton.isEnabled = (siblings.last != textField)

        let elapsedTime: CFTimeInterval = CACurrentMediaTime() - startTime
        showLog("<<<<< \(#function) ended: \(elapsedTime) seconds <<<<<", indentation: -1)
    }
    // swiftlint:enable function_body_length
    // swiftlint:enable cyclomatic_complexity

    /** Remove any toolbar if it is IQToolbar. */
    internal func removeToolbarIfRequired() {    //  (Bug ID: #18)

        guard let siblings: [UIView] = responderViews(), !siblings.isEmpty else {
            return
        }

        showLog(">>>>> \(#function) started >>>>>", indentation: 1)
        let startTime: CFTimeInterval = CACurrentMediaTime()

        showLog("Found \(siblings.count) responder sibling(s)")

        for view in siblings {
            removeToolbarIfRequired(of: view)
        }

        let elapsedTime: CFTimeInterval = CACurrentMediaTime() - startTime
        showLog("<<<<< \(#function) ended: \(elapsedTime) seconds <<<<<", indentation: -1)
    }

    /** Remove any toolbar if it is IQToolbar. */
    internal func removeToolbarIfRequired(of view: UIView) {    //  (Bug ID: #18)

        guard view.responds(to: #selector(setter: UITextField.inputAccessoryView)),
              let toolbar: IQToolbar = view.inputAccessoryView as? IQToolbar,
              toolbar.tag == IQKeyboardManager.kIQPreviousNextButtonToolbarTag ||
                toolbar.tag == IQKeyboardManager.kIQDoneButtonToolbarTag else {
            return
        }

        // setInputAccessoryView: check   (Bug ID: #307)
        if let textField: UITextField = view as? UITextField {
            textField.inputAccessoryView = nil
        } else if let textView: UITextView = view as? UITextView {
            textView.inputAccessoryView = nil
        }
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
