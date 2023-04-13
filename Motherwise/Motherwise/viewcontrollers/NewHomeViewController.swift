//
//  NewHomeViewController.swift
//  Motherwise
//
//  Created by james on 11/16/21.
//  Copyright © 2021 VaCay. All rights reserved.
//

import UIKit
import Kingfisher
import SCLAlertView
import MarqueeLabel
import Firebase
import FirebaseDatabase
import DropDown
import AVFoundation
import SCLAlertView
import DropDown
import Auk
import DynamicBlurView
import GSImageViewerController
import AudioToolbox
import SDWebImage
//import Reactions
import Smile
import Emoji

class NewHomeViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var view_nav:UIView!
    @IBOutlet weak var view_noticount: UIView!
    @IBOutlet weak var lbl_noticount: UILabel!
    @IBOutlet weak var view_notification: UIView!
    @IBOutlet weak var btn_search: UIButton!
    @IBOutlet weak var view_searchbar: UIView!
    @IBOutlet weak var edt_search: UITextField!
    @IBOutlet weak var btn_nav: UIButton!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var ic_notification: UIImageView!
    @IBOutlet weak var postList: UITableView!
    @IBOutlet weak var noResult: UILabel!
    @IBOutlet weak var descBox: MarqueeLabel!
    @IBOutlet weak var newPostButton: UIButton!
    @IBOutlet weak var newPostButtonW: NSLayoutConstraint!
    
    let icLeft = UIImage(named: "ic_left_w")
    let icNavigation = UIImage(named: "ic_nav_menu_w")
    
    let icUnchecked = UIImage(named: "ic_add_user")
    let icChecked = UIImage(named: "ic_checked")
    
    var menu_vc:MainMenu!
    var dark_background:DarkBackground!
    var user_buttons:HomeUserMenu!
    var profile_dialog: UserProfileFrame!
    var isNotified:Bool = false
    var posts = [Post]()
    var searchPosts = [Post]()
    var users = [User]()
        
    let attrs: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: "Comfortaa-Medium", size: 16.0)!,
        .foregroundColor: UIColor.white,
    //   .underlineStyle: NSUnderlineStyle.single.rawValue
    ]
    var groups = [Group]()
    
    var notifiedUsers = [User]()
    var notiFrame:NotisFrame!
    
    var linkpreviews = [PostPreview]()

    override func viewDidLoad() {
        super.viewDidLoad()

        gNewHomeVC = self
        gRecentViewController = self
        
        lbl_title.text = "network_posts".localized().uppercased()
        descBox.text = "marquee_text".localized()
        
        notiFrame = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "NotisFrame")
        notiFrame.view.frame = CGRect(x: 0, y: -screenHeight, width: screenWidth, height: screenHeight)
        
        view_notification.visibilityh = .visible
        
        setIconTintColor(imageView: ic_notification, color: .white)
        
        view_noticount.isHidden = true
        view_searchbar.isHidden = true
        edt_search.attributedPlaceholder = NSAttributedString(string: "search_".localized(),
            attributes: attrs)
        
        view_searchbar.layer.cornerRadius = view_searchbar.frame.height / 2
        view_searchbar.backgroundColor = UIColor(rgb: 0xffffff, alpha: 0.3)
        
        gHomeButton = btn_nav
        
        menu_vc = self.storyboard!.instantiateViewController(withIdentifier: "MainMenu") as? MainMenu
        dark_background = self.storyboard!.instantiateViewController(withIdentifier: "DarkBackground") as? DarkBackground
        user_buttons = (self.storyboard!.instantiateViewController(withIdentifier: "HomeUserMenu") as! HomeUserMenu)
        profile_dialog = (UIStoryboard(name: "Frames", bundle: nil).instantiateViewController(withIdentifier: "UserProfileFrame") as! UserProfileFrame)
        
        self.menu_vc.view.frame = CGRect(x: -UIScreen.main.bounds.width, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.dark_background.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        newPostButton.roundCorners(corners: [.topLeft, .bottomLeft], radius: newPostButton.frame.height / 2)
        newPostButton.titleEdgeInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 10)
        
        gMainMenu = menu_vc
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToGesture(gesture:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToGesture(gesture:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        
        self.view.addGestureRecognizer(swipeRight)
        self.view.addGestureRecognizer(swipeLeft)
        
        isMenuOpen = true
        
        self.postList.delegate = self
        self.postList.dataSource = self
        
        self.postList.estimatedRowHeight = 500.0
        self.postList.rowHeight = UITableView.automaticDimension
        
        UITextView.appearance().linkTextAttributes = [ .foregroundColor: UIColor(rgb: 0x0BFFFF, alpha: 1.0) ]
        
        let tap_menupanel = UITapGestureRecognizer(target: self, action: #selector(self.tapPanel(_:)))
        menu_vc.view.addGestureRecognizer(tap_menupanel)
        
        edt_search.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                            for: UIControl.Event.editingChanged)
        
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                self.getNoitificaitons()
//                print("FCMToken!!!", gFCMToken)
            }
        }
        
        if thisUser.photo_url != ""{
            loadPicture(imageView:menu_vc.logo, url:URL(string: thisUser.photo_url)!)
        }
        menu_vc.profileNameBox.text = thisUser.name
        
        if gFCMToken.count > 0{
            registerFCMToken(member_id: thisUser.idx, token: gFCMToken)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.showNotifications(_:)))
        view_notification.addGestureRecognizer(tap)
        
        print("**************** \(thisUser.idx)")
        
        self.notifiedUsers.removeAll()
        self.getChatNotifiedUsers()
        self.getNotifications()
        self.getCallNotifications()
        self.getHomeData(member_id: thisUser.idx)
        
    }
    
    @objc func showNotifications(_ sender: UITapGestureRecognizer? = nil) {
        if self.notifiedUsers.count > 0 {
            self.notiFrame.view.frame = CGRect(x: 0, y: -screenHeight, width: screenWidth, height: screenHeight)
            UIView.animate(withDuration: 0.3){() -> Void in
                self.notiFrame.view.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
                self.addChild(self.notiFrame)
                self.view.addSubview(self.notiFrame.view)
            }
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "NotificationsViewController")
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func registerFCMToken(member_id: Int64, token:String){
        APIs.registerFCMToken(member_id: member_id, token: token, handleCallback: {
            fcm_token, result_code in
            if result_code == "0"{
                print("token registered!!!", fcm_token)
            }
        })
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        gId = 0
        gRecentViewController = self
        gNewHomeVC = self
        
        if menu_vc != nil { menu_vc.localize() }
        
        lbl_title.text = "network_posts".localized().uppercased()
        descBox.text = "marquee_text".localized()
        edt_search.attributedPlaceholder = NSAttributedString(string: "search_".localized(),
            attributes: attrs)
        
        newPostButton.setTitle(" " + "create_post".localized(), for: .normal)
        let lang = UserDefaults.standard.string(forKey: "app_lang") ?? "en"
        if lang == "es" {newPostButtonW.constant = 170}
        else {newPostButtonW.constant = 130}
        
        self.getPosts(member_id: thisUser.idx)
//        self.postList.setContentOffset(.zero, animated: true)
    }
    
    @objc func tapPanel(_ sender: UITapGestureRecognizer? = nil) {
        close_menu()
    }
    
    @objc func respondToGesture(gesture: UISwipeGestureRecognizer){
        switch gesture.direction{
        case UISwipeGestureRecognizer.Direction.right:
            show_menu()
        case UISwipeGestureRecognizer.Direction.left:
            close_on_swipe()
        default:
            break
        }
    }
    
    func close_on_swipe(){
        if isMenuOpen{
            // show_menu()
        }else{
            close_menu()
        }
    }
    
    func show_menu() {
        UIView.animate(withDuration: 0.3){() -> Void in
            self.addChild(self.dark_background)
            self.view.addSubview(self.dark_background.view)
            self.menu_vc.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            self.addChild(self.menu_vc)
            self.view.addSubview(self.menu_vc.view)
            isMenuOpen = false
            darkBackg = self.dark_background
        }
    }
    
    func close_menu() {
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            self.menu_vc.view.frame = CGRect(x: -UIScreen.main.bounds.width, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            self.dark_background.view.removeFromSuperview()
        }){
            (finished) in
            self.menu_vc.view.removeFromSuperview()
        }
        isMenuOpen = true
    }
    
    
    @IBAction func tap_search(_ sender: Any) {
        if view_searchbar.isHidden{
            view_searchbar.isHidden = false
            btn_search.setImage(cancel, for: .normal)
            lbl_title.isHidden = true
            edt_search.becomeFirstResponder()
            
        }else{
            view_searchbar.isHidden = true
            btn_search.setImage(search, for: .normal)
            lbl_title.isHidden = false
            self.edt_search.text = ""
            self.posts = searchPosts
            edt_search.resignFirstResponder()
            
            self.postList.reloadData()
        }
    }
    
    @IBAction func tap_menu(_ sender: Any) {
        if isMenuOpen{
            isMenuOpen = false
            btn_nav.setImage(icNavigation, for: .normal)
            show_menu()
        }else{
            isMenuOpen = true
            btn_nav.setImage(icLeft, for: .normal)
            close_menu()
        }
    }
    
    func loadPicture(imageView:UIImageView, url:URL){
        let processor = DownsamplingImageProcessor(size: imageView.frame.size)
        ResizingImageProcessor(referenceSize: imageView.frame.size, mode: .aspectFill)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "ic_user"),
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
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
        }
    }
    
    func loadLinkPicture(imageView:UIImageView, url:URL){
        let processor = DownsamplingImageProcessor(size: imageView.frame.size)
        ResizingImageProcessor(referenceSize: imageView.frame.size, mode: .aspectFill)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "ic_user"),
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
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    var kkk = 0
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return UITableView.automaticDimension
    }
            
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell:PostCell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
            
        postList.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
                
        let index:Int = indexPath.row
                
        if posts.indices.contains(index) {
            let post = self.posts[index]
            kkk += 1

            if post.picture_url != "" {
                cell.postImageHeight.constant = 250
                cell.img_post_picture.visibility = .visible
                if kkk > 1 {
                    cell.img_post_picture.sd_setImage(with: URL(string: post.picture_url)!, placeholderImage: nil, options: [], completed: { (downloadedImage, error, cache, url) in
                        do {
                            cell.postImageHeight.constant = try! cell.img_post_picture.frame.size.width * (downloadedImage?.size.height ?? 0) / (downloadedImage?.size.width ?? self.screenWidth)
                        }catch {}
                    })
                }else {
                    loadLinkPicture(imageView: cell.img_post_picture, url: URL(string: post.picture_url)!)
                }
            }else{
                cell.postImageHeight.constant = 0
                cell.img_post_picture.visibility = .gone
            }

            cell.img_post_picture.sizeToFit()

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openDetail(gesture:)))
            cell.img_post_picture.tag = index
            cell.img_post_picture.isUserInteractionEnabled = true
            cell.img_post_picture.addGestureRecognizer(tapGesture)

            if post.user.photo_url != ""{
                loadPicture(imageView: cell.img_poster, url: URL(string: post.user.photo_url)!)
            }
            cell.img_poster.layer.cornerRadius = cell.img_poster.frame.width / 2
            var tap = UITapGestureRecognizer(target: self, action: #selector(tappedUser))
            cell.img_poster.tag = index
            cell.img_poster.addGestureRecognizer(tap)

            cell.lbl_poster_name.text = post.user.name
            tap = UITapGestureRecognizer(target: self, action: #selector(tappedUser))
            cell.lbl_poster_name.tag = index
            cell.lbl_poster_name.addGestureRecognizer(tap)
            
            cell.lbl_cohort.text = post.user.cohort
            cell.lbl_post_title.text = self.processingEmoji(str:post.title)
            cell.lbl_category.text = post.category
            cell.lbl_posted_time.text = post.posted_time
            if posts[index].status == "updated" {
                cell.lbl_posted_time.text = "updated_at".localized() + " " + post.posted_time
            }

            cell.txv_desc.text = self.processingEmoji(str:post.content)
            cell.txv_desc.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
            cell.txv_desc.isScrollEnabled = false

            if post.previews.count > 0 {
                cell.linkView.visibility = .visible
                cell.stackView.arrangedSubviews
                    .filter({ $0 is LinkView})
                    .forEach({ $0.removeFromSuperview() })
                for prev in post.previews {
                    self.linkpreviews.append(prev)
                    let linkView = (Bundle.main.loadNibNamed("LinkView", owner: self, options: nil))?[0] as! LinkView
                    if prev.image_url.count > 0{
                        linkView.linkImageBox.visibilityh = .visible
                        loadLinkPicture(imageView: linkView.linkImageBox, url: URL(string: prev.image_url)!)
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
                    linkView.tag = Int(prev.idx)
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedLinkPreview(gesture:)))
                    linkView.addGestureRecognizer(tap)
                    cell.stackView.addArrangedSubview(linkView)
                    cell.linkView.layoutIfNeeded()
                }
                cell.linkViewH.constant = CGFloat(60 * post.previews.count)
            }else {
                cell.linkView.visibility = .gone
//                cell.linkViewH.constant = 0
            }
            cell.linkView.sizeToFit()
            
            // Comments
            if post.comment_list.count > 0 {
                cell.commentsView.visibility = .visible
                cell.commentsStackView.arrangedSubviews
                    .filter({ $0 is PostCommentView})
                    .forEach({ $0.removeFromSuperview() })
                for c in post.comment_list {
                    let postCommentView = (Bundle.main.loadNibNamed("PostCommentView", owner: self, options: nil))?[0] as! PostCommentView
                    postCommentView.commentedUserNameBox.text = c.user.name
                    postCommentView.commentedUserPictureBox.layer.cornerRadius = postCommentView.commentedUserPictureBox.frame.width / 2
                    if c.user.photo_url.count > 0 {
                        loadPicture(imageView: postCommentView.commentedUserPictureBox, url: URL(string: c.user.photo_url)!)
                    }else {
                        postCommentView.commentedUserPictureBox.image = UIImage(named: "ic_user.png")
                    }
                    postCommentView.bubbleView.roundCorners(corners: [.topRight, .bottomLeft, .bottomRight], radius: 15)
                    postCommentView.bubbleView.textContainerInset = UIEdgeInsets(top: 9, left: 16, bottom: 9, right: 16)
                    postCommentView.bubbleView.backgroundColor = UIColor(rgb: 0x5E5E5E, alpha: 1.0)
                    postCommentView.bubbleView.text = self.processingEmoji(str:c.comment)
                    cell.commentsStackView.addArrangedSubview(postCommentView)
                    cell.commentsView.layoutIfNeeded()
                }
            }else {
                cell.commentsView.visibility = .gone
//                cell.linkViewH.constant = 0
            }
            cell.commentsView.sizeToFit()
            
            self.loadReaction(cell: cell, post: post, index: index)
            
            cell.lbl_comments.text = String(post.comments)

            if post.pictures > 1 {
                cell.lbl_pics.isHidden = false
                cell.lbl_pics.text = "+" + String(post.pictures - 1)
            }else{
                cell.lbl_pics.isHidden = true
            }

            cell.menuButton.setImageTintColor(UIColor(rgb: 0xffffff, alpha: 0.8))
            cell.commentButton.setImageTintColor(.white)

            setRoundShadowView(view: cell.view_content, corner: 5.0)

            cell.commentButton.tag = index
            cell.commentButton.addTarget(self, action: #selector(self.openCommentBox), for: .touchUpInside)

            cell.menuButton.tag = index
            cell.menuButton.addTarget(self, action: #selector(self.openDropDownMenu), for: .touchUpInside)

            cell.txv_desc.tag = index
            cell.txv_desc.isUserInteractionEnabled = true
            tap = UITapGestureRecognizer(target: self, action: #selector(self.openDetail(gesture:)))
            cell.txv_desc.addGestureRecognizer(tap)

            cell.txv_desc.sizeToFit()
            
            cell.view_content.sizeToFit()
            cell.view_content.layoutIfNeeded()
                
        }
        
        return cell
        
    }
    
    @objc func tappedUser(_ sender:UITapGestureRecognizer? = nil) {
        if self.loadingView.isAnimating{
            return
        }
        if let tag = sender?.view?.tag {
            print(tag)
            gUser = self.posts[tag].user
            self.profile_dialog.view.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
            if gUser.photo_url != "" {
                self.profile_dialog.pictureBox.visibility = .visible
                loadPicture(imageView:self.profile_dialog.pictureBox, url: URL(string: gUser.photo_url)!)
            }else{
                self.profile_dialog.pictureBox.visibility = .gone
            }
            self.profile_dialog.nameBox.text = gUser.name
            self.profile_dialog.groupBox.text = gUser.cohort
            self.profile_dialog.group_name = gUser.cohort
            self.profile_dialog.cityBox.text = gUser.city
            self.profile_dialog.buttonView.alpha = 0
            UIView.animate(withDuration: 1.2) {
                self.profile_dialog.buttonView.alpha = 1
                self.addChild(self.profile_dialog)
                self.view.addSubview(self.profile_dialog.view)
            }
        }
    }
    
    @objc func imageTapped(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if (gesture.view as? UIImageView) != nil {
            let imgView = gesture.view as! UIImageView
            let index = imgView.tag
            let post = posts[index]
            if post.pictures > 1{
                self.getPostPictures(post: post, imageView: imgView)
            }else{
                let image = self.getImageFromURL(url: URL(string: post.picture_url)!)
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
    
    func loadReaction(cell:PostCell, post:Post, index:Int) {
        cell.reactionButton.reactionSelector = ReactionSelector()
        cell.reactionButton.config           = ReactionButtonConfig() {
          $0.iconMarging      = 8
          $0.spacing          = 4
          $0.font             = UIFont(name: "HelveticaNeue", size: 14)
          $0.neutralTintColor = .white
          $0.alignment        = .left
        }
        
        if post.my_feeling.lowercased() == "like" {
            cell.reactionButton.reaction = Reaction.facebook.like
            cell.reactionButton.isSelected = true
        }
        else if post.my_feeling.lowercased() == "love" { cell.reactionButton.reaction = Reaction.facebook.love }
        else if post.my_feeling.lowercased() == "haha" { cell.reactionButton.reaction = Reaction.facebook.haha }
        else if post.my_feeling.lowercased() == "wow" { cell.reactionButton.reaction = Reaction.facebook.wow }
        else if post.my_feeling.lowercased() == "sad" { cell.reactionButton.reaction = Reaction.facebook.sad }
        else if post.my_feeling.lowercased() == "angry" { cell.reactionButton.reaction = Reaction.facebook.angry }
        
        var icons = [Reaction]()
        if post.likes > 0 { icons.append(Reaction.facebook.like) }
        if post.loves > 0 { icons.append(Reaction.facebook.love) }
        if post.hahas > 0 { icons.append(Reaction.facebook.haha) }
        if post.wows > 0 { icons.append(Reaction.facebook.wow) }
        if post.sads > 0 { icons.append(Reaction.facebook.sad) }
        if post.angrys > 0 { icons.append(Reaction.facebook.angry) }
        
        cell.reactionSummary.reactions = icons
        cell.reactionSummary.setDefaultText(withTotalNumberOfPeople: post.reactions, includingYou: false)
        cell.reactionSummary.config    = ReactionSummaryConfig {
          $0.spacing      = 8
          $0.iconMarging  = 2
          $0.font         = UIFont(name: "HelveticaNeue", size: 14)
          $0.textColor    = .white
          $0.alignment    = .left
          $0.isAggregated = true
        }
        
        cell.reactionSummary.tag = index
        cell.reactionSummary.addTarget(self, action: #selector(toLikes(sender:)), for: .touchUpInside)
        
        cell.reactionButton.tag = index
        cell.reactionButton.addTarget(self, action: #selector(popupReactionMenu(sender:)), for: .touchUpInside)
        
        cell.reactionButton.reactionSelector!.tag = index
        cell.reactionButton.reactionSelector?.addTarget(self, action: #selector(reactionDidChanged(sender:)), for: .valueChanged)
    }
    
    var selectedCell:PostCell!
    @objc func popupReactionMenu(sender:ReactionButton) {
        let cell = sender.superview?.superviewOfClassType(PostCell.self) as! PostCell
        selectedCell = cell
        print("selected cell: \(selectedCell == nil)")
        let reactionButton = sender as! ReactionButton
        let index = reactionButton.tag
        print("post_id: \(posts[index].idx)")
        print("my feeling: \(posts[index].my_feeling)")
        if reactionButton.isSelected == true {
            reactionButton.presentReactionSelector()
        }else {
            print("unselected")
            reactionButton.reaction = .facebook.like
            reactPost(cell:selectedCell, index:index, member_id: thisUser.idx, post_id: posts[index].idx, feeling: "")
        }
    }
    
    @objc func reactionDidChanged(sender: AnyObject) {
        let select = sender as! ReactionSelector
        let index = select.tag
        let feeling = select.selectedReaction?.title
        print("feeling: \(feeling)")
        print("post_id: \(posts[index].idx)")
        reactPost(cell:selectedCell, index:index, member_id: thisUser.idx, post_id: posts[index].idx, feeling: feeling!.lowercased())
    }
    
    func reactPost(cell:PostCell, index:Int, member_id:Int64, post_id:Int64, feeling:String) {
        APIs.reactPost(member_id: member_id, post_id: post_id, feeling: feeling, handleCallback: {
            post, result_code in
            if result_code == "0" {
                var fposts = self.posts.filter({post in return post.idx == post_id})
                if fposts.count > 0 {
                    fposts[0] = post!
                    self.loadReaction(cell: self.selectedCell, post: post!, index: index)
                }
            }
        })
    }
    
    @objc func toLikes(sender:AnyObject) {
        let index = (sender as! ReactionSummary).tag
        gPost = posts[index]
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "LikesViewController")
        self.present(vc, animated: true, completion: nil)
    }
    
    func likePost(member_id: Int64, post: Post, button:UIButton, likeslabel:UILabel){
        print("post id: \(post.idx)")
        APIs.likePost(member_id: member_id, post_id: post.idx, handleCallback: {
            likes, result_code in
            if result_code == "0"{
                if !post.isLiked {
                    post.isLiked = true
                    button.setImage(UIImage(named: "ic_liked"), for: .normal)
                }else{
                    post.isLiked = false
                    button.setImage(UIImage(named: "ic_like"), for: .normal)
                }
                likeslabel.text = likes
                button.setImageTintColor(.white)
            }else if result_code == "1"{
                self.showToast(msg:"account_not_exist".localized())
                self.logout()
            }else if result_code == "2"{
                self.showToast(msg:"post_not_exist".localized())
                self.getPosts(member_id: thisUser.idx)
            }else {
                self.showToast(msg:"something_wrong".localized())
                self.getPosts(member_id: thisUser.idx)
            }
        })
    }
    
    @objc func openCommentBox(sender:UIButton){
        let index = sender.tag
        let post = posts[index]
        if post.idx > 0 && post.user.idx != thisUser.idx {
            gPost = post
//            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PostDetailViewController")
            let vc = UIStoryboard(name: "PostDetail", bundle: nil).instantiateViewController(identifier: "PostDetailVC")
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
        
    @objc func openDropDownMenu(sender:UIButton){
        let index = sender.tag
        let cell = sender.superview?.superviewOfClassType(PostCell.self) as! PostCell
        
        let dropDown = DropDown()
        
        dropDown.anchorView = cell.menuButton
        if posts[index].user.idx == thisUser.idx{
            dropDown.dataSource = ["  " + "edit".localized(), "  " + "delete".localized()]
            // Action triggered on selection
            dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
                print("Selected item: \(item) at index: \(idx)")
                if idx == 0{
                    gPost = self.posts[index]
                    gNewPostViewController = nil
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "EditPostViewController")
                    self.present(vc, animated: true, completion: nil)
                }else if idx == 1{
                    let alert = UIAlertController(title: "delete".localized(), message: "sure_delete_post".localized(), preferredStyle: .alert)
                    let noAction = UIAlertAction(title: "no".localized(), style: .cancel, handler: {
                        (action : UIAlertAction!) -> Void in })
                    let yesAction = UIAlertAction(title: "yes".localized(), style: .destructive, handler: { alert -> Void in
                        self.deletePost(post_id: self.posts[index].idx)
                    })
                    
                    alert.addAction(yesAction)
                    alert.addAction(noAction)
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }else{
            dropDown.dataSource = ["  " + "message".localized(), "  " + "report_user".localized()]
            // Action triggered on selection
            dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
                print("Selected item: \(item) at index: \(idx)")
                if idx == 0{
                    gUser = self.posts[index].user
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeSendMessageViewController")
                    self.present(vc, animated: true, completion: nil)
                }else if idx == 1{
                    gUser = self.posts[index].user
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ReportViewController")
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
        dropDown.width = 110
        
        dropDown.show()
        
    }
        
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        
    @objc func textFieldDidChange(_ textField: UITextField) {
            
        edt_search.attributedText = NSAttributedString(string: edt_search.text!, attributes: attrs)
            
        posts = filter(keyword: (textField.text?.lowercased())!)
        if posts.isEmpty{
                
        }
        self.postList.reloadData()
    }
        
    func filter(keyword:String) -> [Post]{
        if keyword == ""{
            return searchPosts
        }
        var filteredPosts = [Post]()
        for post in searchPosts{
            if post.title.lowercased().contains(keyword){
                filteredPosts.append(post)
            }else{
                if post.category.lowercased().contains(keyword){
                    filteredPosts.append(post)
                }else{
                    if post.content.lowercased().contains(keyword){
                        filteredPosts.append(post)
                    }else{
                        if String(post.comments).contains(keyword){
                            filteredPosts.append(post)
                        }else{
                            if post.posted_time.contains(keyword){
                                filteredPosts.append(post)
                            }else{
                                if post.user.name.lowercased().contains(keyword){
                                    filteredPosts.append(post)
                                }else{
                                    if post.user.cohort.lowercased().contains(keyword){
                                        filteredPosts.append(post)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return filteredPosts
    }
    
    func getPosts(member_id:Int64){
        self.showLoadingView()
        APIs.getPosts(member_id: member_id, handleCallback: {
            posts, users, result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                self.posts = posts!
                self.searchPosts = posts!
                self.users = users!
                
                gUsers = users!
                self.noResult.isHidden = !self.posts.isEmpty
                
//                let section = 0
//                self.postList.reloadSections([section], with: .automatic)
                self.postList.reloadData()
            }
            else{
                self.dismissLoadingView()
                if result_code == "1" {
                    self.logout()
                } else {
                    self.showToast(msg: "something_wrong".localized())
                }
            }
        })
        
    }
    
    
    func deletePost(post_id: Int64){
        self.showLoadingView()
        APIs.deletePost(post_id: post_id, handleCallback: {
            result_code in
            self.dismissLoadingView()
            if result_code == "0"{
                self.showToast2(msg: "deleted".localized())
                self.getPosts(member_id: thisUser.idx)
            }else if result_code == "1"{
                self.showToast(msg: "post_not_exist".localized())
                self.getPosts(member_id: thisUser.idx)
            }else {
                self.showToast(msg:"something_wrong".localized())
            }
        })
    }
    
    func getPostPictures(post: Post, imageView: UIImageView){
        self.showLoadingView()
        APIs.getPostPictures(post_id: post.idx,handleCallback: {
            pictures, result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                if pictures!.count > 1 {
                    gPostPictures = pictures!
                    gPost = post
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ImagePageViewController")
                    self.present(vc, animated: true, completion: nil)
                }else if pictures?.count == 1 {
                    let image = self.getImageFromURL(url: URL(string: pictures![0].image_url)!)
                    if image != nil {
                        let imageInfo   = GSImageInfo(image: image, imageMode: .aspectFit)
                        let transitionInfo = GSTransitionInfo(fromView:imageView)
                        let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
                            
                        imageViewer.dismissCompletion = {
                            print("dismissCompletion")
                        }
                            
                        self.present(imageViewer, animated: true, completion: nil)
                    }
                }
            }
        })
            
    }
    
    var eee = false
    var ggg = false
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            print(" you reached end of the table")
            print("SeaR COUNT////// \(self.searchPosts.count)")
            if !self.loadingView.isAnimating && !self.eee {
                refreshPosts(member_id: thisUser.idx, num: Int64(self.searchPosts.count))
            }
        }else {
            if scrollView.contentOffset.y <= 0 {
                if !ggg {
                    print("top!")
                    self.getPosts(member_id: thisUser.idx)
                    ggg = true
                }
            }else {
                ggg = false
            }
        }
    }
    
    
    func refreshPosts(member_id:Int64, num:Int64){
        self.showLoadingView()
        APIs.refreshPosts(member_id: member_id, num: num, handleCallback: {
            posts, result_code in
            print(result_code)
            if result_code == "0"{
                print("ReFFFFFF \(posts!.count)")
                if posts!.count > 0 {
                    self.posts = self.posts + posts!
                    self.searchPosts = self.searchPosts + posts!
                }
                if posts!.count == 0 { self.eee = true }
                
                self.dismissLoadingView()
                
                self.postList.reloadData()

            }
        })
    }
    
    
    @objc func openDetail(gesture:UITapGestureRecognizer){
        let index = gesture.view!.tag
        gPost = posts[index]
//        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PostDetailViewController")
        let vc = UIStoryboard(name: "PostDetail", bundle: nil).instantiateViewController(identifier: "PostDetailVC")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }

    @IBAction func newPost(_ sender: Any) {
        gEditPostViewController = nil
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "NewPostViewController")
     //   vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    func reportMember(message:String) {
        self.showLoadingView()
        APIs.reportMember(member_id: gUser.idx, reporter_id: thisUser.idx, message: message, handleCallback: {
            result_code in
            self.dismissLoadingView()
        })
    }

    
    func getNoitificaitons(){
//        self.getCustomerNotification()
    }
    
    var count:Int = 0
    var refs = [DatabaseReference]()
    
    func getCustomerNotification(){
        var ref:DatabaseReference!
        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "order/" + String(thisUser.idx))
        
        ref.observe(.childAdded, with: {(snapshot) -> Void in
            let value = snapshot.value as! [String: Any]
            let timeStamp = value["date"] as! String
            let date = self.getDateFromTimeStamp(timeStamp: Double(timeStamp)!)
            let msg = value["msg"] as! String
            let fromid = value["fromid"] as! String
            let fromname = value["fromname"] as! String
            self.count += 1
            gBadgeCount = self.count
            self.view_notification.visibilityh = .visible
            self.view_noticount.isHidden = false
            self.lbl_noticount.text = String(gBadgeCount)
            UIApplication.shared.applicationIconBadgeNumber = self.count
            AudioServicesPlaySystemSound(SystemSoundID(1106))
//            let noti = Notification()
//            noti.sender_name = fromname
//            noti.message = "Customer's new order: " + fromname
//            noti.date_time = timeStamp
//            noti.image = ""
//            //            self.notiFrame.notis.append(noti)
//            self.notiFrame.notis.insert(noti, at: 0)
//
//            self.refs.insert(snapshot.ref, at: 0)
            
        })
    }
    
    
    func getChatNotifiedUsers(){
                
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
                user.photo_url = sender_photo
                
                if !self.notifiedUsers.contains(where: {$0.email == user.email}) {
                    self.notifiedUsers.append(user)
                }
                
                print("Notified Users////////////////: \(self.notifiedUsers.count)")
                if self.notifiedUsers.count > 0 {
                    self.view_noticount.visibilityh = .visible
                    self.lbl_noticount.text = String(self.notifiedUsers.count)
                }
                UIApplication.shared.applicationIconBadgeNumber = self.count
            })
        })
        
        ref.observe(.childRemoved, with: {(snapshot) -> Void in
            print("Removed////////////////: \(snapshot.key)")
            let userEmail = snapshot.key.replacingOccurrences(of: "ddoott", with: ".")
            if self.notifiedUsers.contains(where: {$0.email == userEmail}){
                self.notifiedUsers.remove(at: self.notifiedUsers.firstIndex(where: {$0.email == userEmail})!)
                print("Notified Users////////////////: \(self.notifiedUsers.count)")
            }
            if self.notifiedUsers.count > 0{
                self.view_noticount.visibilityh = .visible
                self.lbl_noticount.text = String(self.notifiedUsers.count)
            }else{
                self.view_noticount.visibilityh = .gone
            }
            UIApplication.shared.applicationIconBadgeNumber = self.count
        })
    }
    
    func getNotifications(){
                
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
            user.photo_url = sender_photo
            user.key = key
            
            if !self.notifiedUsers.contains(where: {$0.idx == user.idx}) {
                self.notifiedUsers.append(user)
            }
            
            print("Notified Users////////////////: \(self.notifiedUsers.count)")
            if self.notifiedUsers.count > 0{
                self.view_noticount.visibilityh = .visible
                self.lbl_noticount.text = String(self.notifiedUsers.count)
            }
            UIApplication.shared.applicationIconBadgeNumber = self.notifiedUsers.count
        })
        
        ref.observe(.childRemoved, with: {(snapshot) -> Void in
            print("Removed////////////////: \(snapshot.key)")
            let key = snapshot.key
            if self.notifiedUsers.contains(where: {$0.key == key}){
                self.notifiedUsers.remove(at: self.notifiedUsers.firstIndex(where: {$0.key == key})!)
                print("Notified Users////////////////: \(self.notifiedUsers.count)")
            }
            if self.notifiedUsers.count > 0{
                self.view_noticount.visibilityh = .visible
                self.lbl_noticount.text = String(self.notifiedUsers.count)
            }else{
                self.view_noticount.visibilityh = .gone
            }
            UIApplication.shared.applicationIconBadgeNumber = self.notifiedUsers.count
        })
    }
    
    func getCallNotifications(){
            
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
                user.photo_url = sender_photo
                user.key = key
                    
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
                    
                if type == "call_request" {
                    self.showCallAlertDialog(title: noti.sender.name, message: "incoming_call_".localized(), alias: noti.id, ref: ref.child(key))
                }
                
                if !self.notifiedUsers.contains(where: {$0.idx == user.idx}) {
                    self.notifiedUsers.append(user)
                }
                    
                print("Notified Users////////////////: \(self.notifiedUsers.count)")
                if self.notifiedUsers.count > 0 {
                    self.view_noticount.visibilityh = .visible
                    self.lbl_noticount.text = String(self.notifiedUsers.count)
                }
                UIApplication.shared.applicationIconBadgeNumber = self.notifiedUsers.count
            })
                
        })
            
        ref.observe(.childRemoved, with: {(snapshot) -> Void in
            print("Removed////////////////: \(snapshot.key)")
            let key = snapshot.key
            if self.notifiedUsers.contains(where: {$0.key == key}){
                self.notifiedUsers.remove(at: self.notifiedUsers.firstIndex(where: {$0.key == key})!)
                print("Notified Users////////////////: \(self.notifiedUsers.count)")
            }
            if self.notifiedUsers.count > 0{
                self.view_noticount.visibilityh = .visible
                self.lbl_noticount.text = String(self.notifiedUsers.count)
            }else{
                self.view_noticount.visibilityh = .gone
            }
            UIApplication.shared.applicationIconBadgeNumber = self.notifiedUsers.count
        })
            
    }
    
    func getHomeData(member_id:Int64){
        APIs.getHomeData(member_id: member_id, handleCallback: {
            users, groups, admin, result_code in
            print(result_code)
            if result_code == "0"{
                gSelectedUsers.removeAll()
                self.users = users!
                let admins = users!.filter{ user in
                    return user.idx == thisUser.admin_id
                }
                if admins.count > 0 {
                    gAdmin = admins[0]
                }else {
                    gAdmin = admin!
                }                
                self.groups = groups!
                gGroups = groups!
                
            }
        })
    }
    
    
    @IBAction func toNewPost(_ sender: Any) {
        gEditPostViewController = nil
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "NewPostViewController")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        
    }
    
    @objc func tappedLinkPreview(gesture:UITapGestureRecognizer) {
        let linkprevs = linkpreviews.filter({prev in return prev.idx == gesture.view!.tag})
        if linkprevs.count > 0 {
            if let url = URL(string: linkprevs[0].site_url) {
                UIApplication.shared.open(url)
            }
        }
    }
    

}






















































