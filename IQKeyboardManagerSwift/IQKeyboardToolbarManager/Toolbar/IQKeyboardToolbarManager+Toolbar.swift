//
//  IQKeyboardToolbarManager+Toolbar.swift
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
@objc internal extension IQKeyboardToolbarManager {
    /**    reloadInputViews to reload toolbar buttons enable/disable state on the fly Enhancement ID #434. */
    func reloadInputViews() {

        guard let textInputView = textInputView else { return }
        // If enabled then adding toolbar.
        if privateIsEnableAutoToolbar(of: textInputView) {
            self.addToolbarIfRequired(of: textInputView)
        } else {
            self.removeToolbarIfRequired(of: textInputView)
        }
    }
}

@available(iOSApplicationExtension, unavailable)
@MainActor
internal extension IQKeyboardToolbarManager {

    /**
    Default tag for toolbar with Done button   -1001
    */
    private static let toolbarTag = -1001

    // swiftlint:disable function_body_length
    // swiftlint:disable cyclomatic_complexity
    /**
     Add toolbar if it is required to add on textInputViews and it's siblings.
     */
    func addToolbarIfRequired(of textInputView: some IQTextInputView) {

        // Either there is no inputAccessoryView or
        // if accessoryView is not appropriate for current situation
        // (There is Previous/Next/Done toolbar)
        guard let siblings: [any IQTextInputView] = responderViews(of: textInputView), !siblings.isEmpty,
              !Self.hasUserDefinedInputAccessoryView(textInputView: textInputView) else {
            return
        }

        showLog(">>>>> \(#function) started >>>>>", indentation: 1)
        defer {
            showLog("<<<<< \(#function) ended <<<<<", indentation: -1)
        }

        showLog("Found \(siblings.count) responder sibling(s)")
        let rightConfiguration: IQBarButtonItemConfiguration = getRightConfiguration()

        let isTableCollectionView: Bool
        if (textInputView as UIView).iq.superviewOf(type: UITableView.self) != nil ||
            (textInputView as UIView).iq.superviewOf(type: UICollectionView.self) != nil {
            isTableCollectionView = true
        } else {
            isTableCollectionView = false
        }

        let previousNextDisplayMode: IQPreviousNextDisplayMode = toolbarConfiguration.previousNextDisplayMode

        let havePreviousNext: Bool
        switch previousNextDisplayMode {
        case .default:
            // If the textInputView is part of UITableView/UICollectionView then we should be exposing previous/next too
            // Because at this time we don't know previous or next cell if it contains another textInputView to move.
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
        let titleText: String? = placeholderConfig.showPlaceholder ? textInputView.iq.drawingPlaceholder : nil
        if havePreviousNext {
            let prevConfiguration: IQBarButtonItemConfiguration = getPreviousConfiguration()
            let nextConfiguration: IQBarButtonItemConfiguration = getNextConfiguration()

            textInputView.iq.addToolbar(target: self,
                                        previousConfiguration: prevConfiguration,
                                        nextConfiguration: nextConfiguration,
                                        rightConfiguration: rightConfiguration, title: titleText,
                                        titleAccessibilityLabel: placeholderConfig.accessibilityLabel)
            if isTableCollectionView {
                // (Bug ID: #56)
                // In case of UITableView, the next/previous buttons should always be enabled.
                textInputView.iq.toolbar.previousBarButton.isEnabled = true
                textInputView.iq.toolbar.nextBarButton.isEnabled = true
            } else {
                // If first textInputView, then previous should not be enabled.
                if let first = siblings.first {
                    textInputView.iq.toolbar.previousBarButton.isEnabled = first != textInputView
                } else {
                    textInputView.iq.toolbar.previousBarButton.isEnabled = false
                }
                // If last textInputView, then next should not be enabled.
                if let last = siblings.last {
                    textInputView.iq.toolbar.nextBarButton.isEnabled = last != textInputView
                } else {
                    textInputView.iq.toolbar.nextBarButton.isEnabled = false
                }
            }
        } else {
            textInputView.iq.addToolbar(target: self, rightConfiguration: rightConfiguration,
                                        title: titleText,
                                        titleAccessibilityLabel: placeholderConfig.accessibilityLabel)
        }
        // (Bug ID: #78)
        textInputView.inputAccessoryView?.tag = IQKeyboardToolbarManager.toolbarTag

        Self.applyToolbarConfiguration(textInputView: textInputView, toolbarConfiguration: toolbarConfiguration)
    }
    // swiftlint:enable function_body_length
    // swiftlint:enable cyclomatic_complexity

    /** Remove any toolbar if it is IQToolbar. */
    func removeToolbarIfRequired(of textInputView: some IQTextInputView) {    //  (Bug ID: #18)

        guard let toolbar: IQToolbar = textInputView.inputAccessoryView as? IQToolbar,
              toolbar.tag == IQKeyboardToolbarManager.toolbarTag else {
            return
        }

        showLog(">>>>> \(#function) started >>>>>", indentation: 1)

        defer {
            showLog("<<<<< \(#function) ended <<<<<", indentation: -1)
        }

        textInputView.inputAccessoryView = nil
    }
}

@available(iOSApplicationExtension, unavailable)
@MainActor
private extension IQKeyboardToolbarManager {

