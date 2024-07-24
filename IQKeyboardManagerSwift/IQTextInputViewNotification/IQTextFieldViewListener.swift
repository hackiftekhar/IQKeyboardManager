//
//  IQTextFieldViewListener.swift
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
@MainActor
public class IQTextFieldViewListener {

    private var textFieldViewObservers: [AnyHashable: TextFieldViewCompletion] = [:]

#if swift(>=5.7)
    private(set) var lastTextFieldViewInfo: IQTextFieldViewInfo?
#endif

    private(set) var textFieldViewInfo: IQTextFieldViewInfo?

    public var textFieldView: UIView? {
        return textFieldViewInfo?.textFieldView
    }

    public init() {
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
                                                                  name: .beginEditing) else {
            return
        }

#if swift(>=5.7)

        if #available(iOS 16.0, *),
           let lastTextFieldViewInfo = lastTextFieldViewInfo,
           let textView: UITextView = lastTextFieldViewInfo.textFieldView as? UITextView,
           textView.findInteraction?.isFindNavigatorVisible == true {
            // // This means the this didBeginEditing call comes due to find interaction
            textFieldViewInfo = lastTextFieldViewInfo
            sendEvent(info: lastTextFieldViewInfo)
        } else if textFieldViewInfo != info {
            textFieldViewInfo = info
            lastTextFieldViewInfo = nil
            sendEvent(info: info)
        } else {
            lastTextFieldViewInfo = nil
        }
#else
        if textFieldViewInfo != info {
            textFieldViewInfo = info
            sendEvent(info: info)
        }
#endif
    }

    @objc private func didEndEditing(_ notification: Notification) {
        guard let info: IQTextFieldViewInfo = IQTextFieldViewInfo(notification: notification, name: .endEditing) else {
            return
        }

        if textFieldViewInfo != info {
#if swift(>=5.7)
            if #available(iOS 16.0, *),
               let textView: UITextView = info.textFieldView as? UITextView,
                textView.isFindInteractionEnabled {
                lastTextFieldViewInfo = textFieldViewInfo
            } else {
                lastTextFieldViewInfo = nil
            }
#endif
            textFieldViewInfo = info
            sendEvent(info: info)
            textFieldViewInfo = nil
        }
    }
}

@available(iOSApplicationExtension, unavailable)
public extension IQTextFieldViewListener {

    typealias TextFieldViewCompletion = (_ info: IQTextFieldViewInfo) -> Void

    func registerTextFieldViewChange(identifier: AnyHashable, changeHandler: @escaping TextFieldViewCompletion) {
        textFieldViewObservers[identifier] = changeHandler
    }

    func unregisterSizeChange(identifier: AnyHashable) {
        textFieldViewObservers[identifier] = nil
    }

    private func sendEvent(info: IQTextFieldViewInfo) {

        for block in textFieldViewObservers.values {
            block(info)
        }
    }
}
