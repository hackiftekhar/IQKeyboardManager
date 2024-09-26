//
//  IQRootControllerConfiguration.swift
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

@available(iOSApplicationExtension, unavailable)
@MainActor
internal struct IQRootControllerConfiguration {

    weak var rootController: UIViewController?
    let beginOrigin: CGPoint
    let beginSafeAreaInsets: UIEdgeInsets
    let beginOrientation: UIInterfaceOrientation

    init(rootController: UIViewController) {
        self.rootController = rootController
        beginOrigin = rootController.view.frame.origin
        beginSafeAreaInsets = rootController.view.safeAreaInsets

        let interfaceOrientation: UIInterfaceOrientation
        if let scene = rootController.view.window?.windowScene {
            interfaceOrientation = scene.interfaceOrientation
        } else {
            interfaceOrientation = .unknown
        }

        beginOrientation = interfaceOrientation
    }

    var currentOrientation: UIInterfaceOrientation {
        let interfaceOrientation: UIInterfaceOrientation
        if let scene = rootController?.view.window?.windowScene {
            interfaceOrientation = scene.interfaceOrientation
        } else {
            interfaceOrientation = .unknown
        }
        return interfaceOrientation
    }

    var isReady: Bool {
        return rootController?.view.window != nil
    }

    var hasChanged: Bool {
        let origin: CGPoint = rootController?.view.frame.origin ?? .zero
        return !origin.equalTo(beginOrigin)
    }

    var isInteractiveGestureActive: Bool {
        guard let rootController: UIViewController = rootController,
              let navigationController: UINavigationController = rootController.navigationController,
              let interactiveGestureRecognizer = navigationController.interactivePopGestureRecognizer else {
            return false
        }
        switch interactiveGestureRecognizer.state {
        case .began, .changed:
            return true
        case .possible, .ended, .cancelled, .failed, .recognized:
            // swiftlint:disable:next no_fallthrough_only
            fallthrough
        default:
            return false
        }
    }
    @discardableResult
    func restore() -> Bool {
        guard let rootController: UIViewController = rootController,
              !rootController.view.frame.origin.equalTo(beginOrigin) else { return false }
        // Setting it's new frame
        var rect: CGRect = rootController.view.frame
        rect.origin = beginOrigin
        rootController.view.frame = rect
        return true
     }
}
