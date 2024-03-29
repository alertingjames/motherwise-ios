//
//  NotisFrame.swift
//  Motherwise
//
//  Created by Andre on 9/5/20.
//  Copyright © 2020 Motherwise. All rights reserved.
//

import UIKit
import Kingfisher
import DropDown
import FirebaseCore
import FirebaseDatabase
import VoxeetSDK
import VoxeetUXKit

class NotisFrame: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var notiList: UITableView!
    
    @IBOutlet weak var view_searchbar: UIView!
    @IBOutlet weak var edt_search: UITextField!
    @IBOutlet weak var btn_history: UIButton!
    
    let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Comfortaa-Medium", size: 16.0)!,
            .foregroundColor: UIColor.white,
    //        .underlineStyle: NSUnderlineStyle.single.rawValue
    ]
    
    var messages = [Message]()
    var searchMessages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        edt_search.attributedPlaceholder = NSAttributedString(string: "search_".localized(),
            attributes: attrs)
        
        edt_search.textColor = .white
        
        view_searchbar.layer.cornerRadius = view_searchbar.frame.height / 2
        
        btn_history.setImageTintColor(.white)
        
        self.notiList.delegate = self
        self.notiList.dataSource = self
        
        self.notiList.estimatedRowHeight = 80.0
        self.notiList.rowHeight = UITableView.automaticDimension
        
        edt_search.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        self.messages.removeAll()
        self.getChatNotifications()
        self.getNotifications()
        self.getCallNotifications()
        // Refresh all users and groups (you may have received an invitation to a new group)
