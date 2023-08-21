//
//  IQScrollViewConfiguration.swift
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
struct IQScrollViewConfiguration {
    internal let scrollView: UIScrollView
    internal let startingContentOffset: CGPoint
    internal let startingScrollIndicatorInsets: UIEdgeInsets
    internal let startingContentInsets: UIEdgeInsets

    init?(scrollView: UIScrollView?) {
        guard let scrollView = scrollView else { return nil }
        self.scrollView = scrollView
        startingContentOffset = scrollView.contentOffset
        startingContentInsets = scrollView.contentInset

#if swift(>=5.1)
        if #available(iOS 11.1, *) {
            startingScrollIndicatorInsets = scrollView.verticalScrollIndicatorInsets
        } else {
            startingScrollIndicatorInsets = scrollView.scrollIndicatorInsets
        }
#else
        startingScrollIndicatorInsets = scrollView.scrollIndicatorInsets
#endif
    }

    func restore(for textFieldView: UIView?) {
        if scrollView.contentInset != self.startingContentInsets {
            scrollView.contentInset = self.startingContentInsets
        }

#if swift(>=5.1)
        if #available(iOS 11.1, *) {
            if scrollView.verticalScrollIndicatorInsets != self.startingScrollIndicatorInsets {
                scrollView.verticalScrollIndicatorInsets = self.startingScrollIndicatorInsets
            }
        } else {
            if scrollView.scrollIndicatorInsets != self.startingScrollIndicatorInsets {
                scrollView.scrollIndicatorInsets = self.startingScrollIndicatorInsets
            }
        }
#else
        if scrollView.scrollIndicatorInsets != self.startingScrollIndicatorInsets {
            scrollView.scrollIndicatorInsets = self.startingScrollIndicatorInsets
        }
#endif

        if scrollView.shouldRestoreScrollViewContentOffset, !scrollView.contentOffset.equalTo(startingContentOffset) {
            let animatedContentOffset = textFieldView?.superviewOfClassType(UIStackView.self, belowView: scrollView) != nil  //  (Bug ID: #1365, #1508, #1541)

            if animatedContentOffset {
                scrollView.setContentOffset(startingContentOffset, animated: UIView.areAnimationsEnabled)
            } else {
                scrollView.contentOffset = startingContentOffset
            }
        }
    }
}

