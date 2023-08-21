//
//  IQTextFieldViewListener.swift
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
public class IQTextFieldViewListener {

    private var textFieldViewObservers: [AnyHashable: TextFieldViewCompletion] = [:]

    private var textFieldViewInfo: IQTextFieldViewInfo?

    public var textFieldView: UIView? {
        return textFieldViewInfo?.textFieldView
    }

    public init() {
        textFieldViewInfo = nil
        //  Registering for keyboard notification.
        NotificationCenter.default.addObserver(self, selector: #selector(self.didBeginEditing(_:)), name: UITextField.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didEndEditing(_:)), name: UITextField.textDidEndEditingNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.didBeginEditing(_:)), name: UITextView.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didEndEditing(_:)), name: UITextView.textDidEndEditingNotification, object: nil)
    }

    @objc private func didBeginEditing(_ notification: Notification) {
        let info: IQTextFieldViewInfo? = IQTextFieldViewInfo(notification: notification, name: .beginEditing)

        if let info: IQTextFieldViewInfo = info, textFieldViewInfo != info {
            textFieldViewInfo = info
            notifyChange(info: info)
        }
    }

    @objc private func didEndEditing(_ notification: Notification) {
#if swift(>=5.7)
        let info: IQTextFieldViewInfo? = IQTextFieldViewInfo(notification: notification, name: .endEditing)

        if #available(iOS 16.0, *),
           let textView: UITextView = info?.textFieldView as? UITextView,
           textView.isFindInteractionEnabled {
            // Not setting it nil, because it may be doing find interaction.
            // As of now, here textView.findInteraction?.isFindNavigatorVisible returns false
            // So there is no way to detect if this is dismissed due to findInteraction
        } else if let info: IQTextFieldViewInfo = info, textFieldViewInfo != info {
            textFieldViewInfo = nil
            notifyChange(info: info)
        }
#else
        if let info: IQTextFieldViewInfo = info, textFieldViewInfo != info {
            textFieldViewInfo = nil
            notifyChange(info: info)
        }
#endif
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

    private func notifyChange(info: IQTextFieldViewInfo) {

        for block in textFieldViewObservers.values {
            block(info)
        }
    }
}