//
//  RecipesVC.swift
//  Motherwise
//
//  Created by james on 4/8/23.
//  Copyright © 2023 VaCay. All rights reserved.
//

import Kingfisher
import SCLAlertView
import Auk
import DynamicBlurView
import GSImageViewerController

class RecipesVC: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var btn_search: UIButton!
    @IBOutlet weak var view_searchbar: UIView!
    @IBOutlet weak var edt_search: UITextField!
    @IBOutlet weak var btn_nav: UIButton!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var noResult: UILabel!
    
    @IBOutlet weak var recipeList: UITableView!
    
    var recipes = [Recipe]()
    var searchrecipes = [Recipe]()
    
    let attrs: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: "Comfortaa-Medium", size: 16.0)!,
        .foregroundColor: UIColor.white,
    //   .underlineStyle: NSUnderlineStyle.single.rawValue
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch selectedRecipeType {
            case "meat":
            lbl_title.text = "meat_recipes".localized().uppercased()
                break
            case "vegetarian":
                lbl_title.text = "vegetarian_recipes".localized().uppercased()
                break
            case "light_bites":
                lbl_title.text = "light_bites_recipes".localized().uppercased()
                break
            case "sweet_tooth":
                lbl_title.text = "sweet_tooth_recipes".localized().uppercased()
                break
            default:
                lbl_title.text = "recipes".localized().uppercased()
        }

        view_searchbar.isHidden = true
        edt_search.attributedPlaceholder = NSAttributedString(string: "search_".localized(),
            attributes: attrs)
        
        edt_search.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        view_searchbar.layer.cornerRadius = view_searchbar.frame.height / 2
        view_searchbar.backgroundColor = UIColor(rgb: 0xffffff, alpha: 0.3)
        
        self.recipeList.delegate = self
        self.recipeList.dataSource = self
        
        self.recipeList.estimatedRowHeight = 80.0
        self.recipeList.rowHeight = UITableView.automaticDimension
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismissViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getRecipes(admin_id: thisUser.admin_id, category: selectedRecipeType)
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
            self.recipes = searchrecipes
            edt_search.resignFirstResponder()
            self.recipeList.reloadData()
        }
    }
    
    func loadPicture(imageView:UIImageView, url:URL){
        let processor = DownsamplingImageProcessor(size: imageView.frame.size)
        ResizingImageProcessor(referenceSize: imageView.frame.size, mode: .aspectFill)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "ic_recipe.png"),
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
        return recipes.count
    }
            
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell:RecipeCell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as! RecipeCell
            
        recipeList.backgroundColor = .clear
        cell.backgroundColor = .clear
                
        let index:Int = indexPath.row
                
        if recipes.indices.contains(index) {
            
            let r = recipes[index]
            
            if r.title != "" {
                cell.view1.visibility = .visible
                cell.view2.visibility = .gone
                if r.image_url.count > 0{
                    cell.linkImageBox.visibilityh = .visible
                    loadPicture(imageView: cell.linkImageBox, url: URL(string: r.image_url)!)
                }else {
                    cell.linkImageBox.visibilityh = .gone
                }
                cell.linkTitleBox.text = r.title
                if r.icon_url.count > 0{
                    cell.linkiconBox.visibilityh = .visible
                    loadPicture(imageView: cell.linkiconBox, url: URL(string: r.icon_url)!)
                }else {
                    cell.linkiconBox.visibilityh = .gone
                }
                cell.linkDescBox.text = r.description
                if r.description == "" { cell.linkDescBox.visibility = .gone }
                cell.linkUrlBox.text = r.site_url
                cell.frame.size.height = 60
                cell.linkImageW.constant = CGFloat(cell.frame.size.height * 1.2)
                cell.view1.tag = index
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedLink(gesture:)))
                cell.view1.addGestureRecognizer(tap)
            }
            else {
                cell.view1.visibility = .gone
                cell.view2.visibility = .visible
                cell.linkUrlBox2.text = r.site_url
                cell.view2.tag = index
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedLink(gesture:)))
                cell.view2.addGestureRecognizer(tap)
            }
                
            cell.containerView.sizeToFit()
            cell.containerView.layoutIfNeeded()
                
        }
        
        return cell
        
    }
    
    
    @objc func tappedLink(gesture:UITapGestureRecognizer) {
        let r = self.recipes[gesture.view!.tag]
        if r != nil {
            if let url = URL(string: r.site_url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        edt_search.attributedText = NSAttributedString(string: edt_search.text!, attributes: attrs)
        recipes = filter(keyword: (textField.text?.lowercased())!)
        if recipes.isEmpty{
                
        }
        self.recipeList.reloadData()
    }
        
    func filter(keyword:String) -> [Recipe]{
        if keyword == ""{
            return searchrecipes
        }
        var filteredItems = [Recipe]()
        for r in searchrecipes {
            if r.title.lowercased().contains(keyword){
                filteredItems.append(r)
            }else{
                if r.description.lowercased().contains(keyword){
                    filteredItems.append(r)
                }else{
                    if r.site_url.lowercased().contains(keyword){
                        filteredItems.append(r)
                    }
                }
            }
        }
        return filteredItems
    }
    
    func getRecipes(admin_id:Int64, category:String){
        self.showLoadingView()
        APIs.getRecipes(admin_id: admin_id, category: category, handleCallback: {
            rs, result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0" {
                self.recipes = rs!
                self.searchrecipes = rs!
                if rs!.count == 0 {
                    self.noResult.isHidden = false
                }
                self.recipeList.reloadData()
            }
            else{
                self.showToast(msg: "something_wrong".localized())
            }
        })
    }

    
    
    
}
