//
//  IQToolbarConfiguration.swift
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
@objc public final class IQToolbarConfiguration: NSObject {

    /**
     If YES, then uses textField's tintColor property for IQToolbar, otherwise tint color is default. Default is NO.
     */
    @objc public var useTextFieldTintColor: Bool = false

    /**
     This is used for toolbar.tintColor when textfield.keyboardAppearance is UIKeyboardAppearanceDefault.
     If useTextFieldTintColor is YES then this property is ignored. Default is nil and uses black color.
     */
    @objc public var tintColor: UIColor?

    /**
     This is used for toolbar.barTintColor. Default is nil.
     */
    @objc public var barTintColor: UIColor?

    /**
     IQPreviousNextDisplayModeDefault:      Show NextPrevious when there are more than 1 textField otherwise hide.
     IQPreviousNextDisplayModeAlwaysHide:   Do not show NextPrevious buttons in any case.
     IQPreviousNextDisplayModeAlwaysShow:   Always show nextPrevious buttons,
     if there are more than 1 textField then both buttons will be visible but will be shown as disabled.
     */
    @objc public var previousNextDisplayMode: IQPreviousNextDisplayMode = .default

    /**
     /**
      IQAutoToolbarBySubviews:   Creates Toolbar according to subview's hierarchy of Textfield's in view.
      IQAutoToolbarByTag:        Creates Toolbar according to tag property of TextField's.
      IQAutoToolbarByPosition:   Creates Toolbar according to the y,x position
      of textField in it's superview coordinate.

      Default is IQAutoToolbarBySubviews.
      */
     AutoToolbar managing behavior. Default is IQAutoToolbarBySubviews.
     */
    @objc public var manageBehavior: IQAutoToolbarManageBehavior = .bySubviews

    /**
    Buttons configuration displayed on the toolbar, the selector parameter is ignored in below configuration
    */
    @objc public var previousBarButtonConfiguration: IQBarButtonItemConfiguration?
    @objc public var nextBarButtonConfiguration: IQBarButtonItemConfiguration?
    @objc public var doneBarButtonConfiguration: IQBarButtonItemConfiguration?

    @objc public let placeholderConfiguration: IQToolbarPlaceholderConfiguration = .init()
}
