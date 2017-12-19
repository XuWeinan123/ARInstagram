//
//  GuestVC.swift
//  Instagram
//
//  Created by 徐炜楠 on 2017/11/3.
//  Copyright © 2017年 xuweinan. All rights reserved.
//

import UIKit
import AVOSCloud

var guestArray = [AVUser]()
class GuestVC: UICollectionViewController,UICollectionViewDelegateFlowLayout {
    //保存从云端获取的数据
    var puuidArray = [String]()
    var picArray = [AVFile]()
    //界面对象
    var refresher:UIRefreshControl!
    var page:Int = 12
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //设置集合视图的背景色为白色
        self.collectionView?.backgroundColor = .white
        //允许垂直的拉拽刷新操作
        self.collectionView?.alwaysBounceVertical = true
        //导航栏的顶部信息
        self.navigationItem.title = guestArray.last?.username
        //定义导航栏中新的返回按钮
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        //实现向右滑动返回
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(back(_:)))
        backSwipe.direction = .right
        self.view.addGestureRecognizer(backSwipe)
        
        //安装refresh控件
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.collectionView?.addSubview(refresher)
        
        loadPosts()
        
    }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print("\(scrollView.contentOffset.y)+\(scrollView.contentSize.height)+\(self.view.frame.height)")
        if scrollView.contentOffset.y>=scrollView.contentSize.height-self.view.frame.height{
            self.loadMore()
        }
    }
    func loadMore(){
        if page <= picArray.count{
            page  = page + 12
            let query = AVQuery(className: "Posts")
            query.whereKey("username", equalTo: guestArray.last?.username)
            query.limit = page
            query.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                if error == nil{
                    self.puuidArray.removeAll(keepingCapacity: false)
                    self.picArray.removeAll(keepingCapacity: false)
                    
                    for object in objects!{
                        self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                        self.picArray.append((object as AnyObject).value(forKey: "pic") as! AVFile)
                    }
                    print("loaded+\(self.page)")
                    self.collectionView?.reloadData()
                }else{
                    print(error?.localizedDescription)
                }
            })
        }
    }
    @objc func refresh(){
        self.collectionView?.reloadData()
        self.refresher.endRefreshing()
    }
    func loadPosts(){
        print("访客形式的loadPosts方法被执行")
        let query = AVQuery(className:"Posts")
        query.whereKey("username", equalTo: guestArray.last?.username)
        query.limit = page
        query.findObjectsInBackground { (objects:[Any]?, error:Error?) in
            if error == nil{
                self.puuidArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                
                for object in objects!{
                    self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                    self.picArray.append((object as AnyObject).value(forKey: "pic") as! AVFile)
                }
                
                self.collectionView?.reloadData()
            }else{
                print(error?.localizedDescription)
            }
        }
        print("数据载入完成\(self.puuidArray.count)+\(self.picArray.count)")
    }
    @objc func back(_:UIBarButtonItem){
        //退回到之前的控制器
        self.navigationController?.popViewController(animated: true)
        
        //从guestArray中一出最后一个AVUser
        if !guestArray.isEmpty{
            guestArray.removeLast()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return picArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Configure the cell
        let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PictureCell
        
        //从云端载入帖子照片
        picArray[indexPath.row].getDataInBackground { (data:Data?, error:Error?) in
            if error == nil{
                cell.picImg.image = UIImage(data: data!)
            }else{
                print(error?.localizedDescription)
            }
        }
        
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //发送post uuid到postuuid数组中
        print("从GuestVC发送的数据\(puuidArray[indexPath.row])")
        postuuid.append(puuidArray[indexPath.row])
        //导航到postVC控制器
        let postVC = self.storyboard?.instantiateViewController(withIdentifier: "PostVC") as! PostVC
        self.navigationController?.pushViewController(postVC, animated: true)
    }
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        //定义header
        let header = self.collectionView?.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! HeaderView
        
        //第一步，载入访客的基本数据信息
        let infoQuery = AVQuery(className: "_User")
        infoQuery.whereKey("username", equalTo: guestArray.last?.username)
        infoQuery.findObjectsInBackground { (objects:[Any]?, error:Error?) in
            if error == nil{
                //判断是否有用户数据
                guard let objects = objects,objects.count>0 else{
                    return
                }
                for object in objects{
                    header.fullnameLbl.text = ((object as AnyObject).object(forKey: "fullname") as? String)?.uppercased()
                    header.bioLbl.text = (object as AnyObject).object(forKey: "bio") as? String
                    header.bioLbl.sizeToFit()
                    header.webText.text = (object as AnyObject).object(forKey: "web") as? String
                    header.webText.sizeToFit()
                    
                    let avaFile = (object as AnyObject).object(forKey: "ava") as? AVFile
                    avaFile?.getDataInBackground({ (data:Data?, error:Error?) in
                        header.avaImg.image = UIImage(data: data!)
                    })
                }
            }else{
                print(error?.localizedDescription)
            }
        }
        //第二步，设置当前用户和访客之间的关注状态
        let followeeQuery = AVUser.current()?.followeeQuery()
        followeeQuery?.whereKey("user", equalTo: AVUser.current())
        followeeQuery?.whereKey("followee", equalTo: guestArray.last)
        followeeQuery?.countObjectsInBackground({ (count:Int, error:Error?) in
            guard error == nil else {print(error?.localizedDescription);return}
            print("我和她之间有关系吗？\(count)")
            if count == 0{
                header.button.setTitle("关 注", for: .normal)
                header.button.backgroundColor = .lightGray
            }else{
                header.button.setTitle("已关注", for: .normal)
                header.button.backgroundColor = UIColor(hexString: "#549B26")
            }
        })
        //第三步，计算统计数据
        //访客的帖子数
        let posts = AVQuery(className:"Posts")
        posts.whereKey("username", equalTo: guestArray.last?.username)
        posts.countObjectsInBackground { (count:Int, error:Error?) in
            if error == nil{
                header.posts.text = "\(count)"
            }else{
                print(error?.localizedDescription)
            }
        }
        //访客的关注者数
        let followers = AVUser.followerQuery((guestArray.last?.objectId)!)
        followers.countObjectsInBackground { (count:Int, error:Error?) in
            if error == nil{
                header.followers.text = "\(count)"
            }else{
                print(error?.localizedDescription)
            }
        }
        //访客的关注数
        let followings = AVUser.followeeQuery((guestArray.last?.objectId)!)
        followings.countObjectsInBackground { (count:Int, error:Error?) in
            if error == nil{
                header.followings.text = "\(count)"
            }else{
                print(error?.localizedDescription)
            }
        }
        //第四步，实现统计数据的单击手势
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(postsTap(_:)))
        postsTap.numberOfTapsRequired = 1
        header.posts.isUserInteractionEnabled = true
        header.posts.addGestureRecognizer(postsTap)
        
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(followersTap(_:)))
        followersTap.numberOfTapsRequired = 1
        header.followers.isUserInteractionEnabled = true
        header.followers.addGestureRecognizer(followersTap)
        
        let followingsTap = UITapGestureRecognizer(target: self, action: #selector(followingsTap(_:)))
        followingsTap.numberOfTapsRequired = 1
        header.followings.isUserInteractionEnabled = true
        header.followings.addGestureRecognizer(followingsTap)
        
        return header
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.width/3, height: self.view.frame.width/3)
        return size
    }
    @objc func postsTap(_ recognizer:UITapGestureRecognizer){
        if !picArray.isEmpty{
            let index = IndexPath(item: 0, section: 0)
            self.collectionView?.scrollToItem(at: index, at: .top, animated: true)
        }
    }
    @objc func followersTap(_ recognizer:UITapGestureRecognizer){
        print("点击了followersTap")
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "FollowersVC") as! FollowersVC
        
        followers.user = guestArray.last!.username!
        followers.show = "\(followers.user)的粉丝"
        
        self.navigationController?.pushViewController(followers, animated: true)
    }
    @objc func followingsTap(_ recognizer:UITapGestureRecognizer){
        print("点击了followingsTap")
        let followings = self.storyboard?.instantiateViewController(withIdentifier: "FollowersVC") as! FollowersVC
        
        followings.user = guestArray.last!.username!
        followings.show = "\(followings.user)的关注"
        
        self.navigationController?.pushViewController(followings, animated: true)
    }
    
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
    
}
