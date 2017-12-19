//
//  CommentVC.swift
//  Instagram
//
//  Created by 徐炜楠 on 2017/11/5.
//  Copyright © 2017年 xuweinan. All rights reserved.
//

import UIKit
import AVOSCloud
var commentuuid = [String]()//评论的uuid
var commentowner = [String]()//评论的帖子的主人

class CommentVC: UIViewController,UITextViewDelegate,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTxt: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    var refresher = UIRefreshControl()
    
    //从云端获取的数据
    var usernameArray = [String]()
    var avaArray = [AVFile]()
    var commentArray = [String]()
    var dateArray = [Date]()
    //重置UI的默认值
    var tableViewHeight:CGFloat = 0
    var commentY:CGFloat = 0
    var commentHeight:CGFloat = 0
    
    //page size
    var page:Int = 15
    
    //储存keyboard大小的变量
    var keyboard = CGRect()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        alignment()
        loadComments()
        
        self.navigationItem.title = "评论"
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem.init(title: "返回", style: .plain, target: self, action: #selector(back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        //在开始的时候，禁止sendBtn按钮
        self.sendBtn.isEnabled = false
        
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(back(_:)))
        backSwipe.direction = .right
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(backSwipe)
        // Do any additional setup after loading the view.
        
        //键盘方法
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        //为了更好的观察表格视图在键盘出现后的效果
        //self.tableView.backgroundColor = .red
    }
    //消息警告
    func alert(error:String,message:String){
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        //获取用户所滑动的单元格对象
        let cell = tableView.cellForRow(at: indexPath) as! CommentCell
        
        //Action 1. Delete
        let delete = UITableViewRowAction(style: .normal, title: "删除") { (UITableViewRowAction, IndexPath) in
            let commentQuery = AVQuery(className: "Comments")
            commentQuery.whereKey("to", equalTo: commentuuid.last!)
            commentQuery.whereKey("comment", equalTo: cell.commentLbl.text!)
            commentQuery.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                if error == nil{
                    for object in objects!{
                        (object as AnyObject).deleteEventually()
                    }
                }else{
                    print(error?.localizedDescription)
                }
            })
            //从表格视图删除单元格
            self.commentArray.remove(at: indexPath.row)
            self.dateArray.remove(at: indexPath.row)
            self.avaArray.remove(at: indexPath.row)
            self.usernameArray.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            
            //从云端删除hash
            let hashtagQuery = AVQuery(className: "Hashtags")
            hashtagQuery.whereKey("to", equalTo: commentuuid.last)
            hashtagQuery.whereKey("by", equalTo: cell.usernameBtn.titleLabel?.text)
            hashtagQuery.whereKey("comment", equalTo: cell.commentLbl.text)
            print("从云端删除hash")
            hashtagQuery.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                if error == nil{
                    for object in objects!{
                        (object as AnyObject).deleteInBackground({ (success:Bool, error:Error?) in
                            if success {
                                print("删除标签成功")
                            }else{
                                print("删除标签失败\(error)")
                            }
                        })
                    }
                }else{
                    print("查找不到标签")
                }
            })
            //删除评论和mention的消息通知
            let newsQuery = AVQuery(className: "News")
            newsQuery.whereKey("by", equalTo: cell.usernameBtn.titleLabel?.text)
            newsQuery.whereKey("to", equalTo: commentowner.last!)
            
            newsQuery.whereKey("type", containedIn: ["mention","comment"])
            newsQuery.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                if error == nil{
                    for object in objects!{
                        (object as AnyObject).deleteEventually()
                    }
                }
            })
            
            //关闭单元格的编辑状态
            self.tableView.setEditing(false, animated: true)
        }
        //Action 2. Address
        let address = UITableViewRowAction(style: .normal, title: "@") { (_:UITableViewRowAction, _:IndexPath) in
            //在TextView中包含Address
            self.commentTxt.text = "\(self.commentTxt.text + "@" + self.usernameArray[indexPath.row]+" ")"
            //让发送按钮生效
            self.sendBtn.isEnabled = true
            //关闭
            self.tableView.setEditing(false,animated:true)
        }
        //Action 3. 投诉
        let complain = UITableViewRowAction(style: .normal, title: "举报") { (_:UITableViewRowAction, _:IndexPath) in
            //发送投诉到云端
            let complainObj = AVObject(className: "Complain")
            complainObj["by"] = AVUser.current()?.username
            complainObj["post"] = commentuuid.last
            complainObj["to"] = cell.commentLbl.text
            complainObj["owner"] = cell.usernameBtn.titleLabel?.text
            
            complainObj.saveInBackground({ (success:Bool, error:Error?) in
                if success {
                    self.alert(error: "投诉信息已经被成功提交！", message: "感谢您的支持，我们将关注您提交的投诉！")
                }else{
                    self.alert(error: "错误", message: (error?.localizedDescription)!)
                }
            })
            
            //关闭单元格的编辑状态
            self.tableView.setEditing(false, animated: true)
        }
        delete.backgroundColor = .red
        address.backgroundColor = .gray
        complain.backgroundColor = .gray
        if cell.usernameBtn.titleLabel?.text == AVUser.current()?.username{
            return [delete,address]
        }else if commentowner.last == AVUser.current()?.username{
            return [delete,address]
        }else{
            return [address,complain]
        }
    }
    
    @IBAction func usernameBtn_clicked(_ sender: AnyObject) {
        //按钮的index
        let i = sender.layer.value(forKey: "index") as! IndexPath
        //通过i获取栋用户所单击的单元格
        let cell = tableView.cellForRow(at: i) as! CommentCell
        //如果当前用户单击的是自己的username，则调用HomeVC，否则是GuestVC
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
    @IBAction func sendBtn_clicked(_ sender: UIButton) {
        //在表格视图中添加一行
        usernameArray.append((AVUser.current()?.username)!)
        avaArray.append(AVUser.current()?.object(forKey: "ava") as! AVFile)
        dateArray.append(Date())
        commentArray.append(commentTxt.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        tableView.reloadData()
        
        //发送到云端
        let commentObj = AVObject(className: "Comments")
        commentObj["to"] = commentuuid.last!
        commentObj["username"] = AVUser.current()?.username
        commentObj["ava"] = AVUser.current()?.object(forKey: "ava")
        commentObj["comment"] = commentTxt.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        commentObj.saveEventually()//不一定马上提交，等到休闲时刻再提交
        
        //发送hashtag到云端
        let words:[String] = commentTxt.text.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        for var word in words{
            //定义正则表达式
            let pattern = "#[^#]+"
            let regular = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let results = regular.matches(in: word, options: .reportProgress, range: NSMakeRange(0, word.count))
            
            //输出截取结果
            print("符合的结果有\(results.count)")//一般来说只会是一个
            for result in results{
                word = (word as NSString) .substring(with: result.range)
            }
            if word.hasPrefix("#"){
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                word = word.trimmingCharacters(in: CharacterSet.symbols)
                
                let hashtagObj = AVObject(className: "Hashtags")
                hashtagObj["to"] = commentuuid.last
                hashtagObj["by"] = AVUser.current()?.username!
                hashtagObj["hashtag"] = word.lowercased()
                hashtagObj["comment"] = commentTxt.text
                hashtagObj["isPost"] = false
                hashtagObj.saveInBackground({ (success:Bool, error:Error?) in
                    if success {
                        print("hashtag\(word)已被创建")
                    }else{
                        print(error?.localizedDescription)
                    }
                })
            }
        }
        //当遇到@mention发送通知
        
        var mentionCreated = Bool()
        for var word in words{
            if word.hasPrefix("@"){
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                word = word.trimmingCharacters(in: CharacterSet.symbols)
                
                let newsObj = AVObject(className: "News")
                newsObj["by"] = AVUser.current()?.username
                newsObj["ava"] = AVUser.current()?.object(forKey: "ava") as! AVFile
                newsObj["to"] = word
                newsObj["owner"] = commentowner.last
                newsObj["puuid"] = commentuuid.last
                newsObj["type"] = "mention"
                newsObj["checked"] = "no"
                newsObj.saveEventually()
                
                mentionCreated = true
            }
        }
        //发送评论时通知
        if commentowner.last != AVUser.current()?.username && mentionCreated == false{
            let newsObj = AVObject(className: "News")
            newsObj["by"] = AVUser.current()?.username
            newsObj["ava"] = AVUser.current()?.object(forKey: "ava") as! AVFile
            newsObj["to"] = commentowner.last
            newsObj["owner"] = commentowner.last
            newsObj["puuid"] = commentuuid.last
            newsObj["type"] = "comment"
            newsObj["checked"] = "no"
            newsObj.saveEventually()
        }
 
        
        self.tableView.scrollToRow(at: IndexPath.init(row: commentArray.count-1, section: 0), at: .bottom, animated: false)
        
        //重置UI
        commentTxt.text = ""
        commentTxt.frame.size.height = commentHeight
        commentTxt.frame.origin.y = sendBtn.frame.origin.y
        tableView.frame.size.height = tableViewHeight - keyboard.height - commentTxt.frame.height + commentHeight
        
    }
    func loadComments(){
        let countQuery = AVQuery(className: "Comments")
        countQuery.whereKey("to", equalTo: commentuuid.last!)
        countQuery.countObjectsInBackground { (count:Int, error:Error?) in
            if self.page<count{
                self.refresher.addTarget(self, action: #selector(self.loadMore), for: .valueChanged)
                self.tableView.addSubview(self.refresher)
            }
            //获取最新的self.page数量的评论
            let query = AVQuery(className: "Comments")
            query.whereKey("to", equalTo: commentuuid.last!)
            query.skip = count - self.page
            query.addAscendingOrder("createdAt")
            query.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                if error == nil{
                    self.usernameArray.removeAll(keepingCapacity: false)
                    self.commentArray.removeAll(keepingCapacity: false)
                    self.avaArray.removeAll(keepingCapacity: false)
                    self.dateArray.removeAll(keepingCapacity: false)
                    
                    for object in objects!{
                        self.usernameArray.append((object as AnyObject).object(forKey:"username") as! String)
                        self.avaArray.append((object as AnyObject).object(forKey: "ava") as! AVFile)
                        self.commentArray.append((object as AnyObject).object(forKey: "comment") as! String)
                        self.dateArray.append((object as AnyObject).createdAt!!)
                        
                        self.tableView.reloadData()
                        self.tableView.scrollToRow(at: IndexPath.init(row: self.commentArray.count-1, section: 0), at: .bottom, animated: false)
                    }
                }else{
                    print(error!.localizedDescription)
                }
            })
        }
        
    }
    @objc func loadMore(){
        let countQuery = AVQuery(className: "Comments")
        countQuery.whereKey("to", equalTo: commentuuid.last!)
        countQuery.countObjectsInBackground { (count:Int, error:Error?) in
            self.refresher.endRefreshing()
            
            if self.page >= count{
                self.refresher.removeFromSuperview()
            }
            
            if self.page < count{
                self.page = self.page+15
                //获取评论
                let query = AVQuery(className: "Comments")
                query.whereKey("to", equalTo: commentuuid.last!)
                query.skip = count - self.page
                query.addAscendingOrder("createdAt")
                query.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                    if error == nil{
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.commentArray.removeAll(keepingCapacity: false)
                        self.avaArray.removeAll(keepingCapacity: false)
                        self.dateArray.removeAll(keepingCapacity: false)
                        
                        for object in objects!{
                            self.usernameArray.append((object as AnyObject).object(forKey:"username") as! String)
                            self.avaArray.append((object as AnyObject).object(forKey: "ava") as! AVFile)
                            self.commentArray.append((object as AnyObject).object(forKey: "comment") as! String)
                            self.dateArray.append((object as AnyObject).createdAt!!)
                            
                            self.tableView.reloadData()
                        }
                    }else{
                        print(error!.localizedDescription)
                    }
                })
            }
            
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CommentCell
        
        cell.usernameBtn.setTitle(usernameArray[indexPath.row], for: .normal)
        cell.usernameBtn.sizeToFit()
        cell.commentLbl.text = commentArray[indexPath.row]
        avaArray[indexPath.row].getDataInBackground { (data:Data?, error:Error?) in
            cell.avaImg.image = UIImage.init(data: data!)
        }
        
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
        
        //mentions is tappd
        cell.commentLbl.userHandleLinkTapHandler = { label,handle,rang in
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
                    }else{
                        self.alert(error: "查无此人", message: "查无此人")
                    }
                })
            }
            
        }
        //hashtag is tapped
        cell.commentLbl.hashtagLinkTapHandler = {label,handle,rang in
            var mention = handle
            mention = String(mention.dropFirst())
            hashtag.append(mention.lowercased())
            
            let hashvc = self.storyboard?.instantiateViewController(withIdentifier: "HashtagsVC") as! HashtagsVC
            self.navigationController?.pushViewController(hashvc, animated: true)
        }
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        return cell
    }
    @objc func keyboardWillShow(_ notification : Notification){
        let rect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey]) as! NSValue
        keyboard = rect.cgRectValue
        
        UIView.animate(withDuration: 0.4) {
            self.tableView.frame.size.height = self.tableViewHeight - self.keyboard.height
            self.commentTxt.frame.origin.y = self.commentY - self.keyboard.height
            self.sendBtn.frame.origin.y = self.commentTxt.frame.origin.y
        }
    }
    @objc func keyboardWillHide(_ notification : Notification){
        UIView.animate(withDuration: 0.4) {
            self.tableView.frame.size.height = self.tableViewHeight
            self.commentTxt.frame.origin.y = self.commentY
            self.sendBtn.frame.origin.y = self.commentY
        }
    }
    @objc func back(_ sender:UIBarButtonItem){
        self.navigationController?.popViewController(animated: true)
        
        if !commentuuid.isEmpty{
            commentuuid.removeLast()
        }
        if !commentowner.isEmpty{
            commentowner.removeLast()
        }
        
    }
    
    func alignment(){
        //对齐UI控件
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        tableView.frame = CGRect(x: 0, y: 0, width: width, height: height-(self.navigationController?.navigationBar.frame.height)!-UIApplication.shared.statusBarFrame.size.height-42)
        //print("height\(height)\nself.navigationController?.navigationBar.frame.height\(self.navigationController?.navigationBar.frame.height)")
        //tableView.backgroundColor = UIColor.gray
        
        tableView.estimatedRowHeight = width/5.33
        tableView.rowHeight = UITableViewAutomaticDimension
        
        commentTxt.frame = CGRect(x: 16, y: tableView.frame.height+6, width: width-105, height: 30)
        commentTxt.layer.cornerRadius = 4.0
        sendBtn.frame = CGRect(x: width-81, y: tableView.frame.height+6, width: 73, height: 30)
        
        let tapG = UITapGestureRecognizer(target: self, action: #selector(commentTxtClick))
        tapG.numberOfTapsRequired = 1
        commentTxt.isUserInteractionEnabled = true
        //commentTxt.addGestureRecognizer(tapG)
        
        //记录三个初始值
        tableViewHeight = tableView.frame.height
        commentHeight = commentTxt.frame.height
        commentY = commentTxt.frame.origin.y
        
        commentTxt.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    @objc func commentTxtClick(recognizer:UITapGestureRecognizer){
        print("commentTxtClick")
        self.commentTxt.becomeFirstResponder()
    }
    func textViewDidChange(_ textView: UITextView) {
        let spacing = CharacterSet.whitespacesAndNewlines
        if !commentTxt.text.trimmingCharacters(in: spacing).isEmpty{
            sendBtn.isEnabled = true
        }else{
            sendBtn.isEnabled = false
        }
        if textView.contentSize.height > textView.frame.height && textView.frame.height < 130{
            let difference = textView.contentSize.height - textView.frame.height
            textView.frame.origin.y = textView.frame.origin.y - difference
            textView.frame.size.height = textView.contentSize.height
            if textView.contentSize.height + keyboard.height + commentY >= tableView.frame.height{
                tableView.frame.size.height = tableView.frame.size.height - difference
            }
        }else if textView.contentSize.height < textView.frame.height{
            let difference = textView.frame.height - textView.contentSize.height
            textView.frame.origin.y = textView.frame.origin.y+difference
            textView.frame.size.height = textView.contentSize.height
            
            //上移tableView
            if textView.contentSize.height+keyboard.height+commentY > tableView.frame.height{
                tableView.frame.size.height = tableView.frame.size.height + difference
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        //隐藏底部标签栏
        self.tabBarController?.tabBar.isHidden = true
        //调出键盘
        self.commentTxt.becomeFirstResponder()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
