//
//  CustomViewController.swift
//  Demo
//
//  Created by Iftekhar on 19/09/15.
//  Copyright © 2015 Iftekhar. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

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
            let classes = IQKeyboardManager.shared.disabledToolbarClasses
            switchDisableToolbar.isOn = classes.contains(where: { element in
                return element == CustomViewController.self
            })
        }

        do {
            let classes = IQKeyboardManager.shared.enabledToolbarClasses
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
            let classes = IQKeyboardManager.shared.toolbarPreviousNextAllowedClasses
            switchAllowPreviousNext.isOn = classes.contains(where: { element in
                return element == IQPreviousNextView.self
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
            IQKeyboardManager.shared.disabledToolbarClasses.append(CustomViewController.self)
        } else {

            if let index = IQKeyboardManager.shared.disabledToolbarClasses.firstIndex(where: { element in
                return element == CustomViewController.self
            }) {
                IQKeyboardManager.shared.disabledToolbarClasses.remove(at: index)
            }
        }
    }

    @IBAction func enableToolbarAction(_ sender: UISwitch) {
        self.view.endEditing(true)
        if sender.isOn {
            IQKeyboardManager.shared.enabledToolbarClasses.append(CustomViewController.self)
        } else {
            if let index = IQKeyboardManager.shared.enabledToolbarClasses.firstIndex(where: { element in
                return element == CustomViewController.self
            }) {
                IQKeyboardManager.shared.enabledToolbarClasses.remove(at: index)
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
            IQKeyboardManager.shared.toolbarPreviousNextAllowedClasses.append(IQPreviousNextView.self)
        } else {

            if let index = IQKeyboardManager.shared.toolbarPreviousNextAllowedClasses.firstIndex(where: { element in
                return element == IQPreviousNextView.self
            }) {
                IQKeyboardManager.shared.toolbarPreviousNextAllowedClasses.remove(at: index)
            }
        }
    }
}