//        gMainViewController.getHomeData(member_id: thisUser.idx)
    }
    
    func loadPicture(imageView:UIImageView, url:URL){
        let processor = DownsamplingImageProcessor(size: imageView.frame.size)
        ResizingImageProcessor(referenceSize: imageView.frame.size, mode: .aspectFill)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "logo.jpg"),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        {
            result in
            switch result {
            case .success(let value):
                imageView.layer.cornerRadius = imageView.frame.width/2
                print("Task done for: \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
        }
    }
    
     /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
            
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell:NotiCell = tableView.dequeueReusableCell(withIdentifier: "NotiCell", for: indexPath) as! NotiCell
        
        self.notiList.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
                
        let index:Int = indexPath.row
                
        if self.messages.indices.contains(index) {
            
            let message = self.messages[index]
            
            cell.lbl_mark.text = "🔴".decodeEmoji
                    
            if message.sender.photo_url != ""{
                loadPicture(imageView: cell.img_sender, url: URL(string: message.sender.photo_url)!)
            }
            
            cell.img_sender.layer.cornerRadius = cell.img_sender.frame.height / 2
                    
            cell.lbl_sender_name.text = message.sender.name
                
            cell.lbl_time.text = message.messaged_time
            if message.sender.cohort != "" {
                cell.lbl_cohort.visibility = .visible
                if message.sender.cohort == "admin" {cell.lbl_cohort.text = "VaCay Community" } else {cell.lbl_cohort.text = message.sender.cohort}
            }else {
                cell.lbl_cohort.visibility = .gone
            }
            cell.lbl_body.text = message.message
            cell.lbl_body.padding = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
            cell.lbl_body.numberOfLines = 0
            
            cell.btn_menu.setImageTintColor(UIColor.gray)
                
            cell.btn_menu.tag = index
            cell.btn_menu.addTarget(self, action: #selector(openDropDownMenu), for: .touchUpInside)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(tappedView(gesture:)))
            cell.view_content.tag = index
            cell.view_content.addGestureRecognizer(tap)
            cell.view_content.isUserInteractionEnabled = true
            
            cell.view_content.layer.cornerRadius = 5
                    
        }
        
        cell.lbl_body.sizeToFit()
        cell.view_content.sizeToFit()
        cell.view_content.layoutIfNeeded()
                
        return cell
    }
    
    @objc func tappedView(gesture:UITapGestureRecognizer){
        let index = gesture.view?.tag
        let message = self.messages[index!]
        if message.status == "pchat"{
            gUser = message.sender
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PrivateChatViewController")
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }else {
            if !message.status.starts(with: "call"){
                var ref:DatabaseReference!
                ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "notify").child(String(thisUser.idx)).child(message.key)
                ref.removeValue()
            }
            if message.status == "gchat"{
                gSelectedGroupId = Int64(message.id)!
                gSelectedCohort = ""
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "GroupChatViewController")
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }else if message.status == "cchat"{
                gSelectedGroupId = 0
                gSelectedCohort = message.id
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "GroupChatViewController")
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }else if message.status == "post"{
                gId = Int64(message.id)!
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PostsViewController")
                vc.modalPresentationStyle = .fullScreen
                self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
            }else if message.status == "conf"{
                gId = Int64(message.id)!
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ConferencesViewController")
                vc.modalPresentationStyle = .fullScreen
                self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
            }else if message.status == "ginvite"{
                gUsers = gNewHomeVC.users
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeGroupViewController")
                self.present(vc, animated: true, completion: nil)
            }else if message.status.starts(with: "call"){
                var ref:DatabaseReference!
                ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "call").child(String(thisUser.idx)).child(message.key)
                ref.removeValue()
                self.contactCall(message: message)
            }else {
                gId = message.mes_id
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MessageViewController")
                vc.modalPresentationStyle = .fullScreen
                self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
            }
        }
        self.removeFromParent()
        self.view.removeFromSuperview()
    }
            
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        edt_search.attributedText = NSAttributedString(string: edt_search.text!,
        attributes: attrs)
        
        self.messages = filter(keyword: (textField.text?.lowercased())!)
        if messages.isEmpty{
            
        }
        self.notiList.reloadData()
    }
    
    func filter(keyword:String) -> [Message]{
        if keyword == ""{
            return searchMessages
        }
        var filteredMessages = [Message]()
        for message in searchMessages{
            if message.sender.name.lowercased().contains(keyword){
                filteredMessages.append(message)
            }else{
                if message.sender.cohort.lowercased().contains(keyword){
                    filteredMessages.append(message)
                }else{
                    if message.sender.city.lowercased().contains(keyword){
                        filteredMessages.append(message)
                    }else{
                        if message.messaged_time.contains(keyword){
                            filteredMessages.append(message)
                        }else{
                            if message.message.contains(keyword){
                                filteredMessages.append(message)
                            }
                        }
                    }
                }
            }
        }
        return filteredMessages
    }
    
    @objc func openDropDownMenu(sender:UIButton){
        let index = sender.tag
        let cell = sender.superview?.superviewOfClassType(NotiCell.self) as! NotiCell
            
        let dropDown = DropDown()
        
        let message = self.messages[index]
            
        dropDown.anchorView = cell.btn_menu
        dropDown.dataSource = ["  " + "read".localized(), "  " + "progress".localized(), "  " + "contact".localized()]
        // Action triggered on selection
        dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
            print("Selected item: \(item) at index: \(idx)")
            if idx == 0{
                if message.status == "pchat"{
                    gUser = message.sender
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PrivateChatViewController")
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }else {
                    if !message.status.starts(with: "call"){
                        var ref:DatabaseReference!
                        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "notify").child(String(thisUser.idx)).child(message.key)
                        ref.removeValue()
                        gId = message.mes_id
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MessageViewController")
                        self.modalPresentationStyle = .fullScreen
                        self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
                        gMainViewController.getHomeData(member_id: thisUser.idx)
                    }
                }
            }else if idx == 1 {
                if message.status == "pchat"{
                    gUser = message.sender
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PrivateChatViewController")
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }else{
                    if !message.status.starts(with: "call"){
                        var ref:DatabaseReference!
                        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "notify").child(String(thisUser.idx)).child(message.key)
                        ref.removeValue()
                    }
                    if message.status == "gchat"{
                        gSelectedGroupId = Int64(message.id)!
                        gSelectedCohort = ""
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "GroupChatViewController")
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                    }else if message.status == "cchat"{
                        gSelectedGroupId = 0
                        gSelectedCohort = message.id
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "GroupChatViewController")
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                    }else if message.status == "post"{
                        gId = Int64(message.id)!
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PostsViewController")
                        vc.modalPresentationStyle = .fullScreen
                        self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
                    }else if message.status == "conf"{
                        gId = Int64(message.id)!
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ConferencesViewController")
                        vc.modalPresentationStyle = .fullScreen
                        self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
                    }else if message.status == "ginvite"{
                        gUsers = gNewHomeVC.users
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeGroupViewController")
                        self.present(vc, animated: true, completion: nil)
                    }else if message.status.starts(with: "call"){
                        var ref:DatabaseReference!
                        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "call").child(String(thisUser.idx)).child(message.key)
                        ref.removeValue()
                        self.contactCall(message: message)
                    }else {
                        gId = message.mes_id
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MessageViewController")
                        vc.modalPresentationStyle = .fullScreen
                        self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
                    }
                }
            }else if idx == 2 {
                if message.status.starts(with: "call"){
                    var ref:DatabaseReference!
                    ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "notify").child(String(thisUser.idx)).child(message.key)
                    ref.removeValue()
                    self.contactCall(message: message)
                }else {
                    gUser = message.sender
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeSendMessageViewController")
                    self.present(vc, animated: true, completion: nil)
                }
            }
            self.removeFromParent()
            self.view.removeFromSuperview()
        }
            
        DropDown.appearance().textColor = UIColor.black
        DropDown.appearance().selectedTextColor = UIColor.white
        DropDown.appearance().textFont = UIFont.boldSystemFont(ofSize: 13.0)
        DropDown.appearance().backgroundColor = UIColor.white
        DropDown.appearance().selectionBackgroundColor = UIColor.gray
        DropDown.appearance().cellHeight = 40
        
        dropDown.separatorColor = UIColor.lightGray
        dropDown.width = 100
            
        dropDown.show()
            
    }
    
    
    @IBAction func showHistory(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "NotificationsViewController")
        self.present(vc, animated: true, completion: nil)
        self.removeFromParent()
        self.view.removeFromSuperview()
    }
    

    @IBAction func back(_ sender: Any) {
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            self.view.frame = CGRect(x: 0, y: -self.screenHeight, width: self.screenWidth, height: self.screenHeight)
        }){
            (finished) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
    func getChatNotifications(){
//        self.messages.removeAll()
                
        var ref:DatabaseReference!
        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "notification").child(thisUser.email.replacingOccurrences(of: ".", with: "ddoott"))
        ref.observe(.childAdded, with: {(snapshot) -> Void in
            let subRef = ref.child(snapshot.key)
            subRef.observe(.childAdded, with: {(snapshot) -> Void in
                let value = snapshot.value as! [String: Any]
                
                let message = value["msg"] as! String
                let sender_id = value["sender_id"] as! String
                let sender_name = value["senderName"] as! String
                let sender_email = value["sender"] as! String
                let sender_photo = value["senderPhoto"] as! String
                var timeStamp = String(describing: value["time"])
                timeStamp = timeStamp.replacingOccurrences(of: "Optional(", with: "").replacingOccurrences(of: ")", with: "")
                let time = self.getDateTimeFromTimeStamp(timeStamp: Double(timeStamp)!/1000)
                
                let user = User()
                user.idx = Int64(sender_id)!
                user.name = sender_name
                user.email = sender_email
                if gNewHomeVC.users.contains(where: {$0.email == sender_email}){
                    user.cohort = gNewHomeVC.users.filter{user in return user.email == sender_email}[0].cohort
                }
                user.photo_url = sender_photo
                
                let noti = Message()
                noti.sender = user
                noti.messaged_time = time
                noti.timestamp = Int64(timeStamp)!
                noti.message = message
                noti.status = "pchat"
                
                if !self.messages.contains(where: {$0.timestamp == noti.timestamp}) {
                    self.messages.append(noti)
                    self.searchMessages.append(noti)
                    self.messages.sort(by: {$0.timestamp > $1.timestamp})
                    self.notiList.reloadData()
                }
                
                print("Notifications////////////////: \(self.messages.count)")
            })
        })
        
        ref.observe(.childRemoved, with: {(snapshot) -> Void in
            print("Notification Removed////////////////: \(snapshot.key)")
            let userEmail = snapshot.key.replacingOccurrences(of: "ddoott", with: ".")
            if self.messages.contains(where: {$0.sender.email == userEmail}){
                self.messages.remove(at: self.messages.firstIndex(where: {$0.sender.email == userEmail})!)
                print("Notifications////////////////: \(self.messages.count)")
                if self.messages.count > 0{self.messages.sort(by: {$0.timestamp > $1.timestamp})}
                self.notiList.reloadData()
            }
        })
    }
    
    
    func getNotifications(){
//        self.messages.removeAll()
                
        var ref:DatabaseReference!
        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "notify").child(String(thisUser.idx))
        ref.observe(.childAdded, with: {(snapshot) -> Void in
            let value = snapshot.value as! [String: Any]
            
            let message = value["msg"] as! String
            let sender_id = value["sender_id"] as! String
            let sender_name = value["sender_name"] as! String
            let sender_email = value["sender_email"] as! String
            let sender_photo = value["sender_photo"] as! String
            let role = value["role"] as! String
            let type = value["type"] as! String
            let id = value["id"] as! String
            let mes_id = value["mes_id"] as! String
            var timeStamp = String(describing: value["date"])
            timeStamp = timeStamp.replacingOccurrences(of: "Optional(", with: "").replacingOccurrences(of: ")", with: "")
            let time = self.getDateTimeFromTimeStamp(timeStamp: Double(timeStamp)!/1000)
            let key = snapshot.key

            let user = User()
            user.idx = Int64(sender_id)!
            user.name = sender_name
            user.email = sender_email
            if gNewHomeVC.users.contains(where: {$0.email == sender_email}){
                user.cohort = gNewHomeVC.users.filter{user in return user.email == sender_email}[0].cohort
            }
            user.photo_url = sender_photo
            
            let noti = Message()
            noti.sender = user
            noti.messaged_time = time
            noti.timestamp = Int64(timeStamp)!
            noti.message = message
            noti.key = key
            noti.role = role
            noti.type = type
            noti.id = id
            noti.mes_id = Int64(mes_id)!
            if type == "message" {noti.status = "message"}
            else if type == "post" {noti.status = "post"}
            else if type == "group_invite" {noti.status = "ginvite"}
            else if type == "group_chat" {noti.status = "gchat"}
            else if type == "cohort_chat" {noti.status = "cchat"}
            else if type == "conference" {noti.status = "conf"}
            else {noti.status = type}
            
            if !self.messages.contains(where: {$0.timestamp == noti.timestamp}) {
                self.messages.append(noti)
                self.searchMessages.append(noti)
                self.messages.sort(by: {$0.timestamp > $1.timestamp})
                self.notiList.reloadData()
            }
            
            print("Notifications////////////////: \(self.messages.count)")
        })
        
        ref.observe(.childRemoved, with: {(snapshot) -> Void in
            print("Removed////////////////: \(snapshot.key)")
            let key = snapshot.key
            if self.messages.contains(where: {$0.key == key}){
                self.messages.remove(at: self.messages.firstIndex(where: {$0.key == key})!)
                print("Notified Users////////////////: \(self.messages.count)")
                if self.messages.count > 0{self.messages.sort(by: {$0.timestamp > $1.timestamp})}
                self.notiList.reloadData()
            }
        })
    }
    
    
    func getCallNotifications(){
//        self.messages.removeAll()
        
        var ref:DatabaseReference!
        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "call").child(String(thisUser.idx))
        ref.observe(.childAdded, with: {(snapshot0) -> Void in
            let subRef = ref.child(snapshot0.key)
            subRef.observe(.childAdded, with: {(snapshot) -> Void in
                let value = snapshot.value as! [String: Any]
                
                let message = value["msg"] as! String
                let sender_id = value["sender_id"] as! String
                let sender_name = value["sender_name"] as! String
                let sender_email = value["sender_email"] as! String
                let sender_photo = value["sender_photo"] as! String
                let role = value["role"] as! String
                let type = value["type"] as! String
                let id = value["id"] as! String
                let mes_id = value["mes_id"] as! String
                var timeStamp = String(describing: value["date"])
                timeStamp = timeStamp.replacingOccurrences(of: "Optional(", with: "").replacingOccurrences(of: ")", with: "")
                let time = self.getDateTimeFromTimeStamp(timeStamp: Double(timeStamp)!/1000)
                let key = snapshot0.key

                let user = User()
                user.idx = Int64(sender_id)!
                user.name = sender_name
                user.email = sender_email
                if gNewHomeVC.users.contains(where: {$0.email == sender_email}){
                    user.cohort = gNewHomeVC.users.filter{user in return user.email == sender_email}[0].cohort
                }
                user.photo_url = sender_photo
                
                let noti = Message()
                noti.sender = user
                noti.messaged_time = time
                noti.timestamp = Int64(timeStamp)!
                noti.message = message
                noti.key = key
                noti.role = role
                noti.type = type
                noti.id = id
                noti.mes_id = Int64(mes_id)!
                noti.status = type
                
                print("call user: \(noti.sender.name)")
                print("call type: \(noti.type)")
                print("call alias: \(noti.id)")
                
                if !self.messages.contains(where: {$0.timestamp == noti.timestamp}) {
                    self.messages.append(noti)
                    self.searchMessages.append(noti)
                    self.messages.sort(by: {$0.timestamp > $1.timestamp})
                    self.notiList.reloadData()
                }
                
                print("Notifications////////////////: \(self.messages.count)")
            })
            
            subRef.observe(.childRemoved, with: {(snapshot) -> Void in
                print("Removed////////////////: \(snapshot.key)")
                let key = snapshot.key
                if self.messages.contains(where: {$0.key == key}){
                    self.messages.remove(at: self.messages.firstIndex(where: {$0.key == key})!)
                    print("Notified Users////////////////: \(self.messages.count)")
                    if self.messages.count > 0{self.messages.sort(by: {$0.timestamp > $1.timestamp})}
                    self.notiList.reloadData()
                }
            })
        })
        
        ref.observe(.childRemoved, with: {(snapshot) -> Void in
            print("Removed////////////////: \(snapshot.key)")
            let key = snapshot.key
            if self.messages.contains(where: {$0.key == key}){
                self.messages.remove(at: self.messages.firstIndex(where: {$0.key == key})!)
                print("Notified Users////////////////: \(self.messages.count)")
                if self.messages.count > 0{self.messages.sort(by: {$0.timestamp > $1.timestamp})}
                self.notiList.reloadData()
            }
        })
        
    }
    
    
    func contactCall(message:Message) {
        VoxeetUXKit.shared.appearMaximized = true
        VoxeetUXKit.shared.telecom = true
        
        // Example of public variables to change the conference behavior.
        VoxeetSDK.shared.notification.push.type = .callKit
        VoxeetSDK.shared.conference.defaultBuiltInSpeaker = true
        VoxeetSDK.shared.conference.defaultVideo = true
        
        let participantInfo = VTParticipantInfo(externalID: String(message.sender.idx) + String(message.sender.idx), name: message.sender.name, avatarURL: message.sender.photo_url)
        // Conference login
        let myParticipantInfo = VTParticipantInfo(externalID: String(thisUser.idx) + String(thisUser.idx), name: thisUser.name, avatarURL: thisUser.photo_url)
        // Connect a session with participant information.
        VoxeetSDK.shared.session.open(info: myParticipantInfo) { error in
           let options = VTConferenceOptions()
            let alias =  message.id
            options.alias = alias
           
           VoxeetSDK.shared.conference.create(options: options, success: { conference in
               let joinOptions = VTJoinOptions()
               joinOptions.constraints.video = true
               VoxeetSDK.shared.conference.join(conference: conference, options: joinOptions, fail: { error in print(error) })
            // Invite other participants if the conference is just created.
            if conference.isNew {
                VoxeetSDK.shared.notification.invite(conference: conference, participantInfos: [participantInfo], completion: nil)
            }
           }, fail: { error in print(error) })
        }
        
    }
    
}
