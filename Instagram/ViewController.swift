//
//  ViewController.swift
//  Instagram
//
//  Created by 徐炜楠 on 2017/10/27.
//  Copyright © 2017年 xuweinan. All rights reserved.
//

import UIKit
import LeanCloud

class ViewController: UIViewController {
    let post = LCObject(className: "TestObject")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        post.set("words", value: "Hello World!")
        post.save()
        print("成功")
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

