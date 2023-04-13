//
//  PostCell.swift
//  Motherwise
//
//  Created by Andre on 9/5/20.
//  Copyright © 2020 Motherwise. All rights reserved.
//

import UIKit
//import Reactions

class PostCell: UITableViewCell {
    
    @IBOutlet weak var view_content: UIView!
    @IBOutlet weak var img_poster: UIImageView!
    @IBOutlet weak var lbl_poster_name: UILabel!
    @IBOutlet weak var lbl_cohort: UILabel!
    @IBOutlet weak var lbl_post_title: UILabel!
    @IBOutlet weak var lbl_category: UILabel!
    @IBOutlet weak var lbl_posted_time: UILabel!
    @IBOutlet weak var img_post_picture: UIImageView!
    @IBOutlet weak var lbl_comments: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var txv_desc: UITextView!
    @IBOutlet weak var lbl_pics: UILabel!
    @IBOutlet weak var reactionButton: ReactionButton!
    @IBOutlet weak var reactionSummary: ReactionSummary!
    
    @IBOutlet weak var postImageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var linkView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var linkViewH: NSLayoutConstraint!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var commentsView: UIView!
    @IBOutlet weak var commentsStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
