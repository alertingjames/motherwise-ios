//
//  RecipeMenu.swift
//  Motherwise
//
//  Created by james on 4/7/23.
//  Copyright © 2023 VaCay. All rights reserved.
//

import UIKit

class RecipeMenu: BaseViewController {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleBox: UILabel!
    @IBOutlet weak var closeButton: UIImageView!
    @IBOutlet weak var meatButton: UIView!
    @IBOutlet weak var meatIcon: UIImageView!
    @IBOutlet weak var meatLabel: UILabel!
    @IBOutlet weak var vegetarianButton: UIView!
    @IBOutlet weak var vegetarianIcon: UIImageView!
    @IBOutlet weak var vegetarianLabel: UILabel!
    @IBOutlet weak var lightBitesButton: UIView!
    @IBOutlet weak var lightBitesIcon: UIImageView!
    @IBOutlet weak var lightBitesLabel: UILabel!
    @IBOutlet weak var sweetToothButton: UIView!
    @IBOutlet weak var sweetToothIcon: UIImageView!
    @IBOutlet weak var sweetToothLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.layer.cornerRadius = 10
        titleBox.text = "recipes".localized().uppercased()
        meatLabel.text = "meat".localized()
        vegetarianLabel.text = "vegetarian".localized()
        lightBitesLabel.text = "light_bites".localized()
        sweetToothLabel.text = "sweet_tooth".localized()
        meatButton.layer.cornerRadius = 5
        vegetarianButton.layer.cornerRadius = 5
        lightBitesButton.layer.cornerRadius = 5
        sweetToothButton.layer.cornerRadius = 5
        meatIcon.layer.cornerRadius = 3
        vegetarianIcon.layer.cornerRadius = 3
        lightBitesIcon.layer.cornerRadius = 3
        sweetToothIcon.layer.cornerRadius = 3
        
        let blurFx = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurFxView = UIVisualEffectView(effect: blurFx)
        blurFxView.frame = view.bounds
        blurFxView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(blurFxView, at: 0)
        
        containerView.alpha = 0
        
        UIView.animate(withDuration: 0.8) {
            self.containerView.alpha = 1.0
        }
        
        var tap = UITapGestureRecognizer(target: self, action: #selector(closeMenu(gesture:)))
        closeButton.isUserInteractionEnabled = true
        closeButton.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(toMeatRecipes(gesture:)))
        meatButton.isUserInteractionEnabled = true
        meatButton.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(toVegetarianRecipes(gesture:)))
        vegetarianButton.isUserInteractionEnabled = true
        vegetarianButton.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(toLightBitesRecipes(gesture:)))
        lightBitesButton.isUserInteractionEnabled = true
        lightBitesButton.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(toSweetToothRecipes(gesture:)))
        sweetToothButton.isUserInteractionEnabled = true
        sweetToothButton.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedBackground(_ :)))
        self.view.addGestureRecognizer(tap)
        
    }
    
    @objc func tappedBackground(_ sender:UITapGestureRecognizer? = nil) {
        close()
    }
    
    @objc func closeMenu(gesture:UITapGestureRecognizer) {
        close()
    }
    
    func close() {
        UIView.animate(withDuration: 0.3) {
            self.containerView.alpha = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Code you want to be delayed
            self.removeFromParent()
            self.view.removeFromSuperview()
//            self.buttonView.alpha = 1
        }
    }
    
    @objc func toMeatRecipes(gesture:UITapGestureRecognizer) {
        selectedRecipeType = "meat"
        toRecipes()
    }
    
    @objc func toVegetarianRecipes(gesture:UITapGestureRecognizer) {
        selectedRecipeType = "vegetarian"
        toRecipes()
    }
    
    @objc func toLightBitesRecipes(gesture:UITapGestureRecognizer) {
        selectedRecipeType = "light_bites"
        toRecipes()
    }
    
    @objc func toSweetToothRecipes(gesture:UITapGestureRecognizer) {
        selectedRecipeType = "sweet_tooth"
        toRecipes()
    }
    
    func dismiss() {
        self.removeFromParent()
        self.view.removeFromSuperview()
    }
    
    func toRecipes() {
        let vc = UIStoryboard(name: "Comida", bundle: nil).instantiateViewController(identifier: "RecipesVC")
        vc.modalPresentationStyle = .fullScreen
        transitionVc(vc: vc, duration: 0.3, type: .fromRight)
    }
    

}
