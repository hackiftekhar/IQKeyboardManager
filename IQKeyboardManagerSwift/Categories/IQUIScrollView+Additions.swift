//
//  IQUIScrollView+Additions.swift
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

// import Foundation - UIKit contains Foundation
import UIKit

@available(iOSApplicationExtension, unavailable)
@objc public extension UIScrollView {

    private struct AssociatedKeys {
        static var shouldIgnoreScrollingAdjustment: Int = 0
        static var shouldIgnoreContentInsetAdjustment: Int = 0
        static var shouldRestoreScrollViewContentOffset: Int = 0
    }

    /**
     If YES, then scrollview will ignore scrolling (simply not scroll it) for adjusting textfield position. Default is NO.
     */
    var shouldIgnoreScrollingAdjustment: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.shouldIgnoreScrollingAdjustment) as? Bool ?? false
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.shouldIgnoreScrollingAdjustment, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /**
     If YES, then scrollview will ignore content inset adjustment (simply not updating it) when keyboard is shown. Default is NO.
     */
    var shouldIgnoreContentInsetAdjustment: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.shouldIgnoreContentInsetAdjustment) as? Bool ?? false
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.shouldIgnoreContentInsetAdjustment, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /**
     To set customized distance from keyboard for textField/textView. Can't be less than zero
     */
    var shouldRestoreScrollViewContentOffset: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.shouldRestoreScrollViewContentOffset) as? Bool ?? false
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.shouldRestoreScrollViewContentOffset, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

@available(iOSApplicationExtension, unavailable)
internal extension UITableView {

    func previousIndexPath(of indexPath: IndexPath) -> IndexPath? {
        var previousRow = indexPath.row - 1
        var previousSection = indexPath.section

        // Fixing indexPath
        if previousRow < 0 {
            previousSection -= 1
            if previousSection >= 0 {
                previousRow = self.numberOfRows(inSection: previousSection) - 1
            }
        }

        if previousRow >= 0, previousSection >= 0 {
            return IndexPath(row: previousRow, section: previousSection)
        } else {
            return nil
        }
    }
}

@available(iOSApplicationExtension, unavailable)
internal extension UICollectionView {

    func previousIndexPath(of indexPath: IndexPath) -> IndexPath? {
        var previousRow = indexPath.row - 1
        var previousSection = indexPath.section

        // Fixing indexPath
        if previousRow < 0 {
            previousSection -= 1
            if previousSection >= 0 {
                previousRow = self.numberOfItems(inSection: previousSection) - 1
            }
        }

        if previousRow >= 0, previousSection >= 0 {
            return IndexPath(item: previousRow, section: previousSection)
        } else {
            return nil
        }
    }
}
