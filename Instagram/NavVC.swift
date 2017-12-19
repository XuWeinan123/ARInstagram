//
//  NavVC.swift
//  Instagram
//
//  Created by 徐炜楠 on 2017/11/5.
//  Copyright © 2017年 xuweinan. All rights reserved.
//

import UIKit

class NavVC: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //导航栏中Title颜色的设置
        self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.darkText]
        //导航栏中按钮颜色的设置
        self.navigationBar.tintColor = UIColor.darkText
        //导航栏的背景色
        self.navigationBar.barTintColor = UIColor.white
        //不允许透明
        self.navigationBar.isTranslucent = false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.default
    }

}
