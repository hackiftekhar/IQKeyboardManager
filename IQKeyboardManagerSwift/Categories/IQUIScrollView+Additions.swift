//
//  IQUIScrollView+Additions.swift
// https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013-16 Iftekhar Qurashi.
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
import UIKit

private var kIQShouldIgnoreScrollingAdjustment      = "kIQShouldIgnoreScrollingAdjustment"
private var kIQShouldIgnoreContentInsetAdjustment   = "kIQShouldIgnoreContentInsetAdjustment"
private var kIQShouldRestoreScrollViewContentOffset = "kIQShouldRestoreScrollViewContentOffset"

@objc public extension UIScrollView {
    
    /**
     If YES, then scrollview will ignore scrolling (simply not scroll it) for adjusting textfield position. Default is NO.
     */
    @objc var shouldIgnoreScrollingAdjustment: Bool {
        get {
            
            if let aValue = objc_getAssociatedObject(self, &kIQShouldIgnoreScrollingAdjustment) as? Bool {
                return aValue
            } else {
                return false
            }
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kIQShouldIgnoreScrollingAdjustment, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /**
     If YES, then scrollview will ignore content inset adjustment (simply not updating it) when keyboard is shown. Default is NO.
     */
    @objc var shouldIgnoreContentInsetAdjustment: Bool {
        get {
            
            if let aValue = objc_getAssociatedObject(self, &kIQShouldIgnoreContentInsetAdjustment) as? Bool {
                return aValue
            } else {
                return false
            }
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kIQShouldIgnoreContentInsetAdjustment, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /**
     To set customized distance from keyboard for textField/textView. Can't be less than zero
     */
    @objc var shouldRestoreScrollViewContentOffset: Bool {
        get {
            
            if let aValue = objc_getAssociatedObject(self, &kIQShouldRestoreScrollViewContentOffset) as? Bool {
                return aValue
            } else {
                return false
            }
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kIQShouldRestoreScrollViewContentOffset, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

internal extension UITableView {
    
    func previousIndexPath(of indexPath: IndexPath) -> IndexPath? {
        var previousRow = indexPath.row - 1
        var previousSection = indexPath.section
        
        //Fixing indexPath
        if previousRow < 0 {
            previousSection -= 1
            
            if previousSection >= 0 {
                previousRow = self.numberOfRows(inSection: previousSection) - 1
            }
        }
        
        if previousRow >= 0 && previousSection >= 0 {
            return IndexPath(row: previousRow, section: previousSection)
        } else {
            return nil
        }
    }
}

internal extension UICollectionView {
    
    func previousIndexPath(of indexPath: IndexPath) -> IndexPath? {
        var previousRow = indexPath.row - 1
        var previousSection = indexPath.section
        
        //Fixing indexPath
        if previousRow < 0 {
            previousSection -= 1
            
            if previousSection >= 0 {
                previousRow = self.numberOfItems(inSection: previousSection) - 1
            }
        }
        
        if previousRow >= 0 && previousSection >= 0 {
            return IndexPath(item: previousRow, section: previousSection)
        } else {
            return nil
        }
    }
}
