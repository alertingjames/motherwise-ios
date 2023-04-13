//
//  ForgotPasswordViewController.swift
//  Motherwise
//
//  Created by Andre on 9/5/20.
//  Copyright © 2020 Motherwise. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: BaseViewController {
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var view_email: UIView!
    @IBOutlet weak var emailBox: UITextField!
    @IBOutlet weak var submitButton: UIButton!

    @IBOutlet weak var fbtitle: UILabel!
    @IBOutlet weak var fpdesc: UITextView!
    @IBOutlet weak var log_in: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        logo.layer.cornerRadius = 0
        
        fbtitle.text = "forgot_password".localized()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 10
        
        let text = "fp_text".localized()

        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont(name: "Comfortaa-Medium", size: 15.0)!,
            .foregroundColor: UIColor.black
        ]
        let attributedString = NSAttributedString(string: text, attributes: attributes)

        textView.attributedText = attributedString
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        setRoundShadowView(view: view_email, corner: 25)
        setRoundShadowButton(button: submitButton, corner: 25)
        
        emailBox.keyboardType = UIKeyboardType.emailAddress
        emailBox.attributedPlaceholder = NSAttributedString(
            string: "email".localized().firstUppercased,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        
    }
    
    @IBAction func toLogin(_ sender: Any) {
        dismissViewController()
    }

    @IBAction func submit(_ sender: Any) {
        if emailBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            showToast(msg: "enter_email".localized())
            return
        }
        
        if isValidEmail(testStr: (emailBox.text?.trimmingCharacters(in: .whitespacesAndNewlines))!) == false{
            showToast(msg: "invalid_email".localized())
            return
        }
        
        forgotPassword(email: emailBox.text!)
    }
    
    func forgotPassword(email:String)
    {
        showLoadingView()
        APIs.forgotPassword(email: email, handleCallback:{
            result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                self.showToast2(msg: "sent_link_to_email".localized())
                self.openMailBox(email: email)
            }else if result_code == "1"{
                self.showToast(msg: "sorry_dont_know_email".localized())
            }else {
                self.showToast(msg: "something_wrong".localized())
            }
        })
    }
    
    func openMailBox(email:String){
        if let url = URL(string: "mailto:\(email)") {
          if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
          } else {
            UIApplication.shared.openURL(url)
          }
        }
    }
    
}
