//
//  FollowersCell.swift
//  Instagram
//
//  Created by 徐炜楠 on 2017/11/3.
//  Copyright © 2017年 xuweinan. All rights reserved.
//

import UIKit
import AVOSCloud

class FollowersCell: UITableViewCell {

    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var followersTitle: UILabel!
    @IBOutlet weak var followingsTitle: UILabel!
    @IBOutlet weak var posts: UILabel!
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var followings: UILabel!
    @IBOutlet weak var biobg: UIView!
    @IBOutlet weak var bioTxt: UILabel!
    
    @IBOutlet weak var followBtn: UIButton!
    
    var user:AVUser!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //将头像制作成圆形
        avaImg.layer.cornerRadius = avaImg.frame.width/2
        avaImg.clipsToBounds = true
        //布局设置
        //let width = UIScreen.main.bounds.width
        avaImg.frame = CGRect(x: 16, y: 16, width: 156, height: 156)
        usernameLbl.frame = CGRect(x: avaImg.frame.origin.x+avaImg.frame.width+24, y: avaImg.frame.origin.y, width: 181, height: 45)
        postTitle.frame = CGRect(x: usernameLbl.frame.origin.x, y: usernameLbl.frame.origin.y+usernameLbl.frame.height, width: 41, height: 27)
        posts.frame = CGRect(x: postTitle.frame.origin.x+postTitle.frame.width+7, y: postTitle.frame.origin.y, width: 38, height: 27)
        
        followersTitle.frame = CGRect(x: posts.frame.origin.x+posts.frame.width+15, y: postTitle.frame.origin.y, width: 41, height: 27)
        followers.frame = CGRect(x: followersTitle.frame.origin.x+followersTitle.frame.width+7, y: postTitle.frame.origin.y, width: 38, height: 27)

        followingsTitle.frame = CGRect(x: followers.frame.origin.x+followers.frame.width+15, y: postTitle.frame.origin.y, width: 41, height: 27)
        followings.frame = CGRect(x: followingsTitle.frame.origin.x+followingsTitle.frame.width+7, y: postTitle.frame.origin.y, width: 38, height: 27)
        
        biobg.frame = CGRect(x: usernameLbl.frame.origin.x, y: postTitle.frame.origin.y+postTitle.frame.height+12, width: 486, height: avaImg.frame.height+avaImg.frame.origin.y-(postTitle.frame.origin.y+postTitle.frame.height+12))
        bioTxt.frame = CGRect(x: biobg.frame.origin.x+8, y: biobg.frame.origin.y+8, width: biobg.frame.width-16, height: biobg.frame.height-16)
        followBtn.frame = CGRect(x: biobg.frame.origin.x+biobg.frame.width+40, y: biobg.frame.origin.y, width: biobg.frame.height, height: biobg.frame.height)
        biobg.layer.cornerRadius = 4
        followBtn.layer.cornerRadius = followBtn.frame.height/2
    }

    @IBAction func followBtn_clicked(_ sender: Any) {
        
        let title = followBtn.title(for: .normal)
        print("click\(title == "关 注")")
        if title == "关 注"{
            guard user != nil else{return}
            AVUser.current()?.follow(user.objectId!, andCallback: { (success:Bool, error:Error?) in
                if success{
                    self.followBtn.setTitle("已关注", for: .normal)
                    self.followBtn.backgroundColor = UIColor(hexString: "#549B26")
                }else{
                    print("关注出现错误:\(error?.localizedDescription)")
                }
            })
        }else{
            guard user != nil else{return}
            AVUser.current()?.unfollow(user.objectId!, andCallback: { (success:Bool, error:Error?) in
                if success{
                    self.followBtn.setTitle("关 注", for: .normal)
                    self.followBtn.backgroundColor = UIColor.lightGray
                }else{
                    print(error?.localizedDescription)
                }
            })
        }
    }
}
