//
//  CommentOnCommentVC.swift
//  Motherwise
//
//  Created by james on 4/7/23.
//  Copyright © 2023 VaCay. All rights reserved.
//

import UIKit
import ISEmojiView
import Kingfisher

class CommentOnCommentVC: BaseViewController, EmojiViewDelegate {
    
    @IBOutlet weak var titleBox: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var commentBox: UITextView!
    var isEmoji = false
    
    @IBOutlet weak var userPicture: UIImageView!
    @IBOutlet weak var userNameBox: UILabel!
    @IBOutlet weak var userCohortBox: UILabel!
    @IBOutlet weak var userCommentBox: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        submitButton.alpha = 0.5
        titleBox.text = "comment_on_comment".localized()
        
        if gComment1.user.photo_url != ""{
            self.loadPicture(imageView: userPicture, url: URL(string: gComment1.user.photo_url)!)
        }
        userPicture.layer.cornerRadius = userPicture.frame.width / 2
                    
        userNameBox.text = gComment1.user.name
        userCohortBox.text = gComment1.user.cohort
        userCommentBox.text = self.processingEmoji(str:gComment1.comment)
        
        userCommentBox.textContainerInset = UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20)
        userCommentBox.roundCorners(corners: [.topRight, .bottomLeft, .bottomRight], radius: 15)

        submitButton.setImageTintColor(.white)
        commentBox.setPlaceholder(string: "write_something_".localized())
        commentBox.roundCorners(corners: [.topLeft, .bottomLeft, .bottomRight], radius: 15)
        commentBox.textContainerInset = UIEdgeInsets(top: commentBox.textContainerInset.top, left: 8, bottom: commentBox.textContainerInset.bottom, right: commentBox.textContainerInset.right)
        commentBox.becomeFirstResponder()
        
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
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
    
    func textViewDidChange(_ textView: UITextView) {
        textView.checkPlaceholder()
        if textView.text == "" {
            submitButton.alpha = 0.5
        }else{
            submitButton.alpha = 1.0
        }
    }
    
    @IBAction func submit(_ sender: Any) {
        if submitButton.alpha < 1.0 { return }
                
        let parameters: [String:Any] = [
            "member_id" : String(thisUser.idx),
            "post_id" : String(gPost.idx),
            "comment_id": String(gComment1.idx),
            "content" : commentBox.text?.trimmingCharacters(in: .whitespacesAndNewlines).encodeEmoji as Any,
        ]
                
        self.showLoadingView()
        APIs().registerWithoutPicture(withUrl: ReqConst.SERVER_URL + "sendcomment", withParam: parameters) { (isSuccess, response) in
            // Your Will Get Response here
            self.dismissLoadingView()
            print("New Comment Response: \(response)")
            if isSuccess == true{
                let result_code = response["result_code"] as Any
                if result_code as! String == "0"{
                    if gPostDetailVC != nil {
                        gPostDetailVC.getSubcomments(comment_id: gComment1.idx, subcommentsView: gCommentsView, subcommentsStackView: gCommentsStackView)
                    }
                    self.dismiss(animated: true, completion: nil)
                }else if result_code as! String == "1"{
                    self.showToast(msg: "user_not_exist".localized())
                    self.logout()
                }else if result_code as! String == "2"{
                    self.showToast(msg: "post_not_exist".localized())
                    gPostDetailVC.getSubcomments(comment_id: gComment1.idx, subcommentsView: gCommentsView, subcommentsStackView: gCommentsStackView)
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
    
    @IBAction func addEmoji(_ sender: Any) {
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
    
}
