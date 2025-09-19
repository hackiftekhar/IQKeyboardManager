//
//  IQKeyboardToolbarManager+TraitCollectionFix.swift
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
@objc public extension IQKeyboardManager {
    
    /// Enables automatic trait collection preservation for delegate methods.
    /// When enabled, UITraitCollection.current will return correct values 
    /// in textFieldDidEndEditing and other delegate methods when using 
    /// toolbar Done button.
    ///
    /// This property addresses an issue where UITraitCollection.current.userInterfaceStyle
    /// returns incorrect values when the Done button is pressed vs the Return key.
    ///
    /// Default is false for backward compatibility.
    var preserveTraitCollectionInDelegates: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.preserveTraitCollection) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.preserveTraitCollection, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private struct AssociatedKeys {
        static var preserveTraitCollection: UInt8 = 0
    }
}

@available(iOSApplicationExtension, unavailable)
@MainActor
@objc public extension UIViewController {
    
    /// Performs a block with the view controller's trait collection as the current trait collection.
    /// This ensures UITraitCollection.current returns correct values during block execution.
    ///
    /// Use this method in delegate methods like textFieldDidEndEditing when you need 
    /// reliable access to UITraitCollection.current.userInterfaceStyle.
    ///
    /// Example usage:
    /// ```swift
    /// func textFieldDidEndEditing(_ textField: UITextField) {
    ///     self.performWithCurrentTraitCollection {
    ///         let isDark = UITraitCollection.current.userInterfaceStyle == .dark
    ///         // isDark now has the correct value
    ///     }
    /// }
    /// ```
    func performWithCurrentTraitCollection(_ block: () -> Void) {
        self.traitCollection.performAsCurrentTraitCollection {
            block()
        }
    }
}