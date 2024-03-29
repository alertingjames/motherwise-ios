//
//  Post.swift
//  Motherwise
//
//  Created by Andre on 9/5/20.
//  Copyright © 2020 Motherwise. All rights reserved.
//

import Foundation

class Post{
    var idx:Int64 = 0
    var user:User!
    var title:String = ""
    var category:String = ""
    var content:String = ""
    var picture_url:String = ""
    var video_url:String = ""
    var link:String = ""
    var comments:Int64 = 0
    var scheduled_time:String = ""
    var posted_time:String = ""
    // Reactions
    var likes:Int = 0
    var loves:Int = 0
    var hahas:Int = 0
    var wows:Int = 0
    var sads:Int = 0
    var angrys:Int = 0
    var my_feeling:String = ""
    var reactions:Int = 0
    
    var isLiked:Bool = false
    var pictures:Int = 0
    var status:String = ""
    var sch_status:String = ""
    var previews = [PostPreview]()
    var comment_list = [Comment]()
}

var gPost:Post = Post()
