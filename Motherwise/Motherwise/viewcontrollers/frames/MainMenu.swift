//
//  MainMenu.swift
//  Motherwise
//
//  Created by Andre on 9/5/20.
//  Copyright © 2020 Motherwise. All rights reserved.
//

import UIKit

class MainMenu: BaseViewController {
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var profileNameBox: UILabel!
    @IBOutlet weak var networkButton: UIView!
    @IBOutlet weak var meetButton: UIView!
    @IBOutlet weak var groupsButton: UIView!
    @IBOutlet weak var communitiesButton: UIView!
    @IBOutlet weak var conferencesButton: UIView!
//    @IBOutlet weak var postsButton: UIView!
    @IBOutlet weak var messagesButton: UIView!
    @IBOutlet weak var languageButton: UIView!
    @IBOutlet weak var profileButton: UIView!
    @IBOutlet weak var logoutButton: UIView!
    
    @IBOutlet weak var meetIcon: UIImageView!
    @IBOutlet weak var languageIcon: UIImageView!
    @IBOutlet weak var networkIcon: UIImageView!
    @IBOutlet weak var groupsIcon: UIImageView!
    @IBOutlet weak var communitiesIcon: UIImageView!
    @IBOutlet weak var conferencesIcon: UIImageView!
    @IBOutlet weak var postsIcon: UIImageView!
    @IBOutlet weak var messagesIcon: UIImageView!
    @IBOutlet weak var profileIcon: UIImageView!
    @IBOutlet weak var logoutIcon: UIImageView!
    
    @IBOutlet weak var nearbyButton: UIButton!
    @IBOutlet weak var weatherButton: UIButton!
    @IBOutlet weak var extraView: UIView!
    
    @IBOutlet weak var profileFrame: UIView!
    
    
    @IBOutlet weak var lbl_home: UILabel!
    @IBOutlet weak var lbl_meet: UILabel!
    @IBOutlet weak var lbl_groups: UILabel!
    @IBOutlet weak var lbl_communities: UILabel!
    @IBOutlet weak var lbl_conferences: UILabel!
    @IBOutlet weak var lbl_messages: UILabel!
    @IBOutlet weak var lbl_profile: UILabel!
    @IBOutlet weak var lbl_lang: UILabel!
    @IBOutlet weak var lbl_logout: UILabel!
    @IBOutlet weak var lbl_nearby: UILabel!
    @IBOutlet weak var lbl_weather: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        localize()
        
        logo.layer.cornerRadius = 35
        
        nearbyButton.setImageTintColor(.white)
        weatherButton.setImageTintColor(.white)
        
        extraView.roundCorners(corners: [.topLeft, .bottomLeft], radius: extraView.frame.height / 2)
        
        setIconTintColor(imageView:networkIcon, color: UIColor.white)
        setIconTintColor(imageView:meetIcon, color: UIColor.white)
        setIconTintColor(imageView:groupsIcon, color: UIColor.white)
        setIconTintColor(imageView:communitiesIcon, color: UIColor.white)
        setIconTintColor(imageView:conferencesIcon, color: UIColor.white)
//        setIconTintColor(imageView:postsIcon, color: UIColor.white)
        setIconTintColor(imageView:messagesIcon, color: UIColor.white)
        setIconTintColor(imageView:profileIcon, color: UIColor.white)
        setIconTintColor(imageView:languageIcon, color: UIColor.white)
        setIconTintColor(imageView:logoutIcon, color: UIColor.white)
        
        
        
        var tap = UITapGestureRecognizer(target: self, action: #selector(self.getNetworkUsers(_:)))
        networkButton.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.meet(_:)))
        meetButton.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.getGroups(_:)))
        groupsButton.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.getCommunities(_:)))
        communitiesButton.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.getConferences(_:)))
        conferencesButton.addGestureRecognizer(tap)
        
//        tap = UITapGestureRecognizer(target: self, action: #selector(self.getPosts(_:)))
//        postsButton.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.getMessages(_:)))
        messagesButton.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.getMyProfile(_:)))
        profileButton.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.setLanguage(_:)))
        languageButton.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.logout(_:)))
        logoutButton.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.getMyProfile(_:)))
        profileFrame.addGestureRecognizer(tap)
        
    }
    
    func localize() {
        lbl_home.text = "home".localized().uppercased()
        lbl_meet.text = "meet".localized().uppercased()
        lbl_groups.text = "groups".localized().uppercased()
        lbl_communities.text = "communities".localized().uppercased()
        lbl_conferences.text = "conferences".localized().uppercased()
        lbl_messages.text = "messages".localized().uppercased()
        lbl_profile.text = "profile".localized().uppercased()
        lbl_lang.text = "language".localized().uppercased()
        lbl_logout.text = "logout".localized().uppercased()
        lbl_nearby.text = "nearby".localized().firstUppercased
        lbl_weather.text = "weather".localized().firstUppercased
    }
    
    @objc func getNetworkUsers(_ sender: UITapGestureRecognizer? = nil) {
        gNote = ""
        gNewHomeVC.close_menu()
    }
    
    @objc func meet(_ sender: UITapGestureRecognizer? = nil) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeViewController")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        gNewHomeVC.close_menu()
    }
    
    @objc func getGroups(_ sender: UITapGestureRecognizer? = nil) {
        gUsers = gNewHomeVC.users
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeCohortViewController")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        gNewHomeVC.close_menu()
    }
    
    @objc func getCommunities(_ sender: UITapGestureRecognizer? = nil) {
        if gGroups.count == 0{
            showToast(msg: "No community you belong to.")
            return
        }
        gUsers = gNewHomeVC.users
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeGroupViewController")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        gNewHomeVC.close_menu()
    }
    
    @objc func getConferences(_ sender: UITapGestureRecognizer? = nil) {
        gSelectedGroupId = 0
        gSelectedCohort = ""
        gId = 0
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ConferencesViewController")
        vc.modalPresentationStyle = .fullScreen
        self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
        gNewHomeVC.close_menu()
    }
    
    @objc func getPosts(_ sender: UITapGestureRecognizer? = nil) {
        gId = 0
        gPostOpt = "all"
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PostsViewController")
        vc.modalPresentationStyle = .fullScreen
        self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
        gNewHomeVC.close_menu()
    }
    
    @objc func getMessages(_ sender: UITapGestureRecognizer? = nil) {
        gId = 0
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MessageViewController")
        vc.modalPresentationStyle = .fullScreen
        self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
        gNewHomeVC.close_menu()
    }
    
    @objc func getMyProfile(_ sender: UITapGestureRecognizer? = nil) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ProfileViewController")
        vc.modalPresentationStyle = .fullScreen
        self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
        gNewHomeVC.close_menu()
    }
    
    @objc func setLanguage(_ sender: UITapGestureRecognizer? = nil) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "SettingsViewController")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        gNewHomeVC.close_menu()
    }
    
    @objc func logout(_ sender: UITapGestureRecognizer? = nil) {
        
        UserDefaults.standard.set("", forKey: "email")
        UserDefaults.standard.set("", forKey: "role")

        thisUser.idx = 0
        gNote = "logged_out".localized()
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "SplashViewController")
        vc.modalPresentationStyle = .fullScreen
        self.transitionVc(vc: vc, duration: 0.3, type: .fromLeft)
        
    }
    
    func resetSelectedUsers(){
        gNewHomeVC.getHomeData(member_id: thisUser.idx)
    }
    
    @IBAction func nearby(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "NearbyMenuViewController")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        gNewHomeVC.close_menu()
    }
    
    @IBAction func weather(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "WeatherViewController")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        gNewHomeVC.close_menu()
    }
    
}
