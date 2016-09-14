//
//  RefreshLayoutViewController.swift
//  Demo
//
//  Created by IEMacBook01 on 23/05/16.
//  Copyright © 2016 Iftekhar. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class RefreshLayoutViewController: UIViewController {

    @IBOutlet var textViewHeightConstraint : NSLayoutConstraint!
    
    @IBAction func stepperChanged (_ sender : UIStepper) {

        let animationCurve = UIViewAnimationOptions.init(rawValue: 7)
        let animationDuration : TimeInterval = 0.3;

        UIView.animate(withDuration: animationDuration, delay: 0, options: UIViewAnimationOptions.beginFromCurrentState.union(animationCurve), animations: { () -> Void in

            self.textViewHeightConstraint.constant = CGFloat(sender.value);

            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }) { (animated:Bool) -> Void in}
    }

    @IBAction func reloadLayoutAction (_ sender : UIButton) {
        IQKeyboardManager.sharedManager().reloadLayoutIfNeeded()
    }
}
