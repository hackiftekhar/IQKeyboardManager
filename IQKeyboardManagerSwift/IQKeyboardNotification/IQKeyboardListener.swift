//
//  IQKeyboardListener.swift
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

@available(iOSApplicationExtension, unavailable)
// swiftlint:disable line_length
@available(*, deprecated, message: "Please use `IQKeyboardNotification` independently from https://github.com/hackiftekhar/IQKeyboardNotification. IQKeyboardListener will be removed from this library in future release.")
// swiftlint:enable line_length
@MainActor
@objc public final class IQKeyboardListener: NSObject {

    private var storage: Set<AnyCancellable> = []

    private var eventObservers: [AnyHashable: SizeCompletion] = [:]

    public private(set) var oldKeyboardInfo: IQKeyboardInfoDeprecated

    public private(set) var keyboardInfo: IQKeyboardInfoDeprecated {
        didSet {
            guard keyboardInfo != oldValue else { return }
            oldKeyboardInfo = oldValue
            sendKeyboardInfo(info: keyboardInfo)
        }
    }

    @objc public var isVisible: Bool {
        keyboardInfo.isVisible
    }

    @objc public var frame: CGRect {
        keyboardInfo.endFrame
    }

    @objc public override init() {
        keyboardInfo = IQKeyboardInfoDeprecated(notification: nil, event: .didHide)
        oldKeyboardInfo = keyboardInfo

        super.init()

        //  Registering for keyboard notification.
        for event in IQKeyboardInfoDeprecated.Event.allCases {
            NotificationCenter.default.publisher(for: event.notification)
                .map({ IQKeyboardInfoDeprecated(notification: $0, event: event) })
                .assign(to: \.keyboardInfo, on: self)
                .store(in: &storage)
        }
    }

    @objc public func animate(alongsideTransition transition: @escaping () -> Void, completion: (() -> Void)? = nil) {
        keyboardInfo.animate(alongsideTransition: transition, completion: completion)
    }

    public typealias SizeCompletion = (_ event: IQKeyboardInfoDeprecated.Event, _ endFrame: CGRect) -> Void

    @objc public func subscribe(identifier: AnyHashable, changeHandler: @escaping SizeCompletion) {
        eventObservers[identifier] = changeHandler
    }

    @objc public func unsubscribe(identifier: AnyHashable) {
        eventObservers[identifier] = nil
    }

    @objc public func isSubscribed(identifier: AnyHashable) -> Bool {
        eventObservers[identifier] != nil
    }

    private func sendKeyboardInfo(info: IQKeyboardInfoDeprecated) {

        let endFrame: CGRect = info.endFrame

        for block in eventObservers.values {
            block(info.event, endFrame)
        }
    }

    // MARK: Deprecated

    @available(*, deprecated, renamed: "isVisible")
    var keyboardShowing: Bool { isVisible }

    @available(*, deprecated, renamed: "subscribe(identifier:changeHandler:)")
    @objc func registerSizeChange(identifier: AnyHashable, changeHandler: @escaping SizeCompletion) {
        subscribe(identifier: identifier, changeHandler: changeHandler)
    }

    @available(*, deprecated, renamed: "unsubscribe(identifier:)")
    @objc func unregisterSizeChange(identifier: AnyHashable) {
        unsubscribe(identifier: identifier)
    }
}
