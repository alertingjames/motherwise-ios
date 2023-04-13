//
//  RecipeCell.swift
//  Motherwise
//
//  Created by james on 4/8/23.
//  Copyright © 2023 VaCay. All rights reserved.
//

import UIKit

class RecipeCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    
    @IBOutlet weak var linkImageBox: UIImageView!
    @IBOutlet weak var linkImageW: NSLayoutConstraint!
    @IBOutlet weak var linkTitleBox: UILabel!
    @IBOutlet weak var linkDescBox: UILabel!
    @IBOutlet weak var linkiconBox: UIImageView!
    @IBOutlet weak var linkUrlBox: UILabel!
    
    @IBOutlet weak var linkUrlBox2: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
