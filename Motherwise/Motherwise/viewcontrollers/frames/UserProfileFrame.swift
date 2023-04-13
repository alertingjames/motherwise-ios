//
//  UserProfileFrame.swift
//  Motherwise
//
//  Created by james on 4/4/23.
//  Copyright © 2023 VaCay. All rights reserved.
//

import UIKit

class UserProfileFrame: BaseViewController {
    
    @IBOutlet weak var pictureBox: UIImageView!
    @IBOutlet weak var nameBox: UILabel!
    @IBOutlet weak var groupIconBox: UIImageView!
    @IBOutlet weak var locationIconBox: UIImageView!
    @IBOutlet weak var groupBox: UILabel!
    @IBOutlet weak var postsButton: UIView!
    @IBOutlet weak var chatButton: UIView!
    @IBOutlet weak var ic_post: UIImageView!
    @IBOutlet weak var ic_chat: UIImageView!
    @IBOutlet weak var buttonView: UIView!    
    @IBOutlet weak var lbl_posts: UILabel!
    @IBOutlet weak var lbl_chats: UILabel!
    @IBOutlet weak var closeButton: UIImageView!
    @IBOutlet weak var groupView: UIView!
    @IBOutlet weak var cityBox: UILabel!
    
    var group_name:String = ""
    var from_group:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let blurFx = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurFxView = UIVisualEffectView(effect: blurFx)
        blurFxView.frame = view.bounds
        blurFxView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(blurFxView, at: 0)
        
        postsButton.layer.cornerRadius = postsButton.frame.height / 2
        chatButton.layer.cornerRadius = chatButton.frame.height / 2
        
        pictureBox.layer.cornerRadius = pictureBox.frame.height / 2
        
        setIconTintColor(imageView: groupIconBox, color: UIColor(rgb: 0x1DA2D8, alpha: 1.0))
        setIconTintColor(imageView: locationIconBox, color: .white)
        
        setIconTintColor(imageView: ic_post, color: .white)
        setIconTintColor(imageView: ic_chat, color: .white)
        
        buttonView.alpha = 0
        
        UIView.animate(withDuration: 0.8) {
            self.buttonView.alpha = 1.0
        }
        
        var tap = UITapGestureRecognizer(target: self, action: #selector(self.userPosts(_:)))
        postsButton.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.userChat(_:)))
        chatButton.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.closeFrame(_:)))
        closeButton.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.toGroup(_ :)))
        groupView.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedBackground(_ :)))
        self.view.addGestureRecognizer(tap)
        
    }
    
    @objc func tappedBackground(_ sender:UITapGestureRecognizer? = nil) {
        UIView.animate(withDuration: 0.3) {
            self.buttonView.alpha = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Code you want to be delayed
            self.removeFromParent()
            self.view.removeFromSuperview()
//            self.buttonView.alpha = 1
        }
    }
    
    @objc func userPosts(_ sender: UITapGestureRecognizer? = nil) {
        gId = 0
        gPostOpt = "user"
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PostsViewController")
        vc.modalPresentationStyle = .fullScreen
        self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
        dismiss()
    }
    
    @objc func userChat(_ sender: UITapGestureRecognizer? = nil) {
        toChat()
        dismiss()
    }
    
    @objc func closeFrame(_ sender: UITapGestureRecognizer? = nil) {
        dismiss()
    }
    
    @objc func toGroup(_ sender: UITapGestureRecognizer? = nil) {
        if from_group { return }
        gUsers = gNewHomeVC.users.filter{ user in
            return user.cohort == group_name || user.cohort == "admin"
        }
        gGroupName = group_name
        print("Users Count: \(gUsers.count)")
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "GroupMembersViewController")
        vc.modalPresentationStyle = .fullScreen
        self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
        dismiss()
    }
    
    func toChat(){
        gSelectedUsers.removeAll()
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PrivateChatViewController")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    func dismiss() {
        self.removeFromParent()
        self.view.removeFromSuperview()
    }
    

}
