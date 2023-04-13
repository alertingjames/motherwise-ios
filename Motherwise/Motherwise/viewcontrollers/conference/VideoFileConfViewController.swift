//
//  VideoFileConfViewController.swift
//  Motherwise
//
//  Created by Andre on 9/5/20.
//  Copyright © 2020 Motherwise. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Firebase
import FirebaseDatabase
import VoxeetSDK
import VoxeetUXKit
import Kingfisher
import GSImageViewerController
import Emoji
import Smile
import ISEmojiView
import DropDown

class VideoFileConfViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, EmojiViewDelegate {
    
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var btn_users: UIButton!
    @IBOutlet weak var btn_video: UIButton!
    @IBOutlet weak var view_player: UIView!
    @IBOutlet weak var lbl_conf_name: UILabel!
    @IBOutlet weak var lbl_group: UILabel!
    private var participants = [VTParticipantInfo]()
    private var conferenceAlias:String = ""
    var CHAT_ID:String = ""
    var adminParticipantID = ""
    var player: AVPlayer!
    @IBOutlet weak var commentList: UITableView!
    @IBOutlet weak var listH: NSLayoutConstraint!
    @IBOutlet weak var noResult: UILabel!
    @IBOutlet weak var noResultH: NSLayoutConstraint!
    var comments = [Comment]()
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var emojiButton: UIButton!
    @IBOutlet weak var commentBox: UITextView!
    var isEmoji = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbl_title.text = "enjoy_watching".localized().uppercased()
        
        conferenceAlias = gConference.name
        adminParticipantID = String(gAdmin.idx) + String(gAdmin.idx)
        
        if gConference.group_id > 0{
            CHAT_ID = "\(gAdmin.idx)gr\(gConference.group_id)conf\(gConference.idx)"
            self.lbl_group.text = gConference.group_name
        }else {
            CHAT_ID = "\(gAdmin.idx)everyoneconf\(gConference.idx)"
            self.lbl_group.text = "everyone".localized()
        }
        
        self.noResultH.constant = 50
        
        commentBox.layer.cornerRadius = commentBox.frame.height / 2
        noResult.text = "no_comment_".localized()        
        commentBox.setPlaceholder(string: "write_something_".localized())
        commentBox.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        commentBox.delegate = self
        sendButton.setImageTintColor(.white)
        sendButton.visibilityh = .gone

        btn_users.setImageTintColor(.white)
        btn_video.setImageTintColor(.white)
        
        btn_video.visibilityh = .gone
        
        VoxeetUXKit.shared.appearMaximized = true
        VoxeetUXKit.shared.telecom = false

        // Example of public variables to change the conference behavior.
        VoxeetSDK.shared.notification.push.type = .none
        VoxeetSDK.shared.conference.defaultBuiltInSpeaker = true
        VoxeetSDK.shared.conference.defaultVideo = true

        // Conference delegates.
        VoxeetSDK.shared.conference.delegate = self
        
        lbl_conf_name.text = gConference.name
        
        if gConference.type == "file" && gConference.video_url.count > 0{

            self.showLoadingView()
            
            let url = URL(string: gConference.video_url)!
            let playerItem = CachingPlayerItem(url: url)
            playerItem.delegate = self
            self.player = AVPlayer(playerItem: playerItem)
            self.player.rate = 1 //auto play
            let playerFrame = CGRect(x: 0, y: 0, width: self.view_player.frame.size.width, height: self.view_player.frame.size.height)
            let playerController = AVPlayerViewController()
            playerController.player = self.player
            playerController.showsPlaybackControls = true
            playerController.view.frame = playerFrame
            self.view_player.addSubview(playerController.view)
            self.addChild(playerController)
            playerController.didMove(toParent: self)
//            let playerLayer = AVPlayerLayer(player: self.player)
//            playerLayer.frame = self.view_player.bounds
//            self.view_player.layer.addSublayer(playerLayer)
            self.player.play()

        }
        
