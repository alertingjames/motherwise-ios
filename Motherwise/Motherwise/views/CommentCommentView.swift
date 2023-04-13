//
//  CommentCommentView.swift
//  Motherwise
//
//  Created by james on 4/6/23.
//  Copyright © 2023 VaCay. All rights reserved.
//

import UIKit

class CommentCommentView: UIView {
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
    
}
