//
//  IQBarButtonItemConfiguration.swift
//  https://github.com/hackiftekhar/IQKeyboardManager
//  Copyright (c) 2013-24 Iftekhar Qurashi.
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
@available(iOSApplicationExtension, unavailable)
@MainActor
@objc public final class IQBarButtonItemConfiguration: NSObject {

    @objc public init(systemItem: UIBarButtonItem.SystemItem, action: Selector? = nil) {
        self.systemItem = systemItem
        self.image = nil
        self.title = nil
        self.action = action
        super.init()
    }

    @objc public init(image: UIImage, action: Selector? = nil) {
        self.systemItem = nil
        self.image = image
        self.title = nil
        self.action = action
        super.init()
    }

    @objc public init(title: String, action: Selector? = nil) {
        self.systemItem = nil
        self.image = nil
        self.title = title
        self.action = action
        super.init()
    }

    public let systemItem: UIBarButtonItem.SystemItem?    // System Item to be used to instantiate bar button.

    @objc public let image: UIImage?    // Image to show on bar button item if it's not a system item.

    @objc public let title: String?     // Title to show on bar button item if it's not a system item.

    @objc public var action: Selector?  // action for bar button item. Usually 'doneAction:(IQBarButtonItem*)item'.

    public override var accessibilityLabel: String? { didSet { } } // Accessibility related labels

    func apply(on oldBarButtonItem: IQBarButtonItem, target: AnyObject?) -> IQBarButtonItem {

        var newBarButtonItem: IQBarButtonItem = oldBarButtonItem

        if systemItem == nil, !oldBarButtonItem.isSystemItem {
            newBarButtonItem.title = title
            newBarButtonItem.accessibilityLabel = accessibilityLabel
            newBarButtonItem.accessibilityIdentifier = newBarButtonItem.accessibilityLabel
            newBarButtonItem.image = image
            newBarButtonItem.target = target
            newBarButtonItem.action = action
        } else {
            if let systemItem: UIBarButtonItem.SystemItem = systemItem {
                newBarButtonItem = IQBarButtonItem(barButtonSystemItem: systemItem, target: target, action: action)
                newBarButtonItem.isSystemItem = true
            } else if let image: UIImage = image {
                newBarButtonItem = IQBarButtonItem(image: image, style: .plain, target: target, action: action)
            } else {
                newBarButtonItem = IQBarButtonItem(title: title, style: .plain, target: target, action: action)
            }

            newBarButtonItem.invocation = oldBarButtonItem.invocation
            newBarButtonItem.accessibilityLabel = accessibilityLabel
            newBarButtonItem.accessibilityIdentifier = oldBarButtonItem.accessibilityLabel
            newBarButtonItem.isEnabled = oldBarButtonItem.isEnabled
            newBarButtonItem.tag = oldBarButtonItem.tag
        }
        return newBarButtonItem
    }
}
