//
//  IQTextViewConfiguration.swift
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
struct IQTextViewConfiguration {
    internal let textView: UITextView
    internal let startingContentInsets: UIEdgeInsets
    internal let startingScrollIndicatorInsets: UIEdgeInsets

    init?(textView: UITextView?) {
        guard let textView: UITextView = textView else { return nil }
        self.textView = textView
        startingContentInsets = textView.contentInset
#if swift(>=5.1)
        if #available(iOS 11.1, *) {
            startingScrollIndicatorInsets = textView.verticalScrollIndicatorInsets
        } else {
            startingScrollIndicatorInsets = textView.scrollIndicatorInsets
        }
#else
        startingScrollIndicatorInsets = textView.scrollIndicatorInsets
#endif
    }

    func restore() {
        if textView.contentInset != self.startingContentInsets {
            textView.contentInset = self.startingContentInsets
        }

#if swift(>=5.1)
        if #available(iOS 11.1, *) {
            if textView.verticalScrollIndicatorInsets != self.startingScrollIndicatorInsets {
                textView.verticalScrollIndicatorInsets = self.startingScrollIndicatorInsets
            }
        } else {
            if textView.scrollIndicatorInsets != self.startingScrollIndicatorInsets {
                textView.scrollIndicatorInsets = self.startingScrollIndicatorInsets
            }
        }
#else
        if textView.scrollIndicatorInsets != self.startingScrollIndicatorInsets {
            textView.scrollIndicatorInsets = self.startingScrollIndicatorInsets
        }
#endif
    }
}
