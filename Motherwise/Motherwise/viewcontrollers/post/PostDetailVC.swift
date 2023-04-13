//
//  PostDetailVC.swift
//  Motherwise
//
//  Created by james on 4/7/23.
//  Copyright © 2023 VaCay. All rights reserved.
//

import UIKit
import Kingfisher
import SCLAlertView
import DropDown
import Auk
import DynamicBlurView
import YPImagePicker
import SwiftyJSON
import GSImageViewerController
//import Reactions
import Emoji
import Smile
import ISEmojiView
import Alamofire
import SwiftyJSON

class PostDetailVC: BaseViewController, EmojiViewDelegate {
    
    @IBOutlet weak var userPicture: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userCohort: UILabel!
    
    @IBOutlet weak var menuButton: UIButton!
    
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postCategory: UILabel!
    @IBOutlet weak var postDateTime: UILabel!
    
    @IBOutlet weak var postImageContainer: UIView!
    @IBOutlet weak var postImageScrollView: UIScrollView!
    
    @IBOutlet weak var postDesc: UITextView!
    @IBOutlet weak var linkView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var linkViewH: NSLayoutConstraint!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var reactionButton: ReactionButton!
    @IBOutlet weak var reactionSummary: ReactionSummary!
    
    @IBOutlet weak var attachButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var commentBox: UITextView!
    @IBOutlet weak var commentImageBox: UIImageView!
    @IBOutlet weak var noResult: UILabel!
    @IBOutlet weak var view_emoji: UIView!
    @IBOutlet weak var commentLayout: UIView!
    @IBOutlet weak var bottomH: NSLayoutConstraint!
    
    @IBOutlet weak var lbl_emoji1: UILabel!
    @IBOutlet weak var lbl_emoji2: UILabel!
    @IBOutlet weak var lbl_emoji3: UILabel!
    @IBOutlet weak var lbl_emoji4: UILabel!
    @IBOutlet weak var lbl_emoji5: UILabel!
    @IBOutlet weak var lbl_emoji6: UILabel!
    @IBOutlet weak var lbl_emoji7: UILabel!
    @IBOutlet weak var lbl_emoji8: UILabel!
    @IBOutlet weak var lbl_emoji9: UILabel!
    @IBOutlet weak var commentsView: UIView!
    @IBOutlet weak var commentsStackView: UIStackView!
    
    var blurView:DynamicBlurView!
    var sliderImagesArray = NSMutableArray()
    
    var picker:YPImagePicker!
    var imageFile:Data!
    var ImageArray = NSMutableArray()
    
    var comments = [Comment]()
    
    var emojiButtons = [UILabel]()
    var emojiStrings = [String]()
    
    var linkpreviews = [PostPreview]()
    var isEmoji = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gPostDetailVC = self
        
        sendButton.visibilityh = .gone
        attachButton.visibilityh = .visible
        
        bottomH.constant = bottomSafeAreaHeight
        
        commentBox.layer.cornerRadius = commentBox.frame.height / 2
        
        self.commentImageBox.isHidden = true
        self.noResult.text = "no_comment_".localized()
        
        commentBox.setPlaceholder(string: "write_something_".localized())
        commentBox.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        commentBox.delegate = self
        
        var config = YPImagePickerConfiguration()
        config.wordings.libraryTitle = "gallery".localized()
        config.wordings.cameraTitle = "camera".localized()
        YPImagePickerConfiguration.shared = config
        picker = YPImagePicker()
        
        emojiButtons = [lbl_emoji1, lbl_emoji2, lbl_emoji3, lbl_emoji4, lbl_emoji5, lbl_emoji6, lbl_emoji7, lbl_emoji8, lbl_emoji9]
        emojiStrings = ["💖","👍","😊","😄","😍","🙁","😂","😠","😛"]
        
        for emjButton in emojiButtons {
            let index = emojiButtons.firstIndex(of: emjButton)!
            emjButton.text = emojiStrings[index].decodeEmoji
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(addEmoji))
            emjButton.tag = index
            emjButton.isUserInteractionEnabled = true
            emjButton.addGestureRecognizer(tap)
        }
        
        self.commentLayout.isHidden = gPost.user.idx == thisUser.idx
        self.view_emoji.isHidden = true
        
        userPicture.layer.cornerRadius = userPicture.frame.height / 2
        
        if gPost.user.photo_url != ""{
            loadPicture(imageView: userPicture, url: URL(string: gPost.user.photo_url)!)
        }
                
        userName.text = gPost.user.name
        userCohort.text = gPost.user.cohort
        postTitle.text = self.processingEmoji(str:gPost.title)
        postCategory.text = gPost.category
        postDateTime.text = gPost.posted_time
        if gPost.status == "updated" {
            postDateTime.text = "updated_at".localized() + " " + gPost.posted_time
        }
        
        UITextView.appearance().linkTextAttributes = [ .foregroundColor: UIColor(rgb: 0x0BFFFF, alpha: 1.0) ]
        postDesc.text = self.processingEmoji(str:gPost.content)
        
        linkpreviews = gPost.previews
        if gPost.previews.count > 0 {
            linkView.visibility = .visible
            stackView.arrangedSubviews
                .filter({ $0 is LinkView})
                .forEach({ $0.removeFromSuperview() })
            var i = 0
            for prev in gPost.previews {
                i += 1
                let linkView = (Bundle.main.loadNibNamed("LinkView", owner: self, options: nil))?[0] as! LinkView
                if prev.image_url.count > 0{
                    linkView.linkImageBox.visibilityh = .visible
                    loadPicture(imageView: linkView.linkImageBox, url: URL(string: prev.image_url)!)
                }else {
                    linkView.linkImageBox.visibilityh = .gone
                }
                linkView.linkTitleBox.text = prev.title
                if prev.icon_url.count > 0{
                    linkView.linkiconBox.visibilityh = .visible
                    loadPicture(imageView: linkView.linkiconBox, url: URL(string: prev.icon_url)!)
                }else {
                    linkView.linkiconBox.visibilityh = .gone
                }
                linkView.linkUrlBox.text = prev.site_url
                linkView.frame.size.height = 60
                linkView.linkImageW.constant = CGFloat(linkView.frame.size.height * 1.2)
                
                linkView.tag = i
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedLinkPreview(gesture:)))
                linkView.addGestureRecognizer(tap)
                
                stackView.addArrangedSubview(linkView)
                linkView.layoutIfNeeded()
            }
            linkViewH.constant = CGFloat(60 * gPost.previews.count)
        }else {
            linkView.visibility = .gone
//                cell.linkViewH.constant = 0
        }
        linkView.sizeToFit()

        commentsLabel.text = String(gPost.comments)
        
        menuButton.setImageTintColor(UIColor(rgb: 0xffffff, alpha: 0.8))
        commentButton.setImageTintColor(.white)
        
