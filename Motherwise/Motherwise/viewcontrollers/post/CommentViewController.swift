//
//  CommentViewController.swift
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
import Emoji
import Smile

class CommentViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var navBar: UIView!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var commentList: UITableView!
    @IBOutlet weak var penButton: UIButton!
    @IBOutlet weak var noResult: UILabel!

    var imageFile:Data!
    var ImageArray = NSMutableArray()
    
    var comments = [Comment]()
    
    var emojiButtons = [UILabel]()
    var emojiStrings = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addShadowToBar(view: navBar)
        penButton.setImageTintColor(.white)
        
        lbl_title.text = "comment".localized().uppercased()
        noResult.text = "no_comment_".localized()
        
        self.commentList.delegate = self
        self.commentList.dataSource = self
        
        self.commentList.estimatedRowHeight = 170.0
        self.commentList.rowHeight = UITableView.automaticDimension
        
        UITextView.appearance().linkTextAttributes = [ .foregroundColor: UIColor.yellow ]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        gRecentViewController = self
        gCommentVC = self
        self.getComments(post_id: gPost.idx)
        
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
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
            
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell:CommentCell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
                
        let index:Int = indexPath.row
                
        if comments.indices.contains(index) {
            
            let comment = comments[index]
                    
            if comment.image_url != ""{
                loadPicture(imageView: cell.imageBox, url: URL(string: comment.image_url)!)
                cell.imageBox.visibility = .visible
            }else{
                cell.imageBox.visibility = .gone
            }
            
            cell.imageBox.roundCorners(corners: [.topRight, .bottomLeft, .bottomRight], radius: 15)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(gesture:)))

            cell.imageBox.tag = index
            cell.imageBox.addGestureRecognizer(tapGesture)
            cell.imageBox.isUserInteractionEnabled = true
            
            if comment.user.photo_url != ""{
                loadPicture(imageView: cell.userPicture, url: URL(string: comment.user.photo_url)!)
            }
            
            cell.userPicture.layer.cornerRadius = cell.userPicture.frame.width / 2
            
            if comment.user.idx != thisUser.idx{
                cell.userNameBox.text = comment.user.name
            }else{
                cell.userNameBox.text = "Me"
            }
            
            cell.userCohortBox.text = comment.user.cohort
            cell.commentBox.text = self.processingEmoji(str:comment.comment)
            cell.commentedTimeBox.text = comment.commented_time
            
            cell.menuButton.setImageTintColor(UIColor.gray)
            
            cell.menuButton.tag = index
            cell.menuButton.addTarget(self, action: #selector(self.openDropDownMenu), for: .touchUpInside)
            
//            setRoundShadowView(view: cell.contentLayout, corner: 5.0)
                    
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
    
    @objc func openDropDownMenu(sender:UIButton){
        let index = sender.tag
        let cell = sender.superview?.superviewOfClassType(CommentCell.self) as! CommentCell
        
        let dropDown = DropDown()
        
        dropDown.anchorView = cell.menuButton
        if comments[index].user.idx == thisUser.idx{
            dropDown.dataSource = ["  " + "edit".localized(), "  " + "delete".localized()]
            // Action triggered on selection
            dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
                print("Selected item: \(item) at index: \(idx)")
                if idx == 0{
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddCommentViewController") as! AddCommentViewController
                    vc.commentBox.text = self.processingEmoji(str:cell.commentBox.text)
                    vc.commentBox.checkPlaceholder()
                    vc.commentBox.becomeFirstResponder()
                    vc.submitButton.alpha = 1.0
                    self.present(vc, animated: true, completion: nil)
                }else if idx == 1{
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
        }else{
            dropDown.dataSource = ["  " + "message".localized()]
            // Action triggered on selection
            dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
                print("Selected item: \(item) at index: \(idx)")
                if idx == 0{
                    gUser = self.comments[index].user
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
    
    func getComments(post_id:Int64){
        self.showLoadingView()
        APIs.getComments(post_id: post_id, member_id: thisUser.idx, handleCallback: {
            comments, result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                
                self.comments = comments!
                
                if comments!.count == 0 {
                    self.noResult.isHidden = false
                }
                
                self.commentList.reloadData()

            }
            else{
                if result_code == "1" {
                    self.showToast(msg: "post_not_exist".localized())
                } else {
                    self.showToast(msg: "something_wrong".localized())
                }
            }
        })
    }
    
    func deleteComment(comment_id: Int64){
        self.showLoadingView()
        APIs.deleteComment(comment_id: comment_id, handleCallback: {
            result_code in
            self.dismissLoadingView()
            if result_code == "0"{
                self.showToast2(msg: "deleted".localized())
                self.getComments(post_id: gPost.idx)
                if gRecentViewController == gPostViewController{
                    gPostViewController.getUserPosts(me_id: thisUser.idx, member_id: gUser.idx)
                }else if gRecentViewController == gMyPostViewController{
                    gMyPostViewController.getMyPosts(member_id: thisUser.idx)
                }
                
            }else if result_code == "1"{
                self.showToast(msg: "comment_not_exist".localized())
                self.getComments(post_id: gPost.idx)
            }else {
                self.showToast(msg: "something_wrong".localized())
            }
        })
    }
    
    
    @IBAction func openInputView(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddCommentViewController")
        self.present(vc, animated: true, completion: nil)
    }
    
    
    
}
