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
    
    let keyboardManagerProperties = [["Enable", "Keyboard Distance From TextField", "Prevent Showing Bottom Blank Space"],
    ["Enable AutoToolbar","Toolbar Manage Behaviour","Should Toolbar Uses TextField TintColor","Should Show TextField Placeholder","Placeholder Font","Toolbar Tint Color","Toolbar Done BarButtonItem Image","Toolbar Done Button Text"],
    ["Override Keyboard Appearance","UIKeyboard Appearance"],
    ["Should Resign On Touch Outside"],
    ["Should Play Input Clicks"],
    ["Debugging logs in Console"]]
    
    let keyboardManagerPropertyDetails = [["Enable/Disable IQKeyboardManager","Set keyboard distance from textField","Prevent to show blank space between UIKeyboard and View"],
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
    func enableAction (_ sender: UISwitch) {
        
        IQKeyboardManager.sharedManager().enable = sender.isOn
        
        self.tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.fade)
    }
    
    func keyboardDistanceFromTextFieldAction (_ sender: UIStepper) {
        
        IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = CGFloat(sender.value)
        
        self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: UITableViewRowAnimation.none)
    }
    
    func preventShowingBottomBlankSpaceAction (_ sender: UISwitch) {
        
        IQKeyboardManager.sharedManager().preventShowingBottomBlankSpace = sender.isOn
        
        self.tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.fade)
    }
    
    /**  IQToolbar handling     */
    func enableAutoToolbarAction (_ sender: UISwitch) {
        
        IQKeyboardManager.sharedManager().enableAutoToolbar = sender.isOn
        
        self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.fade)
    }
    
    func shouldToolbarUsesTextFieldTintColorAction (_ sender: UISwitch) {
        
        IQKeyboardManager.sharedManager().shouldToolbarUsesTextFieldTintColor = sender.isOn
    }
    
    func shouldShowTextFieldPlaceholder (_ sender: UISwitch) {
        
        IQKeyboardManager.sharedManager().shouldShowTextFieldPlaceholder = sender.isOn
        
        self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.fade)
    }
    
    func toolbarDoneBarButtonItemImage (_ sender: UISwitch) {
        
        if sender.isOn {
            IQKeyboardManager.sharedManager().toolbarDoneBarButtonItemImage = UIImage(named:"IQButtonBarArrowDown")
        } else {
            IQKeyboardManager.sharedManager().toolbarDoneBarButtonItemImage = nil
        }
        
        self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.fade)
    }

    /**  "Keyboard appearance overriding    */
    func overrideKeyboardAppearanceAction (_ sender: UISwitch) {
        
        IQKeyboardManager.sharedManager().overrideKeyboardAppearance = sender.isOn
        
        self.tableView.reloadSections(IndexSet(integer: 2), with: UITableViewRowAnimation.fade)
    }
    
    /**  Resign first responder handling    */
    func shouldResignOnTouchOutsideAction (_ sender: UISwitch) {
        
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = sender.isOn
    }
    
    /**  Sound handling         */
    func shouldPlayInputClicksAction (_ sender: UISwitch) {
        
        IQKeyboardManager.sharedManager().shouldPlayInputClicks = sender.isOn
    }
    
    /**  Debugging         */
    func enableDebugging (_ sender: UISwitch) {
        
        IQKeyboardManager.sharedManager().enableDebugging = sender.isOn
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch (section)
        {
        case 0:
            if IQKeyboardManager.sharedManager().enable == true {
                
                let properties = keyboardManagerProperties[section]
                
                return properties.count
            } else {
                return 1
            }
            
        case 1:
            if IQKeyboardManager.sharedManager().enableAutoToolbar == false {
                return 1
            } else if IQKeyboardManager.sharedManager().shouldShowTextFieldPlaceholder == false {
                return 4
            } else {
                let properties = keyboardManagerProperties[section]
                return properties.count
            }
            
        case 2:
            
            if IQKeyboardManager.sharedManager().overrideKeyboardAppearance == true {
                
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
                
                cell.switchEnable.isOn = IQKeyboardManager.sharedManager().enable
                
                cell.switchEnable.removeTarget(nil, action: nil, for: UIControlEvents.allEvents)
                cell.switchEnable.addTarget(self, action: #selector(self.enableAction(_:)), for: UIControlEvents.valueChanged)
                
                return cell
               
            case 1:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "StepperTableViewCell") as! StepperTableViewCell
                
                cell.labelTitle.text = keyboardManagerProperties[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                
                cell.stepper.value = Double(IQKeyboardManager.sharedManager().keyboardDistanceFromTextField)
                cell.labelStepperValue.text = NSString(format: "%.0f", IQKeyboardManager.sharedManager().keyboardDistanceFromTextField) as String
                
                cell.stepper.removeTarget(nil, action: nil, for: UIControlEvents.allEvents)
                cell.stepper.addTarget(self, action: #selector(self.keyboardDistanceFromTextFieldAction(_:)), for: UIControlEvents.valueChanged)
                
                return cell
                
            case 2:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell") as! SwitchTableViewCell
                cell.switchEnable.isEnabled = true
                
                cell.labelTitle.text = keyboardManagerProperties[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                
                cell.switchEnable.isOn = IQKeyboardManager.sharedManager().preventShowingBottomBlankSpace
                
                cell.switchEnable.removeTarget(nil, action: nil, for: UIControlEvents.allEvents)
                cell.switchEnable.addTarget(self, action: #selector(self.preventShowingBottomBlankSpaceAction(_:)), for: UIControlEvents.valueChanged)
                
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
                
                cell.switchEnable.isOn = IQKeyboardManager.sharedManager().enableAutoToolbar
                
                cell.switchEnable.removeTarget(nil, action: nil, for: UIControlEvents.allEvents)
                cell.switchEnable.addTarget(self, action: #selector(self.enableAutoToolbarAction(_:)), for: UIControlEvents.valueChanged)
                
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
                
                cell.switchEnable.isOn = IQKeyboardManager.sharedManager().shouldToolbarUsesTextFieldTintColor
                
                cell.switchEnable.removeTarget(nil, action: nil, for: UIControlEvents.allEvents)
                cell.switchEnable.addTarget(self, action: #selector(self.shouldToolbarUsesTextFieldTintColorAction(_:)), for: UIControlEvents.valueChanged)
                
                return cell
                
            case 3:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell") as! SwitchTableViewCell
                cell.switchEnable.isEnabled = true
                
                cell.labelTitle.text = keyboardManagerProperties[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                
                cell.switchEnable.isOn = IQKeyboardManager.sharedManager().shouldShowTextFieldPlaceholder
                
                cell.switchEnable.removeTarget(nil, action: nil, for: UIControlEvents.allEvents)
                cell.switchEnable.addTarget(self, action: #selector(self.shouldShowTextFieldPlaceholder(_:)), for: UIControlEvents.valueChanged)
                
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
                cell.colorPickerTextField.selectedColor = IQKeyboardManager.sharedManager().toolbarTintColor
                cell.colorPickerTextField.tag = 15
                cell.colorPickerTextField.delegate = self
                
                return cell
                
            case 6:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "ImageSwitchTableViewCell") as! ImageSwitchTableViewCell
                cell.switchEnable.isEnabled = true
                
                cell.labelTitle.text = keyboardManagerProperties[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                cell.arrowImageView.image = IQKeyboardManager.sharedManager().toolbarDoneBarButtonItemImage
                cell.switchEnable.isOn = IQKeyboardManager.sharedManager().toolbarDoneBarButtonItemImage != nil
                
                cell.switchEnable.removeTarget(nil, action: nil, for: UIControlEvents.allEvents)
                cell.switchEnable.addTarget(self, action: #selector(self.toolbarDoneBarButtonItemImage(_:)), for: UIControlEvents.valueChanged)
                
                return cell

            case 7:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableViewCell") as! TextFieldTableViewCell
                
                cell.labelTitle.text = keyboardManagerProperties[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                cell.textField.text = IQKeyboardManager.sharedManager().toolbarDoneBarButtonItemText
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
                
                cell.switchEnable.isOn = IQKeyboardManager.sharedManager().overrideKeyboardAppearance
                
                cell.switchEnable.removeTarget(nil, action: nil, for: UIControlEvents.allEvents)
                cell.switchEnable.addTarget(self, action: #selector(self.overrideKeyboardAppearanceAction(_:)), for: UIControlEvents.valueChanged)
                
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
                
                cell.switchEnable.isOn = IQKeyboardManager.sharedManager().shouldResignOnTouchOutside
                
                cell.switchEnable.removeTarget(nil, action: nil, for: UIControlEvents.allEvents)
                cell.switchEnable.addTarget(self, action: #selector(self.shouldResignOnTouchOutsideAction(_:)), for: UIControlEvents.valueChanged)
                
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
                
                cell.switchEnable.isOn = IQKeyboardManager.sharedManager().shouldPlayInputClicks
                
                cell.switchEnable.removeTarget(nil, action: nil, for: UIControlEvents.allEvents)
                cell.switchEnable.addTarget(self, action: #selector(self.shouldPlayInputClicksAction(_:)), for: UIControlEvents.valueChanged)
                
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
                
                cell.switchEnable.isOn = IQKeyboardManager.sharedManager().enableDebugging
                
                cell.switchEnable.removeTarget(nil, action: nil, for: UIControlEvents.allEvents)
                cell.switchEnable.addTarget(self, action: #selector(self.enableDebugging(_:)), for: UIControlEvents.valueChanged)
                
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
    
    private func colorPickerTextField(_ textField: ColorPickerTextField, selectedColorAttributes colorAttributes: [String : AnyObject]) {

        if textField.tag == 15 {
            let color = colorAttributes["color"] as! UIColor
            
            if color.isEqual(UIColor.clear) {
                IQKeyboardManager.sharedManager().toolbarTintColor = nil
            } else {
                IQKeyboardManager.sharedManager().toolbarTintColor = color
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {

        if textField.tag == 17 {
            IQKeyboardManager.sharedManager().toolbarDoneBarButtonItemText = textField.text?.characters.count != 0 ? textField.text : nil
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
                        controller.selectedIndex = IQKeyboardManager.sharedManager().toolbarManageBehaviour.hashValue
                        
                    } else if (selectedIndexPath as NSIndexPath).section == 1 && (selectedIndexPath as NSIndexPath).row == 4 {
                        
                        controller.title = "Fonts"
                        controller.options = ["Bold System Font","Italic system font","Regular"]
                        controller.selectedIndex = IQKeyboardManager.sharedManager().toolbarManageBehaviour.hashValue
                        
                        let fonts = [UIFont.boldSystemFont(ofSize: 12),UIFont.italicSystemFont(ofSize: 12),UIFont.systemFont(ofSize: 12)]
                        
                        if let placeholderFont = IQKeyboardManager.sharedManager().placeholderFont {
                            
                            if let index = fonts.index(of: placeholderFont) {
                                
                                controller.selectedIndex = index
                            }
                        }
                        
                    } else if (selectedIndexPath as NSIndexPath).section == 2 && (selectedIndexPath as NSIndexPath).row == 1 {
                        
                        controller.title = "Keyboard Appearance"
                        controller.options = ["UIKeyboardAppearance Default","UIKeyboardAppearance Dark","UIKeyboardAppearance Light"]
                        controller.selectedIndex = IQKeyboardManager.sharedManager().keyboardAppearance.hashValue
                    }
                }
            }
        }
    }
    
    func optionsViewController(_ controller: OptionsViewController, index: NSInteger) {

        if let selectedIndexPath = selectedIndexPathForOptions {
            
            if (selectedIndexPath as NSIndexPath).section == 1 && (selectedIndexPath as NSIndexPath).row == 1 {
                IQKeyboardManager.sharedManager().toolbarManageBehaviour = IQAutoToolbarManageBehaviour(rawValue: index)!
            } else if (selectedIndexPath as NSIndexPath).section == 1 && (selectedIndexPath as NSIndexPath).row == 4 {
                
                let fonts = [UIFont.boldSystemFont(ofSize: 12),UIFont.italicSystemFont(ofSize: 12),UIFont.systemFont(ofSize: 12)]
                IQKeyboardManager.sharedManager().placeholderFont = fonts[index]
            } else if (selectedIndexPath as NSIndexPath).section == 2 && (selectedIndexPath as NSIndexPath).row == 1 {
                
                IQKeyboardManager.sharedManager().keyboardAppearance = UIKeyboardAppearance(rawValue: index)!
            }
        }
    }
}