//        attachButton.setImageTintColor(.white)
        sendButton.setImageTintColor(.white)
        
        self.getPostPictures(post: gPost)
        self.getPostComments(commentsView: commentsView, commentsStackView: commentsStackView)
        
        if gPost.pictures == 0{
            self.postImageContainer.visibility = .gone
        }
        
        loadReactions()
        
    }
    
    func loadReactions() {
        // Reactions
        reactionButton.reactionSelector = ReactionSelector()
        reactionButton.config           = ReactionButtonConfig() {
          $0.iconMarging      = 8
          $0.spacing          = 4
          $0.font             = UIFont(name: "HelveticaNeue", size: 14)
            $0.neutralTintColor = .white
          $0.alignment        = .left
        }
        
        if gPost.my_feeling.lowercased() == "like" {
            reactionButton.reaction = Reaction.facebook.like
            reactionButton.isSelected = true
        }else if gPost.my_feeling.lowercased() == "love" { reactionButton.reaction = Reaction.facebook.love }
        else if gPost.my_feeling.lowercased() == "haha" { reactionButton.reaction = Reaction.facebook.haha }
        else if gPost.my_feeling.lowercased() == "wow" { reactionButton.reaction = Reaction.facebook.wow }
        else if gPost.my_feeling.lowercased() == "sad" { reactionButton.reaction = Reaction.facebook.sad }
        else if gPost.my_feeling.lowercased() == "angry" { reactionButton.reaction = Reaction.facebook.angry }
        
        var icons = [Reaction]()
        if gPost.likes > 0 { icons.append(Reaction.facebook.like) }
        if gPost.loves > 0 { icons.append(Reaction.facebook.love) }
        if gPost.hahas > 0 { icons.append(Reaction.facebook.haha) }
        if gPost.wows > 0 { icons.append(Reaction.facebook.wow) }
        if gPost.sads > 0 { icons.append(Reaction.facebook.sad) }
        if gPost.angrys > 0 { icons.append(Reaction.facebook.angry) }
        
        reactionSummary.reactions = icons
        reactionSummary.setDefaultText(withTotalNumberOfPeople: gPost.reactions, includingYou: false)
        reactionSummary.config    = ReactionSummaryConfig {
          $0.spacing      = 8
          $0.iconMarging  = 2
          $0.font         = UIFont(name: "HelveticaNeue", size: 14)
            $0.textColor    = .white
          $0.alignment    = .left
          $0.isAggregated = true
        }
        reactionSummary.addTarget(self, action: #selector(toLikes(sender:)), for: .touchUpInside)
        reactionButton.addTarget(self, action: #selector(popupReactionMenu(sender:)), for: .touchUpInside)
        reactionButton.reactionSelector?.addTarget(self, action: #selector(reactionDidChanged(sender:)), for: .valueChanged)
    }
    
    @objc func popupReactionMenu(sender:ReactionButton) {
        let reactionButton = sender as! ReactionButton
        if reactionButton.isSelected == true {
            reactionButton.presentReactionSelector()
        }else {
            print("unselected")
            reactionButton.reaction = .facebook.like
            reactPost(member_id: thisUser.idx, post_id: gPost.idx, feeling: "")
        }
    }
    
    @objc func reactionDidChanged(sender: AnyObject) {
        let select = sender as! ReactionSelector
        let feeling = select.selectedReaction?.title
        reactPost(member_id: thisUser.idx, post_id: gPost.idx, feeling: feeling!.lowercased())
    }
    
    func reactPost(member_id:Int64, post_id:Int64, feeling:String) {
        APIs.reactPost(member_id: member_id, post_id: post_id, feeling: feeling, handleCallback: {
            post, result_code in
            if result_code == "0" {
                gPost = post!
                self.loadReactions()
            }
        })
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
    
    @objc func toLikes(sender:AnyObject) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "LikesViewController")
        self.present(vc, animated: true, completion: nil)
    }
    
    
    @objc func tappedLinkPreview(gesture:UITapGestureRecognizer) {
        let linkprev = linkpreviews[gesture.view!.tag - 1]
        if let url = URL(string: linkprev.site_url) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc func addEmoji(sender:UITapGestureRecognizer){
        let label = sender.view as! UILabel
        let index = label.tag
        self.commentBox.text = self.commentBox.text + (self.processingEmoji(str:emojiStrings[index]))
        self.commentBox.checkPlaceholder()
        if self.commentBox.text == ""{
            sendButton.visibilityh = .gone
        }else{
            sendButton.visibilityh = .visible
        }
    }
    
    @objc func textViewDidChange(_ textView: UITextView) {
        textView.checkPlaceholder()
        if textView.text == ""{
            sendButton.visibilityh = .gone
        }else{
            sendButton.visibilityh = .visible
        }
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
    
    func getPostPictures(post: Post){
        self.showLoadingView()
        APIs.getPostPictures(post_id: post.idx,handleCallback: {
            pictures, result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                self.postImageScrollView.auk.settings.contentMode = .scaleAspectFit
                self.blurView = DynamicBlurView(frame: self.postImageContainer.bounds)
                        
                // self.sliderImagesArray.addObjects(from: gPostPictures)
                            
                for pic in pictures! {
                    self.postImageScrollView.auk.show(url: pic.image_url)
                }
                            
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedScrollView(_:)))
                self.postImageScrollView.addGestureRecognizer(tap)
            }
        })
            
    }
    
    @objc func tappedScrollView(_ sender: UITapGestureRecognizer? = nil) {
        let index = self.postImageScrollView.auk.currentPageIndex
    //        print("tapped on Image: \(index)")
        let images = self.postImageScrollView.auk.images
        let image = images[index!]
            
        let imageInfo   = GSImageInfo(image: image , imageMode: .aspectFit)
        let transitionInfo = GSTransitionInfo(fromView:self.postImageScrollView)
        let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
            
        imageViewer.dismissCompletion = {
                print("dismissCompletion")
        }
            
        present(imageViewer, animated: true, completion: nil)
    }
    
    @IBAction func openDropDownMenu(_ sender:Any){
        
        let dropDown = DropDown()
        
        dropDown.anchorView = self.menuButton
        if gPost.user.idx == thisUser.idx{
            dropDown.dataSource = ["  " + "likes".localized(), "  " + "edit".localized(), "  " + "delete".localized()]
            // Action triggered on selection
            dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
                print("Selected item: \(item) at index: \(idx)")
                if idx == 0{
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "LikesViewController")
                    self.present(vc, animated: true, completion: nil)
                }else if idx == 1{
                    gNewPostViewController = nil
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "EditPostViewController")
                    self.present(vc, animated: true, completion: nil)
                }else if idx == 2{
                    let alert = UIAlertController(title: "delete".localized(), message: "sure_delete_post".localized(), preferredStyle: .alert)
                    let noAction = UIAlertAction(title: "no".localized(), style: .cancel, handler: {
                        (action : UIAlertAction!) -> Void in })
                    let yesAction = UIAlertAction(title: "yes".localized(), style: .destructive, handler: { alert -> Void in
                        self.deletePost(post_id: gPost.idx)
                    })
                    
                    alert.addAction(yesAction)
                    alert.addAction(noAction)
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }else{
            dropDown.dataSource = ["  " + "likes".localized(), "  " + "message".localized()]
            // Action triggered on selection
            dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
                print("Selected item: \(item) at index: \(idx)")
                if idx == 0{
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "LikesViewController")
                    self.present(vc, animated: true, completion: nil)
                }else if idx == 1{
                    gUser = gPost.user
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeSendMessageViewController")
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
        
        DropDown.appearance().textColor = UIColor.black
        DropDown.appearance().selectedTextColor = UIColor.white
        DropDown.appearance().textFont = UIFont.boldSystemFont(ofSize: 15.0)
        DropDown.appearance().backgroundColor = UIColor.white
        DropDown.appearance().selectionBackgroundColor = UIColor.gray
        DropDown.appearance().cellHeight = 50
        
        dropDown.separatorColor = UIColor.lightGray
        dropDown.width = 120
        
        dropDown.show()
        
    }
    
    
    
//    @IBAction func openCommentBox(_ sender: Any) {
//        if gPost.idx > 0 && gPost.user.idx != thisUser.idx {
////            self.commentLayout.isHidden = false
//        }
//    }
    
    
    @objc func openCommentBox(sender:UIButton) {
        let cell = sender.superview?.superviewOfClassType(CommentCommentView.self) as! CommentCommentView
        gComment1 = self.comments[sender.tag]
        gCommentsView = cell.subcommentsView
        gCommentsStackView = cell.subcommentsStackView
        let vc = UIStoryboard(name: "PostDetail", bundle: nil).instantiateViewController(identifier: "CommentOnCommentVC")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    
    @objc func openCommentBox1(sender:UIButton) {
        let cell = sender.superview?.superviewOfClassType(CommentCommentView.self) as! CommentCommentView
        gComment1 = self.subcomments[sender.tag]
        gCommentsView = cell.subcommentsView
        gCommentsStackView = cell.subcommentsStackView
        let vc = UIStoryboard(name: "PostDetail", bundle: nil).instantiateViewController(identifier: "CommentOnCommentVC")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func deletePost(post_id: Int64){
        self.showLoadingView()
        APIs.deletePost(post_id: post_id, handleCallback: {
            result_code in
            self.dismissLoadingView()
            if result_code == "0"{
                self.showToast2(msg: "deleted".localized())
                self.dismiss(animated: true, completion: nil)
            }else if result_code == "1"{
                self.showToast(msg: "post_not_exist".localized())
                self.dismiss(animated: true, completion: nil)
            }else {
                self.showToast(msg:"something_wrong".localized())
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func getPostComments(commentsView:UIView, commentsStackView:UIStackView) {
        let params = [
            "post_id":String(gPost.idx),
            "member_id":String(thisUser.idx),
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "getcomments", method: .post, parameters: params).responseJSON { [self] response in
            if response.result.isFailure{
                
            } else {
                let json = JSON(response.result.value!)
                let result_code = json["result_code"].stringValue
                if(result_code == "0") {
                    self.comments.removeAll()
                    let dataArray = json["data"].arrayObject as! [[String: Any]]
                    if !dataArray.isEmpty { commentsView.visibility = .visible }
                    else { commentsView.visibility = .gone }
                    commentsStackView.arrangedSubviews
                        .filter({ $0 is CommentCommentView})
                        .forEach({ $0.removeFromSuperview() })
                    var iii = -1
                    for data in dataArray {
                        let json = JSON(data)
                        var data = json["comment"].object as! [String: Any]
                        let comment = Comment()
                        comment.idx = data["id"] as! Int64
                        comment.post_id = Int64(data["post_id"] as! String)!
                        comment.comment = data["comment_text"] as! String
                        comment.image_url = data["image_url"] as! String
                        comment.commented_time = data["commented_time"] as! String
                        comment.status = data["status"] as! String
                        comment.parent_comment_id = 0
                        comment.parent_comments_view = commentsView
                        comment.parent_comments_stackview = commentsStackView
                        
                        // Reactions
                        comment.likes = (data["likes"] as! String).count > 0 ? Int(data["likes"] as! String)! : 0
                        comment.loves = (data["loves"] as! String).count > 0 ? Int(data["loves"] as! String)! : 0
                        comment.hahas = (data["haha"] as! String).count > 0 ? Int(data["haha"] as! String)! : 0
                        comment.wows = (data["wow"] as! String).count > 0 ? Int(data["wow"] as! String)! : 0
                        comment.sads = (data["sad"] as! String).count > 0 ? Int(data["sad"] as! String)! : 0
                        comment.angrys = (data["angry"] as! String).count > 0 ? Int(data["angry"] as! String)! : 0
                        comment.reactions = (data["reactions"] as! String).count > 0 ? Int(data["reactions"] as! String)! : 0
                        comment.my_feeling = data["liked"] as! String
                        comment.comments = Int64(data["comments"] as! String)!
                        
                        data = json["member"].object as! [String: Any]
                        let user = User()
                        user.idx = data["id"] as! Int64
                        user.admin_id = Int64(data["admin_id"] as! String)!
                        user.name = data["name"] as! String
                        user.email = data["email"] as! String
                        user.password = data["password"] as! String
                        user.photo_url = data["photo_url"] as! String
                        user.phone_number = data["phone_number"] as! String
                        user.city = data["city"] as! String
                        user.address = data["address"] as! String
                        user.lat = data["lat"] as! String
                        user.lng = data["lng"] as! String
                        user.cohort = data["cohort"] as! String
                        user.registered_time = data["registered_time"] as! String
                        user.fcm_token = data["fcm_token"] as! String
                        user.status = data["status"] as! String
                        user.status2 = data["status2"] as! String
                        
                        comment.user = user
                        
                        iii += 1
                        self.comments.append(comment)
                        
                        let commentCommentView = (Bundle.main.loadNibNamed("CommentCommentView", owner: self, options: nil))?[0] as! CommentCommentView
                        
                        if comment.image_url != ""{
                            self.loadPicture(imageView: commentCommentView.imageBox, url: URL(string: comment.image_url)!)
                            commentCommentView.imageBox.visibilityh = .visible
                        }else{
                            commentCommentView.imageBox.visibilityh = .gone
                        }
                        
                        commentCommentView.backgroundColor = UIColor.clear
                            
                        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(gesture:)))
                        commentCommentView.imageBox.tag = iii
                        commentCommentView.imageBox.addGestureRecognizer(tapGesture)
                        commentCommentView.imageBox.isUserInteractionEnabled = true
                            
                        if comment.user.photo_url != ""{
                            self.loadPicture(imageView: commentCommentView.userPicture, url: URL(string: comment.user.photo_url)!)
                        }
                        commentCommentView.userPicture.layer.cornerRadius = commentCommentView.userPicture.frame.width / 2
                                    
                        commentCommentView.userNameBox.text = comment.user.name
                        commentCommentView.userCohortBox.text = comment.user.cohort
                        commentCommentView.commentBox.text = self.processingEmoji(str:comment.comment)
                        commentCommentView.commentedTimeBox.text = comment.commented_time
                        
                        self.loadCommentReaction(ccView: commentCommentView, comment: comment, index: iii)
                        commentCommentView.commentsBox.text = String(comment.comments)
                        
                        commentCommentView.subcommentsView.visibility = .gone
                        
                        commentCommentView.commentsButton.setImageTintColor(.white)
                        commentCommentView.commentsButton.tag = Int(comment.idx)
                        commentCommentView.commentsButton.addTarget(self, action: #selector(self.openSubcomments(sender:)), for: .touchUpInside)
                        
                        commentCommentView.commentButton.setImageTintColor(.white)
                        commentCommentView.commentButton.tag = iii
                        commentCommentView.commentButton.addTarget(self, action: #selector(self.openCommentBox(sender:)), for: .touchUpInside)
                        
                        if comment.user.idx != thisUser.idx {
                            commentCommentView.menuButton.visibilityh = .gone
                        }
                        commentCommentView.menuButton.setImageTintColor(UIColor.lightGray)
                        commentCommentView.menuButton.tag = iii
                        commentCommentView.menuButton.addTarget(self, action: #selector(self.openCommentDropDownMenu(sender:)), for: .touchUpInside)
                                    
                        commentCommentView.commentBox.sizeToFit()
                        
                        commentsStackView.addArrangedSubview(commentCommentView)
                        commentsView.layoutIfNeeded()
                    }
                    
                    self.commentsLabel.text = String(self.comments.count)
                    
                    if comments.count == 0 {
                        self.noResult.isHidden = false
                    }
                    
                } else if result_code == "1" {
                    self.showToast(msg: "post_not_exist".localized())
                } else{
                    self.showToast(msg: "something_wrong".localized())
                }
            }
        }
    }
    
        
    @objc func imageTapped(gesture:UITapGestureRecognizer){
        if (gesture.view as? UIImageView) != nil {
            print("Image Tapped")
            let imgView = gesture.view as! UIImageView
            let index = imgView.tag
                
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
        
    @objc func openCommentDropDownMenu(sender:UIButton){
        let index = sender.tag
        let ccView = sender.superview?.superviewOfClassType(CommentCommentView.self) as! CommentCommentView
            
        let dropDown = DropDown()
            
        dropDown.anchorView = ccView.menuButton
        if comments[index].user.idx == thisUser.idx{
            dropDown.dataSource = ["  " + "delete".localized()]
            // Action triggered on selection
            dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
                print("Selected item: \(item) at index: \(idx)")
                if idx == 0{
                    let alert = UIAlertController(title: "delete".localized(), message: "sure_delete_comment".localized(), preferredStyle: .alert)
                    let noAction = UIAlertAction(title: "no".localized(), style: .cancel, handler: {
                            (action : UIAlertAction!) -> Void in })
                    let yesAction = UIAlertAction(title: "yes".localized(), style: .destructive, handler: { alert -> Void in
                        self.deleteComment(comment_id: self.comments[index].idx)
                    })
                    alert.addAction(yesAction)
                    alert.addAction(noAction)
                    self.present(alert, animated: true, completion: nil)
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
    
    @IBAction func openCamera(_ sender: Any) {
        
        self.isEmoji = true
        let keyboardSettings = KeyboardSettings(bottomType: .categories)
        let emojiView = EmojiView(keyboardSettings: keyboardSettings)
        emojiView.translatesAutoresizingMaskIntoConstraints = false
        emojiView.delegate = self
        commentBox.inputView = emojiView
        commentBox.reloadInputViews()
        commentBox.becomeFirstResponder()
        
//        picker.didFinishPicking { [picker] items, _ in
//            if let photo = items.singlePhoto {
//                self.commentImageBox.image = photo.image
//                self.commentImageBox.layer.cornerRadius = 5
//                self.commentImageBox.isHidden = false
//                self.imageFile = photo.image.jpegData(compressionQuality: 0.8)
//            }
//            picker!.dismiss(animated: true, completion: nil)
//        }
//        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func submitComment(_ sender: Any) {
        if commentBox.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            showToast(msg: "type_something_".localized())
            return
        }
                
        let parameters: [String:Any] = [
            "member_id" : String(thisUser.idx),
            "post_id" : String(gPost.idx),
            "content" : commentBox.text?.trimmingCharacters(in: .whitespacesAndNewlines).encodeEmoji as Any,
        ]
                
        if self.imageFile != nil{
            let ImageDic = ["image" : self.imageFile!]
            // Here you can pass multiple image in array i am passing just one
            ImageArray = NSMutableArray(array: [ImageDic as NSDictionary])
                    
            self.showLoadingView()
            APIs().registerWithPicture(withUrl: ReqConst.SERVER_URL + "submitcomment", withParam: parameters, withImages: ImageArray) { (isSuccess, response) in
                // Your Will Get Response here
                self.dismissLoadingView()
                print("Response: \(response)")
                if isSuccess == true{
                    let result_code = response["result_code"] as Any
                    if result_code as! String == "0"{
                        self.getPostComments(commentsView: self.commentsView, commentsStackView: self.commentsStackView)
                        self.commentImageBox.isHidden = true
                        self.commentBox.text = ""
                        self.commentBox.resignFirstResponder()
                        self.commentBox.checkPlaceholder()
                        self.sendButton.visibilityh = .gone
                        if gRecentViewController == gPostViewController{
                            gPostViewController.getUserPosts(me_id: thisUser.idx, member_id: gUser.idx)
                        }else if gRecentViewController == gMyPostViewController{
                            gMyPostViewController.getMyPosts(member_id: thisUser.idx)
                        }
                        
                    }else if result_code as! String == "1"{
                        self.showToast(msg: "user_not_exist".localized())
                        self.logout()
                    }else if result_code as! String == "2"{
                        self.showToast(msg: "post_not_exist".localized())
                        if gRecentViewController == gPostViewController{
                            gPostViewController.getUserPosts(me_id: thisUser.idx, member_id: gUser.idx)
                        }else if gRecentViewController == gMyPostViewController{
                            gMyPostViewController.getMyPosts(member_id: thisUser.idx)
                        }
                        
                        self.dismiss(animated: true, completion: nil)
                    }else {
                        self.showToast(msg: "something_wrong".localized())
                    }
                }else{
                    self.showToast(msg: "something_wrong".localized())
//                    let message = "File size: " + String(response.fileSize()) + "\n" + "Description: " + response.description
//                    self.showToast(msg: "Issue: \n" + message)
                }
            }
        }else{
            self.showLoadingView()
            APIs().registerWithoutPicture(withUrl: ReqConst.SERVER_URL + "submitcomment", withParam: parameters) { (isSuccess, response) in
                // Your Will Get Response here
                self.dismissLoadingView()
                print("Response: \(response)")
                if isSuccess == true{
                    let result_code = response["result_code"] as Any
                    if result_code as! String == "0"{
                        self.getPostComments(commentsView: self.commentsView, commentsStackView: self.commentsStackView)
                        self.commentImageBox.isHidden = true
                        self.commentBox.text = ""
                        self.commentBox.resignFirstResponder()
                        self.sendButton.visibilityh = .gone
                        self.commentBox.checkPlaceholder()
                        if gRecentViewController == gPostViewController{
                            gPostViewController.getUserPosts(me_id: thisUser.idx, member_id: gUser.idx)
                        }else if gRecentViewController == gMyPostViewController{
                            gMyPostViewController.getMyPosts(member_id: thisUser.idx)
                        }
                        
                    }else if result_code as! String == "1"{
                        self.showToast(msg: "user_not_exist".localized())
                        self.logout()
                    }else if result_code as! String == "2"{
                        self.showToast(msg: "post_not_exist".localized())
                        if gRecentViewController == gPostViewController{
                            gPostViewController.getUserPosts(me_id: thisUser.idx, member_id: gUser.idx)
                        }else if gRecentViewController == gMyPostViewController{
                            gMyPostViewController.getMyPosts(member_id: thisUser.idx)
                        }
                        
                        self.dismiss(animated: true, completion: nil)
                    }else {
                        self.showToast(msg: "something_wrong".localized())
                    }
                }else{
                    self.showToast(msg: "something_wrong".localized())
//                    let message = "File size: " + String(response.fileSize()) + "\n" + "Description: " + response.description
//                    self.showToast(msg: "Issue: \n" + message)
                }
            }
        }
                
    }
    
    func deleteComment(comment_id: Int64){
        self.showLoadingView()
        APIs.deleteComment(comment_id: comment_id, handleCallback: {
            result_code in
            self.dismissLoadingView()
            if result_code == "0"{
                self.showToast2(msg: "deleted".localized())
                self.getPostComments(commentsView: self.commentsView, commentsStackView: self.commentsStackView)
                if gRecentViewController == gPostViewController{
                    gPostViewController.getUserPosts(me_id: thisUser.idx, member_id: gUser.idx)
                }else if gRecentViewController == gMyPostViewController{
                    gMyPostViewController.getMyPosts(member_id: thisUser.idx)
                }
            }else if result_code == "1"{
                self.showToast(msg: "comment_not_exist".localized())
                self.self.getPostComments(commentsView: self.commentsView, commentsStackView: self.commentsStackView)
            }else {
                self.showToast(msg:"something_wrong".localized())
            }
        })
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
    
    
    func loadCommentReaction(ccView:CommentCommentView, comment:Comment, index:Int) {
        ccView.reactionButton.reactionSelector = ReactionSelector()
        ccView.reactionButton.config           = ReactionButtonConfig() {
          $0.iconMarging      = 8
          $0.spacing          = 4
          $0.font             = UIFont(name: "HelveticaNeue", size: 14)
          $0.neutralTintColor = .white
          $0.alignment        = .left
        }
        
        if comment.my_feeling.lowercased() == "like" {
            ccView.reactionButton.reaction = Reaction.facebook.like
            ccView.reactionButton.isSelected = true
        }
        else if comment.my_feeling.lowercased() == "love" { ccView.reactionButton.reaction = Reaction.facebook.love }
        else if comment.my_feeling.lowercased() == "haha" { ccView.reactionButton.reaction = Reaction.facebook.haha }
        else if comment.my_feeling.lowercased() == "wow" { ccView.reactionButton.reaction = Reaction.facebook.wow }
        else if comment.my_feeling.lowercased() == "sad" { ccView.reactionButton.reaction = Reaction.facebook.sad }
        else if comment.my_feeling.lowercased() == "angry" { ccView.reactionButton.reaction = Reaction.facebook.angry }
        
        var icons = [Reaction]()
        if comment.likes > 0 { icons.append(Reaction.facebook.like) }
        if comment.loves > 0 { icons.append(Reaction.facebook.love) }
        if comment.hahas > 0 { icons.append(Reaction.facebook.haha) }
        if comment.wows > 0 { icons.append(Reaction.facebook.wow) }
        if comment.sads > 0 { icons.append(Reaction.facebook.sad) }
        if comment.angrys > 0 { icons.append(Reaction.facebook.angry) }
        
        ccView.reactionSummary.reactions = icons
        ccView.reactionSummary.setDefaultText(withTotalNumberOfPeople: comment.reactions, includingYou: false)
        ccView.reactionSummary.config    = ReactionSummaryConfig {
          $0.spacing      = 8
          $0.iconMarging  = 2
          $0.font         = UIFont(name: "HelveticaNeue", size: 14)
          $0.textColor    = .white
          $0.alignment    = .left
          $0.isAggregated = true
        }
        
        ccView.reactionButton.tag = index
        ccView.reactionButton.addTarget(self, action: #selector(popupCommentReactionMenu(sender:)), for: .touchUpInside)
        
        ccView.reactionButton.reactionSelector!.tag = index
        ccView.reactionButton.reactionSelector?.addTarget(self, action: #selector(reactionCommentDidChanged(sender:)), for: .valueChanged)
    }
    
    var selectedCommentCell:CommentCommentView!
    @objc func popupCommentReactionMenu(sender:ReactionButton) {
        let cell = sender.superview?.superviewOfClassType(CommentCommentView.self) as! CommentCommentView
        selectedCommentCell = cell
        print("selected comment cell: \(selectedCommentCell == nil)")
        let reactionButton = sender as! ReactionButton
        let index = reactionButton.tag
        print("post_id: \(comments[index].idx)")
        print("my feeling: \(comments[index].my_feeling)")
        if reactionButton.isSelected == true {
            reactionButton.presentReactionSelector()
        }else {
            print("unselected")
            reactionButton.reaction = .facebook.like
            reactComment(index:index, member_id: thisUser.idx, comment_id: comments[index].idx, feeling: "")
        }
    }
    
    @objc func reactionCommentDidChanged(sender: AnyObject) {
        let select = sender as! ReactionSelector
        let index = select.tag
        let feeling = select.selectedReaction?.title
        print("feeling: \(feeling)")
        print("comment_id: \(comments[index].idx)")
        reactComment(index:index, member_id: thisUser.idx, comment_id: comments[index].idx, feeling: feeling!.lowercased())
    }
    
    func reactComment(index:Int, member_id:Int64, comment_id:Int64, feeling:String) {
        APIs.reactComment(member_id: member_id, comment_id: comment_id, feeling: feeling, handleCallback: {
            comment, result_code in
            if result_code == "0" {
                var fcomments = self.comments.filter({comment in return comment.idx == comment_id})
                if fcomments.count > 0 {
                    fcomments[0] = comment!
                    self.loadCommentReaction(ccView: self.selectedCommentCell, comment: comment!, index: index)
                }
            }
        })
    }
    
    @objc func openSubcomments(sender:UIButton) {
        let cell = sender.superview?.superviewOfClassType(CommentCommentView.self) as! CommentCommentView
        let comment_id = sender.tag
        let subcommentsView = cell.subcommentsView
        getSubcomments(comment_id: Int64(comment_id), subcommentsView: subcommentsView!, subcommentsStackView: cell.subcommentsStackView)
    }
    
    var subcomments = [Comment]()
    
    func getSubcomments(comment_id:Int64, subcommentsView:UIView, subcommentsStackView:UIStackView) {
        let params = [
            "post_id":String(gPost.idx),
            "member_id":String(thisUser.idx),
            "comment_id":String(comment_id)
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "subcomments", method: .post, parameters: params).responseJSON { response in
            if response.result.isFailure{
                
            } else {
                let json = JSON(response.result.value!)
                let result_code = json["result_code"].stringValue
                if(result_code == "0") {
                    self.subcomments.removeAll()
                    let dataArray = json["data"].arrayObject as! [[String: Any]]
                    if !dataArray.isEmpty { subcommentsView.visibility = .visible }
                    else { subcommentsView.visibility = .gone }
                    subcommentsStackView.arrangedSubviews
                        .filter({ $0 is CommentCommentView})
                        .forEach({ $0.removeFromSuperview() })
                    var iii = -1
                    for data in dataArray {
                        let json = JSON(data)
                        var data = json["comment"].object as! [String: Any]
                        let comment = Comment()
                        comment.idx = data["id"] as! Int64
                        comment.post_id = Int64(data["post_id"] as! String)!
                        comment.comment = data["comment_text"] as! String
                        comment.image_url = data["image_url"] as! String
                        comment.commented_time = data["commented_time"] as! String
                        comment.status = data["status"] as! String
                        comment.parent_comment_id = comment_id
                        comment.parent_comments_view = subcommentsView
                        comment.parent_comments_stackview = subcommentsStackView
                        
                        // Reactions
                        comment.likes = (data["likes"] as! String).count > 0 ? Int(data["likes"] as! String)! : 0
                        comment.loves = (data["loves"] as! String).count > 0 ? Int(data["loves"] as! String)! : 0
                        comment.hahas = (data["haha"] as! String).count > 0 ? Int(data["haha"] as! String)! : 0
                        comment.wows = (data["wow"] as! String).count > 0 ? Int(data["wow"] as! String)! : 0
                        comment.sads = (data["sad"] as! String).count > 0 ? Int(data["sad"] as! String)! : 0
                        comment.angrys = (data["angry"] as! String).count > 0 ? Int(data["angry"] as! String)! : 0
                        comment.reactions = (data["reactions"] as! String).count > 0 ? Int(data["reactions"] as! String)! : 0
                        comment.my_feeling = data["liked"] as! String
                        comment.comments = Int64(data["comments"] as! String)!
                        
                        data = json["member"].object as! [String: Any]
                        let user = User()
                        user.idx = data["id"] as! Int64
                        user.admin_id = Int64(data["admin_id"] as! String)!
                        user.name = data["name"] as! String
                        user.email = data["email"] as! String
                        user.password = data["password"] as! String
                        user.photo_url = data["photo_url"] as! String
                        user.phone_number = data["phone_number"] as! String
                        user.city = data["city"] as! String
                        user.address = data["address"] as! String
                        user.lat = data["lat"] as! String
                        user.lng = data["lng"] as! String
                        user.cohort = data["cohort"] as! String
                        user.registered_time = data["registered_time"] as! String
                        user.fcm_token = data["fcm_token"] as! String
                        user.status = data["status"] as! String
                        user.status2 = data["status2"] as! String
                        
                        comment.user = user
                        
                        iii += 1
                        self.subcomments.append(comment)
                        
                        let commentCommentView = (Bundle.main.loadNibNamed("CommentCommentView", owner: self, options: nil))?[0] as! CommentCommentView
                        
                        if comment.image_url != ""{
                            self.loadPicture(imageView: commentCommentView.imageBox, url: URL(string: comment.image_url)!)
                            commentCommentView.imageBox.visibilityh = .visible
                        }else{
                            commentCommentView.imageBox.visibilityh = .gone
                        }
                        
                        commentCommentView.backgroundColor = UIColor.clear
                            
                        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.subcommentImageTapped(gesture:)))
                        commentCommentView.imageBox.tag = iii
                        commentCommentView.imageBox.addGestureRecognizer(tapGesture)
                        commentCommentView.imageBox.isUserInteractionEnabled = true
                            
                        if comment.user.photo_url != ""{
                            self.loadPicture(imageView: commentCommentView.userPicture, url: URL(string: comment.user.photo_url)!)
                        }
                        commentCommentView.userPicture.layer.cornerRadius = commentCommentView.userPicture.frame.width / 2
                                    
                        commentCommentView.userNameBox.text = comment.user.name
                        commentCommentView.userCohortBox.text = comment.user.cohort
                        commentCommentView.commentBox.text = self.processingEmoji(str:comment.comment)
                        commentCommentView.commentedTimeBox.text = comment.commented_time
                        
                        self.loadCommentReaction1(ccView: commentCommentView, comment: comment, index: iii)
                        commentCommentView.commentsBox.text = String(comment.comments)
                        
                        commentCommentView.subcommentsView.visibility = .gone
                        
                        commentCommentView.commentsButton.setImageTintColor(.white)
                        commentCommentView.commentsButton.tag = Int(comment.idx)
                        commentCommentView.commentsButton.addTarget(self, action: #selector(self.openSubcomments1(sender:)), for: .touchUpInside)
                        
                        commentCommentView.commentButton.setImageTintColor(.white)
                        commentCommentView.commentButton.tag = iii
                        commentCommentView.commentButton.addTarget(self, action: #selector(self.openCommentBox1(sender:)), for: .touchUpInside)
                        
                        if comment.user.idx != thisUser.idx {
                            commentCommentView.menuButton.visibilityh = .gone
                        }
                        commentCommentView.menuButton.setImageTintColor(UIColor.lightGray)
                        commentCommentView.menuButton.tag = iii
                        commentCommentView.menuButton.addTarget(self, action: #selector(self.openCommentDropDownMenu1(sender:)), for: .touchUpInside)
                                    
                        commentCommentView.commentBox.sizeToFit()
                        
                        subcommentsStackView.addArrangedSubview(commentCommentView)
                        subcommentsView.layoutIfNeeded()
                    }
                    
                    
                } else if result_code == "1" {
                    
                } else{
                    
                }
            }
        }
    }
    
    @objc func subcommentImageTapped(gesture:UITapGestureRecognizer){
        if (gesture.view as? UIImageView) != nil {
            print("Image Tapped")
            let imgView = gesture.view as! UIImageView
            let index = imgView.tag
            let image = self.getImageFromURL(url: URL(string: subcomments[index].image_url)!)
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
    
    @objc func openSubcomments1(sender:UIButton) {
        let ccView = sender.superview?.superviewOfClassType(CommentCommentView.self) as! CommentCommentView
        let comment_id = sender.tag
        let subcommentsView = ccView.subcommentsView
        getSubcomments(comment_id: Int64(comment_id), subcommentsView: subcommentsView!, subcommentsStackView: ccView.subcommentsStackView)
    }
    
    
    func loadCommentReaction1(ccView:CommentCommentView, comment:Comment, index:Int) {
        ccView.reactionButton.reactionSelector = ReactionSelector()
        ccView.reactionButton.config           = ReactionButtonConfig() {
          $0.iconMarging      = 8
          $0.spacing          = 4
          $0.font             = UIFont(name: "HelveticaNeue", size: 14)
          $0.neutralTintColor = .white
          $0.alignment        = .left
        }
        
        if comment.my_feeling.lowercased() == "like" {
            ccView.reactionButton.reaction = Reaction.facebook.like
            ccView.reactionButton.isSelected = true
        }
        else if comment.my_feeling.lowercased() == "love" { ccView.reactionButton.reaction = Reaction.facebook.love }
        else if comment.my_feeling.lowercased() == "haha" { ccView.reactionButton.reaction = Reaction.facebook.haha }
        else if comment.my_feeling.lowercased() == "wow" { ccView.reactionButton.reaction = Reaction.facebook.wow }
        else if comment.my_feeling.lowercased() == "sad" { ccView.reactionButton.reaction = Reaction.facebook.sad }
        else if comment.my_feeling.lowercased() == "angry" { ccView.reactionButton.reaction = Reaction.facebook.angry }
        
        var icons = [Reaction]()
        if comment.likes > 0 { icons.append(Reaction.facebook.like) }
        if comment.loves > 0 { icons.append(Reaction.facebook.love) }
        if comment.hahas > 0 { icons.append(Reaction.facebook.haha) }
        if comment.wows > 0 { icons.append(Reaction.facebook.wow) }
        if comment.sads > 0 { icons.append(Reaction.facebook.sad) }
        if comment.angrys > 0 { icons.append(Reaction.facebook.angry) }
        
        ccView.reactionSummary.reactions = icons
        ccView.reactionSummary.setDefaultText(withTotalNumberOfPeople: comment.reactions, includingYou: false)
        ccView.reactionSummary.config    = ReactionSummaryConfig {
          $0.spacing      = 8
          $0.iconMarging  = 2
          $0.font         = UIFont(name: "HelveticaNeue", size: 14)
          $0.textColor    = .white
          $0.alignment    = .left
          $0.isAggregated = true
        }
        
//        ccView.reactionSummary.tag = index
//        ccView.reactionSummary.addTarget(self, action: #selector(toLikes(sender:)), for: .touchUpInside)
        
        ccView.reactionButton.tag = index
        ccView.reactionButton.addTarget(self, action: #selector(popupCommentReactionMenu1(sender:)), for: .touchUpInside)
        
        ccView.reactionButton.reactionSelector!.tag = index
        ccView.reactionButton.reactionSelector?.addTarget(self, action: #selector(reactionCommentDidChanged1(sender:)), for: .valueChanged)
    }
    
    var selectedCCView:CommentCommentView!
    @objc func popupCommentReactionMenu1(sender:ReactionButton) {
        let ccView = sender.superview?.superviewOfClassType(CommentCommentView.self) as! CommentCommentView
        selectedCCView = ccView
        print("selected comment ccView: \(selectedCCView == nil)")
        let reactionButton = sender as! ReactionButton
        let index = reactionButton.tag
        print("post_id: \(subcomments[index].idx)")
        print("my feeling: \(subcomments[index].my_feeling)")
        if reactionButton.isSelected == true {
            reactionButton.presentReactionSelector()
        }else {
            print("unselected")
            reactionButton.reaction = .facebook.like
            reactComment1(index:index, member_id: thisUser.idx, comment_id: subcomments[index].idx, feeling: "")
        }
    }
    
    @objc func reactionCommentDidChanged1(sender: AnyObject) {
        let select = sender as! ReactionSelector
        let index = select.tag
        let feeling = select.selectedReaction?.title
        print("feeling: \(feeling)")
        print("comment_id: \(subcomments[index].idx)")
        reactComment1(index:index, member_id: thisUser.idx, comment_id: subcomments[index].idx, feeling: feeling!.lowercased())
    }
    
    func reactComment1(index:Int, member_id:Int64, comment_id:Int64, feeling:String) {
        APIs.reactComment(member_id: member_id, comment_id: comment_id, feeling: feeling, handleCallback: {
            comment, result_code in
            if result_code == "0" {
                var fcomments = self.subcomments.filter({comment in return comment.idx == comment_id})
                if fcomments.count > 0 {
                    fcomments[0] = comment!
                    self.loadCommentReaction1(ccView: self.selectedCCView, comment: comment!, index: index)
                }
            }
        })
    }
    
    @objc func openCommentDropDownMenu1(sender:UIButton){
        let index = sender.tag
        let ccView = sender.superview?.superviewOfClassType(CommentCommentView.self) as! CommentCommentView
            
        let dropDown = DropDown()
            
        dropDown.anchorView = ccView.menuButton
        if subcomments[index].user.idx == thisUser.idx{
            dropDown.dataSource = ["  " + "delete".localized()]
            // Action triggered on selection
            dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
                if idx == 0{
                    let alert = UIAlertController(title: "delete".localized(), message: "sure_delete_comment".localized(), preferredStyle: .alert)
                    let noAction = UIAlertAction(title: "no".localized(), style: .cancel, handler: {
                            (action : UIAlertAction!) -> Void in })
                    let yesAction = UIAlertAction(title: "yes".localized(), style: .destructive, handler: { alert -> Void in
                        self.deleteSubcomment(comment: self.subcomments[index])
                    })
                    alert.addAction(yesAction)
                    alert.addAction(noAction)
                    self.present(alert, animated: true, completion: nil)
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
    
    func deleteSubcomment(comment: Comment){
        self.showLoadingView()
        APIs.deleteComment(comment_id: comment.idx, handleCallback: {
            result_code in
            self.dismissLoadingView()
            if result_code == "0" {
                self.showToast2(msg: "deleted".localized())
                if comment.parent_comment_id == 0 {
                    self.getPostComments(commentsView: self.commentsView, commentsStackView: self.commentsStackView)
                } else {
                    self.getSubcomments(comment_id: comment.parent_comment_id, subcommentsView: comment.parent_comments_view!, subcommentsStackView: comment.parent_comments_stackview)
                }
            }else if result_code == "1"{
                self.showToast(msg: "comment_not_exist".localized())
                if comment.parent_comment_id == 0 {
                    self.getPostComments(commentsView: self.commentsView, commentsStackView: self.commentsStackView)
                } else {
                    self.getSubcomments(comment_id: comment.parent_comment_id, subcommentsView: comment.parent_comments_view!, subcommentsStackView: comment.parent_comments_stackview)
                }
            }else {
                self.showToast(msg:"something_wrong".localized())
            }
        })
    }
    
    
}
















































