        let myParticipantInfo = VTParticipantInfo(externalID: String(thisUser.idx) + String(thisUser.idx), name: thisUser.name, avatarURL: thisUser.photo_url)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        // Connect a session with participant information.
        VoxeetSDK.shared.session.open(info: myParticipantInfo) { error in
           UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
        self.commentList.delegate = self
        self.commentList.dataSource = self
        self.commentList.estimatedRowHeight = 170.0
        self.commentList.rowHeight = UITableView.automaticDimension
        
        beParticipant(online: true)
        openConference(member_id: thisUser.idx, conf_id: gConference.idx)
        getOnlineUsers()
        
        // Move this viewcontroller to background by clicking on Home Button
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appToBackground),
            name: UIApplication.willResignActiveNotification,
            object: nil)
        
        // Move this viewcontroller to foreground by clicking on app icon
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appToForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil)
        
    }
    
    @objc func appToBackground(notification: NSNotification) {
        print("I moved to background")
        self.beParticipant(online: false)
    }
        
    @objc func appToForeground(notification: NSNotification) {
        print("I moved to foreground.")
        self.beParticipant(online: true)
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if !self.isEmoji {
            commentBox.inputView = nil
            commentBox.keyboardType = .default
            commentBox.reloadInputViews()
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        self.isEmoji = false
        return true
    }
    
    @objc func textViewDidChange(_ textView: UITextView) {
        textView.checkPlaceholder()
        if textView.text == ""{
            sendButton.visibilityh = .gone
        }else{
            sendButton.visibilityh = .visible
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.player.pause()
        self.player = nil
        self.closeVideoConference()
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
                print("Task done for: \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        gVideoFileViewController = self
        gRecentViewController = self
        self.commentList.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        self.commentList.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.commentList.removeObserver(self, forKeyPath: "contentSize")
        self.commentList.reloadData()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            if object is UITableView {
                if let newvalue = change?[.newKey]{
                    let newsize = newvalue as! CGSize
                    self.listH.constant = newsize.height
                }
            }
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
            
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell:CommentCell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        
        cell.backgroundColor = .clear
//        self.commentList.backgroundColor = .clear
                
        let index:Int = indexPath.row
                
        if self.comments.indices.contains(index) {
            
            let comment = self.comments[index]
            
            if comment.image_url != ""{
                self.loadPicture(imageView: cell.imageBox, url: URL(string: comment.image_url)!)
                cell.imageBox.visibility = .visible
            }else{
                cell.imageBox.visibility = .gone
            }

            cell.imageBox.roundCorners(corners: [.topRight, .bottomLeft, .bottomRight], radius: 15)

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(gesture:)))

            cell.imageBox.tag = index
            cell.imageBox.addGestureRecognizer(tapGesture)
            cell.imageBox.isUserInteractionEnabled = true

            if comment.comment != ""{
                cell.commentBox.text = self.processingEmoji(str:comment.comment)
                cell.commentBox.visibility = .visible
            }else {
                cell.commentBox.visibility = .gone
            }
            cell.commentBox.roundCorners(corners: [.topRight, .bottomLeft, .bottomRight], radius: 15)
            cell.commentBox.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            
            cell.commentBoxWidth.constant = UIFont.systemFont(ofSize: 14.0).textWidth(s: cell.commentBox.text) + 40
            if cell.commentBoxWidth.constant < 80 {cell.commentBoxWidth.constant = 80}
            else if cell.commentBoxWidth.constant > self.view.frame.width * 4/5  { cell.commentBoxWidth.constant = self.view.frame.width * 4/5 }
            
            if comment.user.photo_url != ""{
                self.loadPicture(imageView: cell.userPicture, url: URL(string: comment.user.photo_url)!)
            }
            
            cell.userPicture.layer.cornerRadius = cell.userPicture.frame.width / 2
            
            cell.userNameBox.text = comment.user.name

            cell.commentedTimeBox.text = comment.commented_time
            if comment.user.idx == thisUser.idx {
                cell.userCohortBox.text = thisUser.cohort
            }else{
                if gNewHomeVC.users.contains(where: {$0.idx == comment.user.idx}){
                    cell.userCohortBox.text = gNewHomeVC.users.filter{
                        user in user.idx == comment.user.idx
                        }[0].cohort
                }
            }
            
            cell.menuButton.setImageTintColor(.white)
            cell.menuButton.tag = index
            cell.menuButton.addTarget(self, action: #selector(self.openDropDownMenu), for: .touchUpInside)
                                
            cell.commentBox.sizeToFit()
            cell.contentLayout.sizeToFit()
            cell.contentLayout.layoutIfNeeded()
                
        }
        
        return cell
        
    }
    
    @objc func imageTapped(gesture:UITapGestureRecognizer){
        if (gesture.view as? UIImageView) != nil {
            print("Image Tapped")
            let imgView = gesture.view as! UIImageView
            let index = imgView.tag
            
            let comment = gConfComments[index]
            
            if comment.image_url != "" && comment.video_url == ""{
                let image = self.getImageFromURL(url: URL(string: comment.image_url)!)
                if image != nil {
                    let imageInfo   = GSImageInfo(image: image, imageMode: .aspectFit)
                    let transitionInfo = GSTransitionInfo(fromView:imgView)
                    let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
                        
                    imageViewer.dismissCompletion = {
                            print("dismissCompletion")
                    }
                        
                    self.present(imageViewer, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    @IBAction func openLiveVideo(_ sender: Any) {
        guard VoxeetSDK.shared.conference.current == nil else { return }
        self.showLoadingView()
        self.joinVideoConference()
    }
    
    @IBAction func showParticipants(_ sender: Any) {
        if self.loadingView.isAnimating {
            return
        }
        
        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(identifier:"ConfParticipantsViewController")
        self.present(vc, animated:true, completion:nil)
    }
    
    func openConference(member_id:Int64, conf_id:Int64){
        self.showLoadingView()
        APIs.openConference(member_id: member_id, conf_id: conf_id, handleCallback: {
            users, result in
            self.dismissLoadingView()
            gConfUsers = users!
            self.lbl_group.text = self.lbl_group.text! + " " + "participants".localized() + ": " + String(users!.count)
            self.getComments(chatID: self.CHAT_ID)
        })
    }
    
    @IBAction func openCommentFrame(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ConfCommentFrame")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    func getComments(chatID:String){
        gConfComments.removeAll()
            
        var ref:DatabaseReference!
        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "gmmsg" + chatID)
        ref.observe(.childAdded, with: {(snapshot) -> Void in
            let value = snapshot.value as! [String: Any]
            var timeStamp = String(describing: value["time"])
            timeStamp = timeStamp.replacingOccurrences(of: "Optional(", with: "").replacingOccurrences(of: ")", with: "")
            let time = self.getDateTimeFromTimeStamp(timeStamp: Double(timeStamp)!/1000)
            let message = value["message"] as! String
            let image = value["image"] as! String
            let video = value["video"] as! String
            let sender_id = value["sender_id"] as! String
            let sender_name = value["sender"] as! String
            let sender_email = value["sender_email"] as! String
            let sender_photo = value["sender_photo"] as! String

            print("\(time)")
            print("\(sender_name)")
            print("\(sender_id)")
            print("\(message)")
            print("\(sender_email)")
            print("\(sender_photo)")
    //
            let comment = Comment()
            let user = User()
            user.idx = Int64(sender_id)!
            user.name = sender_name
            user.email = sender_email
            user.photo_url = sender_photo

            comment.user = user
            comment.commented_time = time
            comment.comment = message
            comment.image_url = image
            comment.key = snapshot.key

            gConfComments.insert(comment, at: 0)
            
            self.comments.insert(comment, at: 0)
            self.noResult.visibility = .gone
            self.commentList.reloadData()
            self.scrollToFirstRow()
                
        })
        
        ref.observe(.childRemoved, with: {(snapshot) -> Void in
            print("Removed////////////////: \(snapshot.key)")
            let key = snapshot.key
            if self.comments.contains(where: {$0.key == key}){
                self.comments.remove(at: self.comments.firstIndex(where: {$0.key == key})!)
                print("comments2: \(self.comments.count)")
                if self.comments.isEmpty {
                    self.noResult.visibility = .visible
                    self.noResultH.constant = 50
                }else {
                    self.noResult.visibility = .gone
                }
                self.commentList.reloadData()
            }
        })
        
        ref.observe(.childChanged, with: {(snapshot) -> Void in
            print("Changed////////////////: \(snapshot.key)")
            let key = snapshot.key
            let value = snapshot.value as! [String: Any]
            let message = value["message"] as! String
            if self.comments.contains(where: {$0.key == key}){
                self.comments.filter{ comment in
                    return comment.key == key
                    }[0].comment = message
                self.commentList.reloadData()
            }
        })
            
    }
    
    func scrollToFirstRow() {
        let indexPath = NSIndexPath(row: 0, section: 0)
        self.commentList.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
    }
    
    func beParticipant(online:Bool){
        var ref:DatabaseReference!
        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "gmusers" + self.CHAT_ID).child(thisUser.email.replacingOccurrences(of: ".", with: "ddoott"))
        ref.removeValue()
        if !online {
            return
        }
        let subRef = ref.childByAutoId()
        let load:[String:AnyObject] =
            [
                "sender_id": String(thisUser.idx) as AnyObject,
                "sender_name": thisUser.name as AnyObject,
                "sender_email": thisUser.email as AnyObject,
                "sender_photo": thisUser.photo_url as AnyObject
            ]
        subRef.setValue(load)
    }
    
    func joinVideoConference(){
        self.participants.removeAll()
        for i in 0..<onlineUsers.count {
            if i < 30 {
                let user = onlineUsers[i]
                if user.idx != thisUser.idx {
                    self.participants.append(VTParticipantInfo(externalID: String(user.idx) + String(user.idx), name: user.name, avatarURL: user.photo_url))
                }
            }
        }
        
        // Create a conference (with a custom conference alias).
        let options = VTConferenceOptions()
        options.alias = conferenceAlias
        VoxeetSDK.shared.conference.create(options: options, success: { conference in
            // Join the created conference.
            let joinOptions = VTJoinOptions()
            joinOptions.constraints.video = false
            VoxeetSDK.shared.conference.join(conference: conference, options: joinOptions, success: { conference in
                if self.loadingView.isAnimating { self.dismissLoadingView() }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }, fail: { error in
                if self.loadingView.isAnimating { self.dismissLoadingView() }
                self.errorPopUp(error: error)
            })
            
            // Invite other participants if the conference is just created.
            if conference.isNew {
                VoxeetSDK.shared.notification.invite(conference: conference, participantInfos: self.participants, completion: nil)
            }
        }, fail: { error in
            if self.loadingView.isAnimating { self.dismissLoadingView() }
            self.errorPopUp(error: error)
        })
        
    }
    
    private func errorPopUp(error: Error) {
        DispatchQueue.main.async {
            // Error message.
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "ok".localized().uppercased(), style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func closeVideoConference() {
        guard VoxeetSDK.shared.conference.current == nil else { return }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        // Disconnect current session.
        VoxeetSDK.shared.session.close { error in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.beParticipant(online: false)
            self.dismissViewController()
        }
        
        self.beParticipant(online: false)
        self.dismissViewController()
    }
    
    var onlineUsers = [User]()
    func getOnlineUsers(){
        self.onlineUsers.removeAll()
        var ref:DatabaseReference!
        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "gmusers" + CHAT_ID)
        ref.observe(.childAdded, with: {(snapshot) -> Void in
            let subRef = ref.child(snapshot.key)
            subRef.observe(.childAdded, with: {(snapshot) -> Void in
                let value = snapshot.value as! [String: Any]
                
                let sender_id = value["sender_id"] as! String
                let sender_name = value["sender_name"] as! String
                let sender_email = value["sender_email"] as! String
                let sender_photo = value["sender_photo"] as! String

                print("\(sender_name)")
                print("\(sender_id)")
                print("\(sender_email)")
                print("\(sender_photo)")

                let user = User()
                user.idx = Int64(sender_id)!
                user.name = sender_name
                user.email = sender_email
                user.photo_url = sender_photo

                if !self.onlineUsers.contains(where: {$0.idx == user.idx}) {
                    self.onlineUsers.append(user)
                }
                
            })
        })
        
        ref.observe(.childRemoved, with: {(snapshot) -> Void in
            print("Removed////////////////: \(snapshot.key)")
            let userEmail = snapshot.key.replacingOccurrences(of: "ddoott", with: ".")
            if self.onlineUsers.contains(where: {$0.email == userEmail}){
                self.onlineUsers.remove(at: self.onlineUsers.firstIndex(where: {$0.email == userEmail})!)
            }
        })
        
    }
    
    @IBAction func openEmojis(_ sender: Any) {
        self.isEmoji = true
        let keyboardSettings = KeyboardSettings(bottomType: .categories)
        let emojiView = EmojiView(keyboardSettings: keyboardSettings)
        emojiView.translatesAutoresizingMaskIntoConstraints = false
        emojiView.delegate = self
        commentBox.inputView = emojiView
        commentBox.reloadInputViews()
        commentBox.becomeFirstResponder()
    }
    
    // callback when tap a emoji on keyboard
    func emojiViewDidSelectEmoji(_ emoji: String, emojiView: EmojiView) {
        commentBox.insertText(emoji)
    }

    // callback when tap change keyboard button on keyboard
    func emojiViewDidPressChangeKeyboardButton(_ emojiView: EmojiView) {
        commentBox.inputView = nil
        commentBox.keyboardType = .default
        commentBox.reloadInputViews()
    }
        
    // callback when tap delete button on keyboard
    func emojiViewDidPressDeleteBackwardButton(_ emojiView: EmojiView) {
        commentBox.deleteBackward()
    }

    // callback when tap dismiss button on keyboard
    func emojiViewDidPressDismissKeyboardButton(_ emojiView: EmojiView) {
        print("dismiss keyboard")
        commentBox.resignFirstResponder()
    }
    
    var editF:Bool = false
    var indx:Int!
    
    
    @objc func openDropDownMenu(sender:UIButton){
        let index = sender.tag
        let cell = sender.superview?.superviewOfClassType(CommentCell.self) as! CommentCell
        
        let dropDown = DropDown()
        
        let comment = comments[index]
        
        if comment.user.idx == thisUser.idx{
            dropDown.anchorView = cell.menuButton
            dropDown.dataSource = ["  " + "edit".localized(), "  " + "delete".localized()]
            // Action triggered on selection
            dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
                print("Selected item: \(item) at index: \(idx)")
                if idx == 0{
                    self.commentBox.text = comment.comment
                    self.commentBox.checkPlaceholder()
                    self.commentBox.becomeFirstResponder()
                    self.editF = true
                    self.indx = index
                }else if idx == 1{
                    let alert = UIAlertController(title: "delete".localized().firstUppercased, message: "sure_delete_message".localized().firstUppercased, preferredStyle: .alert)
                    let noAction = UIAlertAction(title: "no".localized().firstUppercased, style: .cancel, handler: {
                        (action : UIAlertAction!) -> Void in })
                    let yesAction = UIAlertAction(title: "yes".localized().firstUppercased, style: .destructive, handler: { alert -> Void in
                        var ref:DatabaseReference!
                        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "gmmsg" + self.CHAT_ID).child(comment.key)
                        ref.removeValue()
                    })
                    
                    alert.addAction(yesAction)
                    alert.addAction(noAction)
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }else{
            dropDown.anchorView = cell.menuButton
            dropDown.dataSource = ["  " + "message".localized()]
            // Action triggered on selection
            dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
                print("Selected item: \(item) at index: \(idx)")
                if idx == 0{
                    gUser = comment.user
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeSendMessageViewController")
                    self.present(vc, animated: true, completion: nil)
                }
            }
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
    
    @IBAction func sendComment(_ sender: Any) {
        if commentBox.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            showToast(msg: "type_something_".localized().firstUppercased)
            return
        }
        
        if editF {
            var ref:DatabaseReference!
            let selComment = self.comments[self.indx]
            ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "gmmsg" + self.CHAT_ID).child(selComment.key).child("message")
            ref.setValue(self.commentBox.text)
            editF = false
            self.commentBox.text = ""
            self.commentBox.checkPlaceholder()
            self.commentBox.resignFirstResponder()
            self.sendButton.visibilityh = .gone
            return
        }
        
        var ref:DatabaseReference!
        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "gmmsg" + CHAT_ID).childByAutoId()
        let load:[String:AnyObject] =
            [
                "sender_id": String(thisUser.idx) as AnyObject,
                "sender": thisUser.name as AnyObject,
                "sender_email": thisUser.email as AnyObject,
                "sender_photo": thisUser.photo_url as AnyObject,
                "message": self.commentBox.text as AnyObject,
                "image": "" as AnyObject,
                "video": "" as AnyObject,
                "lat": "" as AnyObject,
                "lon": "" as AnyObject,
                "time": String(Date().currentTimeMillis()) as AnyObject
            ]
        ref.setValue(load)
        
        self.commentBox.text = ""
        self.commentBox.checkPlaceholder()
        self.commentBox.resignFirstResponder()
        self.sendButton.visibilityh = .gone
    }
    
    
}


/*
 *  MARK: - Conference delegate
 */

extension VideoFileConfViewController: VTConferenceDelegate {
    func statusUpdated(status: VTConferenceStatus) {}
    
    func permissionsUpdated(permissions: [Int]) {}
    
    func participantAdded(participant: VTParticipant) {}
    
    func participantUpdated(participant: VTParticipant) {}
    
    func streamAdded(participant: VTParticipant, stream: MediaStream) {
        switch stream.type {
            case .Camera:
                print("Participant ID: \(participant.id)")
                if participant.id == VoxeetSDK.shared.session.participant?.id {
                    // Attaching own participant's video stream to the renderer.
                    if !stream.videoTracks.isEmpty {
                        print("My Stream added: \(participant.id)")
                //    ownCameraView.attach(participant: participant, stream: stream)
                //    ownCameraView.isHidden = false
                    }
                } else if participant.info.externalID == self.adminParticipantID {
                    //refresh
                    print("admin stream added")
                }else {
                    //refresh
                    print("stream added")
                }
            case .ScreenShare:
                // Attaching a video stream to a renderer.
                print("stream added")
            default:
                break
        }
    }
    
    func streamUpdated(participant: VTParticipant, stream: MediaStream) {
        // Get the video renderer.
        print("Participant ID: \(participant.id)")
        if participant.id == VoxeetSDK.shared.session.participant?.id {
            // Attaching own participant's video stream to the renderer.
            if !stream.videoTracks.isEmpty {
                print("My Steam updated: \(participant.id)")
        //    ownCameraView.attach(participant: participant, stream: stream)
        //    ownCameraView.isHidden = false
            }
        } else if participant.info.externalID == self.adminParticipantID {
            //refresh
            print("admin stream updated")
        }else {
            //refresh
            print("stream added")
        }
    }
    
    func streamRemoved(participant: VTParticipant, stream: MediaStream) {
        switch stream.type {
            case .Camera:
                //refresh
                print("stream removed")
            case .ScreenShare:
                // screenshareview alpha = 0
                print("stream removed")
            default:
                break
        }
    }
    
    
}



extension VideoFileConfViewController: CachingPlayerItemDelegate {
    
    func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        if self.loadingView.isAnimating { self.dismissLoadingView() }
        print("File is downloaded and ready for storing")
    }
    
    func playerItem(_ playerItem: CachingPlayerItem, didDownloadBytesSoFar bytesDownloaded: Int, outOf bytesExpected: Int) {
        print("\(bytesDownloaded)/\(bytesExpected)")
    }
    
    func playerItemPlaybackStalled(_ playerItem: CachingPlayerItem) {
        print("Not enough data for playback. Probably because of the poor network. Wait a bit and try to play later.")
        if self.loadingView.isAnimating { self.dismissLoadingView() }
        showToast(msg: "Not enough data for playback. Probably because of the poor network. Wait a bit and try to play later.")
    }
    
    func playerItem(_ playerItem: CachingPlayerItem, downloadingFailedWith error: Error) {
        print(error)
        if self.loadingView.isAnimating { self.dismissLoadingView() }
        showToast(msg: error.localizedDescription)
    }
    
}
