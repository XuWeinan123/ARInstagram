//
//  TabBarVC.swift
//  Instagram
//
//  Created by 徐炜楠 on 2017/11/5.
//  Copyright © 2017年 xuweinan. All rights reserved.
//

import UIKit

class TabBarVC: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.tintColor = UIColor.darkText
        
        self.tabBar.barTintColor = UIColor.white
        
        self.tabBar.isTranslucent = false
        selectedIndex = 1   ;
    }
}
