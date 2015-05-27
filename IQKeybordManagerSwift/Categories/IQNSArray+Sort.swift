//
//  IQNSArray+Sort.swift
// https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013-15 Iftekhar Qurashi.
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

/**
UIView.subviews sorting category.
*/
extension NSArray {
    
    ///--------------
    /// MARK: Sorting
    ///--------------
    
    /**
    Returns the array by sorting the UIView's by their tag property.
    */
    func sortedArrayByTag() -> NSArray {
        
        return sortedArrayUsingComparator({ (let obj1: AnyObject?, let obj2: AnyObject?) -> NSComparisonResult in
            
            let view1 = obj1 as! UIView
            let view2 = obj2 as! UIView
            
            if view1.tag < view2.tag {
                return .OrderedAscending
            } else if view1.tag > view2.tag {
                return .OrderedDescending
            } else {
                return .OrderedSame
            }
        })
    }
    
    /**
    Returns the array by sorting the UIView's by their tag property.
    */
    func sortedArrayByPosition() -> NSArray {
        
        return sortedArrayUsingComparator({ (let obj1: AnyObject?, let obj2: AnyObject?) -> NSComparisonResult in
            
            let view1 = obj1 as! UIView
            let view2 = obj2 as! UIView
            
            let x1 = CGRectGetMinX(view1.frame)
            let y1 = CGRectGetMinY(view1.frame)
            let x2 = CGRectGetMinX(view2.frame)
            let y2 = CGRectGetMinY(view2.frame)
            
            if y1 < y2 {
                return .OrderedAscending
            } else if y1 > y2 {
                return .OrderedDescending
            } else if x1 < x2 {    //Else both y are same so checking for x positions
                
                return .OrderedAscending
            } else if x1 > x2 {
                return .OrderedDescending
            } else {
                return .OrderedSame
            }
        })
    }
}

