//
//  IQKeyboardManager+ToolbarActions.swift
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

// MARK: Previous next button actions
@available(iOSApplicationExtension, unavailable)
public extension IQKeyboardManager {

    /**
    Returns YES if can navigate to previous responder textField/textView, otherwise NO.
    */
    @objc var canGoPrevious: Bool {
        // If it is not first textField. then it's previous object canBecomeFirstResponder.
        guard let textFields: [UIView] = responderViews(),
              let textFieldRetain: UIView = activeConfiguration.textFieldViewInfo?.textFieldView,
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
              let textFieldRetain: UIView = activeConfiguration.textFieldViewInfo?.textFieldView,
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
              let textFieldRetain: UIView = activeConfiguration.textFieldViewInfo?.textFieldView,
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
              let textFieldRetain: UIView = activeConfiguration.textFieldViewInfo?.textFieldView,
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
              let textFieldRetain: UIView = activeConfiguration.textFieldViewInfo?.textFieldView else {
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
              let textFieldRetain: UIView = activeConfiguration.textFieldViewInfo?.textFieldView else {
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

        guard let textFieldRetain: UIView = activeConfiguration.textFieldViewInfo?.textFieldView else {
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
