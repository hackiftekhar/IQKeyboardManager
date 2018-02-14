//
//  IQUIViewController+Additions.swift
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

import UIKit


private var kIQLayoutGuideConstraint = "kIQLayoutGuideConstraint"
private var kShouldMoveWithNegativePosition = "kShouldMoveWithNegativePosition" 


public extension UIViewController {

    /**
    To set customized distance from keyboard for textField/textView. Can't be less than zero
     
     @deprecated    Library is internally handling Safe Area (If you are using Safe Area from Xcode9 and iOS11) and there is no need to do any tweak if you already migrated to use Safe Area
    */
    @available(iOS, deprecated: 11.0)
    @IBOutlet public var IQLayoutGuideConstraint: NSLayoutConstraint? {
        get {
            
            return objc_getAssociatedObject(self, &kIQLayoutGuideConstraint) as? NSLayoutConstraint
        }

        set(newValue) {
            objc_setAssociatedObject(self, &kIQLayoutGuideConstraint, newValue,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /**
     If you don't want to adjust the frame in the case that the textField already positioned above the keyboard, set shouldRestoreScrollViewContentOffset to true inside the viewController
     */
    public var shouldMoveWithNegativePosition: Bool? {
        get {
            return objc_getAssociatedObject(self, &kShouldMoveWithNegativePosition) as? Bool ?? false
        }
        
        set(newValue) {
            objc_setAssociatedObject(self, &kShouldMoveWithNegativePosition, newValue,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
