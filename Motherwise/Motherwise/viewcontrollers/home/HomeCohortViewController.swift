//
//  HomeCohortViewController.swift
//  Motherwise
//
//  Created by Andre on 9/5/20.
//  Copyright © 2020 Motherwise. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class HomeCohortViewController: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var view_group: UIView!
    @IBOutlet weak var groupBox: UITextField!
    
    @IBOutlet weak var membersButton: UIView!
    @IBOutlet weak var conferenceButton: UIView!
    @IBOutlet weak var groupChatButton: UIView!
    
    @IBOutlet weak var ic_members: UIImageView!
    @IBOutlet weak var ic_conference: UIImageView!
    @IBOutlet weak var ic_groupchat: UIImageView!
    
    let thePicker = UIPickerView()
    let groups = [String](arrayLiteral:
        "- Choose a group -",
        "E81",
        "E83",
        "E84",
        "E86",
        "E87",
        "S82",
        "S85",
        "S88",
        "E(v)89",
        "E(v)90",
        "S(v)91",
        "E(v)92",
        "E(v)93",
        "E(v)94",
        "S(v)95",
        "E(v)96",
        "E(v)97",
        "S(v)98",
        "E(v)99",
        "E(v)100",
        "S(v)101",
        "E(v)102",
        "E(v)103",
        "S(v)104",
        "E(v)105",
        "E(v)106",
        "S(v)107",
        "E(v)108",
        "E(v)109",
        "S(v)110",
        "E(v)111",
        "E(v)112",
        "S(v)113",
        "E(v)114",
        "E(v)115",
        "S(v)116",
        "E(v)117",
        "E(v)118",
        "S(v)119",
        "E(v)120",
        "E(v)121",
        "S(v)122",
        "E(v)123",
        "E(v)124",
        "S(v)125",
        "E(v)126",
        "E(v)127",
        "S(v)128",
        "Love Notes E(v)1",
        "Love Notes E(v)2",
        "Love Notes E(v)3",
        "Love Notes E(v)4",
        "Love Notes E(v)5",
        "Love Notes E(v)6",
        "Love Notes E(v)7",
        "Love Notes E(v)8",
        "MotherWise Alumni",
        "MotherWise Team")

    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_members: UILabel!
    @IBOutlet weak var lbl_video: UILabel!
    @IBOutlet weak var lbl_group_chat: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbl_title.text = "connect_with_group".localized().uppercased()
        lbl_members.text = "members".localized()
        lbl_video.text = "video_conference".localized()
        lbl_group_chat.text = "group_chat".localized()
        groupBox.attributedPlaceholder = NSAttributedString(string: "choose_group".localized(),
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        

        membersButton.layer.cornerRadius = 23
        conferenceButton.layer.cornerRadius = 23
        groupChatButton.layer.cornerRadius = 23
        
        view_group.layer.borderColor = UIColor.lightGray.cgColor
        
        view_group.layer.borderWidth = 1.0
        
        view_group.layer.cornerRadius = view_group.frame.height / 2
        
        setIconTintColor(imageView: ic_members, color: UIColor.white)
        
        setIconTintColor(imageView: ic_conference, color: UIColor.white)
        
        setIconTintColor(imageView: ic_groupchat, color: UIColor.white)
        
        var tap = UITapGestureRecognizer(target: self, action: #selector(self.getCohortMembers(_:)))
        membersButton.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.getCohortConferences(_:)))
        conferenceButton.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.cohortGroupChat(_:)))
        groupChatButton.addGestureRecognizer(tap)
        
        thePicker.delegate = self
        groupBox.inputView = thePicker
        thePicker.backgroundColor = UIColor.white
        createToolbar()
        
        
    }
    
    @objc func getCohortMembers(_ sender: UITapGestureRecognizer? = nil) {
        if groupBox.text?.count == 0 {
            showToast(msg: "choose_group".localized())
            return
        }
        gUsers = gNewHomeVC.users.filter{ user in
            return user.cohort == groupBox.text || user.cohort == "admin"
        }
        gGroupName = groupBox.text!
        print("Users Count: \(gUsers.count)")
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "GroupMembersViewController")
        vc.modalPresentationStyle = .fullScreen
        self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
    }
    
    @objc func getCohortConferences(_ sender: UITapGestureRecognizer? = nil) {
        if groupBox.text?.count == 0 {
            showToast(msg: "choose_group".localized())
            return
        }
        gSelectedGroupId = 0
        gSelectedCohort = groupBox.text!
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ConferencesViewController")
        vc.modalPresentationStyle = .fullScreen
        self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
    }
    
    @objc func cohortGroupChat(_ sender: UITapGestureRecognizer? = nil) {
        if groupBox.text?.count == 0 {
            showToast(msg: "choose_group".localized())
            return
        }
        gSelectedGroupId = 0
        gSelectedCohort = groupBox.text!
        gUsers = gNewHomeVC.users.filter{ user in
            return user.cohort == groupBox.text || user.cohort == "admin"
        }
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "GroupChatViewController")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        
    }
    
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return groups.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row > 0{
            groupBox.text = groups[row]
        }else{
            groupBox.text = ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return groups[row]
    }
    
    @objc func closePickerView()
    {
        view.endEditing(true)
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50.0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label:UILabel
        
        if let v = view as? UILabel{
            label = v
        }
        else{
            label = UILabel()
        }
        
        if row == 0{
            label.textColor = UIColor.systemOrange
        }else{
            label.textColor = UIColor.black
        }
        label.textAlignment = .center
        label.font = UIFont(name: "Helvetica", size: 20)
        label.text = groups[row]
        
        return label
    }
    
    func createToolbar()
    {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.tintColor = primaryDarkColor
        toolbar.backgroundColor = UIColor.lightGray
        let doneButton = UIBarButtonItem(title: "done".localized(), style: .plain, target: self, action: #selector(SignupViewController.closePickerView))
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        groupBox.inputAccessoryView = toolbar
    }
    
    
}
