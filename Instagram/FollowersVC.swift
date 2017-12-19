//
//  FollowersVC.swift
//  Instagram
//
//  Created by 徐炜楠 on 2017/11/3.
//  Copyright © 2017年 xuweinan. All rights reserved.
//

import UIKit
import AVOSCloud

class FollowersVC: UITableViewController {
    var show = String()
    var user = String()
    
    var followerArray = [AVUser]()
    
    var userObject:AVUser!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = show

        //如果user变量等于当前登录用户，则表示是从HomeVC跳转。
        //不然，就是从GuestVC页面跳转，那么user就是最近跳转的那一个访客
        if AVUser.current()!.username == user{
            userObject = AVUser.current()
        }else{
            userObject = guestArray.last
        }
        
        if show == "\(self.user)的粉丝"{
            loadFollowers()
        }else{
            loadFollowings()
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func loadFollowers(){
        print("loadFollowers")
        userObject.getFollowers{ (followers:[Any]?, error:Error?) in
            if error == nil && followers != nil{
                self.followerArray = followers! as! [AVUser]
                //获取数据之后需要刷新表格
                self.tableView.reloadData()
            }else{
                print(error?.localizedDescription)
            }
        }
    }
    func loadFollowings(){
        print("loadFollowings")
        userObject.getFollowees({ (followings:[Any]?, error:Error?) in
            if error == nil && followings != nil {
                self.followerArray = followings! as![AVUser]
                //获取数据之后需要刷新表格
                self.tableView.reloadData()
            }else{
                print(error?.localizedDescription)
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return followerArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FollowersCell
        cell.usernameLbl.text = followerArray[indexPath.row].username
        let ava = followerArray[indexPath.row].object(forKey: "ava") as! AVFile
        ava.getDataInBackground { (data:Data?, error:Error?) in
            if error == nil{
                cell.avaImg.image = UIImage(data: data!)
            }else{
                print(error?.localizedDescription)
            }
        }
        //设置帖子数量
        let postsQuery = AVQuery(className: "Posts")
        postsQuery.whereKey("username", equalTo: followerArray[indexPath.row].username!)
        postsQuery.countObjectsInBackground { (count:Int, error:Error?) in
            if error == nil{
                cell.posts.text = String(count)
            }
        }
        //设置关注者数量
        let followersQuery = AVQuery(className: "_Follower")
        followersQuery.whereKey("user", equalTo: followerArray[indexPath.row])//所以AVUser类型之间直接比较的是id？
        followersQuery.countObjectsInBackground { (count:Int, error:Error?) in
            if error == nil {
                cell.followers.text = String(count)
            }
        }
        //设置关注的数量
        let followeesQuery = AVQuery(className: "_Followee")
        followeesQuery.whereKey("user", equalTo: followerArray[indexPath.row])
        followeesQuery.countObjectsInBackground { (count:Int, error:Error?) in
            if error == nil{
                cell.followings.text = String(count)
            }
        }
        //设置关注按钮状态
        let query = followerArray[indexPath.row].followeeQuery()
        query.whereKey("user", equalTo: AVUser.current())
        query.whereKey("followee", equalTo: followerArray[indexPath.row])
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
        //设置简介
        cell.bioTxt.text = followerArray[indexPath.row].object(forKey: "bio") as? String
        cell.bioTxt.sizeToFit()
        //将对象传递给FollowersCell对象
        cell.user = followerArray[indexPath.row]
        //为当前用户关注隐藏按钮，因为点击关注列表里的人是可以进入他的主页的，所以如果在他的主页里看到自己然后关注了就会出现问题，所以现在先解决这个bug
        if cell.usernameLbl.text == AVUser.current()?.username{
            cell.followBtn.isHidden = true
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at:indexPath) as! FollowersCell
        print("打开了\(cell.usernameLbl.text)")
        if cell.usernameLbl.text == AVUser.current()?.username{
            let home = storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(home, animated: true)
        }else{
            guestArray.append(followerArray[indexPath.row])
            let guest = storyboard?.instantiateViewController(withIdentifier: "GuestVC") as! GuestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 188
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
