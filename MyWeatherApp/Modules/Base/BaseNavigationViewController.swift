//
//  BaseNavigationViewController.swift
//  MyWeatherApp
//
//  Created by Lan on 03/08/2018.
//  Copyright © 2018 Lan YU. All rights reserved.
//

import UIKit

class BaseNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
        guard self.navigationBar.subviews.count > 2 else {
            return
        }
        
        self.navigationBar.subviews[0].isHidden = true
        self.navigationBar.subviews[1].alpha = 0
    }
    
    
    fileprivate func setNavigationBarTranslucent() {
        // Override point for customization after application launch.
        // Sets background to a blank/empty image
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        // Sets shadow (line below the bar) to a blank image
        UINavigationBar.appearance().shadowImage = UIImage()
        // Sets the translucent background color
        UINavigationBar.appearance().backgroundColor = .clear
        // Set translucent. (Default value is already true, so this can be removed if desired.)
        UINavigationBar.appearance().isTranslucent = true
    }

}
