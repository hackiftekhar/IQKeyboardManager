//
//  IQKeyboardListener.swift
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
public class IQKeyboardListener {

    private var sizeObservers: [AnyHashable: SizeCompletion] = [:]

    private(set) var keyboardInfo: IQKeyboardInfo {
        didSet {
            if keyboardInfo != oldValue {
                sendEvent()
            }
        }
    }

    public var keyboardShowing: Bool {
        keyboardInfo.keyboardShowing
    }

    public var frame: CGRect {
        keyboardInfo.frame
    }

    public init() {
        keyboardInfo = IQKeyboardInfo(notification: nil, name: .didHide)
        //  Registering for keyboard notification.
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(_:)),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide(_:)),
                                               name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChangeFrame(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidChangeFrame(_:)),
                                               name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        keyboardInfo = IQKeyboardInfo(notification: notification, name: .willShow)
    }

    @objc private func keyboardDidShow(_ notification: Notification) {
        keyboardInfo = IQKeyboardInfo(notification: notification, name: .didShow)
    }

    @objc private func keyboardWillHide(_ notification: Notification?) {
        keyboardInfo = IQKeyboardInfo(notification: notification, name: .willHide)
    }

    @objc private func keyboardDidHide(_ notification: Notification) {
        keyboardInfo = IQKeyboardInfo(notification: notification, name: .didHide)
    }

    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        keyboardInfo = IQKeyboardInfo(notification: notification, name: .willChangeFrame)
    }

    @objc private func keyboardDidChangeFrame(_ notification: Notification) {
        keyboardInfo = IQKeyboardInfo(notification: notification, name: .didChangeFrame)
    }

    public func animate(alongsideTransition transition: @escaping () -> Void, completion: (() -> Void)? = nil) {
        keyboardInfo.animate(alongsideTransition: transition, completion: completion)
    }
}

@available(iOSApplicationExtension, unavailable)
public extension IQKeyboardListener {

    typealias SizeCompletion = (_ name: IQKeyboardInfo.Name, _ size: CGSize) -> Void

    func registerSizeChange(identifier: AnyHashable, changeHandler: @escaping SizeCompletion) {
        sizeObservers[identifier] = changeHandler
    }

    func unregisterSizeChange(identifier: AnyHashable) {
        sizeObservers[identifier] = nil
    }

    private func sendEvent() {

        let size: CGSize = keyboardInfo.frame.size

        for block in sizeObservers.values {
            block(keyboardInfo.name, size)
        }
    }
}
