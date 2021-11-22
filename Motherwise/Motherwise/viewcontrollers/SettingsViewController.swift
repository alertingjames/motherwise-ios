//
//  SettingsViewController.swift
//  Motherwise
//
//  Created by james on 11/16/21.
//  Copyright © 2021 VaCay. All rights reserved.
//

import UIKit

class SettingsViewController: BaseViewController {
    
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var englishButton: UIView!
    @IBOutlet weak var spanishButton: UIView!
    @IBOutlet weak var en_icon: UIImageView!
    @IBOutlet weak var es_icon: UIImageView!
    @IBOutlet weak var lbl_english: UILabel!
    @IBOutlet weak var lbl_spanish: UILabel!    
    @IBOutlet weak var lbl_desc: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbl_title.text = "language".localized().uppercased()
        lbl_english.text = "english".localized()
        lbl_spanish.text = "spanish".localized()
        lbl_desc.text = "change_language".localized()
        
        resetIcons()
        let lang = UserDefaults.standard.string(forKey: "app_lang") ?? "en"
        if lang == "es" {
            es_icon.image = UIImage(systemName: "circle.inset.filled")
        }else {
            en_icon.image = UIImage(systemName: "circle.inset.filled")
        }

        var tap = UITapGestureRecognizer(target: self, action: #selector(selectEnglish(gesture:)))
        englishButton.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(selectSpanish(gesture:)))
        spanishButton.addGestureRecognizer(tap)
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func selectEnglish(gesture:UITapGestureRecognizer){
        resetIcons()
        en_icon.image = UIImage(systemName: "circle.inset.filled")
        Bundle.setLanguage(lang: "en")
    }
    
    
    @objc func selectSpanish(gesture:UITapGestureRecognizer){
        resetIcons()
        es_icon.image = UIImage(systemName: "circle.inset.filled")
        Bundle.setLanguage(lang: "es")
    }
    
    func resetIcons() {
        en_icon.image = UIImage(systemName: "circle")
        es_icon.image = UIImage(systemName: "circle")
    }

}
