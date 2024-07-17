//
//  SettingsViewController.swift
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

class SettingsViewController: UITableViewController {

    let sectionTitles = ["UIKeyboard handling",
    "IQToolbar handling",
    "UIKeyboard appearance overriding",
    "Resign first responder handling",
    "UISound handling",
    "IQKeyboardManager Debug"]

    let keyboardManagerProperties = [
        ["Enable",
         "Keyboard Distance From TextField",
         "Layout If Needed on Update"],
        ["Enable AutoToolbar",
         "Toolbar Manage Behaviour",
         "Should Toolbar Uses TextField TintColor",
         "Should Show TextField Placeholder",
         "Placeholder Font",
         "Toolbar Tint Color",
         "Toolbar Done BarButtonItem Image",
         "Toolbar Done Button Text"],
        ["Override Keyboard Appearance",
         "UIKeyboard Appearance"],
        ["Should Resign On Touch Outside"],
        ["Should Play Input Clicks"],
        ["Debugging logs in Console"]
    ]

    let keyboardManagerPropertyDetails = [
        ["Enable/Disable IQKeyboardManager",
         "Set keyboard distance from textField",
         "Layout the whole view on change"],
        ["Automatic add the IQToolbar on UIKeyboard",
         "AutoToolbar previous/next button managing behaviour",
         "Uses textField's tintColor property for IQToolbar",
         "Add the textField's placeholder text on IQToolbar",
         "UIFont for IQToolbar placeholder text",
         "Override toolbar tintColor property",
         "Replace toolbar done button text with provided image",
         "Override toolbar done button text"],
        ["Override the keyboardAppearance for all UITextField/UITextView",
         "All the UITextField keyboardAppearance is set using this property"],
        ["Resigns Keyboard on touching outside of UITextField/View"],
        ["Plays inputClick sound on next/previous/done click"],
        ["Setting enableDebugging to YES/No to turn on/off debugging mode"]
    ]

    var selectedIndexPathForOptions: IndexPath?

    @IBAction func doneAction (_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    /**  UIKeyboard Handling    */
    @objc func enableAction (_ sender: UISwitch) {

        IQKeyboardManager.shared.enable = sender.isOn

        self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
    }

    @objc func keyboardDistanceFromTextFieldAction (_ sender: UIStepper) {

        IQKeyboardManager.shared.keyboardDistanceFromTextField = CGFloat(sender.value)

        self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
    }

    @objc func layoutIfNeededOnUpdateAction (_ sender: UISwitch) {

        IQKeyboardManager.shared.layoutIfNeededOnUpdate = sender.isOn

        self.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .none)
    }

    /**  IQToolbar handling     */
    @objc func enableAutoToolbarAction (_ sender: UISwitch) {

        IQKeyboardManager.shared.enableAutoToolbar = sender.isOn

        self.tableView.reloadSections(IndexSet(integer: 1), with: .fade)
    }

    @objc func shouldToolbarUsesTextFieldTintColorAction (_ sender: UISwitch) {

        IQKeyboardManager.shared.toolbarConfiguration.useTextFieldTintColor = sender.isOn
    }

    @objc func shouldShowToolbarPlaceholder (_ sender: UISwitch) {

        IQKeyboardManager.shared.toolbarConfiguration.placeholderConfiguration.showPlaceholder = sender.isOn

        self.tableView.reloadSections(IndexSet(integer: 1), with: .fade)
    }

    @objc func toolbarDoneBarButtonItemImage (_ sender: UISwitch) {

        if sender.isOn {
            let config = IQBarButtonItemConfiguration(image: UIImage(named: "IQButtonBarArrowDown")!)
            IQKeyboardManager.shared.toolbarConfiguration.doneBarButtonConfiguration = config
        } else {
            IQKeyboardManager.shared.toolbarConfiguration.doneBarButtonConfiguration = nil
        }

        self.tableView.reloadSections(IndexSet(integer: 1), with: .fade)
    }

    /**  "Keyboard appearance overriding    */
    @objc func overrideKeyboardAppearanceAction (_ sender: UISwitch) {

        IQKeyboardManager.shared.keyboardConfiguration.overrideAppearance = sender.isOn

        self.tableView.reloadSections(IndexSet(integer: 2), with: .fade)
    }

    /**  Resign first responder handling    */
    @objc func shouldResignOnTouchOutsideAction (_ sender: UISwitch) {

        IQKeyboardManager.shared.resignOnTouchOutside = sender.isOn
    }

    /**  Sound handling         */
    @objc func shouldPlayInputClicksAction (_ sender: UISwitch) {

        IQKeyboardManager.shared.playInputClicks = sender.isOn
    }

