//
//  HeaderView.swift
//  Instagram
//
//  Created by 徐炜楠 on 2017/11/2.
//  Copyright © 2017年 xuweinan. All rights reserved.
//

import UIKit
import AVOSCloud

class HeaderView: UICollectionReusableView {
   
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var fullnameLbl: UILabel!
    @IBOutlet weak var webText: UILabel!
    @IBOutlet weak var bioLbl: UILabel!
    @IBOutlet weak var biobg: UIView!
    @IBOutlet weak var line: UIView!
    
    @IBOutlet weak var posts: UILabel!
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var followings: UILabel!
    
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var followersTitle: UILabel!
    @IBOutlet weak var followingsTitle: UILabel!
    
    @IBOutlet weak var button: UIButton!
    @IBAction func followBtn_clicked(_ sender: Any) {
        let title = button.title(for: .normal)
        let user = guestArray.last
        if title == "关 注"{
            guard let user = user else{return}
            AVUser.current()?.follow(user.objectId!, andCallback: { (success:Bool, error:Error?) in
                if success{
                    self.button.setTitle("已关注", for: .normal)
                    self.button.backgroundColor = UIColor(hexString: "#549B26")
                    
                    //发送关注通知
                    let newsObj = AVObject(className: "News")
                    newsObj["by"] = AVUser.current()?.username
                    newsObj["ava"] = AVUser.current()?.object(forKey: "ava") as! AVFile
                    newsObj["to"] = guestArray.last?.username
                    newsObj["owner"] = ""
                    newsObj["puuid"] = ""
                    newsObj["type"] = "follow"
                    newsObj["checked"] = "no"
                    newsObj.saveEventually()
                }else{
                    print(error?.localizedDescription)
                }
            })
        }else{
            guard let user = user  else{return}
            AVUser.current()?.unfollow(user.objectId!, andCallback: { (success:Bool, error:Error?) in
                if success{
                    self.button.setTitle("关 注", for: .normal)
                    self.button.backgroundColor = UIColor.lightGray
                    
                    //删除关注通知
                    let newsQuery = AVQuery(className: "News")
                    newsQuery.whereKey("by", equalTo: AVUser.current()?.username)
                    newsQuery.whereKey("to", equalTo: guestArray.last?.username)
                    newsQuery.whereKey("type", equalTo: "follow")
                    newsQuery.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                        if error == nil {
                            for object in objects!{
                                (object as AnyObject).deleteEventually()
                            }
                        }
                    })
                }else{
                    print(error?.localizedDescription)
                }
            })
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        //对齐
        let width = UIScreen.main.bounds.width
        //对头像进行布局
        avaImg.frame = CGRect(x: 48, y: 48, width: 222, height: 222)
        //用户名称+用户网址
        fullnameLbl.frame = CGRect(x: avaImg.frame.origin.x+avaImg.frame.width+32, y: avaImg.frame.origin.y, width: 181, height: 45)
        webText.frame = CGRect(x: fullnameLbl.frame.origin.x, y: fullnameLbl.frame.origin.y+fullnameLbl.frame.height+4, width: 181, height: 24)
        
        //对三个统计数据进行布局，从右到左
        followings.frame = CGRect(x: width-101, y: avaImg.frame.origin.y, width: 58, height: 45)
        followers.frame = CGRect(x: followings.frame.origin.x-84, y: avaImg.frame.origin.y, width: 58, height: 45)
        posts.frame = CGRect(x: followers.frame.origin.x-84, y: avaImg.frame.origin.y, width: 58, height: 45)
        //设置三个统计数据Title的布局，从右到左
        followingsTitle.center = CGPoint(x: followings.center.x, y: followings.center.y+39)
        followersTitle.center = CGPoint(x: followers.center.x, y: followers.center.y+39)
        postTitle.center = CGPoint(x: posts.center.x, y: posts.center.y+39)
        //简介布局
        bioLbl.frame = CGRect(x: fullnameLbl.frame.origin.x+8, y: webText.frame.origin.y+webText.frame.height+17+8, width: width-fullnameLbl.frame.origin.x-48-16, height: 72-16)
        biobg.frame = CGRect(x: fullnameLbl.frame.origin.x, y: webText.frame.origin.y+webText.frame.height+17, width: width-fullnameLbl.frame.origin.x-48, height: 72)
        //设置按钮的布局
        button.frame = CGRect(x:fullnameLbl.frame.origin.x,y:biobg.frame.origin.y+biobg.frame.height+20,width:biobg.frame.width,height:40)
        
        biobg.layer.cornerRadius = 4
        avaImg.layer.cornerRadius = avaImg.frame.width/2
        button.layer.cornerRadius = 4
        
        line.frame = CGRect(x: 0, y: 317, width: width, height: 1)
    }
}
