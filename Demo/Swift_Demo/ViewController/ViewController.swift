//
//  ViewController.swift
//  swift test
//
//  Created by Iftekhar on 22/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class ViewController: UITableViewController, UIPopoverPresentationControllerDelegate {

    @IBAction func shareClicked (_ sender : UIBarButtonItem) {
        
        let shareString : String = "IQKeyboardManager is really great control for iOS developer to manage keyboard-textField."
        let shareImage : UIImage = UIImage(named: "IQKeyboardManagerScreenshot")!
        let youtubeUrl : URL = URL(string: "http://youtu.be/6nhLw6hju2A")!
        
        var activityItems = [Any]()
        activityItems.append(shareString)
        activityItems.append(shareImage)
        activityItems.append(youtubeUrl)

        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        controller.excludedActivityTypes = [.print,.copyToPasteboard,.assignToContact,.saveToCameraRoll]
        present(controller, animated: true) { () -> Void in

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared.toolbarManageBehaviour = IQAutoToolbarManageBehaviour.byPosition
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifier = segue.identifier {
            
            if identifier == "SettingsNavigationController" {
                
                let controller = segue.destination
                
                controller.modalPresentationStyle = .popover
                controller.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
                controller.popoverPresentationController?.sourceView = sender as? UIView

                let heightWidth = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height);
                controller.preferredContentSize = CGSize(width: heightWidth, height: heightWidth)
                controller.popoverPresentationController?.delegate = self
            }
            else if identifier == "PopoverViewController" {
                let controller = segue.destination
                
                controller.modalPresentationStyle = .popover
                
                controller.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
                controller.popoverPresentationController?.sourceView = sender as? UIView
                
                let heightWidth = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height);
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
    
    override var shouldAutorotate : Bool {
        return true
    }
}
