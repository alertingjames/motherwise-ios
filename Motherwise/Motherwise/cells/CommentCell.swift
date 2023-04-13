//
//  CommentCell.swift
//  Motherwise
//
//  Created by Andre on 9/5/20.
//  Copyright © 2020 Motherwise. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var contentLayout: UIView!
    @IBOutlet weak var userPicture: UIImageView!
    @IBOutlet weak var userNameBox: UILabel!
    @IBOutlet weak var userCohortBox: UILabel!
    @IBOutlet weak var commentedTimeBox: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var commentBox: UITextView!
    @IBOutlet weak var imageBox: UIImageView!    
    @IBOutlet weak var commentBoxWidth: NSLayoutConstraint!
    @IBOutlet weak var subcommentsView: UIView!
    @IBOutlet weak var subcommentsStackView: UIStackView!
    @IBOutlet weak var reactionButton: ReactionButton!    
    @IBOutlet weak var reactionSummary: ReactionSummary!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var commentsBox: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