    static func hasUserDefinedInputAccessoryView(textInputView: some IQTextInputView) -> Bool {
        guard let inputAccessoryView: UIView = textInputView.inputAccessoryView,
              inputAccessoryView.tag != IQKeyboardToolbarManager.toolbarTag else { return false }

        let swiftUIAccessoryNamePrefixes: [String] = [
            "RootUIView",   // iOS 18
            "InputAccessoryHost<InputAccessoryBar>" // iOS 17 and below
        ]
        let classNameString: String = "\(type(of: inputAccessoryView))"

        // If it's SwiftUI accessory view but doesn't have a height (fake accessory view), then we should
        // add our own accessoryView otherwise, keep the SwiftUI accessoryView since user has added it from code
        guard swiftUIAccessoryNamePrefixes.contains(where: { classNameString.hasPrefix($0)}),
              inputAccessoryView.subviews.isEmpty else {
            return true
        }
        return false
    }

    func getRightConfiguration() -> IQBarButtonItemConfiguration {
        let rightConfiguration: IQBarButtonItemConfiguration
        if let configuration: IQBarButtonItemConfiguration = toolbarConfiguration.doneBarButtonConfiguration {
            rightConfiguration = configuration
            rightConfiguration.action = #selector(self.doneAction(_:))
        } else {
            rightConfiguration = IQBarButtonItemConfiguration(systemItem: .done, action: #selector(self.doneAction(_:)))
            rightConfiguration.accessibilityLabel = "Done"
        }
        return rightConfiguration
    }

    func getPreviousConfiguration() -> IQBarButtonItemConfiguration {
        let prevConfiguration: IQBarButtonItemConfiguration
        if let configuration: IQBarButtonItemConfiguration = toolbarConfiguration.previousBarButtonConfiguration {
            configuration.action = #selector(self.previousAction(_:))
            prevConfiguration = configuration
        } else {
            let chevronUp: UIImage = UIImage(systemName: "chevron.up") ?? UIImage()
            prevConfiguration = IQBarButtonItemConfiguration(image: chevronUp,
                                                             action: #selector(self.previousAction(_:)))
            prevConfiguration.accessibilityLabel = "Previous"
        }
        return prevConfiguration
    }

    func getNextConfiguration() -> IQBarButtonItemConfiguration {
        let nextConfiguration: IQBarButtonItemConfiguration
        if let configuration: IQBarButtonItemConfiguration = toolbarConfiguration.nextBarButtonConfiguration {
            configuration.action = #selector(self.nextAction(_:))
            nextConfiguration = configuration
        } else {
            let chevronDown: UIImage = UIImage(systemName: "chevron.down") ?? UIImage()
            nextConfiguration = IQBarButtonItemConfiguration(image: chevronDown,
                                                             action: #selector(self.nextAction(_:)))
            nextConfiguration.accessibilityLabel = "Next"
        }
        return nextConfiguration
    }

    static func applyToolbarConfiguration(textInputView: some IQTextInputView,
                                          toolbarConfiguration: IQToolbarConfiguration) {

        let toolbar: IQToolbar = textInputView.iq.toolbar

        // Setting toolbar tintColor //  (Enhancement ID: #30)
        if toolbarConfiguration.useTextInputViewTintColor {
            toolbar.tintColor = textInputView.tintColor
        } else {
            toolbar.tintColor = toolbarConfiguration.tintColor
        }

        // Bar style according to keyboard appearance
        switch textInputView.keyboardAppearance {
        case .dark:
            toolbar.barStyle = .black
            toolbar.barTintColor = nil
        default:
            toolbar.barStyle = .default
            toolbar.barTintColor = toolbarConfiguration.barTintColor
        }

        // Setting toolbar title font.   //  (Enhancement ID: #30)
        guard toolbarConfiguration.placeholderConfiguration.showPlaceholder,
              !textInputView.iq.hidePlaceholder else {
            toolbar.titleBarButton.title = nil
            return
        }

        // Updating placeholder font to toolbar.     //(Bug ID: #148, #272)
        if toolbar.titleBarButton.title == nil ||
            toolbar.titleBarButton.title != textInputView.iq.drawingPlaceholder {
            toolbar.titleBarButton.title = textInputView.iq.drawingPlaceholder
        }

        // Setting toolbar title font.   //  (Enhancement ID: #30)
        toolbar.titleBarButton.titleFont = toolbarConfiguration.placeholderConfiguration.font

        // Setting toolbar title color.   //  (Enhancement ID: #880)
        toolbar.titleBarButton.titleColor = toolbarConfiguration.placeholderConfiguration.color

        // Setting toolbar button title color.   //  (Enhancement ID: #880)
        toolbar.titleBarButton.selectableTitleColor = toolbarConfiguration.placeholderConfiguration.buttonColor
    }
}
