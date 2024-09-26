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
import Combine
import IQKeyboardCore

@available(iOSApplicationExtension, unavailable)
// swiftlint:disable:next line_length
@available(*, deprecated, message: "Please use `IQTextInputViewNotification` independently from https://github.com/hackiftekhar/IQTextInputViewNotification. IQTextFieldViewListener will be removed from this library in future release.")
@MainActor
@objcMembers public class IQTextFieldViewListener: NSObject {

    private var storage: Set<AnyCancellable> = []

    private var textInputViewObservers: [AnyHashable: TextInputViewCompletion] = [:]

    private var findInteractionTextInputViewInfo: IQTextFieldViewInfo?

    public private(set) var textInputViewInfo: IQTextFieldViewInfo?

    public var textInputView: (some IQTextInputView)? {
        return textInputViewInfo?.textInputView
    }

    public override init() {
        super.init()

        //  Registering for TextInputView notification.
        do {
            let beginEditingNotificationNames: [Notification.Name] = [
                UITextField.textDidBeginEditingNotification,
                UITextView.textDidBeginEditingNotification
            ]

            for notificationName in beginEditingNotificationNames {
                NotificationCenter.default.publisher(for: notificationName)
                    .compactMap({ IQTextFieldViewInfo(notification: $0, event: .beginEditing) })
                    .sink(receiveValue: { [weak self] info in
                        guard let self = self else { return }
                        self.didBeginEditing(info: info)
                    })
                    .store(in: &storage)
            }
        }

        do {
            let endEditingNotificationNames: [Notification.Name] = [
                UITextField.textDidEndEditingNotification,
                UITextView.textDidEndEditingNotification
            ]

            for notificationName in endEditingNotificationNames {
                NotificationCenter.default.publisher(for: notificationName)
                    .compactMap({ IQTextFieldViewInfo(notification: $0, event: .endEditing) })
                    .sink(receiveValue: { [weak self] info in
                        guard let self = self else { return }
                        self.didEndEditing(info: info)
                    })
                    .store(in: &storage)
            }
        }
    }

    private func didBeginEditing(info: IQTextFieldViewInfo) {

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

    private func didEndEditing(info: IQTextFieldViewInfo) {

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

    public typealias TextInputViewCompletion = (_ info: IQTextFieldViewInfo) -> Void

    public func subscribe(identifier: AnyHashable, changeHandler: @escaping TextInputViewCompletion) {
        textInputViewObservers[identifier] = changeHandler

        if let textInputViewInfo = textInputViewInfo {
            changeHandler(textInputViewInfo)
        }
    }

    public func isSubscribed(identifier: AnyHashable) -> Bool {
        return textInputViewObservers[identifier] != nil
    }

    public func unsubscribe(identifier: AnyHashable) {
        textInputViewObservers[identifier] = nil
    }

    private func sendEvent(info: IQTextFieldViewInfo) {

        for block in textInputViewObservers.values {
            block(info)
        }
    }

    // MARK: Deprecated

    @available(*, deprecated, renamed: "textInputViewInfo")
    public var textFieldViewInfo: IQTextFieldViewInfo? { textInputViewInfo }

    @available(*, deprecated, renamed: "textInputView")
    public var textFieldView: (some IQTextInputView)? { textInputView }

    @available(*, deprecated, renamed: "subscribe(identifier:changeHandler:)")
    public func registerTextFieldViewChange(identifier: AnyHashable, changeHandler: @escaping TextInputViewCompletion) {
        subscribe(identifier: identifier, changeHandler: changeHandler)
    }

    @available(*, deprecated, renamed: "unsubscribe(identifier:)")
    public func unregisterSizeChange(identifier: AnyHashable) {
        unsubscribe(identifier: identifier)
    }
}
