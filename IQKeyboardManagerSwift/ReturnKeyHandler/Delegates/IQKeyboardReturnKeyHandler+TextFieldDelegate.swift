//
//  IQKeyboardReturnKeyHandler+TextFieldDelegate.swift
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

// MARK: UITextFieldDelegate
@available(iOSApplicationExtension, unavailable)
extension IQKeyboardReturnKeyHandler: UITextFieldDelegate {

    @objc public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {

        if delegate == nil {

            if let unwrapDelegate: any UITextFieldDelegate = textFieldViewCachedInfo(textField)?.textFieldDelegate {
                if unwrapDelegate.responds(to: #selector((any UITextFieldDelegate).textFieldShouldBeginEditing(_:))) {
                    return unwrapDelegate.textFieldShouldBeginEditing?(textField) ?? false
                }
            }
        }

        return true
    }

    @objc public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {

        if delegate == nil {

            if let unwrapDelegate: any UITextFieldDelegate = textFieldViewCachedInfo(textField)?.textFieldDelegate {
                if unwrapDelegate.responds(to: #selector((any UITextFieldDelegate).textFieldShouldEndEditing(_:))) {
                    return unwrapDelegate.textFieldShouldEndEditing?(textField) ?? false
                }
            }
        }

        return true
    }

    @objc public func textFieldDidBeginEditing(_ textField: UITextField) {
        updateReturnKeyTypeOnTextField(textField)

        var aDelegate: (any UITextFieldDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextFieldViewInfoModel = textFieldViewCachedInfo(textField) {
                aDelegate = model.textFieldDelegate
            }
        }

        aDelegate?.textFieldDidBeginEditing?(textField)
    }

    @objc public func textFieldDidEndEditing(_ textField: UITextField) {

        var aDelegate: (any UITextFieldDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextFieldViewInfoModel = textFieldViewCachedInfo(textField) {
                aDelegate = model.textFieldDelegate
            }
        }

        aDelegate?.textFieldDidEndEditing?(textField)
    }

    @objc public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {

        var aDelegate: (any UITextFieldDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextFieldViewInfoModel = textFieldViewCachedInfo(textField) {
                aDelegate = model.textFieldDelegate
            }
        }

        aDelegate?.textFieldDidEndEditing?(textField, reason: reason)
    }

    @objc public func textField(_ textField: UITextField,
                                shouldChangeCharactersIn range: NSRange,
                                replacementString string: String) -> Bool {

        if delegate == nil {

            if let unwrapDelegate: any UITextFieldDelegate = textFieldViewCachedInfo(textField)?.textFieldDelegate {
                let selector: Selector = #selector((any UITextFieldDelegate).textField(_:shouldChangeCharactersIn:
                                                                                    replacementString:))
                if unwrapDelegate.responds(to: selector) {
                    return unwrapDelegate.textField?(textField,
                                                     shouldChangeCharactersIn: range,
                                                     replacementString: string) ?? false
                }
            }
        }
        return true
    }

    @objc public func textFieldShouldClear(_ textField: UITextField) -> Bool {

        if delegate == nil {

            if let unwrapDelegate: any UITextFieldDelegate = textFieldViewCachedInfo(textField)?.textFieldDelegate {
                if unwrapDelegate.responds(to: #selector((any UITextFieldDelegate).textFieldShouldClear(_:))) {
                    return unwrapDelegate.textFieldShouldClear?(textField) ?? false
                }
            }
        }

        return true
    }

    @objc public func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        var isReturn: Bool = true

        if delegate == nil {

            if let unwrapDelegate: any UITextFieldDelegate = textFieldViewCachedInfo(textField)?.textFieldDelegate {
                if unwrapDelegate.responds(to: #selector((any UITextFieldDelegate).textFieldShouldReturn(_:))) {
                    isReturn = unwrapDelegate.textFieldShouldReturn?(textField) ?? false
                }
            }
        }

        if isReturn {
            goToNextResponderOrResign(textField)
            return true
        } else {
            return goToNextResponderOrResign(textField)
        }
    }
}
