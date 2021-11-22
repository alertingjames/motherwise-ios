//
//  ResetPasswordViewController.swift
//  Motherwise
//
//  Created by Andre on 9/5/20.
//  Copyright © 2020 Motherwise. All rights reserved.
//

import UIKit

class ResetPasswordViewController: BaseViewController {
    
    
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var view_email: UIView!
    @IBOutlet weak var view_oldpwd: UIView!
    @IBOutlet weak var view_newpwd: UIView!
    
    @IBOutlet weak var edt_email: UITextField!
    @IBOutlet weak var edt_oldpwd: UITextField!
    @IBOutlet weak var edt_newpwd: UITextField!
    @IBOutlet weak var btn_show: UIButton!
    @IBOutlet weak var btn_submit: UIButton!
    
    @IBOutlet weak var ic_mail: UIImageView!
    @IBOutlet weak var ic_pwd: UIImageView!
    @IBOutlet weak var ic_pwd2: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbl_title.text = "reset_password".localized().uppercased()

        view_email.layer.cornerRadius = view_email.frame.height / 2
        view_oldpwd.layer.cornerRadius = view_oldpwd.frame.height / 2
        view_newpwd.layer.cornerRadius = view_newpwd.frame.height / 2
        
        ic_mail.image = ic_mail.image?.imageWithColor(color1: UIColor.lightGray)
        ic_pwd.image = ic_pwd.image?.imageWithColor(color1: UIColor.lightGray)
        ic_pwd2.image = ic_pwd2.image?.imageWithColor(color1: UIColor.lightGray)
        
        btn_show.setImageTintColor(.lightGray)
        btn_submit.layer.cornerRadius = btn_submit.frame.height / 2
        
        edt_email.attributedPlaceholder = NSAttributedString(
            string: "email".localized(),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        edt_oldpwd.attributedPlaceholder = NSAttributedString(
            string: "old_password".localized(),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        edt_newpwd.attributedPlaceholder = NSAttributedString(
            string: "new_password".localized(),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        
        edt_email.text = thisUser.email
        edt_email.isEnabled = false
        
        btn_submit.setTitle("submit".localized(), for: .normal)
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submit(_ sender: Any) {
        if edt_oldpwd.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0{
            showToast(msg: "enter_old_password".localized())
            return
        }
        
        if edt_newpwd.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0{
            showToast(msg: "enter_new_password".localized())
            return
        }
        
        if thisUser.password != edt_oldpwd.text?.trimmingCharacters(in: .whitespacesAndNewlines){
            showToast(msg: "enter_correct_old_password".localized())
            return
        }
        
        self.showLoadingView()
        APIs.changePassword(email: edt_email.text!, old_password: self.edt_oldpwd.text!, new_password: self.edt_newpwd.text!, handleCallback: {
            result in
            self.dismissLoadingView()
            if result == "0"{
                thisUser.password = self.edt_newpwd.text?.trimmingCharacters(in: .whitespacesAndNewlines) as! String
                UserDefaults.standard.set(thisUser.password, forKey: "password")
                gProfileViewController.showToast2(msg: "successfully_changed".localized())
                self.dismiss(animated: true, completion: nil)
            }else if result == "1" {
                self.showToast2(msg: "user_not_exist".localized())
                self.logout()
            }else if result == "2"{
                self.showToast2(msg: "email_password_incorrect".localized())
            }else {
                self.showToast2(msg: "something_wrong_".localized())
            }
            
        })
        
    }
    
    var showF:Bool = false
    var show = UIImage(named: "eyeunlock")
    var unshow = UIImage(named: "eyelock")
    
    @IBAction func togglePassword(_ sender: Any) {
        
        if showF == false{
            btn_show.setImage(unshow, for: UIControl.State.normal)
            showF = true
            edt_oldpwd.isSecureTextEntry = false
        }else{
            btn_show.setImage(show, for: UIControl.State.normal)
            showF = false
            edt_oldpwd.isSecureTextEntry = true
        }
        
    }
}
