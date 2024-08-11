//
//  IQScrollViewConfiguration.swift
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
import IQKeyboardCore

@available(iOSApplicationExtension, unavailable)
@MainActor
internal struct IQScrollViewConfiguration {
    let scrollView: UIScrollView
    let startingContentOffset: CGPoint
    let startingScrollIndicatorInsets: UIEdgeInsets
    let startingContentInset: UIEdgeInsets

    private let canRestoreContentOffset: Bool

    init(scrollView: UIScrollView, canRestoreContentOffset: Bool) {
        self.scrollView = scrollView
        self.canRestoreContentOffset = canRestoreContentOffset

        startingContentOffset = scrollView.contentOffset
        startingContentInset = scrollView.contentInset
        startingScrollIndicatorInsets = scrollView.verticalScrollIndicatorInsets
    }

    var hasChanged: Bool {
        if scrollView.contentInset != self.startingContentInset {
            return true
        }

        if canRestoreContentOffset,
           scrollView.iq.restoreContentOffset,
           !scrollView.contentOffset.equalTo(startingContentOffset) {
            return true
        }
        return false
    }

    @discardableResult
    func restore(for textInputView: (some IQTextInputView)?) -> Bool {
        var success: Bool = false

        if scrollView.contentInset != self.startingContentInset {
            scrollView.contentInset = self.startingContentInset
            scrollView.layoutIfNeeded() // (Bug ID: #1996)
            success = true
        }

        if scrollView.verticalScrollIndicatorInsets != self.startingScrollIndicatorInsets {
            scrollView.verticalScrollIndicatorInsets = self.startingScrollIndicatorInsets
        }

        if canRestoreContentOffset,
           scrollView.iq.restoreContentOffset,
           !scrollView.contentOffset.equalTo(startingContentOffset) {

            //  (Bug ID: #1365, #1508, #1541)
            let stackView: UIStackView?
            if let textInputView: UIView = textInputView {
                stackView = textInputView.iq.superviewOf(type: UIStackView.self,
                                                         belowView: scrollView)
            } else {
                stackView = nil
            }
            // (Bug ID: #1901, #1996)
            let animatedContentOffset: Bool = stackView != nil ||
            scrollView is UICollectionView ||
            scrollView is UITableView

            if animatedContentOffset {
                scrollView.setContentOffset(startingContentOffset, animated: UIView.areAnimationsEnabled)
            } else {
                scrollView.contentOffset = startingContentOffset
            }
            success = true
        }

        return success
    }
}
