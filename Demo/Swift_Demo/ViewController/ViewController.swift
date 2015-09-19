//
//  ViewController.swift
//  swift test
//
//  Created by Iftekhar on 22/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    @IBAction func shareClicked (sender : UIBarButtonItem) {
        
        let shareString : String = "IQKeyboardManager is really great control for iOS developer to manage keyboard-textField."
        let shareImage : UIImage = UIImage(named: "IQKeyboardManagerScreenshot")!
        let youtubeUrl : NSURL = NSURL(string: "http://youtu.be/6nhLw6hju2A")!
        
        var activityItems = [NSObject]()
        activityItems.append(shareString)
        activityItems.append(shareImage)
        activityItems.append(youtubeUrl)

        let excludedActivities = [String]()
        activityItems.append(UIActivityTypePrint)
        activityItems.append(UIActivityTypeCopyToPasteboard)
        activityItems.append(UIActivityTypeAssignToContact)
        activityItems.append(UIActivityTypeSaveToCameraRoll)
        
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        controller.excludedActivityTypes = excludedActivities
        presentViewController(controller, animated: true) { () -> Void in

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.sharedManager().toolbarManageBehaviour = IQAutoToolbarManageBehaviour.ByPosition
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func shouldAutorotate() -> Bool {
        return false
    }
    
//    override func supportedInterfaceOrientations() -> Int {
//        return UIInterfaceOrientationMask.Portrait
//    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }
}
