//
//  IQKeyboardManagerCompatible.swift
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

import Foundation

/// Wrapper for IQKeyboardManager compatible types. This type provides an extension point for
/// convenience methods in IQKeyboardManager.
@available(iOSApplicationExtension, unavailable)
public struct IQKeyboardManagerWrapper<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

// swiftlint:disable identifier_name
/// Represents an object type that is compatible with IQKeyboardManager. You can use `iq` property to get a
/// value in the namespace of IQKeyboardManager.
@available(iOSApplicationExtension, unavailable)
public protocol IQKeyboardManagerCompatible {
    /// Type being extended.
    associatedtype Base

    /// Instance IQKeyboardManager extension point.
    var iq: IQKeyboardManagerWrapper<Base> { get set }
}

// swiftlint:disable unused_setter_value
@available(iOSApplicationExtension, unavailable)
public extension IQKeyboardManagerCompatible {

    /// Instance IQKeyboardManager extension point.
    var iq: IQKeyboardManagerWrapper<Self> {
        get { IQKeyboardManagerWrapper(self) }
        set {}
    }
}
// swiftlint:enable unused_setter_value
// swiftlint:enable identifier_name
