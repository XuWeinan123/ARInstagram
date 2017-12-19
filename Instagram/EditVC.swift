//
//  EditVC.swift
//  Instagram
//
//  Created by 徐炜楠 on 2017/11/4.
//  Copyright © 2017年 xuweinan. All rights reserved.
// 用来编辑个人主页

import UIKit
import AVOSCloud

class EditVC: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var fullnameTxt: UITextField!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var webTxt: UITextField!
    @IBOutlet weak var bioTxt: UITextView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var telTxt: UITextField!
    @IBOutlet weak var genderTxt: UITextField!
    
    //PickerView和PickerData
    var genderPicker:UIPickerView!
    let genders = ["男","女"]
    var keyboard = CGRect()
    override func viewDidLoad() {
        super.viewDidLoad()

        //在视图中创建pickerview
        genderPicker = UIPickerView()
        genderPicker.dataSource = self
        genderPicker.delegate = self
        genderPicker.backgroundColor = UIColor.groupTableViewBackground
        genderPicker.showsSelectionIndicator = true
        genderTxt.inputView = genderPicker
        
        //检测键盘出现或消失的状态
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        //声明隐藏虚拟键盘的操作
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTap))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        //单机image view
        let imgTap = UITapGestureRecognizer(target: self, action: #selector(loadImg))
        imgTap.numberOfTapsRequired = 1
        avaImg.isUserInteractionEnabled = true
        avaImg.addGestureRecognizer(imgTap)
        
        //调用布局方法
        alignment()
        //调用信息载入方法
        infomation()
        // Do any additional setup after loading the view.
    }
    @objc func loadImg(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    //获取用户信息
    func infomation(){
        let ava = AVUser.current()?.object(forKey:"ava") as! AVFile
        ava.getDataInBackground { (data:Data?, error:Error?) in
            self.avaImg.image = UIImage(data: data!)
        }
        usernameTxt.text = AVUser.current()?.username
        fullnameTxt.text = AVUser.current()?.object(forKey: "fullname") as? String
        bioTxt.text = AVUser.current()?.object(forKey: "bio") as? String
        webTxt.text = AVUser.current()?.object(forKey: "web") as? String
        emailTxt.text = AVUser.current()?.email
        telTxt.text = AVUser.current()?.mobilePhoneNumber
        genderTxt.text = AVUser.current()?.object(forKey: "gender") as? String
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        avaImg.image = (info[UIImagePickerControllerEditedImage] as? UIImage)?.cropToSquare()
        self.dismiss(animated: true, completion: nil)
    }
    @objc func hideKeyboardTap(recognizer:UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    @objc func showKeyboard(notification:Notification){
        let rect = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        keyboard = rect.cgRectValue
        
        //当虚拟键盘出现以后，将滚动视图的内容高度变为控制器视图高度加上键盘高度的一半
        UIView.animate(withDuration: 0.4) {
            self.scrollView.contentSize.height = self.view.frame.height + self.keyboard.height/2
        }
    }
    @objc func hideKeyboard(notification:Notification){
        UIView.animate(withDuration: 0.4) {
            self.scrollView.contentSize.height = 0
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTxt.text = genders[row]
        self.view.endEditing(true)
    }
    func alignment(){
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        scrollView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        avaImg.frame = CGRect(x: width/2-72, y: 72, width: 144, height: 144)
        avaImg.layer.cornerRadius = avaImg.frame.width/2
        avaImg.clipsToBounds = true
        usernameTxt.frame = CGRect(x: 32, y: avaImg.frame.origin.y + 48 + 144, width: width-64, height: 48)
        fullnameTxt.frame = CGRect(x: 32, y: usernameTxt.frame.origin.y+48, width: width-64, height: 48)
        webTxt.frame = CGRect(x: 32, y: fullnameTxt.frame.origin.y+48, width: width-64, height: 48)
        bioTxt.frame = CGRect(x: 32, y: webTxt.frame.origin.y+48+20, width: width-64, height: 89)
        
        titleLbl.frame = CGRect(x: 42, y: bioTxt.frame.origin.y+66+89, width: 74, height: 21)
        emailTxt.frame = CGRect(x: 32, y: titleLbl.frame.origin.y+21+15, width: width-64, height: 48)
        telTxt.frame = CGRect(x: 32, y: emailTxt.frame.origin.y+48, width: width-64, height: 48)
        genderTxt.frame = CGRect(x: 32, y: telTxt.frame.origin.y+48, width: width-64, height: 48)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func save_clicked(_ sender: Any) {
        if !validateEmail(email: emailTxt.text!){
            alert(error: "错误的Email地址", message: "请输入正确的电子邮件地址")
            return
        }
        if !webTxt.text!.isEmpty && !validateWeb(web: webTxt.text!){
            alert(error: "错误的网页链接", message: "请输入正确的网址")
            return
        }
        if !telTxt.text!.isEmpty && !validateMobilePhoneNumber(mobilePhoneNumber: telTxt.text!){
            alert(error: "错误的手机号码", message: "请输入正确的手机号码")
            return
        }
        //保存Field信息到服务器中
        let user = AVUser.current()
        let avaData = UIImageJPEGRepresentation(avaImg.image!, 0.5)
        let avaFile = AVFile(name: "ava.jpg", data: avaData!)
        user?["ava"] = avaFile
        user?.username = usernameTxt.text?.lowercased()
        user?.email = emailTxt.text?.lowercased()
        user?["fullname"] = fullnameTxt.text?.lowercased()
        user?["web"] = webTxt.text?.lowercased()
        user?["bio"] = bioTxt.text
        
        //如果tel为空，则发送""给mobilePhoneNumber字段，否则传入信息
        if telTxt.text!.isEmpty{
            user?.mobilePhoneNumber = ""
        }else{
            user?.mobilePhoneNumber = telTxt.text
        }
        
        //如果gender为空，则发送""给gender字段，否则传入信息
        if genderTxt.text!.isEmpty{
            user?["gender"] = ""
        }else{
            user?["gender"] = genderTxt.text
        }
        //发送用户信息到服务器
        user?.saveInBackground({ (success:Bool, error:Error?) in
            if success{
                //隐藏键盘
                self.view.endEditing(true)
                
                //退出EditVC控制器
                self.dismiss(animated: true, completion: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:"reload"), object: nil)
            }else{
                print(error?.localizedDescription)
            }
        })
    }
    func alert(error:String,message:String){
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    func validateEmail(email:String) -> Bool {
        let regex = "\\w[-\\w.+]*@([A-Za-z0-9][-A-Za-z0-9]+\\.)+[A-Za-z]{2,14}"
        let range = email.range(of: regex,options:.regularExpression)
        let result = range != nil ? true:false
        return result
    }
    func validateWeb(web:String) -> Bool {
        let regex = "www\\.[A-Za-z0-9._%+-]+\\.[A-Za-z]{2,14}"
        let range = web.range(of: regex,options:.regularExpression)
        let result = range != nil ?true:false
        return result
    }
    func validateMobilePhoneNumber(mobilePhoneNumber:String) -> Bool {
        let regex = "0?(13|14|15|18|17)[0-9]{9}"
        let range = mobilePhoneNumber.range(of: regex,options:.regularExpression)
        let result = range != nil ? true:false
        return result
    }
    @IBAction func cancel_clicked(_ sender: Any) {
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
