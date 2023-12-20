//
//  IQBarButtonItem.swift
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

@available(iOSApplicationExtension, unavailable)
@MainActor
@objc open class IQBarButtonItem: UIBarButtonItem {

    internal static let flexibleBarButtonItem: IQBarButtonItem = IQBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                                                                 target: nil, action: nil)

    @objc public override init() {
        super.init()
        initialize()
    }

    @objc public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    private func initialize() {

        let states: [UIControl.State] = [.normal, .highlighted, .disabled, .focused]

        for state in states {

            setBackgroundImage(UIImage(), for: state, barMetrics: .default)
            setBackgroundImage(UIImage(), for: state, style: .plain, barMetrics: .default)
            setBackButtonBackgroundImage(UIImage(), for: state, barMetrics: .default)
        }

        setTitlePositionAdjustment(UIOffset(), for: .default)
        setBackgroundVerticalPositionAdjustment(0, for: .default)
        setBackButtonBackgroundVerticalPositionAdjustment(0, for: .default)
    }

    @objc override open var tintColor: UIColor? {
        didSet {

            var textAttributes: [NSAttributedString.Key: Any] = [:]
            textAttributes[.foregroundColor] = tintColor

            if let attributes: [NSAttributedString.Key: Any] = titleTextAttributes(for: .normal) {
                for (key, value) in attributes {
                    textAttributes[key] = value
                }
            }

            setTitleTextAttributes(textAttributes, for: .normal)
        }
    }

    /**
     Boolean to know if it's a system item or custom item,
     we are having a limitation that we cannot override a designated initializer,
     so we are manually setting this property once in initialization
     */
    internal var isSystemItem: Bool = false

    /**
     Additional target & action to do get callback action.
     Note that setting custom target & selector doesn't affect native functionality,
     this is just an additional target to get a callback.
     
     @param target Target object.
     @param action Target Selector.
     */
    @objc open func setTarget(_ target: AnyObject?, action: Selector?) {
        if let target: AnyObject = target, let action: Selector = action {
            invocation = IQInvocation(target, action)
        } else {
            invocation = nil
        }
    }

    /**
     Customized Invocation to be called when button is pressed.
     invocation is internally created using setTarget:action: method.
     */
    @objc open var invocation: IQInvocation? {
        didSet {
            // We have to put this condition here because if we override this function then
            // We were getting "Cannot override '_' which has been marked unavailable" in Xcode 15
            if let titleBarButton = self as? IQTitleBarButtonItem {

                if let target = invocation?.target, let action = invocation?.action {
                    titleBarButton.isEnabled = true
                    titleBarButton.titleButton?.isEnabled = true
                    titleBarButton.titleButton?.addTarget(target, action: action, for: .touchUpInside)
                } else {
                    titleBarButton.isEnabled = false
                    titleBarButton.titleButton?.isEnabled = false
                    titleBarButton.titleButton?.removeTarget(nil, action: nil, for: .touchUpInside)
                }
            }
        }
    }
}
