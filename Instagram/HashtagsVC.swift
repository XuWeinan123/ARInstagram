//
//  HashtagsVC.swift
//  Instagram
//
//  Created by 徐炜楠 on 2017/11/7.
//  Copyright © 2017年 xuweinan. All rights reserved.
//

import UIKit
import AVOSCloud

var hashtag = [String]()

class HashtagsVC: UICollectionViewController {

    var refresher:UIRefreshControl!
    var page:Int = 24
    
    //从云端获取记录后存储数据
    var picArray = [AVFile]()
    var puuidArray = [String]()
    var filterArray = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.alwaysBounceVertical = true
        self.navigationItem.title = "#" + "\(hashtag.last!.uppercased())"
        
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        //实现右滑返回
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(back(_:)))
        self.view.addGestureRecognizer(backSwipe)
        
        //安装refresh控件
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.collectionView?.addSubview(refresher)
    }
    //loadHashtags
    func loadHashtags(){
    
        
        //获取相关帖子
        let hashtagQuery = AVQuery(className: "Hashtags")
        hashtagQuery.whereKey("hashtag", equalTo: hashtag.last!)
        hashtagQuery.findObjectsInBackground { (objects:[Any]?, error:Error?) in
            if error == nil {
                self.filterArray.removeAll(keepingCapacity: false)
                
                for object in objects!{
                    self.filterArray.append((object as AnyObject).value(forKey: "to") as! String)
                }
                
                //通过filterArray的uuid，找出相关的帖子
                let query = AVQuery(className: "Posts")
                query.whereKey("puuid", containedIn: self.filterArray)
                query.limit = self.page
                query.addDescendingOrder("createdAt")
                query.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                    if error == nil{
                        self.picArray.removeAll(keepingCapacity: false)
                        self.puuidArray.removeAll(keepingCapacity: false)
                        
                        for object in objects!{
                            self.picArray.append((object as AnyObject).value(forKey: "pic") as! AVFile)
                            self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                        }
                        
                        //reload
                        self.collectionView?.reloadData()
                        self.refresher.endRefreshing()
                    }else{
                        print(error?.localizedDescription)
                    }
                })
            }else{
                print(error?.localizedDescription)
            }
        }
    }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height/3{
            loadMore()
        }
    }
    func loadMore(){
        if page <= puuidArray.count{
            page = page+15
            
            //获取相关帖子
            let hashtagQuery = AVQuery(className: "Hashtags")
            hashtagQuery.whereKey("hashtag", equalTo: hashtag.last!)
            hashtagQuery.findObjectsInBackground { (objects:[Any]?, error:Error?) in
                if error == nil {
                    self.filterArray.removeAll(keepingCapacity: false)
                    
                    for object in objects!{
                        self.filterArray.append((object as AnyObject).value(forKey: "to") as! String)
                    }
                    
                    //通过filterArray的uuid，找出相关的帖子
                    let query = AVQuery(className: "Posts")
                    query.whereKey("puuid", containedIn: self.filterArray)
                    query.limit = self.page
                    query.addDescendingOrder("createdAt")
                    query.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                        if error == nil{
                            self.picArray.removeAll(keepingCapacity: false)
                            self.puuidArray.removeAll(keepingCapacity: false)
                            
                            for object in objects!{
                                self.picArray.append((object as AnyObject).value(forKey: "pic") as! AVFile)
                                self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                            }
                            
                            //reload
                            self.collectionView?.reloadData()
                        }else{
                            print(error?.localizedDescription)
                        }
                    })
                }else{
                    print(error?.localizedDescription)
                }
            }
        }
    }
    @objc func back(_:UIBarButtonItem){
        self.navigationController?.popViewController(animated: true)
        
        if !hashtag.isEmpty{
            hashtag.removeLast()
        }
    }
    @objc func refresh(){
        self.collectionView?.reloadData()
        self.refresher.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.width/3, height: self.view.frame.width/3)
        return size
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //发送post uuid到postuuid数组中
        print("从HomeVC发送的数据\(puuidArray[indexPath.row])")
        postuuid.append(puuidArray[indexPath.row])
        //导航到postVC控制器
        let postVC = self.storyboard?.instantiateViewController(withIdentifier: "PostVC") as! PostVC
        self.navigationController?.pushViewController(postVC, animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return puuidArray.count
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
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
