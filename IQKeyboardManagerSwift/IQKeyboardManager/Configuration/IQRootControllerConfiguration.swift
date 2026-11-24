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
internal final class IQRootControllerConfiguration {

    weak var rootController: UIViewController?
    let beginSafeAreaInsets: UIEdgeInsets
    let beginOrientation: UIInterfaceOrientation

    private weak var adjustedView: UIView?
    private weak var adjustedSuperview: UIView?
    private var adjustment: (centerY: CGFloat, height: CGFloat, distance: CGFloat)?

    init(rootController: UIViewController, orientation: UIInterfaceOrientation) {
        self.rootController = rootController
        beginSafeAreaInsets = rootController.view.safeAreaInsets
        beginOrientation = orientation
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
        return movedDistance != 0
    }

    var movedDistance: CGFloat {
        guard let adjustment = adjustment, let view = adjustedView,
              view === rootController?.viewIfLoaded, view.superview === adjustedSuperview else { return 0 }
        let heightChange = view.bounds.height - adjustment.height
        let resizedCenterY = adjustment.centerY + heightChange * view.layer.anchorPoint.y
        guard view.center.y == adjustment.centerY || view.center.y == resizedCenterY else { return 0 }
        return adjustment.distance
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
    func adjust(upBy moveUp: CGFloat, keyboardHeight: CGFloat) -> Bool {
        guard let view = rootController?.viewIfLoaded else { return false }

        let distance = movedDistance
        var targetDistance = max(0, distance + moveUp)
        if moveUp >= 0 {
            let top = view.convert(view.bounds, to: view.superview).minY
            targetDistance = min(targetDistance, max(0, distance + top + keyboardHeight))
        }
        return setMovedDistance(targetDistance, on: view)
    }

    @discardableResult
    func restore() -> Bool {
        guard let view = rootController?.viewIfLoaded else { return false }
        return setMovedDistance(0, on: view)
    }

    private func setMovedDistance(_ distance: CGFloat, on view: UIView) -> Bool {
        let delta = movedDistance - distance
        let centerY = view.center.y + delta
        adjustedView = view
        adjustedSuperview = view.superview
        adjustment = distance == 0 ? nil : (centerY, view.bounds.height, distance)

        guard delta != 0 else { return false }
        view.center.y = centerY
        return true
    }
}
