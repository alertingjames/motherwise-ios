//
//  ReportViewController.swift
//  Motherwise
//
//  Created by Andre on 9/12/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit
import Kingfisher

class ReportViewController: BaseViewController {
    
    @IBOutlet weak var userPicture: UIImageView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textBox: UITextView!
    @IBOutlet weak var lbl_title: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lbl_title.text = "report_user_".localized().uppercased()
        userPicture.layer.cornerRadius = 35 / 2
        loadPicture(imageView: userPicture, url: URL(string: gUser.photo_url)!)
        
        sendButton.roundCorners(corners: [.topLeft], radius: 35 / 2)

        textBox.setPlaceholder(string: "type_report_".localized())
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
    
    @IBAction func submitReport(_ sender: Any) {
        if textBox.text.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            showToast(msg: "type_report_".localized())
            return
        }
        
        self.submitReport(member_id: gUser.idx, reporter_id: thisUser.idx, message: textBox.text.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    
    func submitReport(member_id:Int64, reporter_id: Int64, message:String){
        self.showLoadingView()
        APIs.reportMember(member_id:member_id, reporter_id: reporter_id, message: message, handleCallback: {
            result_code in
            self.dismissLoadingView()
            if result_code == "0"{
                self.showToast2(msg: "report_submited".localized())
                self.textBox.text = ""
                self.textBox.checkPlaceholder()
                self.sendButton.isHidden = true
            }else if result_code == "1"{
                self.showToast(msg: "user_not_exist".localized())
            }else{
                self.showToast(msg: "something_wrong".localized())
                
            }
        })
    }

}