    /**  Debugging         */
    @objc func enableDebugging (_ sender: UISwitch) {

        IQKeyboardManager.shared.enableDebugging = sender.isOn
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let identifier = segue.identifier else {
            return
        }

        if identifier.elementsEqual("OptionsViewController"),
            let controller = segue.destination as? OptionsViewController,
           let cell = sender as? UITableViewCell {

            controller.delegate = self

            selectedIndexPathForOptions = self.tableView.indexPath(for: cell)

            guard let selectedIndexPath = selectedIndexPathForOptions else {
                return
            }

            if selectedIndexPath.section == 1 && selectedIndexPath.row == 1 {

                controller.title = "Toolbar Manage Behaviour"
                controller.options = ["IQAutoToolbar By Subviews", "IQAutoToolbar By Tag", "IQAutoToolbar By Position"]
                controller.selectedIndex = IQKeyboardManager.shared.toolbarConfiguration.manageBehavior.hashValue

            } else if selectedIndexPath.section == 1 && selectedIndexPath.row == 4 {

                controller.title = "Fonts"
                controller.options = ["Bold System Font", "Italic system font", "Regular"]
                controller.selectedIndex = IQKeyboardManager.shared.toolbarConfiguration.manageBehavior.hashValue

                let fonts = [UIFont.boldSystemFont(ofSize: 12),
                             UIFont.italicSystemFont(ofSize: 12),
                             UIFont.systemFont(ofSize: 12)]

                if let placeholderFont = IQKeyboardManager.shared.toolbarConfiguration.placeholderConfiguration.font {

                    if let index = fonts.firstIndex(of: placeholderFont) {

                        controller.selectedIndex = index
                    }
                }

            } else if selectedIndexPath.section == 2 && selectedIndexPath.row == 1 {

                controller.title = "Keyboard Appearance"
                controller.options = ["UIKeyboardAppearance Default",
                                      "UIKeyboardAppearance Dark",
                                      "UIKeyboardAppearance Light"]
                controller.selectedIndex = IQKeyboardManager.shared.keyboardConfiguration.appearance.hashValue
            }
        }
    }
}

@available(iOS 14.0, *)
extension SettingsViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        viewController.dismiss(animated: true)
    }

    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        viewController.dismiss(animated: true)
        let color = viewController.selectedColor
        if color.isEqual(UIColor.clear) {
            IQKeyboardManager.shared.toolbarConfiguration.tintColor = nil
        } else {
            IQKeyboardManager.shared.toolbarConfiguration.tintColor = color
        }
    }

    func colorPickerViewController(_ viewController: UIColorPickerViewController,
                                   didSelect color: UIColor, continuously: Bool) {
        viewController.dismiss(animated: true)
        if color.isEqual(UIColor.clear) {
            IQKeyboardManager.shared.toolbarConfiguration.tintColor = nil
        } else {
            IQKeyboardManager.shared.toolbarConfiguration.tintColor = color
        }
    }
}

extension SettingsViewController: UITextFieldDelegate {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {

        if textField.tag == 17 {
            if let title = textField.text, !title.isEmpty {
                let config = IQBarButtonItemConfiguration(title: title)
                IQKeyboardManager.shared.toolbarConfiguration.doneBarButtonConfiguration = config
            } else {
                IQKeyboardManager.shared.toolbarConfiguration.doneBarButtonConfiguration = nil
            }
        }
    }
}

extension SettingsViewController: OptionsViewControllerDelegate {
    nonisolated func optionsViewController(_ controller: OptionsViewController, index: NSInteger) {

        DispatchQueue.main.async {

            guard let selectedIndexPath = self.selectedIndexPathForOptions else {
                return
            }

            if selectedIndexPath.section == 1 && selectedIndexPath.row == 1 {
                let value = IQAutoToolbarManageBehavior(rawValue: index)!
                IQKeyboardManager.shared.toolbarConfiguration.manageBehavior = value
            } else if selectedIndexPath.section == 1 && selectedIndexPath.row == 4 {

                let fonts = [UIFont.boldSystemFont(ofSize: 12),
                             UIFont.italicSystemFont(ofSize: 12),
                             UIFont.systemFont(ofSize: 12)]
                IQKeyboardManager.shared.toolbarConfiguration.placeholderConfiguration.font = fonts[index]
            } else if selectedIndexPath.section == 2 && selectedIndexPath.row == 1 {

                IQKeyboardManager.shared.keyboardConfiguration.appearance = UIKeyboardAppearance(rawValue: index)!
            }
        }
    }
}
