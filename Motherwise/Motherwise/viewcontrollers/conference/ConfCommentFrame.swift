//
//  ConfCommentFrame.swift
//  Motherwise
//
//  Created by Andre on 9/5/20.
//  Copyright © 2020 Motherwise. All rights reserved.
//

import UIKit
import Kingfisher
import SCLAlertView
import YPImagePicker
import SwiftyJSON
import DropDown
import Auk
import DynamicBlurView
import GSImageViewerController
import Firebase
import FirebaseDatabase
import FirebaseStorage
import AVFoundation
import AudioToolbox
import Emoji
import Smile
import ISEmojiView

class ConfCommentFrame: BaseViewController, UITableViewDataSource, UITableViewDelegate, EmojiViewDelegate {

    @IBOutlet weak var navBar: UIView!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var commentList: UITableView!
    @IBOutlet weak var attachButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var commentBox: UITextView!
    @IBOutlet weak var commentImageBox: UIImageView!
    @IBOutlet weak var noResult: UILabel!
    @IBOutlet weak var listH: NSLayoutConstraint!
    @IBOutlet weak var bottomH: NSLayoutConstraint!
    
    @IBOutlet weak var lbl_participants: UILabel!
    
    var imageFile:Data!
    var ImageArray = NSMutableArray()
    
    var comments = [Comment]()
    
    var CHAT_ID:String = ""
    
    @IBOutlet weak var btn_image_upload: UIButton!
    @IBOutlet weak var btn_image_cancel: UIButton!
    @IBOutlet weak var view_image_form: UIView!
    
    @IBOutlet weak var img_user1: UIImageView!
    @IBOutlet weak var img_user2: UIImageView!    
    @IBOutlet weak var img_user3: UIImageView!
    
    var userImages = [UIImageView]()    
    var isEmoji = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addShadowToBar(view: navBar)
        bottomH.constant = bottomSafeAreaHeight
        
        lbl_title.text = "add_comments".localized().uppercased()
        
        sendButton.setImageTintColor(primaryDarkColor)
        btn_image_upload.layer.cornerRadius = btn_image_upload.frame.height / 2
        btn_image_cancel.layer.cornerRadius = btn_image_cancel.frame.height / 2
        
        sendButton.visibilityh = .gone
        
        userImages = [img_user1, img_user2, img_user3]
        for userImage in userImages{
            userImage.isHidden = true
            userImage.layer.cornerRadius = userImage.frame.height / 2
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(showParticipants))
            userImage.isUserInteractionEnabled = true
            userImage.addGestureRecognizer(tap)
        }
        
        commentBox.layer.cornerRadius = commentBox.frame.height / 2
        
        self.view_image_form.isHidden = true
        
        commentBox.setPlaceholder(string: "write_something_".localized())
        commentBox.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
