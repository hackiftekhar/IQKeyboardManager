//
//  CustomViewController.swift
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
import IQKeyboardManagerSwift
import IQKeyboardToolbarManager
import IQKeyboardReturnKeyHandler

class CustomViewController: BaseViewController {

    fileprivate var returnHandler: IQKeyboardReturnKeyHandler!
    @IBOutlet var settingsView: UIView!

    @IBOutlet var switchDisableViewController: UISwitch!
    @IBOutlet var switchEnableViewController: UISwitch!

    @IBOutlet var switchDisableToolbar: UISwitch!
    @IBOutlet var switchEnableToolbar: UISwitch!

    @IBOutlet var switchDisableTouchResign: UISwitch!
    @IBOutlet var switchEnableTouchResign: UISwitch!

    @IBOutlet var switchAllowPreviousNext: UISwitch!

    @IBOutlet var settingsTopConstraint: NSLayoutConstraint!

    deinit {
        returnHandler = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        settingsView.layer.shadowColor = UIColor.black.cgColor
        settingsView.layer.shadowOffset = CGSize.zero
        settingsView.layer.shadowRadius = 5.0
        settingsView.layer.shadowOpacity = 0.5

        returnHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnHandler.lastTextFieldReturnKeyType = .done
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        do {
            let classes = IQKeyboardManager.shared.disabledDistanceHandlingClasses
            switchDisableViewController.isOn = classes.contains(where: { element in
                return element == CustomViewController.self
            })
        }

        do {
            let classes = IQKeyboardManager.shared.enabledDistanceHandlingClasses
            switchEnableViewController.isOn = classes.contains(where: { element in
                return element == CustomViewController.self
            })
        }

        do {
            let classes = IQKeyboardToolbarManager.shared.disabledToolbarClasses
            switchDisableToolbar.isOn = classes.contains(where: { element in
                return element == CustomViewController.self
            })
        }

        do {
            let classes = IQKeyboardToolbarManager.shared.enabledToolbarClasses
            switchEnableToolbar.isOn = classes.contains(where: { element in
                return element == CustomViewController.self
            })
        }

        do {
            let classes = IQKeyboardManager.shared.disabledTouchResignedClasses
            switchDisableTouchResign.isOn = classes.contains(where: { element in
                return element == CustomViewController.self
            })
        }

        do {
            let classes = IQKeyboardManager.shared.enabledTouchResignedClasses
            switchEnableTouchResign.isOn = classes.contains(where: { element in
                return element == CustomViewController.self
            })
        }

        do {
            let classes = IQKeyboardToolbarManager.shared.deepResponderAllowedContainerClasses
            switchAllowPreviousNext.isOn = classes.contains(where: { element in
                return element == IQDeepResponderContainerView.self
            })
        }
    }

    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {

            let finalCurve = UIView.AnimationOptions.beginFromCurrentState.union(.init(rawValue: 7))

            let animationDuration: TimeInterval = 0.3

            UIView.animate(withDuration: animationDuration, delay: 0, options: finalCurve, animations: { () -> Void in

                if self.settingsTopConstraint.constant != 0 {
                    self.settingsTopConstraint.constant = 0
                } else {
                    self.settingsTopConstraint.constant = -self.settingsView.frame.size.height+30
                }

                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }

    @IBAction func disableInViewControllerAction(_ sender: UISwitch) {
        self.view.endEditing(true)
        if sender.isOn {
            IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(CustomViewController.self)
        } else {

            if let index = IQKeyboardManager.shared.disabledDistanceHandlingClasses.firstIndex(where: { element in
                return element == CustomViewController.self
            }) {
                IQKeyboardManager.shared.disabledDistanceHandlingClasses.remove(at: index)
            }
        }
    }

    @IBAction func enableInViewControllerAction(_ sender: UISwitch) {
        self.view.endEditing(true)
        if sender.isOn {
            IQKeyboardManager.shared.enabledDistanceHandlingClasses.append(CustomViewController.self)
        } else {

            if let index = IQKeyboardManager.shared.enabledDistanceHandlingClasses.firstIndex(where: { element in
                return element == CustomViewController.self
            }) {
                IQKeyboardManager.shared.enabledDistanceHandlingClasses.remove(at: index)
            }
        }
    }

    @IBAction func disableToolbarAction(_ sender: UISwitch) {
        self.view.endEditing(true)
        if sender.isOn {
            IQKeyboardToolbarManager.shared.disabledToolbarClasses.append(CustomViewController.self)
        } else {

            if let index = IQKeyboardToolbarManager.shared.disabledToolbarClasses.firstIndex(where: { element in
                return element == CustomViewController.self
            }) {
                IQKeyboardToolbarManager.shared.disabledToolbarClasses.remove(at: index)
            }
        }
    }

    @IBAction func enableToolbarAction(_ sender: UISwitch) {
        self.view.endEditing(true)
        if sender.isOn {
            IQKeyboardToolbarManager.shared.enabledToolbarClasses.append(CustomViewController.self)
        } else {
            if let index = IQKeyboardToolbarManager.shared.enabledToolbarClasses.firstIndex(where: { element in
                return element == CustomViewController.self
            }) {
                IQKeyboardToolbarManager.shared.enabledToolbarClasses.remove(at: index)
            }
        }
    }

    @IBAction func disableTouchOutsideAction(_ sender: UISwitch) {
        self.view.endEditing(true)
        if sender.isOn {
            IQKeyboardManager.shared.disabledTouchResignedClasses.append(CustomViewController.self)
        } else {
            if let index = IQKeyboardManager.shared.disabledTouchResignedClasses.firstIndex(where: { element in
                return element == CustomViewController.self
            }) {
                IQKeyboardManager.shared.disabledTouchResignedClasses.remove(at: index)
            }
        }
    }

    @IBAction func enableTouchOutsideAction(_ sender: UISwitch) {
        self.view.endEditing(true)
        if sender.isOn {
            IQKeyboardManager.shared.enabledTouchResignedClasses.append(CustomViewController.self)
        } else {

            if let index = IQKeyboardManager.shared.enabledTouchResignedClasses.firstIndex(where: { element in
                return element == CustomViewController.self
            }) {
                IQKeyboardManager.shared.enabledTouchResignedClasses.remove(at: index)
            }
        }
    }

    @IBAction func allowedPreviousNextAction(_ sender: UISwitch) {
        self.view.endEditing(true)
        if sender.isOn {
            IQKeyboardToolbarManager.shared.deepResponderAllowedContainerClasses.append(IQDeepResponderContainerView.self)
        } else {

            if let index = IQKeyboardToolbarManager.shared.deepResponderAllowedContainerClasses.firstIndex(where: { element in
                return element == IQDeepResponderContainerView.self
            }) {
                IQKeyboardToolbarManager.shared.deepResponderAllowedContainerClasses.remove(at: index)
            }
        }
    }
}
