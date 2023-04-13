//
//  AddCommentViewController.swift
//  Motherwise
//
//  Created by james on 4/8/22.
//  Copyright © 2022 VaCay. All rights reserved.
//

import UIKit
import ISEmojiView

class AddCommentViewController: BaseViewController, EmojiViewDelegate {
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var commentBox: UITextView!
    var isEmoji = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        submitButton.alpha = 0.5

        submitButton.setImageTintColor(.white)
        commentBox.setPlaceholder(string: "write_something_".localized())
        commentBox.textContainerInset = UIEdgeInsets(top: commentBox.textContainerInset.top, left: 8, bottom: commentBox.textContainerInset.bottom, right: commentBox.textContainerInset.right)
        commentBox.becomeFirstResponder()
        
        if(commentBox.text.count > 0) {
            commentBox.checkPlaceholder()
            submitButton.alpha = 1.0
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
        if textView.text == ""{
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
            "content" : commentBox.text?.trimmingCharacters(in: .whitespacesAndNewlines).encodeEmoji as Any,
        ]
                
        self.showLoadingView()
        APIs().registerWithoutPicture(withUrl: ReqConst.SERVER_URL + "submitcomment", withParam: parameters) { (isSuccess, response) in
            // Your Will Get Response here
            self.dismissLoadingView()
            print("Response: \(response)")
            if isSuccess == true{
                let result_code = response["result_code"] as Any
                if result_code as! String == "0"{
                    if gRecentViewController == gCommentVC { gCommentVC.getComments(post_id: gPost.idx) }
                    if gPostViewController != nil {
                        gPostViewController.getUserPosts(me_id: thisUser.idx, member_id: gUser.idx)
                    }
                    if gMyPostViewController != nil {
                        gMyPostViewController.getMyPosts(member_id: thisUser.idx)
                    }
                    self.dismiss(animated: true, completion: nil)
                }else if result_code as! String == "1"{
                    self.showToast(msg: "user_not_exist".localized())
                    self.logout()
                }else if result_code as! String == "2"{
                    self.showToast(msg: "post_not_exist".localized())
                    if gPostViewController != nil {
                        gPostViewController.getUserPosts(me_id: thisUser.idx, member_id: gUser.idx)
                    }
                    if gMyPostViewController != nil {
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
