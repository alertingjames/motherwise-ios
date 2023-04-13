//
//  FoodResourceDetailVC.swift
//  Motherwise
//
//  Created by james on 4/8/23.
//  Copyright © 2023 VaCay. All rights reserved.
//

import UIKit
import Kingfisher

class FoodResourceDetailVC: BaseViewController {
    @IBOutlet weak var imageBox: UIImageView!
    @IBOutlet weak var closeButton: UIImageView!
    @IBOutlet weak var titleBox: UILabel!
    @IBOutlet weak var groupView: UIView!
    @IBOutlet weak var groupBox: UILabel!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationBox: UILabel!
    @IBOutlet weak var dailyMealView: UIView!
    @IBOutlet weak var dailyMealBox: UILabel!
    @IBOutlet weak var webButton: UIImageView!
    @IBOutlet weak var locationButton: UIImageView!
    @IBOutlet weak var descriptionBox: UITextView!
    @IBOutlet weak var buttonSpace: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageBox.layer.cornerRadius = imageBox.frame.height / 2
        if gFR.image_url != "" {
            loadPicture(imageView: imageBox, url: URL(string: gFR.image_url)!)
        }
        titleBox.text = gFR.title
        if gFR.group == "" { groupView.visibility = .gone }
        groupBox.text = gFR.group
        if gFR.location == "" { locationView.visibility = .gone }
        locationBox.text = gFR.location
        if gFR.daily_meal == "" { dailyMealView.visibility = .gone }
        dailyMealBox.text = gFR.daily_meal.capitalized
        
        descriptionBox.textContainerInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        descriptionBox.layer.cornerRadius = 5
        descriptionBox.text = gFR.description
        
        var tap = UITapGestureRecognizer(target: self, action: #selector(close))
        closeButton.isUserInteractionEnabled = true
        closeButton.addGestureRecognizer(tap)
        
        if gFR.location == "" {
            locationButton.visibility = .gone
            buttonSpace.constant = 0
        }
        
        if gFR.site_url == "" { webButton.visibility = .gone }
        
        tap = UITapGestureRecognizer(target: self, action: #selector(toWeb))
        webButton.isUserInteractionEnabled = true
        webButton.addGestureRecognizer(tap)
        
        setIconTintColor(imageView: webButton, color: .blue)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(toMap))
        locationButton.isUserInteractionEnabled = true
        locationButton.addGestureRecognizer(tap)
        
        setIconTintColor(imageView: locationButton, color: .blue)
        
    }
    
    
    @objc func close() {
        self.dismiss(animated: true)
    }
    
    @objc func toWeb() {
        if let url = URL(string: gFR.site_url) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc func toMap() {
        if let url = URL(string: "https://www.google.com/maps/search/?api=1&query=" + gFR.location.replacingOccurrences(of: " ", with: "%20") + "&z=15") {
            UIApplication.shared.open(url)
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
    

}
