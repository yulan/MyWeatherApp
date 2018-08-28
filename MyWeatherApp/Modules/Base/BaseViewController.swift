//
//  BaseViewController.swift
//  MyWeatherApp
//
//  Created by Lan on 06/08/2018.
//  Copyright © 2018 Lan YU. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    // Override the tab bar tranparent behavior
    var isTabBarTranparent: Bool = false {
        didSet {
            self.isNavigationBarGradient = isTabBarTranparent
            if self.isTabBarTranparent {
                UIScrollView.appearance().contentInsetAdjustmentBehavior = .never
                self.setNavigationBarTranslucent()
            }
        }
    }

    fileprivate func setNavigationBarTranslucent(_ isTranslucent: Bool = true) {
        // Override point for customization after application launch.
        // Sets background to a blank/empty image
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        // Sets shadow (line below the bar) to a blank image
        self.navigationController?.navigationBar.shadowImage = isTranslucent ? UIImage() : nil
        // Sets the translucent background color
        self.navigationController?.navigationBar.backgroundColor = isTranslucent ? .clear : nil
        // Set translucent. (Default value is already true, so this can be removed if desired.)
        self.navigationController?.navigationBar.isTranslucent = isTranslucent
    }
    
    // Override the tab bar hidden behavior
    // default: false
    var isTabBarHidden: Bool {
        return false
    }
    
    var isNavigationBarGradient: Bool = false
    
    let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension BaseViewController: UIScrollViewDelegate {
    
    // MARK: UIScrollViewDelegate
    
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            
            guard self.isNavigationBarGradient else { return }
            
            let offsetY = scrollView.contentOffset.y
            if offsetY >= 0 && offsetY < 64 {
                let progress = offsetY / 64
                let themeColor = UIColor.white.withAlphaComponent(progress)
                self.navigationController?.navigationBar.backgroundColor = themeColor
                self.statusBarView.backgroundColor = UIColor.white.withAlphaComponent(progress)
                if !self.view.subviews.contains(statusBarView) {
                    view.addSubview(statusBarView)
                }
            } else if offsetY < 0  {
                self.setNavigationBarTranslucent()
            } else {

            }
        }
    
}