//        commentBox.becomeFirstResponder()
        
        self.commentList.delegate = self
        self.commentList.dataSource = self
        
        self.commentList.estimatedRowHeight = 170.0
        self.commentList.rowHeight = UITableView.automaticDimension
        
        UITextView.appearance().linkTextAttributes = [ .foregroundColor: UIColor.blue ]
        
        if gConference.group_id > 0{
            CHAT_ID = "\(gAdmin.idx)gr\(gConference.group_id)conf\(gConference.idx)"
        }else {
            CHAT_ID = "\(gAdmin.idx)everyoneconf\(gConference.idx)"
        }
        
        if gConfComments.count > 0{
            self.comments = gConfComments
            self.commentList.reloadData()
            self.scrollToFirstRow()
            self.getComments()
            gConfComments.removeAll()
        }else{
            self.getComments()
        }
        
        self.getParticipants()
        
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

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
        return comments.count
    }
            
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell:ConfCommentCell = tableView.dequeueReusableCell(withIdentifier: "ConfCommentCell", for: indexPath) as! ConfCommentCell
                
        let index:Int = indexPath.row
                
        if comments.indices.contains(index) {
            
            let comment = comments[index]
            
            if comment.user.idx == thisUser.idx {
                cell.myImageBox.roundCorners(corners: [.topLeft, .topRight, .bottomLeft], radius: 15)
                cell.myCommentBox.roundCorners(corners: [.topLeft, .topRight, .bottomLeft], radius: 15)
                cell.contentLayout.visibility = .gone
                cell.myContentLayout.visibility = .visible
                
                if comment.image_url != ""{
                    loadPicture(imageView: cell.myImageBox, url: URL(string: comment.image_url)!)
                    cell.myImageBox.visibility = .visible
                }else{
                    cell.myImageBox.visibility = .gone
                }

                cell.myImageBox.layer.borderColor = UIColor(rgb: 0xcce6ff, alpha: 1.0).cgColor
                cell.myImageBox.layer.borderWidth = 5

                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(gesture:)))

                cell.myImageBox.tag = index
                cell.myImageBox.addGestureRecognizer(tapGesture)
                cell.myImageBox.isUserInteractionEnabled = true

                if comment.comment != ""{
                    cell.myCommentBox.text = self.processingEmoji(str:comment.comment)
                    cell.myCommentBox.visibility = .visible
                    
                    cell.myCommentBoxWidth.constant = UIFont.systemFont(ofSize: 16.0).textWidth(s: cell.myCommentBox.text) + 120
                    if cell.myCommentBoxWidth.constant < 80 {cell.myCommentBoxWidth.constant = 80}
                    else if cell.myCommentBoxWidth.constant > self.screenWidth * 5/6 { cell.myCommentBoxWidth.constant = self.screenWidth * 5/6 }
                }else{
                    cell.myCommentBox.visibility = .gone
                }

                cell.myCommentBox.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

                cell.myCommentedTimeBox.text = comment.commented_time
                
                cell.myMenuButton.tag = index
                cell.myMenuButton.addTarget(self, action: #selector(self.openDropDownMenu), for: .touchUpInside)
                            
                // setRoundShadowView(view: cell.contentLayout, corner: 5.0)
                                    
                cell.myCommentBox.sizeToFit()
                cell.myContentLayout.sizeToFit()
                cell.myContentLayout.layoutIfNeeded()
                
            }else{
                cell.imageBox.roundCorners(corners: [.topLeft, .topRight, .bottomRight], radius: 15)
                cell.commentBox.roundCorners(corners: [.topLeft, .topRight, .bottomRight], radius: 15)
                cell.contentLayout.visibility = .visible
                cell.myContentLayout.visibility = .gone
                
                if comment.image_url != ""{
                    loadPicture(imageView: cell.imageBox, url: URL(string: comment.image_url)!)
                    cell.imageBox.visibility = .visible
                }else{
                    cell.imageBox.visibility = .gone
                }
                
                cell.imageBox.layer.borderColor = UIColor(rgb: 0xe6e6e6, alpha: 1.0).cgColor
                cell.imageBox.layer.borderWidth = 5
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(gesture:)))

                cell.imageBox.tag = index
                cell.imageBox.addGestureRecognizer(tapGesture)
                cell.imageBox.isUserInteractionEnabled = true
                
                if comment.user.photo_url != ""{
                    loadPicture(imageView: cell.userPicture, url: URL(string: comment.user.photo_url)!)
                }else {
                    cell.userPicture.image = UIImage(named: "ic_user")
                }
                
                cell.userPicture.layer.cornerRadius = cell.userPicture.frame.width / 2
                        
                if comment.user.idx == thisUser.idx {
                    cell.userNameBox.text = "Me"
                    cell.userNameBox.textColor = primaryDarkColor
                }else{
                    cell.userNameBox.text = comment.user.name
                    cell.userNameBox.textColor = .darkText
                }
                
                if comment.comment != ""{
                    cell.commentBox.text = self.processingEmoji(str:comment.comment)
                    cell.commentBox.visibility = .visible
                    
                    cell.commentBoxWidth.constant = UIFont.systemFont(ofSize: 16.0).textWidth(s: cell.commentBox.text) + 120
                    if cell.commentBoxWidth.constant < 80 {cell.commentBoxWidth.constant = 80}
                    else if cell.commentBoxWidth.constant > self.view.frame.width * 5/6 { cell.commentBoxWidth.constant = self.view.frame.width * 5/6 }
                }else{
                    cell.commentBox.visibility = .gone
                }
                
                cell.commentBox.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
                
                cell.commentedTimeBox.text = comment.commented_time
                
                cell.menuButton.tag = index
                cell.menuButton.addTarget(self, action: #selector(self.openDropDownMenu), for: .touchUpInside)
                            
                // setRoundShadowView(view: cell.contentLayout, corner: 5.0)
                                    
                cell.commentBox.sizeToFit()
                cell.contentLayout.sizeToFit()
                cell.contentLayout.layoutIfNeeded()
            }
                
        }
        
        return cell
        
    }
    
    @objc func imageTapped(gesture:UITapGestureRecognizer){
        if (gesture.view as? UIImageView) != nil {
            print("Image Tapped")
            let imgView = gesture.view as! UIImageView
            let index = imgView.tag
            
            if comments[index].image_url != "" && comments[index].video_url == ""{
                let image = self.getImageFromURL(url: URL(string: comments[index].image_url)!)
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
    
    
    var editF:Bool = false
    var indx:Int!
    
    
    @objc func openDropDownMenu(sender:UIButton){
        let index = sender.tag
        let cell = sender.superview?.superviewOfClassType(ConfCommentCell.self) as! ConfCommentCell
        
        let dropDown = DropDown()
        
        let comment = comments[index]
        
        if comment.user.idx == thisUser.idx{
            dropDown.anchorView = cell.myMenuButton
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
    
    
    func textViewDidChange(_ textView: UITextView) {
        textView.checkPlaceholder()
        if textView.text == ""{
            sendButton.visibilityh = .gone
        }else{
            sendButton.visibilityh = .visible
        }
    }
    
    @IBAction func openAttachMenu(_ sender: Any) {
        
        self.isEmoji = true
        let keyboardSettings = KeyboardSettings(bottomType: .categories)
        let emojiView = EmojiView(keyboardSettings: keyboardSettings)
        emojiView.translatesAutoresizingMaskIntoConstraints = false
        emojiView.delegate = self
        commentBox.inputView = emojiView
        commentBox.reloadInputViews()
        commentBox.becomeFirstResponder()
        
//        let dropDown = DropDown()
//
//        dropDown.anchorView = self.attachButton
//        dropDown.dataSource = ["  📷".decodeEmoji, "  😊".decodeEmoji]
//        // Action triggered on selection
//        dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
//            if idx == 0{
//                var picker:YPImagePicker!
//                var config = YPImagePickerConfiguration()
//                config.wordings.libraryTitle = "gallary".localized().firstUppercased
//                config.wordings.cameraTitle = "camera".localized().firstUppercased
//                YPImagePickerConfiguration.shared = config
//                picker = YPImagePicker()
//                picker.didFinishPicking { [picker] items, _ in
//                    if let photo = items.singlePhoto {
//                        self.commentImageBox.image = photo.image
//                        self.commentImageBox.layer.cornerRadius = 5
//                        self.view_image_form.isHidden = false
//                        self.imageFile = photo.image.jpegData(compressionQuality: 0.8)
//                    }
//                    picker!.dismiss(animated: true, completion: nil)
//                }
//                self.present(picker, animated: true, completion: nil)
//            }else if idx == 1{
//                self.view_emoji.visibility = .visible
//            }
//        }
//
//        DropDown.appearance().textColor = UIColor.black
//        DropDown.appearance().selectedTextColor = UIColor.white
//        DropDown.appearance().textFont = UIFont.boldSystemFont(ofSize: 25.0)
//        DropDown.appearance().backgroundColor = UIColor.white
//        DropDown.appearance().selectionBackgroundColor = UIColor.gray
//        DropDown.appearance().cellHeight = 45
//
//        dropDown.separatorColor = UIColor.lightGray
//        dropDown.width = 70
//
//        dropDown.show()
        
    }
    
    @IBAction func submitComment(_ sender: Any) {
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
    
    func deleteComment(comment_id: Int64){
        
    }
    
    func getComments(){
        self.comments.removeAll()
        var ref:DatabaseReference!
        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "gmmsg" + CHAT_ID)
        print("CHAT ID: \(CHAT_ID)")
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

            self.comments.insert(comment, at: 0)

            self.commentList.reloadData()
            self.scrollToFirstRow()
        })
        
        ref.observe(.childRemoved, with: {(snapshot) -> Void in
            print("Removed////////////////: \(snapshot.key)")
            let key = snapshot.key
            if self.comments.contains(where: {$0.key == key}){
                self.comments.remove(at: self.comments.firstIndex(where: {$0.key == key})!)
                print("comments2: \(self.comments.count)")
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
    
    func uploadFileToStorage(file:Data){
        
        self.showLoadingView()
        
        // Get a reference to the storage service using the default Firebase App
        // Get a non-default Storage bucket
        let storage = Storage.storage(url:"gs://motherwise-1585202524394.appspot.com")
        let storageRef = storage.reference()

        // Create a reference to the file you want to upload
        let fileRef = storageRef.child(String(Date().currentTimeMillis()) + ".jpg")

        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = fileRef.putData(file, metadata: nil) { (metadata, error) in
          guard let metadata = metadata else {
            // Uh-oh, an error occurred!
            return
          }
          // Metadata contains file metadata such as size, content-type.
          let size = metadata.size
          // You can also access to download URL after upload.
          fileRef.downloadURL { (url, error) in
            self.dismissLoadingView()
            guard let downloadURL = url else {
              // Uh-oh, an error occurred!
              return
            }
            print("Download URL: \(downloadURL)")
            var ref:DatabaseReference!
            ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "gmmsg" + self.CHAT_ID).childByAutoId()
            let load:[String:AnyObject] =
                [
                    "sender_id": String(thisUser.idx) as AnyObject,
                    "sender": thisUser.name as AnyObject,
                    "sender_email": thisUser.email as AnyObject,
                    "sender_photo": thisUser.photo_url as AnyObject,
                    "message": "" as AnyObject,
                    "image": "\(downloadURL)" as AnyObject,
                    "video": "" as AnyObject,
                    "lat": "" as AnyObject,
                    "lon": "" as AnyObject,
                    "time": String(Date().currentTimeMillis()) as AnyObject
                ]
            ref.setValue(load)

            self.view_image_form.isHidden = true
            self.imageFile = nil
          }
        }
        
    }
    
    
    @IBAction func uploadImage(_ sender: Any) {
        if self.imageFile != nil{
            self.uploadFileToStorage(file: self.imageFile)
        }
    }
    
    @IBAction func cancelImage(_ sender: Any) {
        self.view_image_form.isHidden = true
        self.imageFile = nil
    }
    
    var users = [User]()
    
    func getParticipants(){
        self.users.removeAll()
        
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

                if !self.users.contains(where: {$0.idx == user.idx}) {
                    self.users.append(user)
                    self.updateUI()
                }
                print("Users////////////////: \(self.users.count)")
                
            })
        })
        
        ref.observe(.childRemoved, with: {(snapshot) -> Void in
            print("Removed////////////////: \(snapshot.key)")
            let userEmail = snapshot.key.replacingOccurrences(of: "ddoott", with: ".")
            if self.users.contains(where: {$0.email == userEmail}){
                self.users.remove(at: self.users.firstIndex(where: {$0.email == userEmail})!)
                print("Users////////////////: \(self.users.count)")
                self.updateUI()
            }
        })
        
    }
    
    @objc func showParticipants(gesture:UITapGestureRecognizer){
        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(identifier:"ConfParticipantsViewController")
        self.present(vc, animated:true, completion:nil)
    }
    
    func updateUI(){
        if self.users.count == 1{
            self.loadPicture(imageView: self.userImages[2], url: URL(string: self.users[0].photo_url)!)
            self.userImages[2].isHidden = false
            self.userImages[1].isHidden = true
            self.userImages[0].isHidden = true
        }else if self.users.count == 2{
            self.loadPicture(imageView: self.userImages[2], url: URL(string: self.users[0].photo_url)!)
            self.loadPicture(imageView: self.userImages[1], url: URL(string: self.users[1].photo_url)!)
            self.userImages[2].isHidden = false
            self.userImages[1].isHidden = false
            self.userImages[0].isHidden = true
        }else if self.users.count >= 3{
            self.loadPicture(imageView: self.userImages[2], url: URL(string: self.users[self.users.count - 1].photo_url)!)
            self.loadPicture(imageView: self.userImages[1], url: URL(string: self.users[self.users.count - 2].photo_url)!)
            self.loadPicture(imageView: self.userImages[0], url: URL(string: self.users[self.users.count - 3].photo_url)!)
            self.userImages[2].isHidden = false
            self.userImages[1].isHidden = false
            self.userImages[0].isHidden = false
        }
        self.lbl_participants.text = String(self.users.count)
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
    
    
    
    
}
