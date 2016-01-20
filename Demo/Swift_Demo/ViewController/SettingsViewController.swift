//
//  SettingsViewController.swift
//  Demo
//
//  Created by Iftekhar on 26/08/15.
//  Copyright (c) 2015 Iftekhar. All rights reserved.
//


class SettingsViewController: UITableViewController, OptionsViewControllerDelegate {

    let sectionTitles = [
        "UIKeyboard handling",
        "IQToolbar handling",
        "UITextView handling",
        "UIKeyboard appearance overriding",
        "Resign first responder handling",
        "UISound handling",
        "UIAnimation handling"]
    
    let keyboardManagerProperties = [
        ["Enable", "Keyboard Distance From TextField", "Prevent Showing Bottom Blank Space"],
        ["Enable AutoToolbar","Toolbar Manage Behaviour","Should Toolbar Uses TextField TintColor","Should Show TextField Placeholder","Placeholder Font"],
        ["Can Adjust TextView","Should Fix TextView Clip"],
        ["Override Keyboard Appearance","UIKeyboard Appearance"],
        ["Should Resign On Touch Outside"],
        ["Should Play Input Clicks"],
        ["Should Adopt Default Keyboard Animation"]]
    
    let keyboardManagerPropertyDetails = [
        ["Enable/Disable IQKeyboardManager","Set keyboard distance from textField","Prevent to show blank space between UIKeyboard and View"],
        ["Automatic add the IQToolbar on UIKeyboard","AutoToolbar previous/next button managing behaviour","Uses textField's tintColor property for IQToolbar","Add the textField's placeholder text on IQToolbar","UIFont for IQToolbar placeholder text"],
        ["Adjust textView's frame when it is too big in height","Adjust textView's contentInset to fix a bug"],
        ["Override the keyboardAppearance for all UITextField/UITextView","All the UITextField keyboardAppearance is set using this property"],
        ["Resigns Keyboard on touching outside of UITextField/View"],
        ["Plays inputClick sound on next/previous/done click"],
        ["Uses keyboard default animation curve style to move view"]]
        
