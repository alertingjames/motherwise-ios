//
//  FRCell.swift
//  Motherwise
//
//  Created by james on 4/7/23.
//  Copyright © 2023 VaCay. All rights reserved.
//

import UIKit

class FRCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageBox: UIImageView!
    @IBOutlet weak var titleBox: UILabel!
    @IBOutlet weak var subtitleBox: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
