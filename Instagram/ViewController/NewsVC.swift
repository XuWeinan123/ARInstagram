//
//  NewsVC.swift
//  Instagram
//
//  Created by 徐炜楠 on 2017/11/8.
//  Copyright © 2017年 xuweinan. All rights reserved.
//

import UIKit
import AVOSCloud

class NewsVC: UITableViewController {
    
    var usernameArray = [String]()
    var avaArray = [AVFile]()
    var typeArray = [String]()
    var dateArray = [Date]()
    var puuidArray = [String]()
    var ownerArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "消息"

        //调整高度
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 93
        
        //从云端载入数据
        let query = AVQuery(className: "News")
        query.whereKey("to", equalTo: AVUser.current()?.username)
        query.limit = 30
        query.findObjectsInBackground { (objects:[Any]?, error:Error?) in
            if error == nil{
                self.usernameArray.removeAll(keepingCapacity: false)
                self.avaArray.removeAll(keepingCapacity: false)
                self.typeArray.removeAll(keepingCapacity: false)
                self.dateArray.removeAll(keepingCapacity: false)
                self.puuidArray.removeAll(keepingCapacity: false)
                self.ownerArray.removeAll(keepingCapacity: false)
                
                for object in objects!{
                    self.usernameArray.append((object as AnyObject).value(forKey: "by") as! String)
                    self.avaArray.append((object as AnyObject).value(forKey: "ava") as! AVFile)
                    self.typeArray.append((object as AnyObject).value(forKey: "type") as! String)
                    self.dateArray.append((object as AnyObject).createdAt as! Date)
                    self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                    self.ownerArray.append((object as AnyObject).value(forKey: "owner") as! String)
                    
                    self.tableView.reloadData()
                }
            }
        }
    }
    @IBAction func usernameBtn_clicked(_ sender: AnyObject) {
        //按钮的index
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        //通过i获取到用户所单击的单元格
        let cell = tableView.cellForRow(at: i) as! NewsCell
        
        //如果当前用户单击的是自己的username,则调用HomeVC，否则是GuestVC
        if cell.usernameBtn.titleLabel?.text == AVUser.current()?.username{
            let home = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(home, animated: true)
        }else{
            let query = AVUser.query()
            query.whereKey("username", equalTo: cell.usernameBtn.titleLabel?.text)
            query.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                if let object = objects?.last{
                    guestArray.append(object as! AVUser)
                    let guest = self.storyboard?.instantiateViewController(withIdentifier: "GuestVC") as! GuestVC
                    self.navigationController?.pushViewController(guest, animated: true)
                }
            })
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernameArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NewsCell
        cell.usernameBtn.setTitle(usernameArray[indexPath.row], for: .normal)
        avaArray[indexPath.row].getDataInBackground { (data:Data?, error:Error?) in
            if error == nil{
                cell.avaImg.image = UIImage(data: data!)
            }else{
                print(error?.localizedDescription)
            }
        }
        
        //消息的发布时间和当前时间的间隔差
        let from = dateArray[indexPath.row]
        let now = Date()
        let components:Set<Calendar.Component> = [.second,.minute,.hour,.day,.weekOfMonth]
        let difference = Calendar.current.dateComponents(components, from: from,to:now)
        
        if difference.second!<=0{
            cell.dateLbl.text = "现在"
        }
        if difference.second!>0&&difference.minute!<=0{
            cell.dateLbl.text = "\(difference.second!)秒"
        }
        if difference.minute!>0&&difference.hour!<=0{
            cell.dateLbl.text = "\(difference.minute!)分"
        }
        if difference.hour!>0&&difference.day!<=0{
            cell.dateLbl.text = "\(difference.hour!)时"
        }
        if difference.day!>0&&difference.weekOfMonth!<=0{
            cell.dateLbl.text = "\(difference.day!)天"
        }
        if difference.weekOfMonth!>0{
            cell.dateLbl.text = "\(difference.weekOfMonth!)周"
        }
        
        //定义info文本信息
        if typeArray[indexPath.row] == "mention"{
            cell.infoLbl.text = "@了你"
        }else if typeArray[indexPath.row] == "comment"{
            cell.infoLbl.text = "评论了你的帖子"
        }else if typeArray[indexPath.row] == "follow"{
            cell.infoLbl.text = "关注了你"
        }else if typeArray[indexPath.row] == "like"{
            cell.infoLbl.text = "喜欢你的帖子"
        }
        
        //赋值indexPath给usernameBtn
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! NewsCell
        
        //跳转到@mention评论
        if cell.infoLbl.text == "评论了你的帖子" || cell.infoLbl.text == "@了你"{
            commentuuid.append(puuidArray[indexPath.row])
            commentowner.append(ownerArray[indexPath.row])
            //跳转到评论页面
            let comments = self.storyboard?.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
            self.navigationController?.pushViewController(comments, animated: true)
        }else if cell.infoLbl.text == "关注了你"{
            //获取关注人的AVUser对象
            let query = AVUser.query()
            query.whereKey("username", equalTo: cell.usernameBtn.titleLabel?.text)
            query.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                if let object = objects?.last{
                    guestArray.append(object as! AVUser)
                    
                    //跳转到访客页面
                    let guest = self.storyboard?.instantiateViewController(withIdentifier: "GuestVC") as! GuestVC
                    self.navigationController?.pushViewController(guest, animated: true)
                }
            })
        }else if cell.infoLbl.text == "喜欢你的帖子"{
            postuuid.append(puuidArray[indexPath.row])
            
            let post = self.storyboard?.instantiateViewController(withIdentifier: "PostVC") as! PostVC
            self.navigationController?.pushViewController(post, animated: true)
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
