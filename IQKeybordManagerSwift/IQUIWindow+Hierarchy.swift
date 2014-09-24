//
//  IQUIWindow+Hierarchy.swift
//  IQKeyboard
//
//  Created by Iftekhar on 21/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

import Foundation
import UIKit

extension UIWindow {

    /*! @return Returns the current Top Most ViewController in hierarchy.   */
    func topMostController()->UIViewController {
        
        var topController = rootViewController
        
        while (topController?.presentedViewController != nil) {
            topController = topController?.presentedViewController
        }
        
        return topController!
    }
    
    /*! @return Returns the topViewController in stack of topMostController.    */
    func currentViewController()->UIViewController {
        
        var currentViewController = topMostController()
        
        while (currentViewController is UINavigationController && (currentViewController as UINavigationController).topViewController != nil) {
            currentViewController = (currentViewController as UINavigationController).topViewController
        }

        return currentViewController
    }
}
