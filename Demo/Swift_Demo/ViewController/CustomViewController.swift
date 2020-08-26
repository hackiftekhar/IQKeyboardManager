//
//  CustomViewController.swift
//  Demo
//
//  Created by Iftekhar on 19/09/15.
//  Copyright © 2015 Iftekhar. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class CustomViewController: UIViewController, UIPopoverPresentationControllerDelegate {

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

        switchDisableViewController.isOn = IQKeyboardManager.shared.disabledDistanceHandlingClasses.contains(where: { element in
            return element == CustomViewController.self
        })

        switchEnableViewController.isOn = IQKeyboardManager.shared.enabledDistanceHandlingClasses.contains(where: { element in
            return element == CustomViewController.self
        })

        switchDisableToolbar.isOn = IQKeyboardManager.shared.disabledToolbarClasses.contains(where: { element in
            return element == CustomViewController.self
        })
        switchEnableToolbar.isOn = IQKeyboardManager.shared.enabledToolbarClasses.contains(where: { element in
            return element == CustomViewController.self
        })

        switchDisableTouchResign.isOn = IQKeyboardManager.shared.disabledTouchResignedClasses.contains(where: { element in
            return element == CustomViewController.self
        })
        switchEnableTouchResign.isOn = IQKeyboardManager.shared.enabledTouchResignedClasses.contains(where: { element in
            return element == CustomViewController.self
        })

        switchAllowPreviousNext.isOn = IQKeyboardManager.shared.toolbarPreviousNextAllowedClasses.contains(where: { element in
            return element == IQPreviousNextView.self
        })
    }

    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {

            #if swift(>=4.2)
            let finalCurve = UIView.AnimationOptions.beginFromCurrentState.union(.init(rawValue: 7))
            #else
            let finalCurve = UIViewAnimationOptions.beginFromCurrentState.union(.init(rawValue: 7))
            #endif

            let animationDuration: TimeInterval = 0.3

            UIView.animate(withDuration: animationDuration, delay: 0, options: finalCurve, animations: { () -> Void in

                if self.settingsTopConstraint.constant != 0 {
                    self.settingsTopConstraint.constant = 0
                } else {
                    self.settingsTopConstraint.constant = -self.settingsView.frame.size.height+30
                }

                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }) { (_: Bool) -> Void in}
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let identifier = segue.identifier {

            if identifier == "SettingsNavigationController" {

                let controller = segue.destination

                controller.modalPresentationStyle = .popover
                controller.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem

                let heightWidth = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
                controller.preferredContentSize = CGSize(width: heightWidth, height: heightWidth)
                controller.popoverPresentationController?.delegate = self
            }
        }
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        self.view.endEditing(true)
    }

    override var shouldAutorotate: Bool {
        return true
    }
}
