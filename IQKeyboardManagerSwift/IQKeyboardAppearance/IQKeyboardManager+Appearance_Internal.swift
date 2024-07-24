//
//  IQKeyboardManager+Internal.swift
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
import IQTextInputViewNotification
import IQKeyboardCore

@available(iOSApplicationExtension, unavailable)
@MainActor
internal extension IQKeyboardManager {

    func registerActiveStateChangeForAppearance() {
        let observer: IQTextInputViewNotification = self.activeConfiguration.textInputViewObserver
        observer.subscribe(identifier: "keyboardAppearance",
                                             changeHandler: { [weak self] info in
            guard let self = self else { return }
            switch info.event {
            case .beginEditing:
                guard keyboardConfiguration.overrideAppearance,
                      let textInput: any UITextInput = info.textInputView as? (any UITextInput),
                      textInput.keyboardAppearance != keyboardConfiguration.appearance else { return }

                // Setting textField keyboard appearance and reloading inputViews.
                if let textFieldView: UITextField = info.textInputView as? UITextField {
                    textFieldView.keyboardAppearance = keyboardConfiguration.appearance
                } else if let textFieldView: UITextView = info.textInputView as? UITextView {
                    textFieldView.keyboardAppearance = keyboardConfiguration.appearance
                }
                info.textInputView.reloadInputViews()
            case .endEditing:
                break
            }
        })
    }
}
