//
//  UploadVC.swift
//  Instagram
//
//  Created by 徐炜楠 on 2017/11/4.
//  Copyright © 2017年 xuweinan. All rights reserved.
//

import UIKit
import AVOSCloud

class UploadVC: UIViewController,UINavigationControllerDelegate {

    @IBOutlet weak var picImg: UIImageView!
    @IBOutlet weak var titleTxt: UITextView!
    @IBOutlet weak var publishBtn: UIButton!
    @IBOutlet weak var removeBtn: UIButton!
    
    var ARImage:ARVC!
    override func viewDidLoad() {
        super.viewDidLoad()
        //导航栏的title
        //self.navigationItem.title = "上传"
        publishBtn.isEnabled = false
        publishBtn.backgroundColor = .lightGray
        //单机ImageView
        let picTap = UITapGestureRecognizer(target: self, action: #selector(selectImg))
        picTap.numberOfTapsRequired = 1
        self.picImg.isUserInteractionEnabled = true
        self.picImg.addGestureRecognizer(picTap)
        
        removeBtn.isHidden = true
        picImg.image = UIImage(named: "pp")
        titleTxt.text = ""
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        //alignment()
        if ARImage != nil{
            if ARImage.image != nil{
                picImg.image = ARImage.image
                //显示移除按钮
                removeBtn.isHidden = false
                //允许publish btn
                publishBtn.isEnabled = true
                publishBtn.backgroundColor = UIColor(red: 52.0/255.0, green: 169.0/255.0, blue: 255.0/255.0, alpha: 1)
                //实现二次单击放大图片
                let zoomTap = UITapGestureRecognizer(target: self, action: #selector(zoomImg))
                zoomTap.numberOfTapsRequired = 1
                picImg.isUserInteractionEnabled = true
                picImg.addGestureRecognizer(zoomTap)
                
                ARImage.image = nil
            }
        }
    }
    
    @IBAction func removeBtn_clicked(_ sender: Any) {
        self.viewDidLoad()
    }
    @objc func selectImg(){
        ARImage = self.storyboard?.instantiateViewController(withIdentifier: "ARImage") as! ARVC
        self.navigationController?.pushViewController(ARImage, animated: true)
    }
    @objc func zoomImg() {
        let zoomed = CGRect(x: 0, y: self.view.center.y-self.view.center.x-self.navigationController!.navigationBar.frame.height*1.5, width: self.view.frame.width, height: self.view.frame.width)
        let unzoomed = CGRect(x: self.view.frame.width/4, y: 96-self.navigationController!.navigationBar.frame.height, width: self.view.frame.width/2, height: self.view.frame.width/2)
        if picImg.frame == unzoomed{
            UIView.animate(withDuration: 0.3, animations: {
                self.picImg.frame = zoomed
                self.view.backgroundColor = .black
                self.titleTxt.alpha = 0
                self.publishBtn.alpha = 0
                self.removeBtn.alpha = 0
            })
        }else{
            UIView.animate(withDuration: 0.3, animations: {
                self.picImg.frame = unzoomed
                self.view.backgroundColor = .white
                self.titleTxt.alpha = 1
                self.publishBtn.alpha = 1
                self.removeBtn.alpha = 1
            })
        }
    }

    func alignment(){
        let width = self.view.frame.width
        picImg.frame = CGRect(x: width/4, y: 96-self.navigationController!.navigationBar.frame.height, width: width/2, height: width/2)
        titleTxt.frame = CGRect(x: 32, y: picImg.frame.origin.y+picImg.frame.height+56, width: width-64, height: picImg.frame.height/4)
        publishBtn.frame = CGRect(x: 32, y: titleTxt.frame.origin.y+titleTxt.frame.height+36, width: width-64, height: 49)
        publishBtn.layer.cornerRadius = 24.5
        
        removeBtn.frame = CGRect(x: picImg.frame.origin.x+picImg.frame.width-72, y: picImg.frame.origin.y, width: 72, height: 72)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func publishBtn_clicked(_ sender: Any) {
        self.view.endEditing(true)
        
        let object = AVObject(className: "Posts")
        object["username"] = AVUser.current()?.username
        object["ava"] = AVUser.current()?.value(forKey: "ava") as! AVFile
        let uuid = NSUUID().uuidString
        object["puuid"] = "\(AVUser.current()?.username) \(uuid)"
        
        //titleTxt是否为空
        if titleTxt.text.isEmpty{
            object["title"] = ""
        }else{
            object["title"] = titleTxt.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        //生成照片数据
        let imageData = UIImageJPEGRepresentation(picImg.image!, 0.5)
        let imageFile = AVFile(name: "post.jpg", data: imageData!)
        object["pic"] = imageFile
        
        //发送hashtag到云端
        let words:[String] = titleTxt.text.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        for var word in words{
            //定义正则表达式
            let pattern = "#[^#]+"
            let regular = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let results = regular.matches(in: word, options: .reportProgress, range: NSMakeRange(0, word.count))
            
            //输出截取结果
            print("符合的结果有\(results.count)")//一般来说只会是一个
            for result in results{
                word = (word as NSString) .substring(with: result.range)
            }
            if word.hasPrefix("#"){
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                word = word.trimmingCharacters(in: CharacterSet.symbols)
                
                let hashtagObj = AVObject(className: "Hashtags")
                hashtagObj["to"] = "\(AVUser.current()?.username!)\(uuid)"
                hashtagObj["by"] = AVUser.current()?.username!
                hashtagObj["hashtag"] = word.lowercased()
                hashtagObj["comment"] = titleTxt.text
                hashtagObj["isPost"] = true
                hashtagObj.saveInBackground({ (success:Bool, error:Error?) in
                    if success {
                        print("hashtag\(word)已被创建")
                    }else{
                        print(error?.localizedDescription)
                    }
                })
            }
        }
        
        //存储
        object.saveInBackground { (success:Bool, error:Error?) in
            if error == nil{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:"uploaded"), object: nil)
                self.tabBarController?.selectedIndex = 0
                //重置一切
                self.viewDidLoad()
            }else{
                print("上传错误！\(error?.localizedDescription)")
            }
        }
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
