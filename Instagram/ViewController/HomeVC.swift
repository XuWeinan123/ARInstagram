//
//  HomeVC.swift
//  Instagram
//
//  Created by 徐炜楠 on 2017/11/2.
//  Copyright © 2017年 xuweinan. All rights reserved.
//

import UIKit
import AVOSCloud

class HomeVC: UICollectionViewController,UICollectionViewDelegateFlowLayout {

    //刷新控件
    var refresher:UIRefreshControl!
    
    //每页载入帖子的数量
    var page:Int = 12
    
    var puuidArray = [String]()
    var picArray = [AVFile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //设置refresher控件到集合视图之中
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refresher)

        //设置导航栏标题
        self.navigationItem.title = (AVUser.current()?.username?.uppercased())!
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        //从EditVC类接受Notification
        NotificationCenter.default.addObserver(self, selector: #selector(reload(notification:)), name: NSNotification.Name(rawValue:"reload"), object: nil)
        
        loadPosts()
        //设置集合视图在垂直方向上有反弹的效果
        self.collectionView?.alwaysBounceVertical = true
        // Do any additional setup after loading the view.
        
        //从UploadVC类接收Notification
        NotificationCenter.default.addObserver(self, selector: #selector(uploaded(notification:)), name: NSNotification.Name(rawValue:"uploaded"), object: nil)
        
    }
    @objc func uploaded(notification:Notification){
        loadPosts()
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //发送post uuid到postuuid数组中
        print("从HomeVC发送的数据\(puuidArray[indexPath.row])")
        postuuid.append(puuidArray[indexPath.row])
        //导航到postVC控制器
        let postVC = self.storyboard?.instantiateViewController(withIdentifier: "PostVC") as! PostVC
        self.navigationController?.pushViewController(postVC, animated: true)
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
            query.whereKey("username", equalTo: AVUser.current()?.username)
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
    @objc func reload(notification:Notification){
        collectionView?.reloadData()
    }

    @IBAction func logout(_ sender: Any) {
        let alert = UIAlertController(title: "退出确认", message: "请问您确定要退出吗？", preferredStyle: .alert)
        let ok = UIAlertAction(title: "确定", style: .destructive) { (action:UIAlertAction) in
            print("注销确认")
            AVUser.logOut()
            //从UserDefaults中移除用户登记记录
            UserDefaults.standard.removeObject(forKey: "username")
            UserDefaults.standard.synchronize()
            
            //设置应用程序的rootViewController为登录控制器
            let signIn = self.storyboard?.instantiateViewController(withIdentifier: "SignInVC")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = signIn
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel) { (action:UIAlertAction) in
            print("取消确认")
        }
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    @objc func refresh(){
        collectionView?.reloadData()
        print("开始刷新")
        //停止刷新动画
        refresher.endRefreshing()
        
    }
    func loadPosts(){
        let query = AVQuery(className: "Posts")
        query.whereKey("username", equalTo: AVUser.current()?.username)
        query.limit = page
        query.findObjectsInBackground({ (objects:[Any]?,error:Error?) in
            if error == nil {
                //清空两个数组
                self.puuidArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                for object in objects!{
                    self.puuidArray.append((object as AnyObject).value(forKey:"puuid") as! String)
                    self.picArray.append((object as AnyObject).value(forKey:"pic") as! AVFile)
                }
                self.collectionView?.reloadData()
            }else{
                print("查询下载错误！\(error?.localizedDescription)")
            }
        })
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: 278, height: 278)
        return size
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("数量picArray.count\(picArray.count)")
        return picArray.count
    }
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = self.collectionView?.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! HeaderView
        //定义头部信息
        header.fullnameLbl.text = (AVUser.current()?.object(forKey: "fullname") as? String)?.uppercased()
        header.webText.text = AVUser.current()?.object(forKey: "web") as? String
        header.webText.sizeToFit()
        header.bioLbl.text = AVUser.current()?.object(forKey: "bio") as? String
        header.bioLbl.sizeToFit()
        let avaQuery = AVUser.current()?.object(forKey: "ava") as! AVFile
        avaQuery.getDataInBackground(){(data:Data?,error:Error?) in
            if data == nil{
                print(error?.localizedDescription)
            }else{
                header.avaImg.image = UIImage(data: data!)
            }
        }
        //设置帖子数量
        let currentUser :AVUser = AVUser.current()!
        let postsQuery = AVQuery(className: "Posts")
        postsQuery.whereKey("username", equalTo: currentUser.username)
        postsQuery.countObjectsInBackground { (count:Int, error:Error?) in
            if error == nil{
                header.posts.text = String(count)
            }
        }
        //设置关注者数量
        let followersQuery = AVQuery(className: "_Follower")
        followersQuery.whereKey("user", equalTo: currentUser)//所以AVUser类型之间直接比较的是id？
        followersQuery.countObjectsInBackground { (count:Int, error:Error?) in
            if error == nil {
                header.followers.text = String(count)
            }
        }
        //设置关注的数量
        let followeesQuery = AVQuery(className: "_Followee")
        followeesQuery.whereKey("user", equalTo: currentUser)
        followeesQuery.countObjectsInBackground { (count:Int, error:Error?) in
            if error == nil{
                header.followings.text = String(count)
            }
        }
        //设置帖子数的单击操作
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(postsTap(_:)))
        postsTap.numberOfTapsRequired = 1
        header.posts.isUserInteractionEnabled = true
        header.posts.addGestureRecognizer(postsTap)
        //关注者的操作
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(followersTap(_:)))
        followersTap.numberOfTapsRequired = 1
        header.followers.isUserInteractionEnabled = true
        header.followers.addGestureRecognizer(followersTap)
        //关注数的操作
        let followingsTap = UITapGestureRecognizer(target: self, action: #selector(followingsTap(_:)))
        followingsTap.numberOfTapsRequired = 1
        header.followings.isUserInteractionEnabled = true
        header.followings.addGestureRecognizer(followingsTap)
        return header
    }
    @objc func postsTap(_ recognizer:UITapGestureRecognizer){
        if !picArray.isEmpty{
            let index = IndexPath(item: 0, section: 0)
            self.collectionView?.scrollToItem(at: index, at: UICollectionViewScrollPosition.top, animated: true)
        }else{
            print("图片太少了，赶紧拍点照片去吧")
        }
    }
    @objc func followersTap(_ recognizer:UITapGestureRecognizer){
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "FollowersVC") as! FollowersVC
        followers.user = (AVUser.current()?.username)!
        followers.show = "\(followers.user)的粉丝"
        
        self.navigationController?.pushViewController(followers, animated: true)
    }
    @objc func followingsTap(_ recognizer:UITapGestureRecognizer){
        
        let followings = self.storyboard?.instantiateViewController(withIdentifier: "FollowersVC") as! FollowersVC
        
        followings.user = (AVUser.current()?.username)!
        followings.show = "\(followings.user)的关注"
        self.navigationController?.pushViewController(followings, animated: true)
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PictureCell
        
        picArray[indexPath.row].getDataInBackground(){ (data:Data?,error:Error?) in
            if error == nil{
                cell.picImg.image = UIImage(data: data!)
            }else{
                print("图片下载错误！\(error?.localizedDescription)")
            }
        }
        // Configure the cell
    
        return cell
    }

}
