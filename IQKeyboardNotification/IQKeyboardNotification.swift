//
//  IQKeyboardNotification.swift
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
import Combine

@available(iOSApplicationExtension, unavailable)
@MainActor
public class IQKeyboardNotification {

    private var cancellable: Set<AnyCancellable> = []

    private var eventObservers: [IQKeyboardInfo.Event: [AnyHashable: SizeCompletion]] = [:]

    public private(set) var keyboardInfo: IQKeyboardInfo {
        didSet {
            guard keyboardInfo != oldValue else { return }
            sendKeyboardInfo(info: keyboardInfo)
        }
    }

    public var isVisible: Bool {
        keyboardInfo.isVisible
    }

    public var frame: CGRect {
        keyboardInfo.endFrame
    }

    public init() {
        keyboardInfo = IQKeyboardInfo(notification: nil, event: .didHide)
        //  Registering for keyboard notification.

        for event in IQKeyboardInfo.Event.allCases {
            NotificationCenter.default.publisher(for: event.notification)
                .map({ IQKeyboardInfo(notification: $0, event: event) })
                .assign(to: \.keyboardInfo, on: self)
                .store(in: &cancellable)
        }
    }

    public func animate(alongsideTransition transition: @escaping () -> Void, completion: (() -> Void)? = nil) {
        keyboardInfo.animate(alongsideTransition: transition, completion: completion)
    }
}

@available(iOSApplicationExtension, unavailable)
public extension IQKeyboardNotification {

    typealias SizeCompletion = (_ event: IQKeyboardInfo.Event, _ size: CGSize) -> Void

    func subscribe(events: [IQKeyboardInfo.Event] = IQKeyboardInfo.Event.allCases,
                   identifier: AnyHashable, changeHandler: @escaping SizeCompletion) {

//        private var eventObservers: [IQKeyboardInfo.Event: [AnyHashable: SizeCompletion]] = [:]

        for event in events {
            var existingObservers: [AnyHashable: SizeCompletion] = eventObservers[event] ?? [:]
            existingObservers[identifier] = changeHandler
            eventObservers[event] = existingObservers
        }
    }

    func unsubscribe(events: [IQKeyboardInfo.Event] = IQKeyboardInfo.Event.allCases, identifier: AnyHashable) {

        for event in events {
            var existingObservers: [AnyHashable: SizeCompletion] = eventObservers[event] ?? [:]
            existingObservers[identifier] = nil
            eventObservers[event] = existingObservers
        }
    }

    private func sendKeyboardInfo(info: IQKeyboardInfo) {

        guard let observers = eventObservers[info.event], !observers.isEmpty else { return }

        let size: CGSize = info.endFrame.size

        for block in observers.values {
            block(info.event, size)
        }
    }
}
