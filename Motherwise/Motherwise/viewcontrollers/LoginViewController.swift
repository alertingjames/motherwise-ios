//
//  LoginViewController.swift
//  Motherwise
//
//  Created by Andre on 9/5/20.
//  Copyright © 2020 Motherwise. All rights reserved.
//

import UIKit

class LoginViewController: BaseViewController {
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var view_email: UIView!
    @IBOutlet weak var emailBox: UITextField!
    @IBOutlet weak var view_password: UIView!
    @IBOutlet weak var passwordBox: UITextField!
    @IBOutlet weak var showButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    var show = UIImage(named: "eyeunlock")
    var unshow = UIImage(named: "eyelock")
    var showF = false
    
    let attrs: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: "Comfortaa-Medium", size: 17.0)!,
        .foregroundColor: primaryColor,
        .underlineStyle: NSUnderlineStyle.single.rawValue
    ]    
    
    @IBOutlet weak var welcome: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        logo.layer.cornerRadius = 0
        
        let attributeString = NSMutableAttributedString(string: "forgot_password".localized(),
                                                        attributes: attrs)
        forgotPasswordButton.setAttributedTitle(attributeString, for: .normal)
        
        setRoundShadowView(view: view_email, corner: 25)
        setRoundShadowView(view: view_password, corner: 25)
        setRoundShadowButton(button: loginButton, corner: 25)
        setRoundShadowButton(button: signupButton, corner: 25)
        
        emailBox.keyboardType = UIKeyboardType.emailAddress
        
        emailBox.attributedPlaceholder = NSAttributedString(
            string: "email".localized(),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        passwordBox.attributedPlaceholder = NSAttributedString(
            string: "password".localized(),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        signupButton.visibility = .gone
        
        loginButton.setTitle("log_in".localized(), for: .normal)
        signupButton.setTitle("sign_up".localized(), for: .normal)
        
    }
    
    @IBAction func toForgotPassword(_ sender: Any) {
        print("Clicked on ForgotPassword button")
        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier:"ForgotPasswordViewController")
        vc.modalPresentationStyle = .fullScreen
        self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
    }
    
    @IBAction func toggle(_ sender: Any) {
        if showF == false{
            showButton.setImage(unshow, for: UIControl.State.normal)
            showF = true
            passwordBox.isSecureTextEntry = false
        }else{
            showButton.setImage(show, for: UIControl.State.normal)
            showF = false
            passwordBox.isSecureTextEntry = true
        }
    }
    
    @IBAction func login(_ sender: Any) {
        if emailBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            showToast(msg: "enter_email".localized())
            return
        }
        
        if isValidEmail(testStr: (emailBox.text?.trimmingCharacters(in: .whitespacesAndNewlines))!) == false{
            showToast(msg: "invalid_email".localized())
            return
        }
        
        if passwordBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            showToast(msg: "enter_password".localized())
            return
        }
        
        login(email: emailBox.text!, password: passwordBox.text!)
    }
    
    
    
    func login(email:String, password: String)
    {
        showLoadingView()
        APIs.login(email: email, password: password, handleCallback:{
            user, result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                thisUser = user!
                UserDefaults.standard.set(thisUser.email, forKey: "email")
                UserDefaults.standard.set(thisUser.password, forKey: "password")
                if thisUser.status2.count == 0 {
                    gNote = "read_terms".localized()
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TermsViewController")
                    vc.modalPresentationStyle = .fullScreen
                    self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
                }else{
                    gNote = "login_success".localized()
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewHomeViewController")
                    vc.modalPresentationStyle = .fullScreen
                    self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
                }
            }else if result_code == "1" {
                thisUser = user!
                gNote = "add_location".localized()
                UserDefaults.standard.set(thisUser.email, forKey: "email")
                UserDefaults.standard.set(thisUser.password, forKey: "password")
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewHomeViewController")
                vc.modalPresentationStyle = .fullScreen
                self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
            }else if result_code == "2" {
                thisUser = user!
                UserDefaults.standard.set(thisUser.email, forKey: "email")
                UserDefaults.standard.set(thisUser.password, forKey: "password")
                if thisUser.status2.count == 0 {
                    gNote = "read_terms".localized()
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TermsViewController")
                    vc.modalPresentationStyle = .fullScreen
                    self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
                }else{
                    gNote = "register_profile".localized()
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignupViewController")
                    vc.modalPresentationStyle = .fullScreen
                    self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
                }
            }else{
                if result_code == "3" {
                    thisUser.idx = 0
                    self.showToast(msg: "password_incorrect".localized())
                }else if result_code == "4" {
                    thisUser.idx = 0
                    self.showToast(msg: "user_not_exist".localized())
                }else {
                    thisUser.idx = 0
                    self.showToast(msg: "something_wrong".localized())
                }
            }
        })
    }
    
    @IBAction func toSignup(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignupViewController")
        vc.modalPresentationStyle = .fullScreen
        self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
    }
    
}
