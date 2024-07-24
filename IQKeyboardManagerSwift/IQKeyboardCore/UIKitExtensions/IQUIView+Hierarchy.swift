//
//  IQUIView+Hierarchy.swift
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
UIView hierarchy category.
*/

@available(iOSApplicationExtension, unavailable)
@MainActor
public extension IQKeyboardManagerWrapper where Base: UIView {

    // MARK: viewControllers

    /**
     Returns the UIViewController object that manages the receiver.
     */
    func viewContainingController() -> UIViewController? {

        var nextResponder: UIResponder? = base

        repeat {
            nextResponder = nextResponder?.next

            if let viewController: UIViewController = nextResponder as? UIViewController {
                return viewController
            }

        } while nextResponder != nil

        return nil
    }

    /**
     Returns the topMost UIViewController object in hierarchy.
     */
    func topMostController() -> UIViewController? {

        var controllersHierarchy: [UIViewController] = []

        if var topController: UIViewController = base?.window?.rootViewController {
            controllersHierarchy.append(topController)

            while let presented: UIViewController = topController.presentedViewController {

                topController = presented

                controllersHierarchy.append(presented)
            }

            var matchController: UIResponder? = viewContainingController()

            while let mController: UIViewController = matchController as? UIViewController,
                  !controllersHierarchy.contains(mController) {

                repeat {
                    matchController = matchController?.next

                } while matchController != nil && matchController is UIViewController == false
            }

            return matchController as? UIViewController

        } else {
            return viewContainingController()
        }
    }
}

@available(iOSApplicationExtension, unavailable)
@MainActor
public extension IQKeyboardManagerWrapper where Base: UIView {
    // MARK: Superviews/Subviews/Siblings

    /**
    Returns the superView of provided class type.

     
     @param classType class type of the object which is to be search in above hierarchy and return
     
     @param belowView view object in upper hierarchy where method should stop searching and return nil
*/
    func superviewOf<T: UIView>(type classType: T.Type, belowView: UIView? = nil) -> T? {

        var superView: UIView? = base?.superview

        while let unwrappedSuperView: UIView = superView {

            if unwrappedSuperView.isKind(of: classType) {

                // If it's UIScrollView, then validating for special cases
                if unwrappedSuperView is UIScrollView {

                    let classNameString: String = "\(type(of: unwrappedSuperView.self))"

                    // If it's not UITableViewWrapperView class,
                    // this is internal class which is actually manage in UITableview.
                    // The speciality of this class is that it's superview is UITableView.
                    // If it's not UITableViewCellScrollView class, 
                    // this is internal class which is actually manage in UITableviewCell.
                    // The speciality of this class is that it's superview is UITableViewCell.
                    // If it's not _UIQueuingScrollView class, 
                    // actually we validate for _ prefix which usually used by Apple internal classes
                    if !(unwrappedSuperView.superview is UITableView),
                        !(unwrappedSuperView.superview is UITableViewCell),
                        !classNameString.hasPrefix("_") {
                        return superView as? T
                    }
                } else {
                    return superView as? T
                }
            } else if unwrappedSuperView == belowView {
                return nil
            }

            superView = unwrappedSuperView.superview
        }

        return nil
    }

    // MARK: Special TextFields

    /**
     Returns searchBar if receiver object is UISearchBarTextField, otherwise return nil.
    */
    func textFieldSearchBar() -> UISearchBar? {

        var responder: UIResponder? = base?.next

        while let bar: UIResponder = responder {

            if let searchBar: UISearchBar = bar as? UISearchBar {
                return searchBar
            } else if bar is UIViewController {
                break
            }

            responder = bar.next
        }

        return nil
    }

    /**
    Returns YES if the receiver object is UIAlertSheetTextField, otherwise return NO.
    */
    func isAlertViewTextField() -> Bool {

        var alertViewController: UIResponder? = viewContainingController()

        var isAlertViewTextField: Bool = false

        while let controller: UIResponder = alertViewController, !isAlertViewTextField {

            if controller is UIAlertController {
                isAlertViewTextField = true
                break
            }

            alertViewController = controller.next
        }

        return isAlertViewTextField
    }
}

@available(iOSApplicationExtension, unavailable)
@objc public extension UIView {

    @available(*, unavailable, renamed: "iq.viewContainingController()")
    func viewContainingController() -> UIViewController? { nil }

    @available(*, unavailable, renamed: "iq.topMostController()")
    func topMostController() -> UIViewController? { nil }

    @available(*, unavailable, renamed: "iq.superviewOf(type:belowView:)")
    func superviewOfClassType(_ classType: UIView.Type, belowView: UIView? = nil) -> UIView? { nil }
}
