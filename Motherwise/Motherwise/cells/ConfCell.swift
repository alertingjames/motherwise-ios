//
//  ConfCell.swift
//  Motherwise
//
//  Created by Andre on 9/5/20.
//  Copyright © 2020 Motherwise. All rights reserved.
//

import UIKit

class ConfCell: UITableViewCell {
    
    @IBOutlet weak var view_content: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var lbl_conf_name: UILabel!
    @IBOutlet weak var lbl_start_time: UILabel!
    @IBOutlet weak var lbl_created_time: UILabel!
    @IBOutlet weak var lbl_group_name: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
