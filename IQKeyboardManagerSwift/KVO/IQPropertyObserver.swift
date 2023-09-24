//
//  IQPropertyObserver.swift
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

import Foundation

class IQPropertyObserver<Subject, Value> where Subject: NSObject, Value: Equatable {
    let object: Subject
    private var observation: NSKeyValueObservation?
    let debounce: TimeInterval?
    let changeHandler: (_ old: Value?, _ new: Value?) -> Void

    var lastValue: Value?
    var timer: Timer?

    init(object: Subject,
         keyPath: KeyPath<Subject, Value>,
         debounce: TimeInterval? = nil,
         changeHandler: @escaping ((_ old: Value?, _ new: Value?) -> Void)) {
        self.object = object
        self.debounce = debounce
        self.changeHandler = changeHandler

        observation = object.observe(keyPath,
                                     options: [.old, .new],
                                     changeHandler: { [weak self] _, change in
            if change.oldValue != change.newValue {
                self?.send(change.oldValue, change.newValue)
            }
        })
    }

    private func send(_ old: Value?, _ new: Value?) {
        guard let debounce = debounce else {
            timer?.invalidate()
            lastValue = new
            changeHandler(old, new)
            return
        }
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: debounce, repeats: false, block: { [weak self] _ in
            if self?.lastValue != new {
                self?.changeHandler(old, new)
            }
        })
    }

    func invalidate() {
        observation?.invalidate()
        observation = nil
    }
}
