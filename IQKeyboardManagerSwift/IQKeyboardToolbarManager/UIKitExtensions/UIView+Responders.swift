//
//  UIView+Responders.swift
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
private struct AssociatedKeys {
    static var ignoreSwitchingByNextPrevious: Int = 0
}

/**
UIView category for managing textInputView
*/
@available(iOSApplicationExtension, unavailable)
@MainActor
public extension IQKeyboardExtension where Base: IQTextInputView {

    /**
     If ignoreSwitchingByNextPrevious is true then library will ignore this textInputView
     while moving to other textInputView using keyboard toolbar next previous buttons.
     Default is false
     */
    var ignoreSwitchingByNextPrevious: Bool {
        get {
            if let base = base {
                return objc_getAssociatedObject(base, &AssociatedKeys.ignoreSwitchingByNextPrevious) as? Bool ?? false
            }
            return false
        }
        set(newValue) {
            if let base = base {
                objc_setAssociatedObject(base, &AssociatedKeys.ignoreSwitchingByNextPrevious,
                                         newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}

// swiftlint:disable unused_setter_value
@available(iOSApplicationExtension, unavailable)
@MainActor
@objc public extension UIView {
    @available(*, unavailable, renamed: "iq.ignoreSwitchingByNextPrevious")
    var ignoreSwitchingByNextPrevious: Bool {
        get { false }
        set { }
    }
}
// swiftlint:enable unused_setter_value

@available(iOSApplicationExtension, unavailable)
@MainActor
internal extension IQKeyboardExtension where Base: IQTextInputView {

    /**
     Returns all siblings of the receiver which canBecomeFirstResponder.
     */
    func responderSiblings() -> [any IQTextInputView] {

        //    Getting all siblings
        guard let siblings: [UIView] = base?.superview?.subviews else { return [] }

        // Array of textInputView.
        var textInputViews: [any IQTextInputView] = []
        for view in siblings {
            if let view = view as? any IQTextInputView,
               view == base || !view.internalIgnoreSwitchingByNextPrevious,
               view.internalCanBecomeFirstResponder() {
                textInputViews.append(view)
            }
        }

        return textInputViews
    }
}

/**
UIView category for managing textInputView
*/
@available(iOSApplicationExtension, unavailable)
@MainActor
internal extension IQKeyboardExtension where Base: UIView {

    /**
    Returns all deep subViews of the receiver which canBecomeFirstResponder.
    */
    func deepResponderViews() -> [any IQTextInputView] {

        guard let subviews: [UIView] = base?.subviews, !subviews.isEmpty else { return [] }

        // Array of textInputViews.
        var textInputViews: [any IQTextInputView] = []

        for view in subviews {

            if let view = view as? any IQTextInputView,
               view == base || !view.internalIgnoreSwitchingByNextPrevious,
               view.internalCanBecomeFirstResponder() {
                textInputViews.append(view)
            }
            // Sometimes there are hidden or disabled views and textInputView inside them still recorded,
            // so we added some more validations here (Bug ID: #458)
            // Uncommented else (Bug ID: #625)
            else if view.subviews.count != 0,
                    base?.isUserInteractionEnabled == true,
                    base?.isHidden == false, base?.alpha != 0.0 {
                for deepView in view.iq.deepResponderViews() {
                    textInputViews.append(deepView)
                }
            }
        }

        // subviews are returning in opposite order. Sorting according the frames 'y'.
        return textInputViews.sorted(by: { (view1: any IQTextInputView, view2: any IQTextInputView) -> Bool in

            let frame1: CGRect = view1.convert(view1.bounds, to: base)
            let frame2: CGRect = view2.convert(view2.bounds, to: base)

            if frame1.minY != frame2.minY {
                return frame1.minY < frame2.minY
            } else {
                return frame1.minX < frame2.minX
            }
        })
    }
}

@available(iOSApplicationExtension, unavailable)
@MainActor
private extension IQKeyboardExtension where Base: IQTextInputView {

    func canBecomeFirstResponder() -> Bool {

        var canBecomeFirstResponder: Bool = base?.iqIsEnabled == true

        if canBecomeFirstResponder {
            canBecomeFirstResponder = base?.isUserInteractionEnabled == true &&
            base?.isHidden == false &&
            base?.alpha != 0.0 &&
            !isAlertViewTextField() &&
            textFieldSearchBar() == nil
        }

        return canBecomeFirstResponder
    }
}

@available(iOSApplicationExtension, unavailable)
@MainActor
fileprivate extension IQTextInputView {
    var internalIgnoreSwitchingByNextPrevious: Bool {
        return iq.ignoreSwitchingByNextPrevious
    }
    func internalCanBecomeFirstResponder() -> Bool {
        return iq.canBecomeFirstResponder()
    }
}
