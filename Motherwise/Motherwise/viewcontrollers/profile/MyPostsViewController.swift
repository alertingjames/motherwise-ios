//
//  MyPostsViewController.swift
//  Motherwise
//
//  Created by Andre on 9/5/20.
//  Copyright © 2020 Motherwise. All rights reserved.
//

import UIKit
import Kingfisher
import SCLAlertView
import DropDown
import Auk
import DynamicBlurView
import GSImageViewerController
import AVFoundation
import AudioToolbox
import SDWebImage
import Foundation

class MyPostsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var view_nav:UIView!
    @IBOutlet weak var btn_search: UIButton!
    @IBOutlet weak var view_searchbar: UIView!
    @IBOutlet weak var edt_search: UITextField!
    @IBOutlet weak var btn_nav: UIButton!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var postList: UITableView!
    @IBOutlet weak var btn_new_post: UIButton!
    @IBOutlet weak var noResult: UILabel!
    
    var posts = [Post]()
    var searchPosts = [Post]()
    var users = [User]()
        
    let attrs: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: "Comfortaa-Medium", size: 16.0)!,
        .foregroundColor: UIColor.white,
    //   .underlineStyle: NSUnderlineStyle.single.rawValue
    ]
    
    var linkpreviews = [PostPreview]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        gMyPostViewController = self
        gRecentViewController = self
        
        lbl_title.text = "my_posts".localized().uppercased()
        
        btn_new_post.setImageTintColor(.white)
        view_searchbar.isHidden = true
        edt_search.attributedPlaceholder = NSAttributedString(string: "search_".localized(),
            attributes: attrs)
        
        edt_search.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        view_searchbar.layer.cornerRadius = view_searchbar.frame.height / 2
        view_searchbar.backgroundColor = UIColor(rgb: 0xffffff, alpha: 0.3)
        
        self.postList.delegate = self
        self.postList.dataSource = self
        
        self.postList.estimatedRowHeight = 500.0
        self.postList.rowHeight = UITableView.automaticDimension
        
        UITextView.appearance().linkTextAttributes = [ .foregroundColor: UIColor(rgb: 0x0BFFFF, alpha: 1.0) ]
        
//        self.getPosts(member_id: thisUser.idx)
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismissViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.getMyPosts(member_id: thisUser.idx)
        
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
    
    func loadPicture(imageView:UIImageView, url:URL){
        let processor = DownsamplingImageProcessor(size: imageView.frame.size)
            >> ResizingImageProcessor(referenceSize: imageView.frame.size, mode: .aspectFill)
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
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    var kkk = 0
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
            
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell:PostCell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
            
        postList.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
                
        let index:Int = indexPath.row
        let post = posts[index]
                
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
                    loadPicture(imageView: cell.img_post_picture, url: URL(string: post.picture_url)!)
                }
            }else{
                cell.postImageHeight.constant = 0
                cell.img_post_picture.visibility = .gone
            }
            
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
            if post.status == "updated" {
                cell.lbl_posted_time.text = "updated_at".localized() + " " + post.posted_time
            }
            cell.txv_desc.text = post.content.decodeEmoji
            cell.txv_desc.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
            cell.txv_desc.isScrollEnabled = false
            
            cell.lbl_likes.text = String(post.likes)
            
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
                self.showToast(msg:"user_not_exist".localized())
                self.logout()
            }else if result_code == "2"{
                self.showToast(msg:"post_not_exist".localized())
                self.getMyPosts(member_id: thisUser.idx)
            }else {
                self.showToast(msg:"something_wrong".localized())
                self.getMyPosts(member_id: thisUser.idx)
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
            dropDown.dataSource = ["  " + "message".localized()]
            // Action triggered on selection
            dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
                print("Selected item: \(item) at index: \(idx)")
                if idx == 0{
                    gUser = self.posts[index].user
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
    
    func getMyPosts(member_id:Int64){
        self.showLoadingView()
        APIs.getUserPosts(me_id:member_id, member_id: member_id, handleCallback: {
            cnt, posts, users, result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                self.users.removeAll()
                
                self.posts = posts!
                self.searchPosts = posts!
                
                gProfileViewController.btn_posts.setTitle("posts".localized().firstUppercased + ": " + String(cnt), for: .normal)
                
                if self.posts.count > 0 {
                    self.noResult.isHidden = true
                }
                
                self.users = users!
                gUsers = users!
                
                self.postList.reloadData()

            }
            else{
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
                self.getMyPosts(member_id: thisUser.idx)
            }else if result_code == "1"{
                self.showToast(msg: "post_not_exist".localized())
                self.getMyPosts(member_id: thisUser.idx)
            }else {
                self.showToast(msg: "something_wrong".localized())
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
        APIs.refreshUserPosts(me_id: member_id, member_id: member_id, num: num, handleCallback: {
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
    
    @objc func tappedLinkPreview(gesture:UITapGestureRecognizer) {
        let linkprevs = linkpreviews.filter({prev in return prev.idx == gesture.view!.tag})
        if linkprevs.count > 0 {
            if let url = URL(string: linkprevs[0].site_url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    
}

