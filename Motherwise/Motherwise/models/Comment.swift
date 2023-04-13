//
//  Comment.swift
//  Motherwise
//
//  Created by Andre on 9/5/20.
//  Copyright © 2020 Motherwise. All rights reserved.
//

import Foundation
import UIKit

class Comment{
    var idx:Int64 = 0
    var post_id:Int64 = 0
    var user:User!
    var comment:String = ""
    var image_url:String = ""
    var video_url:String = ""
    var commented_time:String = ""
    var timestamp:Int64 = 0
    var status:String = ""
    var disp:Int = 0
    
    var parent_comment_id:Int64 = 0
    var parent_comments_view:UIView!
    var parent_comments_stackview:UIStackView!
    
    var key:String = ""
    
    // Reactions
    var likes:Int = 0
    var loves:Int = 0
    var hahas:Int = 0
    var wows:Int = 0
    var sads:Int = 0
    var angrys:Int = 0
    var my_feeling:String = ""
    var reactions:Int = 0
    var comments:Int64 = 0
    var isLiked:Bool = false
}

var gComment = Comment()
