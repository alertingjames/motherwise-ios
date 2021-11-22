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
    
    let icLeft = UIImage(named: "ic_left_w")
    let icNavigation = UIImage(named: "ic_nav_menu_w")
    
    let icUnchecked = UIImage(named: "ic_add_user")
    let icChecked = UIImage(named: "ic_checked")
    
    var menu_vc:MainMenu!
    var dark_background:DarkBackground!
    var user_buttons:HomeUserMenu!
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
        user_buttons = self.storyboard!.instantiateViewController(withIdentifier: "HomeUserMenu") as! HomeUserMenu
        
        self.menu_vc.view.frame = CGRect(x: -UIScreen.main.bounds.width, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.dark_background.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        newPostButton.layer.cornerRadius = newPostButton.frame.height / 2
        
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
        
        self.getPosts(member_id: thisUser.idx)
        self.postList.setContentOffset(.zero, animated: true)
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
            >> ResizingImageProcessor(referenceSize: imageView.frame.size, mode: .aspectFill)
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
                print("Task done for: \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
        }
    }
    
    func loadLinkPicture(imageView:UIImageView, url:URL){
        let processor = DownsamplingImageProcessor(size: imageView.frame.size)
            >> ResizingImageProcessor(referenceSize: imageView.frame.size, mode: .aspectFill)
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
        let post = self.posts[index]
                
        if posts.indices.contains(index) {
            kkk += 1
            
            if post.picture_url != ""{
                cell.postImageHeight.constant = 250
                cell.img_post_picture.visibility = .visible
                if kkk > 1 {
                    cell.img_post_picture.sd_setImage(with: URL(string: post.picture_url)!, placeholderImage: nil, options: [], completed: { (downloadedImage, error, cache, url) in
                        print(downloadedImage?.size.width)//prints width of image
                        print(downloadedImage?.size.height)//prints height of image
                        do {
                            cell.postImageHeight.constant = try! cell.img_post_picture.frame.size.width * (downloadedImage?.size.height)! / (downloadedImage?.size.width)!
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
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(gesture:)))

            cell.img_post_picture.tag = index
            cell.img_post_picture.addGestureRecognizer(tapGesture)
            cell.img_post_picture.isUserInteractionEnabled = true
            
            if post.user.photo_url != ""{
                loadPicture(imageView: cell.img_poster, url: URL(string: post.user.photo_url)!)
            }
            
            cell.img_poster.layer.cornerRadius = cell.img_poster.frame.width / 2
                    
            cell.lbl_poster_name.text = post.user.name
            cell.lbl_cohort.text = post.user.cohort
            cell.lbl_post_title.text = post.title.decodeEmoji
            cell.lbl_category.text = post.category
            cell.lbl_posted_time.text = post.posted_time
            if posts[index].status == "updated" {
                cell.lbl_posted_time.text = "updated_at".localized() + " " + post.posted_time
            }
            
            cell.txv_desc.text = post.content.decodeEmoji
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
            
            cell.lbl_likes.text = String(post.likes)

            cell.lbl_comments.text = String(post.comments)
            
            if post.pictures > 1{
                cell.lbl_pics.isHidden = false
                cell.lbl_pics.text = "+" + String(post.pictures - 1)
            }else{
                cell.lbl_pics.isHidden = true
            }
            
            if post.isLiked {
                cell.likeButton.setImage(UIImage(named: "ic_liked"), for: .normal)
            }else{
                cell.likeButton.setImage(UIImage(named: "ic_like"), for: .normal)
            }
            
            cell.menuButton.setImageTintColor(UIColor(rgb: 0xffffff, alpha: 0.8))
            cell.detailButton.setImageTintColor(UIColor.white)
            cell.likeButton.setImageTintColor(.white)
            cell.commentButton.setImageTintColor(.white)
            
            setRoundShadowView(view: cell.view_content, corner: 5.0)
            
            cell.likeButton.tag = index
            cell.likeButton.addTarget(self, action: #selector(self.toggleLike), for: .touchUpInside)
            
            cell.commentButton.tag = index
            cell.commentButton.addTarget(self, action: #selector(self.openCommentBox), for: .touchUpInside)
            
            cell.menuButton.tag = index
            cell.menuButton.addTarget(self, action: #selector(self.openDropDownMenu), for: .touchUpInside)
            
            cell.detailButton.tag = index
            cell.detailButton.addTarget(self, action: #selector(self.openDetail), for: .touchUpInside)
                    
            cell.txv_desc.sizeToFit()
            cell.view_content.sizeToFit()
            cell.view_content.layoutIfNeeded()
                
        }
        
        return cell
        
    }
    
    @objc func imageTapped(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if (gesture.view as? UIImageView) != nil {
            print("Image Tapped")
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
    
    @objc func toggleLike(sender:UIButton){
        let index = sender.tag
        let post = posts[index]
        if post.idx > 0 && post.user.idx != thisUser.idx {
            let cell = sender.superview?.superviewOfClassType(PostCell.self) as! PostCell
            likePost(member_id: thisUser.idx, post: post, button:sender, likeslabel: cell.lbl_likes!)
        }
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
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "CommentViewController")
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
            print(result_code)
            if result_code == "0"{
                
                self.posts = posts!
                self.searchPosts = posts!
                self.users = users!
                
                gUsers = users!
                
                if self.posts.count == 0 {
                    self.noResult.isHidden = false
                }
                
                self.dismissLoadingView()
                
                let section = 0
                self.postList.reloadSections([section], with: .automatic)

            }
            else{
                self.dismissLoadingView()
                if result_code == "1" {
                    self.logout()
                } else {
                    self.showToast(msg: "Something wrong!")
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
                if posts!.count < 10 { self.eee = true }
                
                self.dismissLoadingView()
                
                self.postList.reloadData()

            }
        })
    }
    
    
    @objc func openDetail(sender:UIButton){
        let index = sender.tag
        gPost = posts[index]
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PostDetailViewController")
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
                if self.notifiedUsers.count > 0{
                    self.view_noticount.visibilityh = .visible
                    self.lbl_noticount.text = String(self.notifiedUsers.count)
                }
                
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
                if self.notifiedUsers.count > 0{
                    self.view_noticount.visibilityh = .visible
                    self.lbl_noticount.text = String(self.notifiedUsers.count)
                }
                
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























































