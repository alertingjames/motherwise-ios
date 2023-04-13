//
//  FoodResourcesVC.swift
//  Motherwise
//
//  Created by james on 4/7/23.
//  Copyright © 2023 VaCay. All rights reserved.
//

import UIKit
import Kingfisher
import SCLAlertView
import Auk
import DynamicBlurView
import GSImageViewerController

class FoodResourcesVC: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var btn_search: UIButton!
    @IBOutlet weak var view_searchbar: UIView!
    @IBOutlet weak var edt_search: UITextField!
    @IBOutlet weak var btn_nav: UIButton!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var noResult: UILabel!
    
    @IBOutlet weak var frList: UITableView!
    
    var foodresources = [FoodResource]()
    var searchfoodresources = [FoodResource]()
    
    let attrs: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: "Comfortaa-Medium", size: 16.0)!,
        .foregroundColor: UIColor.white,
    //   .underlineStyle: NSUnderlineStyle.single.rawValue
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gFoodResourcesVC = self
        
        lbl_title.text = "resources_in_community".localized()

        view_searchbar.isHidden = true
        edt_search.attributedPlaceholder = NSAttributedString(string: "search_".localized(),
            attributes: attrs)
        
        edt_search.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        view_searchbar.layer.cornerRadius = view_searchbar.frame.height / 2
        view_searchbar.backgroundColor = UIColor(rgb: 0xffffff, alpha: 0.3)
        
        self.frList.delegate = self
        self.frList.dataSource = self
        
        self.frList.estimatedRowHeight = 80.0
        self.frList.rowHeight = UITableView.automaticDimension
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismissViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getFoodResources(admin_id: thisUser.admin_id)
    }
    
    @IBAction func tap_search(_ sender: Any) {
        if view_searchbar.isHidden{
            view_searchbar.isHidden = false
            btn_search.setImage(cancel, for: .normal)
            lbl_title.isHidden = true
            edt_search.becomeFirstResponder()
            
        }else{
            view_searchbar.isHidden = true
            btn_search.setImage(search, for: .normal)
            lbl_title.isHidden = false
            self.edt_search.text = ""
            self.foodresources = searchfoodresources
            edt_search.resignFirstResponder()
            self.frList.reloadData()
        }
    }
    
    func loadPicture(imageView:UIImageView, url:URL){
        let processor = DownsamplingImageProcessor(size: imageView.frame.size)
        ResizingImageProcessor(referenceSize: imageView.frame.size, mode: .aspectFill)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "frlogo.png"),
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
                print("Task done for: \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
        }
    }
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodresources.count
    }
            
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell:FRCell = tableView.dequeueReusableCell(withIdentifier: "FRCell", for: indexPath) as! FRCell
            
        frList.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
                
        let index:Int = indexPath.row
                
        if foodresources.indices.contains(index) {
            
            let fr = foodresources[index]
            
            if fr.image_url != "" {
                loadPicture(imageView: cell.imageBox, url: URL(string: fr.image_url)!)
            } else {
                cell.imageBox.image = UIImage(named: "frlogo.png")
            }
            
            cell.imageBox.layer.cornerRadius = cell.imageBox.frame.width / 2
                    
            cell.titleBox.text = fr.title
            if fr.location != "" { cell.subtitleBox.text = fr.location }
            else if fr.group != "" { cell.subtitleBox.text = fr.group }
            else if fr.daily_meal != "" { cell.subtitleBox.text = fr.daily_meal }
            else if fr.category != "" { cell.subtitleBox.text = fr.category }
            
            cell.menuButton.setImageTintColor(UIColor(rgb: 0xffffff, alpha: 0.8))
            
            cell.menuButton.tag = index
            cell.menuButton.addTarget(self, action: #selector(self.openDetail), for: .touchUpInside)
                
            cell.containerView.sizeToFit()
            cell.containerView.layoutIfNeeded()
                
        }
        
        return cell
        
    }
    
    
    @objc func openDetail(sender:UIButton){
        let index = sender.tag
        let fr = foodresources[index]
        gFR = fr
        let vc = UIStoryboard(name: "Comida", bundle: nil).instantiateViewController(identifier: "FoodResourceDetailVC")
        self.present(vc, animated: true, completion: nil)
        
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        edt_search.attributedText = NSAttributedString(string: edt_search.text!, attributes: attrs)
        foodresources = filter(keyword: (textField.text?.lowercased())!)
        if foodresources.isEmpty{
                
        }
        self.frList.reloadData()
    }
        
    func filter(keyword:String) -> [FoodResource]{
        if keyword == ""{
            return searchfoodresources
        }
        var filteredFRs = [FoodResource]()
        for fr in searchfoodresources{
            if fr.title.lowercased().contains(keyword){
                filteredFRs.append(fr)
            }else{
                if fr.location.lowercased().contains(keyword){
                    filteredFRs.append(fr)
                }else{
                    if fr.group.lowercased().contains(keyword){
                        filteredFRs.append(fr)
                    }
                }
            }
        }
        return filteredFRs
    }
    
    func getFoodResources(admin_id:Int64){
        self.showLoadingView()
        APIs.getFoodResources(admin_id: admin_id, handleCallback: {
            frs, result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0" {
                self.foodresources = frs!
                self.searchfoodresources = frs!
                if frs!.count == 0 {
                    self.noResult.isHidden = false
                }
                self.frList.reloadData()
            }
            else{
                self.showToast(msg: "something_wrong".localized())
            }
        })
    }

    
    
    
}
