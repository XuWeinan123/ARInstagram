//
//  PostCell.swift
//  Instagram
//
//  Created by 徐炜楠 on 2017/11/5.
//  Copyright © 2017年 xuweinan. All rights reserved.
//

import UIKit
import AVOSCloud
import Lottie

class PostCell: UITableViewCell {

    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var dateLbl: UILabel!
    
    @IBOutlet weak var picImg: UIImageView!
    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var titleLbl: KILabel!
    @IBOutlet weak var puuidLbl: UILabel!
    
    //这里代码乱七八糟的，别看了
    override func awakeFromNib() {
        super.awakeFromNib()
        likeBtn.setTitleColor(.clear, for: .normal)
        let width = UIScreen.main.bounds.width
        //双击照片添加喜爱
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        likeTap.numberOfTapsRequired = 2
        picImg.isUserInteractionEnabled = true
        picImg.addGestureRecognizer(likeTap)
        //启用约束
        avaImg.translatesAutoresizingMaskIntoConstraints = false
        usernameBtn.translatesAutoresizingMaskIntoConstraints = false
        dateLbl.translatesAutoresizingMaskIntoConstraints = false
        picImg.translatesAutoresizingMaskIntoConstraints = false
        likeBtn.translatesAutoresizingMaskIntoConstraints = false
        commentBtn.translatesAutoresizingMaskIntoConstraints = false
        moreBtn.translatesAutoresizingMaskIntoConstraints = false
        likeLbl.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        puuidLbl.translatesAutoresizingMaskIntoConstraints = false
        
        let picWidth = width-20
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-10-[ava(30)]-10-[pic(\(picWidth))]-5-[like(30)]",
            options: [],
            metrics: nil,
            views: ["ava":avaImg,"pic":picImg,"like":likeBtn]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-10-[username]",
            options: [],
            metrics: nil,
            views: ["username":usernameBtn]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:[pic]-5-[comment(30)]",
            options: [],
            metrics: nil,
            views: ["pic":picImg,"comment":commentBtn]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-15-[date]",
            options: [],
            metrics: nil,
            views: ["date":dateLbl]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:[like]-5-[title]-5-|",
            options: [],
            metrics: nil,
            views: ["like":likeBtn,"title":titleLbl]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:[pic]-5-[more(30)]",
            options: [],
            metrics: nil,
            views: ["pic":picImg,"more":moreBtn]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:[pic]-10-[likes]",
            options: [],
            metrics: nil,
            views: ["pic":picImg,"likes":likeLbl]))
        //水平方向的约束
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-10-[ava(30)]-10-[username]",
            options: [],
            metrics: nil,
            views: ["ava":avaImg,"username":usernameBtn]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[pic]-0-|",
            options: [],
            metrics: nil,
            views: ["pic":picImg]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-15-[like(30)]-5-[likes(32)]-10-[comment(30)]",
            options: [],
            metrics: nil,
            views: ["like":likeBtn,"likes":likeLbl,"comment":commentBtn]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:[more(30)]-15-|",
            options: [],
            metrics: nil,
            views: ["more":moreBtn]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-15-[title]-15-|",
            options: [],
            metrics: nil,
            views: ["title":titleLbl]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:[date]-10-|",
            options: [],
            metrics: nil,
            views: ["date":dateLbl]))
        
        avaImg.layer.cornerRadius = avaImg.frame.width/2
        avaImg.clipsToBounds = true
        // Initialization code
    }

    @objc func likeTapped(){
        //创建一个大的灰色桃心
        let lottieView = LOTAnimationView(name: "likeTapAni1")
        lottieView.center = picImg.center
        self.addSubview(lottieView)
        lottieView.play()
        
        let title = likeBtn.title(for: .normal)
        
        if title == "unlike"{
            let object = AVObject(className: "Likes")
            object["by"] = AVUser.current()?.username
            object["to"] = puuidLbl.text
            object.saveInBackground({ (success:Bool, error:Error?) in
                if success{
                    print("标记为：like!")
                    self.likeBtn.setTitle("like", for: .normal)
                    self.likeBtn.setBackgroundImage(UIImage(named:"like"), for: .normal)
                    
                    //如果设置为喜爱，则发送通知给表格视图刷新表格
                    NotificationCenter.default.post(name: NSNotification.Name.init("likeClick"), object: nil)
                    //单击喜爱按钮后添加消息通知
                    if self.usernameBtn.titleLabel?.text != AVUser.current()?.username{
                        let newsObj = AVObject(className: "News")
                        newsObj["by"] = AVUser.current()?.username
                        newsObj["ava"] = AVUser.current()?.object(forKey: "ava") as! AVFile
                        newsObj["to"] = self.usernameBtn.titleLabel?.text
                        newsObj["owner"] = self.usernameBtn.titleLabel?.text
                        newsObj["type"] = "like"
                        newsObj["puuid"] = self.puuidLbl.text
                        newsObj["checked"] = "no"
                        newsObj.saveEventually()
                    }
                }
            })
        }
    }
    @IBAction func likeBtn_clicked(_ sender: AnyObject) {
        //获取likeBtn按钮的Title
        let title = sender.title(for: .normal)
        
        if title == "unlike"{
            let object = AVObject(className: "Likes")
            object["by"] = AVUser.current()?.username
            object["to"] = puuidLbl.text
            object.saveInBackground({ (success:Bool, error:Error?) in
                if success{
                    print("标记为：like!")
                    self.likeBtn.setTitle("like", for: .normal)
                    self.likeBtn.setBackgroundImage(UIImage(named:"like"), for: .normal)
                    //通知表格视图刷新表格
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:"likeClick"), object: nil)
                    //单击喜爱按钮后添加消息通知
                    if self.usernameBtn.titleLabel?.text != AVUser.current()?.username{
                        let newsObj = AVObject(className: "News")
                        newsObj["by"] = AVUser.current()?.username
                        newsObj["ava"] = AVUser.current()?.object(forKey: "ava") as! AVFile
                        newsObj["to"] = self.usernameBtn.titleLabel?.text
                        newsObj["owner"] = self.usernameBtn.titleLabel?.text
                        newsObj["type"] = "like"
                        newsObj["puuid"] = self.puuidLbl.text
                        newsObj["checked"] = "no"
                        newsObj.saveEventually()
                    }
                }
            })
        }else{
            //搜索Likes表中对应的记录
            let query = AVQuery(className: "Likes")
            query.whereKey("by", equalTo: AVUser.current()?.username)
            query.whereKey("to", equalTo: puuidLbl.text)
            query.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                for object in objects!{
                    (object as AnyObject).deleteInBackground({ (success:Bool, error:Error?) in
                        if success {
                            print("删除like记录，disliked")
                            self.likeBtn.setTitle("unlike", for: .normal)
                            self.likeBtn.setBackgroundImage(UIImage(named:"unlike"), for: .normal)
                            //发送通知
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue:"likeClick"), object: nil)
                            
                            //删除消息通知
                            let newsQuery = AVQuery(className: "News")
                            newsQuery.whereKey("by", equalTo: AVUser.current()?.username)
                            newsQuery.whereKey("to", equalTo: self.usernameBtn.titleLabel?.text)
                            newsQuery.whereKey("puuid", equalTo: self.puuidLbl.text)
                            newsQuery.whereKey("type", equalTo: "like")
                            
                            newsQuery.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                                if error == nil {
                                    for object in objects!{
                                        (object as AnyObject).deleteEventually()
                                    }
                                }
                            })
                        }
                    })
                }
            })
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
