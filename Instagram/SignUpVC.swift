
//
//  SignUpVC.swift
//  Instagram
//
//  Created by 徐炜楠 on 2017/10/27.
//  Copyright © 2017年 xuweinan. All rights reserved.
//

import UIKit
import AVOSCloud

class SignUpVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var repeatPasswordTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var fullnameTxt: UITextField!
    @IBOutlet weak var bioTxt: UITextField!
    @IBOutlet weak var webTxt: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    var scrollViewHeight:CGFloat = 0
    var keyboard:CGRect = CGRect()
    
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var signUpBtnWidth: NSLayoutConstraint!
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        //UI元素布局
        let viewWidth = self.view.frame.width
        cancelBtn.frame = CGRect(x: 32, y: 72, width: 32, height: 32)
        avaImg.frame = CGRect(x:self.view.frame.width/2-72,y:72,width:144,height:144)
        😎必填.frame = CGRect(x: 42, y: avaImg.frame.origin.y+192, width: 37, height: 18)
        usernameTxt.frame = CGRect(x: 32, y: 😎必填.frame.origin.y+33, width: viewWidth-64, height: 48)
        passwordTxt.frame = CGRect(x: 32, y: usernameTxt.frame.origin.y+48, width: viewWidth-64, height: 48)
        repeatPasswordTxt.frame = CGRect(x: 32, y: passwordTxt.frame.origin.y+48, width: viewWidth-64, height: 48)
        emailTxt.frame = CGRect(x: 32, y: repeatPasswordTxt.frame.origin.y+48, width: viewWidth-64, height: 48)
        😂😱🤩.frame = CGRect(x: 42, y: emailTxt.frame.origin.y+96, width: 37, height: 18)
        fullnameTxt.frame = CGRect(x: 32, y: 😂😱🤩.frame.origin.y+33, width: viewWidth-64, height: 48)
        bioTxt.frame = CGRect(x: 32,y:fullnameTxt.frame.origin.y+48,width:viewWidth-64,height:48)
        webTxt.frame = CGRect(x: 32,y:bioTxt.frame.origin.y+48,width:viewWidth-64,height:48)
        signUpBtn.frame = CGRect(x: 32, y: webTxt.frame.origin.y+96, width: viewWidth - 64, height: 40)
        
        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        scrollView.contentSize.height = self.view.frame.height
        scrollViewHeight = self.view.frame.height
 */
        signUpBtnWidth.constant = self.view.frame.width-64
        NotificationCenter.default.addObserver(self, selector: #selector(receiverNotification), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        //检测键盘出现或消失的状态
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        //声明隐藏虚拟键盘的操作
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTap))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        //self.view.addGestureRecognizer(hideTap)
        
        avaImg.layer.cornerRadius = avaImg.frame.width/2
        avaImg.clipsToBounds = true
        let imgTap = UITapGestureRecognizer(target: self, action: #selector(loadImg))
        imgTap.numberOfTapsRequired = 1
        avaImg.isUserInteractionEnabled = true
        avaImg.addGestureRecognizer(imgTap)
        // Do any additional setup after loading the view.
    }
    @objc func receiverNotification(){
        signUpBtnWidth.constant = self.view.frame.width-64
        print("self.view.frame.width:\(self.view.frame.width)")
    }
    @IBAction func signUpBtn_clicked(_ sender: Any) {
        print("注册按钮被按下！")
        self.view.endEditing(true)
        if usernameTxt.text!.isEmpty||passwordTxt.text!.isEmpty||repeatPasswordTxt.text!.isEmpty||emailTxt.text!.isEmpty{
            let alert = UIAlertController(title: "请注意", message: "请填写好所有必填字段", preferredStyle: .alert)
            let ok = UIAlertAction(title: "好的", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }else if passwordTxt.text != repeatPasswordTxt.text{
            let alert = UIAlertController(title: "请注意", message: "两次输入的密码不一致", preferredStyle: .alert)
            let ok = UIAlertAction(title: "好的", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }else{
            //发送注册数据到服务器相关的列
            let user = AVUser()
            user.username = usernameTxt.text?.lowercased()
            user.email = emailTxt.text?.lowercased()
            user.password = passwordTxt.text
            
            if !fullnameTxt.text!.isEmpty{
                user["fullname"] = fullnameTxt.text?.lowercased()
            }else{
                user["fullname"] = "无名无姓"
            }
            if !bioTxt.text!.isEmpty{
                user["bio"] = bioTxt.text
            }else{
                user["bio"] = "简介为空，欢迎补充。"
            }
            if !webTxt.text!.isEmpty{
                user["web"] = webTxt.text?.lowercased()
            }else{
                user["web"] = ""
            }
            user["gender"] = ""
            
            let avaData = UIImageJPEGRepresentation(avaImg.image!.cropToSquare()!, 0.5)
            let avaFile = AVFile(name: "ava.jpg", data: avaData!)
            user["ava"] = avaFile
            print("sssssssss")
            user.signUpInBackground{(success:Bool,error:Error?) in
                if success{
                    print("用户注册成功！")
                    AVUser.logInWithUsername(inBackground: user.username!, password: user.password!, block: {(user:AVUser?,error:Error?) in
                        if let user = user{
                            UserDefaults.standard.set(user.username, forKey: "username")
                            UserDefaults.standard.synchronize()
                            //从AppDelegate类中调用login方法
                            let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.login()
                        }else{
                            print(error?.localizedDescription)
                        }
                    })
                }else{
                    print(error?.localizedDescription ?? "默认")
                }
            }
        }
        
    }
    @IBAction func cancelBtn_clicked(_ sender: Any) {
        print("取消按钮被按下！")
        self.view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    @objc func showKeyboard(notification:Notification){
        let rect = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        keyboard = rect.cgRectValue
        scrollViewBottom.constant = -keyboard.height
    }
    @objc func hideKeyboard(notification:Notification){
        //print(notification)
        scrollViewBottom.constant = 0
    }
    @objc func hideKeyboardTap(notification:Notification){
        //self.view.endEditing(true)
        print("hideKeyboardTap")
    }
    @objc func loadImg(recognizer:UITapGestureRecognizer){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker,animated: true,completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        avaImg.image = (info[UIImagePickerControllerEditedImage] as? UIImage)?.cropToSquare()
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
