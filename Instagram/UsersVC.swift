//
//  UsersVC.swift
//  Instagram
//
//  Created by 徐炜楠 on 2017/11/8.
//  Copyright © 2017年 xuweinan. All rights reserved.
//

import UIKit
import AVOSCloud

class UsersVC: UITableViewController,UISearchBarDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    //搜索栏
    var searchBar = UISearchBar()
    
    //从云端获取信息后保存数据的数组
    var usernameArray = [String]()
    var avaArray = [AVFile]()
    var bioArray = [String]()
    var userArray = [AVUser]()
    
    //集合视图UI
    var collectionView:UICollectionView!
    //存储云端数据的数组
    var picArray = [AVFile]()
    var puuidArray = [String]()
    var page:Int = 24

    override func viewDidLoad() {
        super.viewDidLoad()
        //导航栏的title
        self.navigationItem.title = "搜索"
        //实现searchbar功能
        searchBar.delegate = self
        searchBar.placeholder = "点击搜索用户"
        searchBar.showsCancelButton = true
        searchBar.sizeToFit()
        searchBar.tintColor = UIColor.groupTableViewBackground
        searchBar.frame.size.width = self.view.frame.width - 30
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.leftBarButtonItem = searchItem
        
        loadUsers()
        collectionViewLaunch()
    }
    func loadPost(){
        let query = AVQuery(className: "Posts")
        query.limit = page
        query.findObjectsInBackground { (objects:[Any]?, error:Error?) in
            if error == nil{
                //清空数组
                self.picArray.removeAll(keepingCapacity: false)
                self.puuidArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    self.picArray.append((object as AnyObject).value(forKey:"pic") as! AVFile)
                    self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                }
                self.collectionView.reloadData()
            }else{
                print(error?.localizedDescription)
            }
        }
    }
    func loadMore(){
        //如果有更多的帖子需要载入
        if page <= picArray.count{
            //增加page的数量
            page = page+24
            
            //载入更多的帖子
            let query = AVQuery(className: "Posts")
            query.limit = page
            query.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                if error == nil{
                    //清空数组
                    self.picArray.removeAll(keepingCapacity: false)
                    self.puuidArray.removeAll(keepingCapacity: false)
                    
                    //获得相关数据
                    for object in objects!{
                        self.picArray.append((object as AnyObject).value(forKey: "pic") as! AVFile)
                        self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                    }
                    self.collectionView.reloadData()
                }else{
                    print(error?.localizedDescription)
                }
            })
        }
    }
    func loadUsers(){
        let usersQuery = AVUser.query()
        usersQuery.addDescendingOrder("createdAt")
        usersQuery.limit = 20
        usersQuery.findObjectsInBackground { (objects:[Any]?, error:Error?) in
            if error == nil{
                self.usernameArray.removeAll(keepingCapacity: false)
                self.avaArray.removeAll(keepingCapacity: false)
                
                for object in objects!{
                    let user = object as! AVUser
                    self.userArray.append(user)
                    self.usernameArray.append((object as AnyObject).username!!)
                    self.avaArray.append((object as AnyObject).value(forKey: "ava") as! AVFile)
                    //设置简介
                    self.bioArray.append(user.object(forKey: "bio") as! String)
                    //以下部分需要二次查询，因此不用数组的方式
                    /*//设置帖子数量
                    let postsQuery = AVQuery(className: "Posts")
                    postsQuery.whereKey("username", equalTo: self.usernameArray.last)
                    postsQuery.countObjectsInBackground { (count:Int, error:Error?) in
                        if error == nil{
                            self.postsArray.append(count)
                            print("查询结束！")
                        }else{
                            print("出现了错误\(error?.localizedDescription)")
                        }
                    }
                    //设置关注者数量
                    let followersQuery = AVQuery(className: "_Follower")
                    followersQuery.whereKey("user", equalTo: user)//所以AVUser类型之间直接比较的是id？
                    followersQuery.countObjectsInBackground { (count:Int, error:Error?) in
                        if error == nil {
                            self.followersArray.append(count)
                        }
                    }
                    //设置关注的数量
                    let followeesQuery = AVQuery(className: "_Followee")
                    followeesQuery.whereKey("user", equalTo: user)
                    followeesQuery.countObjectsInBackground { (count:Int, error:Error?) in
                        if error == nil{
                            self.followingsArray.append(count)
                        }
                    }
                    
                    //设置是否关注
                    let query = user.followeeQuery()
                    query.whereKey("user", equalTo: AVUser.current())
                    query.whereKey("followee", equalTo: user)
                    query.countObjectsInBackground { (count:Int, error:Error?) in
                        //根据数量设置按钮的风格
                        if error == nil{
                            if count == 0{
                                self.isFollowedArray.append(false)
                            }else{
                                self.isFollowedArray.append(true)
                            }
                        }
                    }*/
                }
                
                //刷新视图表格
                self.tableView.reloadData()
            }else{
                print(error?.localizedDescription)
            }
        }
    }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height/6{
            self.loadMore()
        }
    }
    func collectionViewLaunch(){
        //集合视图的布局
        let layout = UICollectionViewFlowLayout()
        
        //定义item的尺寸
        layout.itemSize = CGSize(width: 278, height: 278)
        
        //设置滚动方向
        layout.scrollDirection = .vertical
        
        //定义滚动视图在视图中的为主
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - (self.tabBarController?.tabBar.frame.height)! - (self.navigationController?.navigationBar.frame.height)!-20)
        
        //实例化滚动视图
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        
        self.view.addSubview(collectionView)
        
        //定义集合视图中的单元格
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        //载入帖子
        loadPost()
        
    }
    
    //设置每个Section中行之间的间隔
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    //设置每个Section中item的间隔
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    //确定集合视图中items的数量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let picImg = UIImageView(frame:CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height))
        cell.addSubview(picImg)
        picArray[indexPath.row].getDataInBackground { (data:Data?, error:Error?) in
            if error == nil {
                picImg.image = UIImage(data: data!)
            }else{
                print(error?.localizedDescription)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //从uuidArray数组获取到当前所单机的帖子的uuid，并压入到全局数组postuuid中
        postuuid.append(puuidArray[indexPath.row])
        
        //呈现PostVC
        let post = self.storyboard?.instantiateViewController(withIdentifier: "PostVC") as! PostVC
        self.navigationController?.pushViewController(post, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print("searchBar:\(searchBar),range:\(range),text:\(text)")
        let textfinished = (searchBar.text! as NSString).replacingCharacters(in: range, with: text)
        guard textfinished != "" else {
            collectionView.isHidden = false
            return true
        }
        collectionView.isHidden = true
        let userQuery = AVUser.query()
        userQuery.whereKey("username", matchesRegex: "(?i)"+textfinished)
        userQuery.findObjectsInBackground { (objects:[Any]?, error:Error?) in
            if error == nil{
                if objects!.isEmpty{
                    let fullnameQuery = AVUser.query()
                    fullnameQuery.whereKey("fullname", matchesRegex: "(?i)"+textfinished)
                    fullnameQuery.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                        if error == nil{
                            self.usernameArray.removeAll(keepingCapacity: false)
                            self.avaArray.removeAll(keepingCapacity: false)
                            
                            //查找相关数据
                            for object in objects!{
                                self.usernameArray.append((object as AnyObject).username!!)
                                self.avaArray.append((object as AnyObject).value(forKey: "ava") as! AVFile)
                            }
                            self.tableView.reloadData()
                        }
                    })
                }else{
                    self.usernameArray.removeAll(keepingCapacity: false)
                    self.avaArray.removeAll(keepingCapacity: false)
                    
                    //查找相关数据
                    for object in objects!{
                        self.usernameArray.append((object as AnyObject).username!!)
                        self.avaArray.append((object as AnyObject).value(forKey: "ava") as! AVFile)
                    }
                    self.tableView.reloadData()
                }
                
            }
        }
        return true
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar){
        searchBar.showsCancelButton = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //当搜索结束后显示集合视图
        print("当搜索结束后显示集合视图")
        collectionView.isHidden = false
        
        searchBar.resignFirstResponder()
        
        searchBar.showsCancelButton = false
        searchBar.text = ""
        loadUsers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernameArray.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 188
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FollowersCell
        cell.backgroundColor = UIColor(hexString: "#F8F8F8")
        cell.user = userArray[indexPath.row]
        //隐藏followBtn按钮
        cell.followBtn.isHidden = true
        
        cell.usernameLbl.text = usernameArray[indexPath.row]
        avaArray[indexPath.row].getDataInBackground { (data:Data?, error:Error?) in
            if error == nil{
                cell.avaImg.image = UIImage(data: data!)
            }
        }
        //print("postsArray的量:\(postsArray.count),indexPath.row:\(indexPath.row),usernameArray:\(usernameArray.count)")
        cell.bioTxt.text = bioArray[indexPath.row]
        cell.bioTxt.sizeToFit()
        
        //查询posts\followers\followings\isFollowed
        //设置帖子数量
        let postsQuery = AVQuery(className: "Posts")
        postsQuery.whereKey("username", equalTo: userArray[indexPath.row].username!)
        postsQuery.countObjectsInBackground { (count:Int, error:Error?) in
            if error == nil{
                cell.posts.text = String(count)
            }
        }
        //设置关注者数量
        let followersQuery = AVQuery(className: "_Follower")
        followersQuery.whereKey("user", equalTo: userArray[indexPath.row])//所以AVUser类型之间直接比较的是id？
        followersQuery.countObjectsInBackground { (count:Int, error:Error?) in
            if error == nil {
                cell.followers.text = String(count)
            }
        }
        //设置关注的数量
        let followeesQuery = AVQuery(className: "_Followee")
        followeesQuery.whereKey("user", equalTo: userArray[indexPath.row])
        followeesQuery.countObjectsInBackground { (count:Int, error:Error?) in
            if error == nil{
                cell.followings.text = String(count)
            }
        }
        //设置关注按钮状态
        if AVUser.current() == userArray[indexPath.row]{
            cell.followBtn.isHidden = true
        }else{
            cell.followBtn.isHidden = false
            let query = userArray[indexPath.row].followeeQuery()
            query.whereKey("user", equalTo: AVUser.current())
            query.whereKey("followee", equalTo: userArray[indexPath.row])
            query.countObjectsInBackground { (count:Int, error:Error?) in
                //根据数量设置按钮的风格
                if error == nil{
                    if count == 0{
                        cell.followBtn.setTitle("关 注", for: .normal)
                        cell.followBtn.backgroundColor = .lightGray
                    }else{
                        cell.followBtn.setTitle("已关注", for: .normal)
                        cell.followBtn.backgroundColor = UIColor(hexString: "#549B26")
                    }
                }
            }
        }
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //获取当前用户选择的单元格对象
        let cell = tableView.cellForRow(at: indexPath) as! FollowersCell
        
        if cell.usernameLbl.text == AVUser.current()?.username{
            let home = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(home, animated: true)
        }else{
            let query = AVUser.query()
            query.whereKey("username", equalTo: cell.usernameLbl.text)
            query.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                if let object = objects?.last{
                    guestArray.append(object as! AVUser)
                    let guest = self.storyboard?.instantiateViewController(withIdentifier: "GuestVC") as! GuestVC
                    self.navigationController?.pushViewController(guest, animated: true)
                }
            })
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
