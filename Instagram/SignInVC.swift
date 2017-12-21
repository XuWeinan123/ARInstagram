//
//  SignInVC.swift
//  Instagram
//
//  Created by 徐炜楠 on 2017/10/27.
//  Copyright © 2017年 xuweinan. All rights reserved.
//

import UIKit
import AVOSCloud

class SignInVC: UIViewController {

    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet var signInBtn: UIButton!
    @IBOutlet var signUpBtn: UIButton!
    @IBOutlet var forgotBtn: UIButton!
    @IBOutlet weak var offlineBtn: UIButton!
    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        /*
        //UI自适应部分
        print("屏幕宽度是\(self.view.frame.width)，屏幕高度是\(self.view.frame.height)")
        label.frame = CGRect(x: 32, y: 72, width: self.view.frame.width-64, height: 50)
        
        usernameTxt.frame = CGRect(x: 32, y: 190, width: self.view.frame.width-64, height: 48)
        passwordTxt.frame = CGRect(x: 32, y: 238, width: self.view.frame.width-64, height: 48)
        usernameTxt.becomeFirstResponder()
        forgotBtn.frame = CGRect(x: 701, y: 357, width: 110, height: 38)
        signInBtn.frame = CGRect(x: 32, y: 306, width: self.view.frame.width-64, height: 40)
        signUpBtn.frame = CGRect(x:22,y:357,width:92,height:38)
        offlineBtn.frame = CGRect(x: self.view.frame.width/2-48, y: self.view.frame.height-40-30, width: 96, height: 30)
        */
        //label字体设置
        for supportTheFont: String in UIFont.familyNames {
            print("字体\(supportTheFont)")
        }
        label.font = UIFont(name: "pacifico", size: 25)
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func hideKeyboard(recognizer:UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    @IBAction func signInBtn_clicked(_ sender: UIButton) {
        print("登录按钮被单击")
        self.view.endEditing(true)
        
        if usernameTxt.text!.isEmpty||passwordTxt.text!.isEmpty{
            let alert = UIAlertController(title: "请注意", message: "请填写好所有的字段", preferredStyle: .alert)
            let ok = UIAlertAction(title:"OK",style:.cancel,handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            return
        }
        AVUser.logInWithUsername(inBackground: usernameTxt.text!, password: passwordTxt.text!, block: {(user:AVUser?,error:Error?) in
            if error == nil{
                UserDefaults.standard.set(user!.username, forKey: "username")
                UserDefaults.standard.synchronize()
                
                let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
            }else{
                print("登录错误\(error?.localizedDescription)")
            }
        })
    }
    @IBAction func offlineBtn_clicked(_ sender: UIButton) {
        UserDefaults.standard.set(false, forKey: "online")
        UserDefaults.standard.synchronize()
        
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.offline()
    }
}