    var selectedIndexPathForOptions : NSIndexPath?
    
    
    @IBAction func doneAction (sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /**  UIKeyboard Handling    */
    func enableAction (sender: UISwitch) {
        
        IQKeyboardManager.sharedManager().enable = sender.on
        
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func keyboardDistanceFromTextFieldAction (sender: UIStepper) {
        
        IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = CGFloat(sender.value)
        
        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
    }
    
    func preventShowingBottomBlankSpaceAction (sender: UISwitch) {
        
        IQKeyboardManager.sharedManager().preventShowingBottomBlankSpace = sender.on
        
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    /**  IQToolbar handling     */
    func enableAutoToolbarAction (sender: UISwitch) {
        
        IQKeyboardManager.sharedManager().enableAutoToolbar = sender.on
        
        self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func shouldToolbarUsesTextFieldTintColorAction (sender: UISwitch) {
        
        IQKeyboardManager.sharedManager().shouldToolbarUsesTextFieldTintColor = sender.on
    }
    
    func shouldShowTextFieldPlaceholder (sender: UISwitch) {
        
        IQKeyboardManager.sharedManager().shouldShowTextFieldPlaceholder = sender.on
        
        self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    /**  UITextView handling    */
    func canAdjustTextViewAction (sender: UISwitch) {
        
        IQKeyboardManager.sharedManager().canAdjustTextView = sender.on
        
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func shouldFixTextViewClipAction (sender: UISwitch) {
        
        IQKeyboardManager.sharedManager().shouldFixTextViewClip = sender.on
        
        self.tableView.reloadSections(NSIndexSet(index: 3), withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    /**  "Keyboard appearance overriding    */
    func overrideKeyboardAppearanceAction (sender: UISwitch) {
        
        IQKeyboardManager.sharedManager().overrideKeyboardAppearance = sender.on
        
        self.tableView.reloadSections(NSIndexSet(index: 3), withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    /**  Resign first responder handling    */
    func shouldResignOnTouchOutsideAction (sender: UISwitch) {
        
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = sender.on
    }
    
    /**  Sound handling         */
    func shouldPlayInputClicksAction (sender: UISwitch) {
        
        IQKeyboardManager.sharedManager().shouldPlayInputClicks = sender.on
    }
    
    /**  Animation handling     */
    func shouldAdoptDefaultKeyboardAnimation (sender: UISwitch) {
        
        IQKeyboardManager.sharedManager().shouldAdoptDefaultKeyboardAnimation = sender.on
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionTitles.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
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
            
        case 3:
            
            if IQKeyboardManager.sharedManager().overrideKeyboardAppearance == true {
                
                let properties = keyboardManagerProperties[section]
                
                return properties.count
            } else {
                return 1
            }
            
        case 2,4,5,6:
            let properties = keyboardManagerProperties[section]
            
            return properties.count
            
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        return sectionTitles[section]
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        switch (indexPath.section) {
        case 0:
    
            switch (indexPath.row) {
     
            case 0:
                
                let cell = tableView.dequeueReusableCellWithIdentifier("SwitchTableViewCell") as! SwitchTableViewCell
                cell.switchEnable.enabled = true
                
                cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row]
                
                cell.switchEnable.on = IQKeyboardManager.sharedManager().enable
                
                cell.switchEnable.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.AllEvents)
                cell.switchEnable.addTarget(self, action: Selector("enableAction:"), forControlEvents: UIControlEvents.ValueChanged)
                
                return cell
               
            case 1:
                
                let cell = tableView.dequeueReusableCellWithIdentifier("StepperTableViewCell") as! StepperTableViewCell
                
                cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row]
                
                cell.stepper.value = Double(IQKeyboardManager.sharedManager().keyboardDistanceFromTextField)
                cell.labelStepperValue.text = NSString(format: "%.0f", IQKeyboardManager.sharedManager().keyboardDistanceFromTextField) as String
                
                cell.stepper.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.AllEvents)
                cell.stepper.addTarget(self, action: Selector("keyboardDistanceFromTextFieldAction:"), forControlEvents: UIControlEvents.ValueChanged)
                
                return cell
                
            case 2:
                
                let cell = tableView.dequeueReusableCellWithIdentifier("SwitchTableViewCell") as! SwitchTableViewCell
                cell.switchEnable.enabled = true
                
                cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row]
                
                cell.switchEnable.on = IQKeyboardManager.sharedManager().preventShowingBottomBlankSpace
                
                cell.switchEnable.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.AllEvents)
                cell.switchEnable.addTarget(self, action: Selector("preventShowingBottomBlankSpaceAction:"), forControlEvents: UIControlEvents.ValueChanged)
                
                return cell
                
            default:
                break
            }

            
        case 1:
            
            switch (indexPath.row) {
                
            case 0:
                
                let cell = tableView.dequeueReusableCellWithIdentifier("SwitchTableViewCell") as! SwitchTableViewCell
                cell.switchEnable.enabled = true
                
                cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row]
                
                cell.switchEnable.on = IQKeyboardManager.sharedManager().enableAutoToolbar
                
                cell.switchEnable.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.AllEvents)
                cell.switchEnable.addTarget(self, action: Selector("enableAutoToolbarAction:"), forControlEvents: UIControlEvents.ValueChanged)
                
                return cell

            case 1:
                
                let cell = tableView.dequeueReusableCellWithIdentifier("NavigationTableViewCell") as! NavigationTableViewCell
                
                cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row]
                
                return cell

            case 2:
                
                let cell = tableView.dequeueReusableCellWithIdentifier("SwitchTableViewCell") as! SwitchTableViewCell
                cell.switchEnable.enabled = true
                
                cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row]
                
                cell.switchEnable.on = IQKeyboardManager.sharedManager().shouldToolbarUsesTextFieldTintColor
                
                cell.switchEnable.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.AllEvents)
                cell.switchEnable.addTarget(self, action: Selector("shouldToolbarUsesTextFieldTintColorAction:"), forControlEvents: UIControlEvents.ValueChanged)
                
                return cell
                
            case 3:
                
                let cell = tableView.dequeueReusableCellWithIdentifier("SwitchTableViewCell") as! SwitchTableViewCell
                cell.switchEnable.enabled = true
                
                cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row]
                
                cell.switchEnable.on = IQKeyboardManager.sharedManager().shouldShowTextFieldPlaceholder
                
                cell.switchEnable.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.AllEvents)
                cell.switchEnable.addTarget(self, action: Selector("shouldShowTextFieldPlaceholder:"), forControlEvents: UIControlEvents.ValueChanged)
                
