//
//  IQTextFieldViewListener.swift
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

@available(iOSApplicationExtension, unavailable)
@MainActor
@objc public class IQTextFieldViewListener: NSObject {

    private var textFieldViewObservers: [AnyHashable: TextFieldViewCompletion] = [:]

    private var findInteractionTextInputViewInfo: IQTextFieldViewInfo?

    public private(set) var textInputViewInfo: IQTextFieldViewInfo?

    public var textInputView: (some IQTextInputView)? {
        return textInputViewInfo?.textInputView
    }

    @objc public override init() {
        super.init()
        //  Registering for keyboard notification.
        NotificationCenter.default.addObserver(self, selector: #selector(self.didBeginEditing(_:)),
                                               name: UITextField.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didEndEditing(_:)),
                                               name: UITextField.textDidEndEditingNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.didBeginEditing(_:)),
                                               name: UITextView.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didEndEditing(_:)),
                                               name: UITextView.textDidEndEditingNotification, object: nil)
    }

    @objc private func didBeginEditing(_ notification: Notification) {
        guard let info: IQTextFieldViewInfo = IQTextFieldViewInfo(notification: notification,
                                                                  event: .beginEditing) else {
            return
        }

        if #available(iOS 16.0, *),
           let findInteractionTextInputViewInfo = findInteractionTextInputViewInfo,
           findInteractionTextInputViewInfo.textInputView.iqFindInteraction?.isFindNavigatorVisible == true {
            // // This means the this didBeginEditing call comes due to find interaction
            textInputViewInfo = findInteractionTextInputViewInfo
            sendEvent(info: findInteractionTextInputViewInfo)
        } else if textInputViewInfo != info {
            textInputViewInfo = info
            findInteractionTextInputViewInfo = nil
            sendEvent(info: info)
        } else {
            findInteractionTextInputViewInfo = nil
        }
    }

    @objc private func didEndEditing(_ notification: Notification) {
        guard let info: IQTextFieldViewInfo = IQTextFieldViewInfo(notification: notification, event: .endEditing) else {
            return
        }

        if textInputViewInfo != info {
            if #available(iOS 16.0, *),
               info.textInputView.iqIsFindInteractionEnabled {
                findInteractionTextInputViewInfo = textInputViewInfo
            } else {
                findInteractionTextInputViewInfo = nil
            }
            textInputViewInfo = info
            sendEvent(info: info)
            textInputViewInfo = nil
        }
    }
}

@available(iOSApplicationExtension, unavailable)
@MainActor
public extension IQTextFieldViewListener {

    typealias TextFieldViewCompletion = (_ info: IQTextFieldViewInfo) -> Void

    func subscribe(identifier: AnyHashable, changeHandler: @escaping TextFieldViewCompletion) {
        textFieldViewObservers[identifier] = changeHandler
    }

    func unsubscribe(identifier: AnyHashable) {
        textFieldViewObservers[identifier] = nil
    }

    private func sendEvent(info: IQTextFieldViewInfo) {

        for block in textFieldViewObservers.values {
            block(info)
        }
    }
}

@available(iOSApplicationExtension, unavailable)
@MainActor
public extension IQTextFieldViewListener {

    @available(*, deprecated, renamed: "textInputViewInfo")
    var textFieldViewInfo: IQTextFieldViewInfo? { textInputViewInfo }

    @available(*, deprecated, renamed: "textInputView")
    var textFieldView: (some IQTextInputView)? { textInputView }

    @available(*, deprecated, renamed: "subscribe(identifier:changeHandler:)")
    func registerTextFieldViewChange(identifier: AnyHashable, changeHandler: @escaping TextFieldViewCompletion) {
        subscribe(identifier: identifier, changeHandler: changeHandler)
    }

    @available(*, deprecated, renamed: "unsubscribe(identifier:)")
    func unregisterSizeChange(identifier: AnyHashable) {
        unsubscribe(identifier: identifier)
    }
}
