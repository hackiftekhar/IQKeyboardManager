//
//  NavigationController.swift
//  DemoSwift
//
//  Created by Iftekhar on 10/5/23.
//  Copyright © 2023 Iftekhar. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.barTintColor = UIColor.white

        if #available(iOS 13.0, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithTransparentBackground()
            navigationBarAppearance.backgroundColor = UIColor.white

            navigationBar.standardAppearance = navigationBarAppearance
            navigationBar.compactAppearance = navigationBarAppearance
            navigationBar.scrollEdgeAppearance = navigationBarAppearance
            if #available(iOS 15.0, *) {
                navigationBar.compactScrollEdgeAppearance = navigationBarAppearance
            }
        }

        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        if let tabBarController = tabBarController {
            return tabBarController.preferredStatusBarUpdateAnimation
        } else {
            return .fade
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let tabBarController = tabBarController {
            return tabBarController.preferredStatusBarStyle
        } else {
            return .lightContent
        }
    }
}
