//
//  IQBarButtonItemConfiguration.swift
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

/**
 IQBarButtonItemConfiguration for creating toolbar with bar button items
 */
//@available(iOSApplicationExtension, unavailable)
//@objc public final class IQBarButtonItemConfiguration: NSObject {
//
//    @objc public init(barButtonSystemItem: UIBarButtonItem.SystemItem) {
//        self.systemItem = barButtonSystemItem
//        self.image = nil
//        self.title = nil
//        super.init()
//    }
//
//    @objc public init(image: UIImage) {
//        self.systemItem = nil
//        self.image = image
//        self.title = nil
//        super.init()
//    }
//
//    @objc public init(title: String) {
//        self.systemItem = nil
//        self.image = nil
//        self.title = title
//        super.init()
//    }
//
//    public let systemItem: UIBarButtonItem.SystemItem?    // System Item to be used to instantiate bar button.
//
//    @objc public let image: UIImage?    // Image to show on bar button item if it's not a system item.
//
//    @objc public let title: String?     // Title to show on bar button item if it's not a system item.
//
//    @objc internal var action: Selector?  // action for bar button item. Usually 'doneAction:(IQBarButtonItem*)item'.
//}

@available(iOSApplicationExtension, unavailable)
@objc public final class IQBarButtonItemConfiguration: NSObject {

    @objc public init(barButtonSystemItem: UIBarButtonItem.SystemItem, action: Selector) {
        self.barButtonSystemItem = barButtonSystemItem
        self.image = nil
        self.title = nil
        self.action = action
        super.init()
    }

    @objc public init(image: UIImage, action: Selector) {
        self.barButtonSystemItem = nil
        self.image = image
        self.title = nil
        self.action = action
        super.init()
    }

    @objc public init(title: String, action: Selector) {
        self.barButtonSystemItem = nil
        self.image = nil
        self.title = title
        self.action = action
        super.init()
    }

    public let barButtonSystemItem: UIBarButtonItem.SystemItem?    // System Item to be used to instantiate bar button.

    @objc public let image: UIImage?    // Image to show on bar button item if it's not a system item.

    @objc public let title: String?     // Title to show on bar button item if it's not a system item.

    @objc public let action: Selector?  // action for bar button item. Usually 'doneAction:(IQBarButtonItem*)item'.
}
