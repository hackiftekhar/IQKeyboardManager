//
//  BaseTableViewController.swift
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

class BaseTableViewController: UITableViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let presentButtonTitle = (self.presentingViewController == nil) ? "Present" : "Dismiss"
        let presentBarButtonItem = UIBarButtonItem(title: presentButtonTitle,
                                                   style: .done,
                                                   target: self,
                                                   action: #selector(presentAction(_:)))

        let settingsBarButtongItem = UIBarButtonItem(image: UIImage(named: "settings"),
                                                     style: .done,
                                                     target: self,
                                                     action: #selector(settingsAction(_:)))
        self.navigationItem.rightBarButtonItems = [settingsBarButtongItem, presentBarButtonItem]
    }

    override var shouldAutorotate: Bool {
        return true
    }
}

extension BaseTableViewController {

    @IBAction private func presentAction(_ sender: UIBarButtonItem) {

        if self.presentingViewController == nil {

            let controller = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
            controller.popoverPresentationController?.barButtonItem = sender

            controller.addAction(.init(title: "Full Screen", style: .default, handler: { _ in
                self.presentUsing(style: .fullScreen, sender: sender)
            }))

            controller.addAction(.init(title: "Page Sheet", style: .default, handler: { _ in
                self.presentUsing(style: .pageSheet, sender: sender)
            }))

            controller.addAction(.init(title: "Form Sheet", style: .default, handler: { _ in
                self.presentUsing(style: .formSheet, sender: sender)
            }))

            controller.addAction(.init(title: "Current Context", style: .default, handler: { _ in
                self.presentUsing(style: .currentContext, sender: sender)
            }))

            controller.addAction(.init(title: "Over Full Screen", style: .default, handler: { _ in
                self.presentUsing(style: .overFullScreen, sender: sender)
            }))

            controller.addAction(.init(title: "Over Current Context", style: .default, handler: { _ in
                self.presentUsing(style: .overCurrentContext, sender: sender)
            }))

            controller.addAction(.init(title: "Popover", style: .default, handler: { _ in
                self.presentUsing(style: .popover, sender: sender)
            }))

            if #available(iOS 13, *) {
                controller.addAction(.init(title: "Automatic", style: .default, handler: { _ in
                    self.presentUsing(style: .automatic, sender: sender)
                }))
            }

            controller.addAction(.init(title: "Cancel", style: .cancel))

            present(controller, animated: true, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    func presentUsing(style: UIModalPresentationStyle, sender: UIBarButtonItem) {

        let classNameString: String = "\(type(of: self.self))"

        let controller: UIViewController = (storyboard?.instantiateViewController(withIdentifier: classNameString))!
        let navController: NavigationController = NavigationController(rootViewController: controller)
        navController.navigationBar.tintColor = self.navigationController?.navigationBar.tintColor
        navController.navigationBar.barTintColor = self.navigationController?.navigationBar.barTintColor
        navController.navigationBar.titleTextAttributes = self.navigationController?.navigationBar.titleTextAttributes
        navController.modalPresentationStyle = style
        if style == .popover {
            let heightWidth = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
            navController.preferredContentSize = CGSize(width: heightWidth, height: heightWidth)
            navController.popoverPresentationController?.barButtonItem = sender
            navController.popoverPresentationController?.delegate = self
        }
        present(navController, animated: true, completion: nil)
    }
}

extension BaseTableViewController {

    @IBAction private func settingsAction(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SettingsViewController")

        let navController: NavigationController = NavigationController(rootViewController: controller)
        navController.navigationBar.tintColor = self.navigationController?.navigationBar.tintColor
        navController.navigationBar.barTintColor = self.navigationController?.navigationBar.barTintColor
        navController.navigationBar.titleTextAttributes = self.navigationController?.navigationBar.titleTextAttributes
        navController.modalPresentationStyle = .popover
        navController.popoverPresentationController?.barButtonItem = sender
        let heightWidth = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        navController.preferredContentSize = CGSize(width: heightWidth, height: heightWidth)
        navController.popoverPresentationController?.delegate = self
        present(navController, animated: true, completion: nil)
    }
}

extension BaseTableViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        self.view.endEditing(true)
    }
}
