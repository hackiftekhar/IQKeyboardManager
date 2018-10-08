//
//  SettingsViewController.swift
//  Demo
//
//  Created by Iftekhar on 26/08/15.
//  Copyright (c) 2015 Iftekhar. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class SettingsViewController: UITableViewController, OptionsViewControllerDelegate, ColorPickerTextFieldDelegate {

    let sectionTitles = ["UIKeyboard handling",
    "IQToolbar handling",
    "UIKeyboard appearance overriding",
    "Resign first responder handling",
    "UISound handling",
    "IQKeyboardManager Debug"]
    
    let keyboardManagerProperties = [["Enable", "Keyboard Distance From TextField"],
    ["Enable AutoToolbar","Toolbar Manage Behaviour","Should Toolbar Uses TextField TintColor","Should Show TextField Placeholder","Placeholder Font","Toolbar Tint Color","Toolbar Done BarButtonItem Image","Toolbar Done Button Text"],
    ["Override Keyboard Appearance","UIKeyboard Appearance"],
    ["Should Resign On Touch Outside"],
    ["Should Play Input Clicks"],
    ["Debugging logs in Console"]]
    
    let keyboardManagerPropertyDetails = [["Enable/Disable IQKeyboardManager","Set keyboard distance from textField"],
    ["Automatic add the IQToolbar on UIKeyboard","AutoToolbar previous/next button managing behaviour","Uses textField's tintColor property for IQToolbar","Add the textField's placeholder text on IQToolbar","UIFont for IQToolbar placeholder text","Override toolbar tintColor property","Replace toolbar done button text with provided image","Override toolbar done button text"],
    ["Override the keyboardAppearance for all UITextField/UITextView","All the UITextField keyboardAppearance is set using this property"],
    ["Resigns Keyboard on touching outside of UITextField/View"],
    ["Plays inputClick sound on next/previous/done click"],
    ["Setting enableDebugging to YES/No to turn on/off debugging mode"]]
    
    var selectedIndexPathForOptions : IndexPath?
    
    
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
    
    /**  IQToolbar handling     */
    @objc func enableAutoToolbarAction (_ sender: UISwitch) {
        
        IQKeyboardManager.shared.enableAutoToolbar = sender.isOn
        
        self.tableView.reloadSections(IndexSet(integer: 1), with: .fade)
    }
    
    @objc func shouldToolbarUsesTextFieldTintColorAction (_ sender: UISwitch) {
        
        IQKeyboardManager.shared.shouldToolbarUsesTextFieldTintColor = sender.isOn
    }
    
    @objc func shouldShowToolbarPlaceholder (_ sender: UISwitch) {
        
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = sender.isOn
        
        self.tableView.reloadSections(IndexSet(integer: 1), with: .fade)
    }
    
    @objc func toolbarDoneBarButtonItemImage (_ sender: UISwitch) {
        
        if sender.isOn {
            IQKeyboardManager.shared.toolbarDoneBarButtonItemImage = UIImage(named:"IQButtonBarArrowDown")
        } else {
            IQKeyboardManager.shared.toolbarDoneBarButtonItemImage = nil
        }
        
        self.tableView.reloadSections(IndexSet(integer: 1), with: .fade)
    }

    /**  "Keyboard appearance overriding    */
    @objc func overrideKeyboardAppearanceAction (_ sender: UISwitch) {
        
        IQKeyboardManager.shared.overrideKeyboardAppearance = sender.isOn
        
        self.tableView.reloadSections(IndexSet(integer: 2), with: .fade)
    }
    
    /**  Resign first responder handling    */
    @objc func shouldResignOnTouchOutsideAction (_ sender: UISwitch) {
        
        IQKeyboardManager.shared.shouldResignOnTouchOutside = sender.isOn
    }
    
    /**  Sound handling         */
    @objc func shouldPlayInputClicksAction (_ sender: UISwitch) {
        
        IQKeyboardManager.shared.shouldPlayInputClicks = sender.isOn
    }
    
    /**  Debugging         */
    @objc func enableDebugging (_ sender: UISwitch) {
        
        IQKeyboardManager.shared.enableDebugging = sender.isOn
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        #if swift(>=4.2)
        return UITableView.automaticDimension
        #else
        return UITableViewAutomaticDimension
        #endif
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch (section)
        {
        case 0:
            if IQKeyboardManager.shared.enable == true {
                
                let properties = keyboardManagerProperties[section]
                
                return properties.count
            } else {
                return 1
            }
            
        case 1:
            if IQKeyboardManager.shared.enableAutoToolbar == false {
                return 1
            } else if IQKeyboardManager.shared.shouldShowToolbarPlaceholder == false {
                return 4
            } else {
                let properties = keyboardManagerProperties[section]
                return properties.count
            }
            
        case 2:
            
            if IQKeyboardManager.shared.overrideKeyboardAppearance == true {
                
                let properties = keyboardManagerProperties[section]
                
                return properties.count
            } else {
                return 1
            }
            
        case 3,4,5:
            let properties = keyboardManagerProperties[section]
            
            return properties.count
            
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        return sectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        switch ((indexPath as NSIndexPath).section) {
        case 0:
    
            switch ((indexPath as NSIndexPath).row) {
     
            case 0:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell") as! SwitchTableViewCell
                cell.switchEnable.isEnabled = true
                
                cell.labelTitle.text = keyboardManagerProperties[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                
                cell.switchEnable.isOn = IQKeyboardManager.shared.enable
                
                cell.switchEnable.removeTarget(nil, action: nil, for: .allEvents)
                cell.switchEnable.addTarget(self, action: #selector(self.enableAction(_:)), for: .valueChanged)
                
                return cell
               
            case 1:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "StepperTableViewCell") as! StepperTableViewCell
                
                cell.labelTitle.text = keyboardManagerProperties[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                
                cell.stepper.value = Double(IQKeyboardManager.shared.keyboardDistanceFromTextField)
                cell.labelStepperValue.text = NSString(format: "%.0f", IQKeyboardManager.shared.keyboardDistanceFromTextField) as String
                
                cell.stepper.removeTarget(nil, action: nil, for: .allEvents)
                cell.stepper.addTarget(self, action: #selector(self.keyboardDistanceFromTextFieldAction(_:)), for: .valueChanged)
                
                return cell
            default:
                break
            }

            
        case 1:
            
            switch ((indexPath as NSIndexPath).row) {
                
            case 0:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell") as! SwitchTableViewCell
                cell.switchEnable.isEnabled = true
                
                cell.labelTitle.text = keyboardManagerProperties[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                
                cell.switchEnable.isOn = IQKeyboardManager.shared.enableAutoToolbar
                
                cell.switchEnable.removeTarget(nil, action: nil, for: .allEvents)
                cell.switchEnable.addTarget(self, action: #selector(self.enableAutoToolbarAction(_:)), for: .valueChanged)
                
                return cell

            case 1:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "NavigationTableViewCell") as! NavigationTableViewCell
                
                cell.labelTitle.text = keyboardManagerProperties[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                
                return cell

            case 2:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell") as! SwitchTableViewCell
                cell.switchEnable.isEnabled = true
                
                cell.labelTitle.text = keyboardManagerProperties[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                
                cell.switchEnable.isOn = IQKeyboardManager.shared.shouldToolbarUsesTextFieldTintColor
                
                cell.switchEnable.removeTarget(nil, action: nil, for: .allEvents)
                cell.switchEnable.addTarget(self, action: #selector(self.shouldToolbarUsesTextFieldTintColorAction(_:)), for: .valueChanged)
                
                return cell
                
            case 3:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell") as! SwitchTableViewCell
                cell.switchEnable.isEnabled = true
                
                cell.labelTitle.text = keyboardManagerProperties[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                
                cell.switchEnable.isOn = IQKeyboardManager.shared.shouldShowToolbarPlaceholder
                
                cell.switchEnable.removeTarget(nil, action: nil, for: .allEvents)
                cell.switchEnable.addTarget(self, action: #selector(self.shouldShowToolbarPlaceholder(_:)), for: .valueChanged)
                
                return cell
                
            case 4:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "NavigationTableViewCell") as! NavigationTableViewCell
                
                cell.labelTitle.text = keyboardManagerProperties[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                
                return cell
                
            case 5:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "ColorTableViewCell") as! ColorTableViewCell
                
                cell.labelTitle.text = keyboardManagerProperties[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                cell.colorPickerTextField.selectedColor = IQKeyboardManager.shared.toolbarTintColor
                cell.colorPickerTextField.tag = 15
                cell.colorPickerTextField.delegate = self
                
                return cell
                
            case 6:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "ImageSwitchTableViewCell") as! ImageSwitchTableViewCell
                cell.switchEnable.isEnabled = true
                
                cell.labelTitle.text = keyboardManagerProperties[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                cell.arrowImageView.image = IQKeyboardManager.shared.toolbarDoneBarButtonItemImage
                cell.switchEnable.isOn = IQKeyboardManager.shared.toolbarDoneBarButtonItemImage != nil
                
                cell.switchEnable.removeTarget(nil, action: nil, for: .allEvents)
                cell.switchEnable.addTarget(self, action: #selector(self.toolbarDoneBarButtonItemImage(_:)), for: .valueChanged)
                
                return cell

            case 7:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableViewCell") as! TextFieldTableViewCell
                
                cell.labelTitle.text = keyboardManagerProperties[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                cell.textField.text = IQKeyboardManager.shared.toolbarDoneBarButtonItemText
                cell.textField.tag = 17
                cell.textField.delegate = self
                
                return cell

            default:
                break
            }
            
        case 2:
            
            switch ((indexPath as NSIndexPath).row) {
                
            case 0:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell") as! SwitchTableViewCell
                cell.switchEnable.isEnabled = true
                
                cell.labelTitle.text = keyboardManagerProperties[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                
                cell.switchEnable.isOn = IQKeyboardManager.shared.overrideKeyboardAppearance
                
                cell.switchEnable.removeTarget(nil, action: nil, for: .allEvents)
                cell.switchEnable.addTarget(self, action: #selector(self.overrideKeyboardAppearanceAction(_:)), for: .valueChanged)
                
                return cell

            case 1:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "NavigationTableViewCell") as! NavigationTableViewCell
                
                cell.labelTitle.text = keyboardManagerProperties[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                
                return cell
                
            default:
                break
            }
            
            
        case 3:
            
            switch ((indexPath as NSIndexPath).row) {
                
            case 0:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell") as! SwitchTableViewCell
                cell.switchEnable.isEnabled = true
                
                cell.labelTitle.text = keyboardManagerProperties[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                
                cell.switchEnable.isOn = IQKeyboardManager.shared.shouldResignOnTouchOutside
                
                cell.switchEnable.removeTarget(nil, action: nil, for: .allEvents)
                cell.switchEnable.addTarget(self, action: #selector(self.shouldResignOnTouchOutsideAction(_:)), for: .valueChanged)
                
                return cell
                
            default:
                break
            }
            
        case 4:
            
            switch ((indexPath as NSIndexPath).row) {
                
            case 0:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell") as! SwitchTableViewCell
                cell.switchEnable.isEnabled = true
                
                cell.labelTitle.text = keyboardManagerProperties[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                
                cell.switchEnable.isOn = IQKeyboardManager.shared.shouldPlayInputClicks
                
                cell.switchEnable.removeTarget(nil, action: nil, for: .allEvents)
                cell.switchEnable.addTarget(self, action: #selector(self.shouldPlayInputClicksAction(_:)), for: .valueChanged)
                
                return cell
                
            default:
                break
            }
            
        case 5:
            
            switch ((indexPath as NSIndexPath).row) {
                
            case 0:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell") as! SwitchTableViewCell
                cell.switchEnable.isEnabled = true
                
                cell.labelTitle.text = keyboardManagerProperties[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                
                cell.switchEnable.isOn = IQKeyboardManager.shared.enableDebugging
                
                cell.switchEnable.removeTarget(nil, action: nil, for: .allEvents)
                cell.switchEnable.addTarget(self, action: #selector(self.enableDebugging(_:)), for: .valueChanged)
                
                return cell
                
            default:
                break
            }
            
        default:
            break
        }
        
        return UITableViewCell()
     }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func colorPickerTextField(_ textField: ColorPickerTextField, selectedColorAttributes colorAttributes: [String : Any] = [:]) {

        if textField.tag == 15 {
            let color = colorAttributes["color"] as! UIColor
            
            if color.isEqual(UIColor.clear) {
                IQKeyboardManager.shared.toolbarTintColor = nil
            } else {
                IQKeyboardManager.shared.toolbarTintColor = color
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {

        if textField.tag == 17 {
            IQKeyboardManager.shared.toolbarDoneBarButtonItemText = textField.text?.isEmpty == false ? textField.text : nil
        }
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let identifier = segue.identifier {
            
            if identifier == "OptionsViewController" {
                
                let controller = segue.destination as! OptionsViewController
                controller.delegate = self
                
                let cell = sender as! UITableViewCell
                
                selectedIndexPathForOptions = self.tableView.indexPath(for: cell)
                
                if let selectedIndexPath = selectedIndexPathForOptions {

                    if (selectedIndexPath as NSIndexPath).section == 1 && (selectedIndexPath as NSIndexPath).row == 1 {
                        
                        controller.title = "Toolbar Manage Behaviour"
                        controller.options = ["IQAutoToolbar By Subviews","IQAutoToolbar By Tag","IQAutoToolbar By Position"]
                        controller.selectedIndex = IQKeyboardManager.shared.toolbarManageBehaviour.hashValue
                        
                    } else if (selectedIndexPath as NSIndexPath).section == 1 && (selectedIndexPath as NSIndexPath).row == 4 {
                        
                        controller.title = "Fonts"
                        controller.options = ["Bold System Font","Italic system font","Regular"]
                        controller.selectedIndex = IQKeyboardManager.shared.toolbarManageBehaviour.hashValue
                        
                        let fonts = [UIFont.boldSystemFont(ofSize: 12),UIFont.italicSystemFont(ofSize: 12),UIFont.systemFont(ofSize: 12)]
                        
                        if let placeholderFont = IQKeyboardManager.shared.placeholderFont {
                            
                            if let index = fonts.index(of: placeholderFont) {
                                
                                controller.selectedIndex = index
                            }
                        }
                        
                    } else if (selectedIndexPath as NSIndexPath).section == 2 && (selectedIndexPath as NSIndexPath).row == 1 {
                        
                        controller.title = "Keyboard Appearance"
                        controller.options = ["UIKeyboardAppearance Default","UIKeyboardAppearance Dark","UIKeyboardAppearance Light"]
                        controller.selectedIndex = IQKeyboardManager.shared.keyboardAppearance.hashValue
                    }
                }
            }
        }
    }
    
    func optionsViewController(_ controller: OptionsViewController, index: NSInteger) {

        if let selectedIndexPath = selectedIndexPathForOptions {
            
            if (selectedIndexPath as NSIndexPath).section == 1 && (selectedIndexPath as NSIndexPath).row == 1 {
                IQKeyboardManager.shared.toolbarManageBehaviour = IQAutoToolbarManageBehaviour(rawValue: index)!
            } else if (selectedIndexPath as NSIndexPath).section == 1 && (selectedIndexPath as NSIndexPath).row == 4 {
                
                let fonts = [UIFont.boldSystemFont(ofSize: 12),UIFont.italicSystemFont(ofSize: 12),UIFont.systemFont(ofSize: 12)]
                IQKeyboardManager.shared.placeholderFont = fonts[index]
            } else if (selectedIndexPath as NSIndexPath).section == 2 && (selectedIndexPath as NSIndexPath).row == 1 {
                
                IQKeyboardManager.shared.keyboardAppearance = UIKeyboardAppearance(rawValue: index)!
            }
        }
    }
}
