//
//  ReplyMessageViewController.swift
//  Motherwise
//
//  Created by Andre on 9/5/20.
//  Copyright © 2020 Motherwise. All rights reserved.
//

import UIKit
import Kingfisher

class ReplyMessageViewController:  BaseViewController {

    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var userPicture: UIImageView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textBox: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbl_title.text = "reply_message".localized().uppercased().uppercased()
        
        userPicture.layer.cornerRadius = 35 / 2
        
        loadPicture(imageView: userPicture, url: URL(string: gMessage.sender.photo_url)!)
        
        sendButton.roundCorners(corners: [.topLeft], radius: 35 / 2)

        textBox.setPlaceholder(string: "write_something_".localized())
        textBox.textContainerInset = UIEdgeInsets(top: textBox.textContainerInset.top, left: 8, bottom: textBox.textContainerInset.bottom, right: textBox.textContainerInset.right)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textView.checkPlaceholder()
        if textView.text == ""{
            sendButton.isHidden = true
        }else{
            sendButton.isHidden = false
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
                imageView.layer.cornerRadius = imageView.frame.width/2
                print("Task done for: \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
        }
    }

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        if textBox.text.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            showToast(msg: "write_something_".localized())
            return
        }
        
        self.sendReplyMessage(me_id: thisUser.idx, member_id: gMessage.sender.idx, message_id: gMessage.idx, message: textBox.text.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    
    func sendReplyMessage(me_id:Int64, member_id: Int64, message_id:Int64, message:String){
        self.showLoadingView()
        APIs.replyMessage(me_id:me_id, member_id: member_id, message_id: message_id, message: message, handleCallback: {
            result_code in
            self.dismissLoadingView()
            if result_code == "0"{
                self.showToast2(msg: "message_sent".localized())
                self.textBox.text = ""
                self.textBox.checkPlaceholder()
                self.sendButton.isHidden = true
            }else if result_code == "1"{
                self.showToast(msg: "account_not_exist".localized())
                self.logout()
            }else if result_code == "2"{
                self.showToast(msg: "user_not_exist".localized())
                self.dismiss(animated: true, completion: nil)
            }else{
                self.showToast(msg: "somthing_wrong".localized())
                
            }
        })
    }
    
}