                return cell
                
            case 4:
                
                let cell = tableView.dequeueReusableCellWithIdentifier("NavigationTableViewCell") as! NavigationTableViewCell
                
                cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row]
                
                return cell
                
            default:
                break
            }
            
            
        case 2:
            
            switch (indexPath.row) {
                
            case 0:
                
                let cell = tableView.dequeueReusableCellWithIdentifier("SwitchTableViewCell") as! SwitchTableViewCell
                cell.switchEnable.enabled = true
                
                cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row]
                
                cell.switchEnable.on = IQKeyboardManager.sharedManager().canAdjustTextView
                
                cell.switchEnable.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.AllEvents)
                cell.switchEnable.addTarget(self, action: Selector("canAdjustTextViewAction:"), forControlEvents: UIControlEvents.ValueChanged)
                
                return cell

            case 1:
                
                let cell = tableView.dequeueReusableCellWithIdentifier("SwitchTableViewCell") as! SwitchTableViewCell
                cell.switchEnable.enabled = true
                
                cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row]
                
                cell.switchEnable.on = IQKeyboardManager.sharedManager().shouldFixTextViewClip
                
                cell.switchEnable.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.AllEvents)
                cell.switchEnable.addTarget(self, action: Selector("shouldFixTextViewClipwAction:"), forControlEvents: UIControlEvents.ValueChanged)
                
                return cell
                
            default:
                break
            }
            
            
        case 3:
            
            switch (indexPath.row) {
                
            case 0:
                
                let cell = tableView.dequeueReusableCellWithIdentifier("SwitchTableViewCell") as! SwitchTableViewCell
                cell.switchEnable.enabled = true
                
                cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row]
                
                cell.switchEnable.on = IQKeyboardManager.sharedManager().overrideKeyboardAppearance
                
                cell.switchEnable.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.AllEvents)
                cell.switchEnable.addTarget(self, action: Selector("overrideKeyboardAppearanceAction:"), forControlEvents: UIControlEvents.ValueChanged)
                
                return cell

            case 1:
                
                let cell = tableView.dequeueReusableCellWithIdentifier("NavigationTableViewCell") as! NavigationTableViewCell
                
                cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row]
                
                return cell
                
            default:
                break
            }
            
            
        case 4:
            
            switch (indexPath.row) {
                
            case 0:
                
                let cell = tableView.dequeueReusableCellWithIdentifier("SwitchTableViewCell") as! SwitchTableViewCell
                cell.switchEnable.enabled = true
                
                cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row]
                
                cell.switchEnable.on = IQKeyboardManager.sharedManager().shouldResignOnTouchOutside
                
                cell.switchEnable.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.AllEvents)
                cell.switchEnable.addTarget(self, action: Selector("shouldResignOnTouchOutsideAction:"), forControlEvents: UIControlEvents.ValueChanged)
                
                return cell
                
            default:
                break
            }
            
        case 5:
            
            switch (indexPath.row) {
                
            case 0:
                
                let cell = tableView.dequeueReusableCellWithIdentifier("SwitchTableViewCell") as! SwitchTableViewCell
                cell.switchEnable.enabled = true
                
                cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row]
                
                cell.switchEnable.on = IQKeyboardManager.sharedManager().shouldPlayInputClicks
                
                cell.switchEnable.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.AllEvents)
                cell.switchEnable.addTarget(self, action: Selector("shouldPlayInputClicksAction:"), forControlEvents: UIControlEvents.ValueChanged)
                
                return cell
                
            default:
                break
            }
            
        case 6:
            
            switch (indexPath.row) {
                
            case 0:
                
                let cell = tableView.dequeueReusableCellWithIdentifier("SwitchTableViewCell") as! SwitchTableViewCell
                cell.switchEnable.enabled = true
                
                cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row]
                
                cell.switchEnable.on = IQKeyboardManager.sharedManager().shouldAdoptDefaultKeyboardAnimation
                
                cell.switchEnable.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.AllEvents)
                cell.switchEnable.addTarget(self, action: Selector("shouldAdoptDefaultKeyboardAnimation:"), forControlEvents: UIControlEvents.ValueChanged)
                
                return cell
                
            default:
                break
            }

        default:
            break
        }
        
        return UITableViewCell()
     }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if let identifier = segue.identifier {
            
            if identifier == "OptionsViewController" {
                
                let controller = segue.destinationViewController as! OptionsViewController
                controller.delegate = self
                
                let cell = sender as! UITableViewCell
                
                selectedIndexPathForOptions = self.tableView.indexPathForCell(cell)
                
                if let selectedIndexPath = selectedIndexPathForOptions {

                    if selectedIndexPath.section == 1 && selectedIndexPath.row == 1 {
                        
                        controller.title = "Toolbar Manage Behaviour"
                        controller.options = ["IQAutoToolbar By Subviews","IQAutoToolbar By Tag","IQAutoToolbar By Position"]
                        controller.selectedIndex = IQKeyboardManager.sharedManager().toolbarManageBehaviour.hashValue
                        
                    } else if selectedIndexPath.section == 1 && selectedIndexPath.row == 4 {
                        
                        controller.title = "Fonts"
                        controller.options = ["Bold System Font","Italic system font","Regular"]
                        controller.selectedIndex = IQKeyboardManager.sharedManager().toolbarManageBehaviour.hashValue
                        
                        let fonts = [UIFont.boldSystemFontOfSize(12),UIFont.italicSystemFontOfSize(12),UIFont.systemFontOfSize(12)]
                        
                        if let placeholderFont = IQKeyboardManager.sharedManager().placeholderFont {
                            
                            if let index = fonts.indexOf(placeholderFont) {
                                
                                controller.selectedIndex = index
                            }
                        }
                        
                    } else if selectedIndexPath.section == 3 && selectedIndexPath.row == 1 {
                        
                        controller.title = "Keyboard Appearance"
                        controller.options = ["UIKeyboardAppearance Default","UIKeyboardAppearance Dark","UIKeyboardAppearance Light"]
                        controller.selectedIndex = IQKeyboardManager.sharedManager().keyboardAppearance.hashValue
                    }
                }
            }
        }
    }
    
    func optionsViewController(controller: OptionsViewController, index: NSInteger) {

        if let selectedIndexPath = selectedIndexPathForOptions {
            
            if selectedIndexPath.section == 1 && selectedIndexPath.row == 1 {
                IQKeyboardManager.sharedManager().toolbarManageBehaviour = IQAutoToolbarManageBehaviour(rawValue: index)!
            } else if selectedIndexPath.section == 1 && selectedIndexPath.row == 4 {
                
                let fonts = [UIFont.boldSystemFontOfSize(12),UIFont.italicSystemFontOfSize(12),UIFont.systemFontOfSize(12)]
                IQKeyboardManager.sharedManager().placeholderFont = fonts[index]
            } else if selectedIndexPath.section == 3 && selectedIndexPath.row == 1 {
                
                IQKeyboardManager.sharedManager().keyboardAppearance = UIKeyboardAppearance(rawValue: index)!
            }
        }
    }
}
