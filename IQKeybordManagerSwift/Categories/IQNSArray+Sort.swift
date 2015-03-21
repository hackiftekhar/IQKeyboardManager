//
//  IQNSArray+Sort.swift
// https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013-14 Iftekhar Qurashi.
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

extension NSArray {
    
    /** @abstract Returns the array by sorting the UIView's by their tag property. */
    func sortedArrayByTag() -> NSArray {
        
        return sortedArrayUsingComparator({ (let view1: AnyObject?, let view2: AnyObject?) -> NSComparisonResult in
            
            if view1?.tag < view2?.tag {
                return .OrderedAscending
            } else if view1?.tag > view2?.tag {
                return .OrderedDescending
            } else {
                return .OrderedSame
            }
        })
    }
    
    /** @abstract Returns the array by sorting the UIView's by their tag property. */
    func sortedArrayByPosition() -> NSArray {
        
        return sortedArrayUsingComparator({ (let view1: AnyObject?, let view2: AnyObject?) -> NSComparisonResult in
            
            if view1?.y < view2?.y {
                return .OrderedAscending
            } else if view1?.y > view2?.y {
                return .OrderedDescending
            } else if view1?.x < view2?.x {   //Else both y are same so checking for x positions
                return .OrderedAscending
            } else if view1?.x > view2?.x {
                return .OrderedDescending
            } else {
                return .OrderedSame
            }
        })
    }
}