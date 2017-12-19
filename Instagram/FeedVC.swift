//
//  FeedVC.swift
//  Instagram
//
//  Created by 徐炜楠 on 2017/11/7.
//  Copyright © 2017年 xuweinan. All rights reserved.
//

import UIKit
import AVOSCloud
import SVProgressHUD

class FeedVC: UITableViewController {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var refresher = UIRefreshControl()
    
    //储存云端发的数据
    var usernameArray = [String]()
    var avaArray = [AVFile]()
    var dateArray = [Date]()
    var picArray = [AVFile]()
    var titleArray = [String]()
    var puuidArray = [String]()
    
    //存储当前用户所关注的人
    var followArray = [String]()
    
    //page size
    var page:Int = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //导航栏的title
        self.navigationItem.title = "关注"
        
        //设置单元格的动态行高
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 450
        
        //设置refresher
        refresher.addTarget(self, action: #selector(loadPosts), for: .valueChanged)
        self.view.addSubview(refresher)
        
        //从云端载入帖子
        loadPosts()
        
        //水平居中
        indicator.center.x = tableView.center.x
        
        //从UploadVC类接收Notification
        NotificationCenter.default.addObserver(self, selector: #selector(uploaded(notification:)), name: NSNotification.Name(rawValue:"uploaded"), object: nil)
        //设置接受到likeClick消息后的操作
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name.init("likeClick"), object: nil)
    }
    @objc func refresh(){
        print("收到likeClick消息后执行refresh操作")
        self.tableView.reloadData()
    }
    @objc func uploaded(notification:Notification){
        loadPosts()
    }
    @IBAction func moreBtn_clicked(_ sender: AnyObject) {
        let i = sender.layer.value(forKey: "index") as! IndexPath
        let cell = tableView.cellForRow(at: i) as! PostCell
        
        //1.删除操作
        let delete = UIAlertAction(title: "删除", style: .default) { (UIAlertion) in
            print("开始删除")
            //1.1从数组中删除相应的数据
            self.usernameArray.remove(at: i.row)
            self.avaArray.remove(at: i.row)
            self.picArray.remove(at: i.row)
            self.dateArray.remove(at: i.row)
            self.titleArray.remove(at: i.row)
            self.puuidArray.remove(at: i.row)
            //1.2删除云端的记录
            let postQuery = AVQuery(className: "Posts")
            postQuery.whereKey("puuid", equalTo: cell.puuidLbl.text)
            postQuery.findObjectsInBackground { (objects:[Any]?, error:Error?) in
                if error == nil {
                    for object in objects! {
                        (object as AnyObject).deleteInBackground({ (success:Bool, error:Error?) in
                            if success{
                                //发送通知更新帖子
                                NotificationCenter.default.post(name: NSNotification.Name.init("uploaded"), object: nil)
                                //销毁当前控制器
                                self.navigationController?.popViewController(animated: true)
                            }else{
                                print("删除发生错误1\(error?.localizedDescription)")
                            }
                        })
                    }
                }else{
                    print("删除发生错误2\(error?.localizedDescription)")
                }
            }
            //1.3删除帖子的like记录
            let likeQuery = AVQuery(className: "Likes")
            likeQuery.whereKey("to", equalTo: cell.puuidLbl.text)
            likeQuery.findObjectsInBackground { (objects:[Any]?, error:Error?) in
                if error == nil {
                    for object in objects!{
                        (object as AnyObject).deleteEventually()
                    }
                }
            }
            //1.4删除帖子相关的评论
            let commentQuery = AVQuery(className: "Comments")
            commentQuery.whereKey("to", equalTo: cell.puuidLbl.text)
            commentQuery.findObjectsInBackground { (objects:[Any]?, error:Error?) in
                if error == nil {
                    for object in objects! {
                        (object as AnyObject).deleteEventually()
                    }
                }
            }
            //1.5删除帖子相关的Hashtag
            let hashtagQuery = AVQuery(className: "Hashtags")
            hashtagQuery.whereKey("to", equalTo: cell.puuidLbl.text)
            hashtagQuery.findObjectsInBackground { (objects:[Any]?, error:Error?) in
                if error == nil{
                    for object in objects! {
                        (object as AnyObject).deleteEventually()
                    }
                }
            }
        }
        delete.setValue(UIColor.red, forKey: "_titleTextColor")
        
        //2.投诉操作（新建了个表）
        let complain = UIAlertAction(title: "投诉", style: .default) { (UIAlertAction) in
            //发送数据
            let complainObject = AVObject(className: "PostComplain")
            complainObject["by"] = AVUser.current()?.username
            complainObject["post"] = cell.puuidLbl.text
            complainObject["to"] = cell.titleLbl.text
            complainObject["owner"] = cell.usernameBtn.titleLabel?.text
            complainObject.saveInBackground({ (success:Bool, error:Error?) in
                if success{
                    self.alert(error: "投诉信息已经被成功提交！", message: "感谢您的支持，我们将关注您提交的投诉！")
                }else{
                    self.alert(error: "错误", message: error!.localizedDescription)
                }
            })
        }
        //3.取消操作
        let cancel = UIAlertAction(title:"取消",style:.cancel,handler:nil)
        //3.5保存到相册操作
        let save = UIAlertAction(title: "保存图片", style: .default) { (UIAlertAction) in
            UIImageWriteToSavedPhotosAlbum(cell.picImg.image!, self, #selector(self.didSaveImageToAlbum(image:didFinishSavingWithError:contextInfo:)), nil)
        }
        
        //4.创建菜单控制器
        let menu = UIAlertController(title: "菜单选项", message: nil, preferredStyle: .actionSheet)
        
        if cell.usernameBtn.titleLabel?.text == AVUser.current()?.username{
            menu.addAction(save)
            menu.addAction(delete)
            menu.addAction(cancel)
        }else{
            menu.addAction(save)
            menu.addAction(complain)
            menu.addAction(cancel)
        }
        
        if(UIDevice.current.model == "iPad"){
            menu.popoverPresentationController?.sourceView = cell.moreBtn
        }
        
        self.present(menu, animated: true, completion: nil)
    }
    //完成存储方法
    @objc func didSaveImageToAlbum(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:AnyObject) {
        SVProgressHUD.setMinimumDismissTimeInterval(1.2)
        if error != nil {
            SVProgressHUD.showError(withStatus: "保存失败")
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        } else {
            SVProgressHUD.showSuccess(withStatus: "保存成功")
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        }
    }
    //alert方法
    func alert(error:String,message:String){
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func commentBtn_clicked(_ sender: UIButton) {
        let i = sender.layer.value(forKey: "index") as! IndexPath
        let cell = tableView.cellForRow(at: i) as! PostCell
        commentuuid.append(cell.puuidLbl.text!)
        commentowner.append(cell.usernameBtn.titleLabel!.text!)
        
        let comment = self.storyboard?.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        self.navigationController?.pushViewController(comment, animated: true)
        
    }
    @IBAction func usernameBtn_clicked(_ sender: AnyObject) {
        //按钮的index
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        //通过i获取到用户所单击的单元格
        let cell = tableView.cellForRow(at: i) as! PostCell
        
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
    @objc func loadPosts(){
        AVUser.current()?.getFollowees({ (objects:[Any]?, error:Error?) in
            if error == nil{
                //清空数组
                self.followArray.removeAll(keepingCapacity: false)
                
                for object in objects!{
                    self.followArray.append((object as AnyObject).username as! String)
                }
                //添加当前用户到followArray数组中
                self.followArray.append((AVUser.current()?.username)!)
                
                let query = AVQuery(className: "Posts")
                query.whereKey("username", containedIn: self.followArray)
                query.limit = self.page
                query.addDescendingOrder("createdAt")
                query.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                    if error == nil{
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.avaArray.removeAll(keepingCapacity: false)
                        self.dateArray.removeAll(keepingCapacity: false)
                        self.picArray.removeAll(keepingCapacity: false)
                        self.titleArray.removeAll(keepingCapacity: false)
                        self.puuidArray.removeAll(keepingCapacity: false)
                        
                        for object in objects!{
                            self.usernameArray.append((object as AnyObject).value(forKey: "username") as! String)
                            self.avaArray.append((object as AnyObject).value(forKey: "ava") as! AVFile)
                            self.dateArray.append((object as AnyObject).createdAt as! Date)
                            self.picArray.append((object as AnyObject).value(forKey: "pic") as! AVFile)
                            self.titleArray.append((object as AnyObject).value(forKey: "title") as! String)
                            self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                        }
                        
                        self.tableView.reloadData()
                        self.refresher.endRefreshing()
                    }else{
                        print(error?.localizedDescription)
                    }
                })
            }
        })
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height-scrollView.frame.height*2{
            loadMore()
        }
    }
    func loadMore(){
        if self.page <= puuidArray.count{
            //开始Indicator动画
            indicator.startAnimating()
            
            //将page数量+10
            page = page+10
            AVUser.current()?.getFollowers({ (objects:[Any]?, error:Error?) in
                if error == nil{
                    self.followArray.removeAll(keepingCapacity: false)
                    
                    for object in objects!{
                        self.followArray.append((object as AnyObject).username as! String)
                        
                    }
                    
                    //添加当前用户到followArray数组中
                    self.followArray.append(AVUser.current()?.username as! String)
                    let query = AVQuery(className: "Posts")
                    query.whereKey("username", containedIn: self.followArray)
                    query.limit = self.page
                    query.addDescendingOrder("createdAt")
                    query.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                        if error == nil{
                            self.usernameArray.removeAll(keepingCapacity: false)
                            self.avaArray.removeAll(keepingCapacity: false)
                            self.dateArray.removeAll(keepingCapacity: false)
                            self.picArray.removeAll(keepingCapacity: false)
                            self.titleArray.removeAll(keepingCapacity: false)
                            self.puuidArray.removeAll(keepingCapacity: false)
                            
                            for object in objects!{
                                self.usernameArray.append((object as AnyObject).value(forKey: "username") as! String)
                                self.avaArray.append((object as AnyObject).value(forKey: "ava") as! AVFile)
                                self.dateArray.append((object as AnyObject).createdAt as! Date)
                                self.picArray.append((object as AnyObject).value(forKey: "pic") as! AVFile)
                                self.titleArray.append((object as AnyObject).value(forKey: "title") as! String)
                                self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                            }
                            
                            self.tableView.reloadData()
                            self.indicator.stopAnimating()
                            
                        }else{
                            print(error?.localizedDescription)
                        }
                    })
                }
            })
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("数量puuidArray.count\(puuidArray.count)")
        return puuidArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostCell
        cell.usernameBtn.setTitle(usernameArray[indexPath.row], for: .normal)
        cell.puuidLbl.text = puuidArray[indexPath.row]
        cell.titleLbl.text = titleArray[indexPath.row]
        //Lbl自适应大小
        cell.titleLbl.sizeToFit()
        cell.usernameBtn.sizeToFit()
        
        //配置用户头像
        avaArray[indexPath.row].getDataInBackground { (data:Data?, error:Error?) in
            cell.avaImg.image = UIImage(data: data!)
        }
        //配置帖子照片
        picArray[indexPath.row].getDataInBackground { (data:Data?, error:Error?) in
            cell.picImg.image = UIImage(data: data!)
        }
        //帖子的发布时间和当前时间的间隔差
        //获取帖子的创建时间
        let from = dateArray[indexPath.row]
        //获取当前时间
        let now = Date()
        //创建Calendar.Component类型的Set集合
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
        
        //根据用户是否喜爱决定likeBtn的样式
        let didLike = AVQuery(className: "Likes")
        didLike.whereKey("by", equalTo: AVUser.current()?.username)
        didLike.whereKey("to", equalTo: cell.puuidLbl.text)
        didLike.countObjectsInBackground { (count:Int, error:Error?) in
            if count == 0{
                cell.likeBtn.setTitle("unlike", for: .normal)
                cell.likeBtn.setBackgroundImage(UIImage(named:"unlike"), for: .normal)
            }else{
                cell.likeBtn.setTitle("like", for: .normal)
                cell.likeBtn.setBackgroundImage(UIImage(named:"like"), for: .normal)
            }
        }
        //计算帖子的喜爱总数
        let countLikes = AVQuery(className: "Likes")
        countLikes.whereKey("to", equalTo: cell.puuidLbl.text)
        countLikes.countObjectsInBackground { (count:Int, error:Error?) in
            cell.likeLbl.text = "\(count)"
        }
        
        //将indexPath赋值给usernameBtn的layer属性的自定义变量
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        print("usernameBtn打上标记\(indexPath)")
        //将indexPath复制给comment的layer属性的自定义变量
        cell.commentBtn.layer.setValue(indexPath, forKey: "index")
        print("commentBtn打上标记\(indexPath)")
        cell.moreBtn.layer.setValue(indexPath, forKey: "index")
        print("moreBtn打上标记\(indexPath)")
        
        //mentions is tappd
        cell.titleLbl.userHandleLinkTapHandler = { label,handle,rang in
            var mention = handle
            mention = String(mention.dropFirst())
            if mention.lowercased() == AVUser.current()?.username{
                let home = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                self.navigationController?.pushViewController(home, animated: true)
            }else{
                let query = AVUser.query()
                query.whereKey("username", equalTo: mention.lowercased())
                query.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                    if let object = objects?.last{
                        guestArray.append(object as! AVUser)
                        let guest = self.storyboard?.instantiateViewController(withIdentifier: "GuestVC") as! GuestVC
                        self.navigationController?.pushViewController(guest, animated: true)
                    }
                })
            }
            
        }
        //hashtag is tapped
        cell.titleLbl.hashtagLinkTapHandler = {label,handle,rang in
            var mention = handle
            mention = String(mention.dropFirst())
            hashtag.append(mention.lowercased())
            
            let hashvc = self.storyboard?.instantiateViewController(withIdentifier: "HashtagsVC") as! HashtagsVC
            self.navigationController?.pushViewController(hashvc, animated: true)
        }
        
        return cell
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
