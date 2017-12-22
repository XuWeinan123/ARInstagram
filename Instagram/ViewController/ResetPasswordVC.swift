//
//  ResetPasswordVC.swift
//  Instagram
//
//  Created by 徐炜楠 on 2017/10/27.
//  Copyright © 2017年 xuweinan. All rights reserved.
//

import UIKit
import AVOSCloud

class ResetPasswordVC: UIViewController {

    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        //调整UI
        emailTxt.frame = CGRect(x: 32, y: 72, width: self.view.frame.width-64, height: 48)
        resetBtn.frame = CGRect(x: 32, y: emailTxt.frame.origin.y+68, width: self.view.frame.width-64, height: 40)
        cancelBtn.frame = CGRect(x: 32, y: resetBtn.frame.origin.y+60, width: self.view.frame.width-64, height: 40)
        cancelBtn.layer.cornerRadius = 4
        // Do any additional setup after loading theme view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func resetBtn_clicked(_ sender: Any) {
        self.view.endEditing(true)
        if emailTxt.text!.isEmpty{
            let alert = UIAlertController(title: "请注意", message: "电子邮件不能为空", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        AVUser.requestPasswordResetForEmail(inBackground: emailTxt.text!, block: {
            (success:Bool,error:Error?) in
            if success {
                let alert = UIAlertController(title: "OK", message: "重置密码链接已经发送到您的电子邮箱", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: {(_) in
                    self.dismiss(animated: true, completion: nil)
                })
                alert.addAction(ok)
                self.present(alert,animated: true,completion: nil)
            }else{
                print(error?.localizedDescription)
            }
        })
    }
        
    @IBAction func cancelBtn_clicked(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
