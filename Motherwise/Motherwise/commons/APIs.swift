//
//  APIs.swift
//  Motherwise
//
//  Created by Andre on 9/5/20.
//  Copyright © 2020 Motherwise. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class APIs {
    
    static func login(email : String, password: String, handleCallback: @escaping (User?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "email":email,
            "password":password
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "login", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                
                NSLog("\(json)")
                
                let result_code = json["result_code"].stringValue
                
                if result_code != nil {
                    
                    if(result_code == "0" || result_code == "1" || result_code == "2"){
                        
                        let data = json["data"].object as! [String: Any]
                        let user = User()
                        user.idx = data["id"] as! Int64
                        user.admin_id = Int64(data["admin_id"] as! String)!
                        user.name = data["name"] as! String
                        user.email = data["email"] as! String
                        user.password = data["password"] as! String
                        user.photo_url = data["photo_url"] as! String
                        user.phone_number = data["phone_number"] as! String
                        user.city = data["city"] as! String
                        user.address = data["address"] as! String
                        user.lat = data["lat"] as! String
                        user.lng = data["lng"] as! String
                        user.cohort = data["cohort"] as! String
                        user.registered_time = data["registered_time"] as! String
                        user.fcm_token = data["fcm_token"] as! String
                        user.status = data["status"] as! String
                        user.status2 = data["status2"] as! String
                        
                        handleCallback(user, result_code)
                    
                    }else{
                        handleCallback(nil, result_code)
                    }
                }else{
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    
    func registerWithPicture(withUrl strURL: String,withParam postParam: Dictionary<String, Any>,withImages imageArray:NSMutableArray,completion:@escaping (_ isSuccess: Bool, _ response:NSDictionary) -> Void)
    {
        
        Alamofire.upload(multipartFormData: { (MultipartFormData) in
            
            // Here is your Image Array
            for (imageDic) in imageArray
            {
                let imageDic = imageDic as! NSDictionary
                
                for (key,valus) in imageDic
                {
                    MultipartFormData.append(valus as! Data, withName:key as! String, fileName: String(NSDate().timeIntervalSince1970) + ".jpg", mimeType: "image/jpg")
                }
            }
            
            // Here is your Post paramaters
            for (key, value) in postParam
            {
                MultipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
            
        }, usingThreshold: UInt64.init(), to: strURL, method: .post) { (result) in
            
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    
                    if response.response?.statusCode == 200
                    {
                        let json = response.result.value as? NSDictionary
                        
                        completion(true,json!);
                    }
                    else
                    {
                        completion(false,[:]);
                    }
                }
                
            case .failure(let encodingError):
                print(encodingError)
                
                completion(false,[:]);
            }
            
        }
    }
    
    func registerWithoutPicture(withUrl strURL: String,withParam postParam: Dictionary<String, Any>,completion:@escaping (_ isSuccess: Bool, _ response:NSDictionary) -> Void)
    {
        
        Alamofire.upload(multipartFormData: { (MultipartFormData) in
            
            // Here is your Post paramaters
            for (key, value) in postParam
            {
                MultipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
            
        }, usingThreshold: UInt64.init(), to: strURL, method: .post) { (result) in
            
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    
                    if response.response?.statusCode == 200
                    {
                        let json = response.result.value as? NSDictionary
                        
                        completion(true,json!);
                    }
                    else
                    {
                        completion(false,[:]);
                    }
                }
                
            case .failure(let encodingError):
                print(encodingError)
                
                completion(false,[:]);
            }
            
        }
    }
    
    static func forgotPassword(email : String, handleCallback: @escaping (String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "email":email
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "forgotpassword", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                if(json["result_code"].stringValue == "0"){
                    handleCallback("0")
                }
                else if(json["result_code"].stringValue == "1"){
                    handleCallback("1")
                }else{
                    handleCallback("Server issue")
                }
                
            }
        }
    }
    
    static func addLocation(member_id:Int64, address:String, city:String, lat:String, lng:String, handleCallback: @escaping (User?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "member_id":String(member_id),
            "address":address,
            "city":city,
            "lat":lat,
            "lng":lng
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "addlocation", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("Add Location Result!!!\(json)")
                let result_code = json["result_code"].stringValue
                
                if result_code != nil {
                    
                    if(result_code == "0"){
                        
                        let data = json["data"].object as! [String: Any]
                        let user = User()
                        user.idx = data["id"] as! Int64
                        user.admin_id = Int64(data["admin_id"] as! String)!
                        user.name = data["name"] as! String
                        user.email = data["email"] as! String
                        user.password = data["password"] as! String
                        user.photo_url = data["photo_url"] as! String
                        user.phone_number = data["phone_number"] as! String
                        user.city = data["city"] as! String
                        user.address = data["address"] as! String
                        user.lat = data["lat"] as! String
                        user.lng = data["lng"] as! String
                        user.cohort = data["cohort"] as! String
                        user.registered_time = data["registered_time"] as! String
                        user.fcm_token = data["fcm_token"] as! String
                        user.status = data["status"] as! String
                        user.status2 = data["status2"] as! String
                        
                        handleCallback(user, result_code)
                    
                    }else{
                        handleCallback(nil, result_code)
                    }
                }else{
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    static func registerFCMToken(member_id:Int64, token:String, handleCallback: @escaping (String, String) -> ())
    {
        //NSLog(url)
        let params = [
            "fcm_token":token,
            "member_id": String(member_id),
            ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "uploadfcmtoken", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("", "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                if(json["result_code"].stringValue == "0"){
                    handleCallback(json["fcm_token"].stringValue, "0")
                }else {
                    handleCallback("", "Server issue")
                }
            }
        }
    }
    
    static func getHomeData(member_id: Int64, handleCallback: @escaping ([User]?, [Group]?, User?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "member_id":String(member_id)
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "home", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, nil, nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                let result_code = json["result_code"].stringValue
                if(result_code == "0"){
                    var users = [User]()
                    var groups = [Group]()
                    
                    var dataArray = json["users"].arrayObject as! [[String: Any]]
                    for data in dataArray{
                        let user = User()
                        user.idx = data["id"] as! Int64
                        user.admin_id = Int64(data["admin_id"] as! String)!
                        user.name = data["name"] as! String
                        user.email = data["email"] as! String
                        user.password = data["password"] as! String
                        user.photo_url = data["photo_url"] as! String
                        user.phone_number = data["phone_number"] as! String
                        user.city = data["city"] as! String
                        user.address = data["address"] as! String
                        user.lat = data["lat"] as! String
                        user.lng = data["lng"] as! String
                        user.cohort = data["cohort"] as! String
                        user.registered_time = data["registered_time"] as! String
                        user.fcm_token = data["fcm_token"] as! String
                        user.status = data["status"] as! String
                        user.status2 = data["status2"] as! String
                        
                        users.append(user)
                    }
                    
                    dataArray = json["groups"].arrayObject as! [[String: Any]]
                    for data in dataArray{
                        let group = Group()
                        group.idx = data["id"] as! Int64
                        group.user_id = Int64(data["member_id"] as! String)!
                        group.name = data["name"] as! String
                        group.member_count = Int64(data["member_count"] as! String)!
                        group.code = data["code"] as! String
                        group.color = data["color"] as! String
                        group.created_time = data["created_time"] as! String
                        group.last_connected_time = data["last_connected_time"] as! String
                        group.status = data["status"] as! String
                        
                        groups.append(group)
                    }
                    
                    let data = json["admin"].object as! [String: Any]
                    let user = User()
                    user.idx = data["id"] as! Int64
                    user.admin_id = Int64(data["admin_id"] as! String)!
                    user.name = data["name"] as! String
                    user.email = data["email"] as! String
                    user.password = data["password"] as! String
                    user.photo_url = data["photo_url"] as! String
                    user.phone_number = data["phone_number"] as! String
                    user.city = data["city"] as! String
                    user.address = data["address"] as! String
                    user.lat = data["lat"] as! String
                    user.lng = data["lng"] as! String
                    user.cohort = data["cohort"] as! String
                    user.registered_time = data["registered_time"] as! String
                    user.fcm_token = data["fcm_token"] as! String
                    user.status = data["status"] as! String
                    user.status2 = data["status2"] as! String
                    
                    handleCallback(users, groups, user, "0")
                    
                }else if result_code == "1" || result_code == "2"{
                    handleCallback(nil, nil, nil, result_code)
                }
                else{
                    handleCallback(nil, nil, nil, "Server issue")
                }
                
            }
        }
    }
    
    static func sendUserMessage(me_id:Int64, member_id:Int64, message:String, handleCallback: @escaping (String) -> ())
    {
        //NSLog(url)
        let params = [
            "me_id": String(me_id),
            "member_id": String(member_id),
            "message": message
            ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "sendmembermessage", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("SEND MESSAGE response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    handleCallback(result_code)
                }else {
                    handleCallback("Server issue")
                }
            }
        }
    }
    
    static func sendMessageToSelecteds(me_id:Int64, members:String, message:String, handleCallback: @escaping (String) -> ())
    {
        //NSLog(url)
        let params = [
            "me_id": String(me_id),
            "members": members,
            "message": message
            ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "messageselecteds", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("SEND MESSAGE response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    handleCallback(result_code)
                }else {
                    handleCallback("Server issue")
                }
            }
        }
    }
    
    
    static func getPosts(member_id: Int64, handleCallback: @escaping ([Post]?, [User]?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "member_id":String(member_id)
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "networkposts", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
//                NSLog("\(json)")
                let result_code = json["result_code"].stringValue
                if(result_code == "0"){
                    var posts = [Post]()
                    var users = [User]()
                    
                    var dataArray = json["users"].arrayObject as! [[String: Any]]
                    for data in dataArray{
                        let user = User()
                        user.idx = data["id"] as! Int64
                        user.admin_id = Int64(data["admin_id"] as! String)!
                        user.name = data["name"] as! String
                        user.email = data["email"] as! String
                        user.password = data["password"] as! String
                        user.photo_url = data["photo_url"] as! String
                        user.phone_number = data["phone_number"] as! String
                        user.city = data["city"] as! String
                        user.address = data["address"] as! String
                        user.lat = data["lat"] as! String
                        user.lng = data["lng"] as! String
                        user.cohort = data["cohort"] as! String
                        user.registered_time = data["registered_time"] as! String
                        user.fcm_token = data["fcm_token"] as! String
                        user.username = data["username"] as! String
                        user.status = data["status"] as! String
                        user.status2 = data["status2"] as! String
                        
                        users.append(user)
                    }
                    
                    dataArray = json["posts"].arrayObject as! [[String: Any]]
                    for data in dataArray{
                        
                        let json = JSON(data)
                        
                        var data = json["post"].object as! [String: Any]
                        let post = Post()
                        post.idx = data["id"] as! Int64
                        post.title = data["title"] as! String
                        post.category = data["category"] as! String
                        post.content = data["content"] as! String
                        post.picture_url = data["picture_url"] as! String
                        // Reactions
                        post.likes = (data["likes"] as! String).count > 0 ? Int(data["likes"] as! String)! : 0
                        post.loves = (data["loves"] as! String).count > 0 ? Int(data["loves"] as! String)! : 0
                        post.hahas = (data["haha"] as! String).count > 0 ? Int(data["haha"] as! String)! : 0
                        post.wows = (data["wow"] as! String).count > 0 ? Int(data["wow"] as! String)! : 0
                        post.sads = (data["sad"] as! String).count > 0 ? Int(data["sad"] as! String)! : 0
                        post.angrys = (data["angry"] as! String).count > 0 ? Int(data["angry"] as! String)! : 0
                        post.reactions = (data["reactions"] as! String).count > 0 ? Int(data["reactions"] as! String)! : 0
                        post.my_feeling = data["liked"] as! String
                        
                        post.comments = Int64(data["comments"] as! String)!
                        post.scheduled_time = data["scheduled_time"] as! String
                        post.posted_time = data["posted_time"] as! String
                        if data["liked"] as! String == "yes"{
                            post.isLiked = true
                        }else {
                            post.isLiked = false
                        }
                        post.status = data["status"] as! String
                        post.sch_status = data["sch_status"] as! String
                        
                        
                        data = json["member"].object as! [String: Any]
                        let user = User()
                        user.idx = data["id"] as! Int64
                        user.admin_id = Int64(data["admin_id"] as! String)!
                        user.name = data["name"] as! String
                        user.email = data["email"] as! String
                        user.password = data["password"] as! String
                        user.photo_url = data["photo_url"] as! String
                        user.phone_number = data["phone_number"] as! String
                        user.city = data["city"] as! String
                        user.address = data["address"] as! String
                        user.lat = data["lat"] as! String
                        user.lng = data["lng"] as! String
                        user.cohort = data["cohort"] as! String
                        user.registered_time = data["registered_time"] as! String
                        user.fcm_token = data["fcm_token"] as! String
                        user.status = data["status"] as! String
                        user.status2 = data["status2"] as! String
                        
                        post.user = user
                        
                        let pics = json["pics"].stringValue
                        let pic_count = Int(pics)
                        
                        post.pictures = pic_count!
                        
                        var prevs = [PostPreview]()
                        let prevJsonArray = json["prevs"].arrayObject as! [[String: Any]]
                        for prevdata in prevJsonArray{
                            let prev = PostPreview()
                            prev.idx = prevdata["id"] as! Int64
                            prev.post_id = Int64(prevdata["post_id"] as! String)!
                            prev.title = prevdata["title"] as! String
                            prev.description = prevdata["description"] as! String
                            prev.image_url = prevdata["image_url"] as! String
                            prev.icon_url = prevdata["icon_url"] as! String
                            prev.site_url = prevdata["site_url"] as! String
                            prevs.append(prev)
                        }
                        post.previews = prevs
                        
                        var comments = [Comment]()
                        let commentJsonArray = json["comments"].arrayObject as! [[String: Any]]
                        for commentObj in commentJsonArray {
                            var cdata = commentObj["comment"] as! [String: Any]
                            let comment = Comment()
                            comment.idx = cdata["id"] as! Int64
                            comment.post_id = Int64(cdata["post_id"] as! String)!
                            comment.comment = cdata["comment_text"] as! String
                            
                            var udata = commentObj["commented_member"] as! [String: Any]
                            let user = User()
                            user.idx = udata["id"] as! Int64
                            user.admin_id = Int64(udata["admin_id"] as! String)!
                            user.name = udata["name"] as! String
                            user.photo_url = udata["photo_url"] as! String
                            comment.user = user                            
                            comments.append(comment)
                        }
                        post.comment_list = comments
                        
                        posts.append(post)
                    }
                    
                    handleCallback(posts, users, "0")
                    
                }else if result_code == "1" {
                    handleCallback(nil, nil, result_code)
                }
                else{
                    handleCallback(nil, nil, "Server issue")
                }
                
            }
        }
    }
    
    
    static func getpostcategories(admin_id:Int64, handleCallback: @escaping (String?, String?, String) -> ())
    {
        //NSLog(url)
        let params = [
            "admin_id": String(admin_id),
            ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "upostcategories", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("", "", "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("Post Categories response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    if result_code == "0" {
                        let us_categories = json["us_categories"].stringValue
                        let es_categories = json["es_categories"].stringValue
                        handleCallback(us_categories, es_categories, result_code)
                    }else { handleCallback("", "", "server issue") }
                }else {
                    handleCallback("", "", "Server issue")
                }
            }
        }
    }
    
    
    static func getUserPosts(me_id: Int64, member_id: Int64, handleCallback: @escaping (Int, [Post]?, [User]?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "member_id":String(member_id),
            "me_id":String(me_id)
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "userposts", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(0, nil, nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                let total_posts = json["total_posts"].stringValue
                let result_code = json["result_code"].stringValue
                if(result_code == "0"){
                    var posts = [Post]()
                    var users = [User]()
                    
                    var dataArray = json["users"].arrayObject as! [[String: Any]]
                    for data in dataArray{
                        let user = User()
                        user.idx = data["id"] as! Int64
                        user.admin_id = Int64(data["admin_id"] as! String)!
                        user.name = data["name"] as! String
                        user.email = data["email"] as! String
                        user.password = data["password"] as! String
                        user.photo_url = data["photo_url"] as! String
                        user.phone_number = data["phone_number"] as! String
                        user.city = data["city"] as! String
                        user.address = data["address"] as! String
                        user.lat = data["lat"] as! String
                        user.lng = data["lng"] as! String
                        user.cohort = data["cohort"] as! String
                        user.registered_time = data["registered_time"] as! String
                        user.fcm_token = data["fcm_token"] as! String
                        user.username = data["username"] as! String
                        user.status = data["status"] as! String
                        user.status2 = data["status2"] as! String
                        
                        users.append(user)
                    }
                    
                    dataArray = json["posts"].arrayObject as! [[String: Any]]
                    for data in dataArray{
                        
                        let json = JSON(data)
                        
                        var data = json["post"].object as! [String: Any]
                        let post = Post()
                        post.idx = data["id"] as! Int64
                        post.title = data["title"] as! String
                        post.category = data["category"] as! String
                        post.content = data["content"] as! String
                        post.picture_url = data["picture_url"] as! String
                        // Reactions
                        post.likes = (data["likes"] as! String).count > 0 ? Int(data["likes"] as! String)! : 0
                        post.loves = (data["loves"] as! String).count > 0 ? Int(data["loves"] as! String)! : 0
                        post.hahas = (data["haha"] as! String).count > 0 ? Int(data["haha"] as! String)! : 0
                        post.wows = (data["wow"] as! String).count > 0 ? Int(data["wow"] as! String)! : 0
                        post.sads = (data["sad"] as! String).count > 0 ? Int(data["sad"] as! String)! : 0
                        post.angrys = (data["angry"] as! String).count > 0 ? Int(data["angry"] as! String)! : 0
                        post.reactions = (data["reactions"] as! String).count > 0 ? Int(data["reactions"] as! String)! : 0
                        post.my_feeling = data["liked"] as! String
                        
                        post.comments = Int64(data["comments"] as! String)!
                        post.scheduled_time = data["scheduled_time"] as! String
                        post.posted_time = data["posted_time"] as! String
                        if data["liked"] as! String == "yes"{
                            post.isLiked = true
                        }else {
                            post.isLiked = false
                        }
                        post.status = data["status"] as! String
                        post.sch_status = data["sch_status"] as! String
                        
                        
                        data = json["member"].object as! [String: Any]
                        let user = User()
                        user.idx = data["id"] as! Int64
                        user.admin_id = Int64(data["admin_id"] as! String)!
                        user.name = data["name"] as! String
                        user.email = data["email"] as! String
                        user.password = data["password"] as! String
                        user.photo_url = data["photo_url"] as! String
                        user.phone_number = data["phone_number"] as! String
                        user.city = data["city"] as! String
                        user.address = data["address"] as! String
                        user.lat = data["lat"] as! String
                        user.lng = data["lng"] as! String
                        user.cohort = data["cohort"] as! String
                        user.registered_time = data["registered_time"] as! String
                        user.fcm_token = data["fcm_token"] as! String
                        user.status = data["status"] as! String
                        user.status2 = data["status2"] as! String
                        
                        post.user = user
                        
                        let pics = json["pics"].stringValue
                        let pic_count = Int(pics)
                        
                        post.pictures = pic_count!
                        
                        var prevs = [PostPreview]()
                        let prevJsonArray = json["prevs"].arrayObject as! [[String: Any]]
                        for prevdata in prevJsonArray{
                            let prev = PostPreview()
                            prev.idx = prevdata["id"] as! Int64
                            prev.post_id = Int64(prevdata["post_id"] as! String)!
                            prev.title = prevdata["title"] as! String
                            prev.description = prevdata["description"] as! String
                            prev.image_url = prevdata["image_url"] as! String
                            prev.icon_url = prevdata["icon_url"] as! String
                            prev.site_url = prevdata["site_url"] as! String
                            prevs.append(prev)
                        }
                        post.previews = prevs
                        
                        var comments = [Comment]()
                        let commentJsonArray = json["comments"].arrayObject as! [[String: Any]]
                        for commentObj in commentJsonArray {
                            var cdata = commentObj["comment"] as! [String: Any]
                            let comment = Comment()
                            comment.idx = cdata["id"] as! Int64
                            comment.post_id = Int64(cdata["post_id"] as! String)!
                            comment.comment = cdata["comment_text"] as! String
                            
                            var udata = commentObj["commented_member"] as! [String: Any]
                            let user = User()
                            user.idx = udata["id"] as! Int64
                            user.admin_id = Int64(udata["admin_id"] as! String)!
                            user.name = udata["name"] as! String
                            user.photo_url = udata["photo_url"] as! String
                            comment.user = user
                            comments.append(comment)
                        }
                        post.comment_list = comments
                        
                        posts.append(post)
                    }
                    
                    handleCallback(Int(total_posts)!, posts, users, "0")
                    
                }else if result_code == "1" {
                    handleCallback(0, nil, nil, result_code)
                }
                else{
                    handleCallback(0, nil, nil, "Server issue")
                }
                
            }
        }
    }
    
    
    static func likePost(member_id:Int64, post_id:Int64, handleCallback: @escaping (String, String) -> ())
    {
        //NSLog(url)
        let params = [
            "member_id": String(member_id),
            "post_id": String(post_id),
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "likepost", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("", "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("SEND MESSAGE response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    if result_code == "0"{
                        let likes = json["likes"].stringValue
                        handleCallback(likes, result_code)
                    }else{
                        handleCallback("", result_code)
                    }
                    
                }else {
                    handleCallback("", "Server issue")
                }
            }
        }
    }
    
    
    static func reactPost(member_id:Int64, post_id:Int64, feeling:String, handleCallback: @escaping (Post?, String) -> ())
    {
        let params = [
            "member_id": String(member_id),
            "post_id": String(post_id),
            "feeling": feeling,
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "react_post", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure {
                handleCallback(nil, "Server issue")
            } else {
                let json = JSON(response.result.value!)
                NSLog("React post response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    if result_code == "0"{
                        var data = json["post"].object as! [String: Any]
                        let post = Post()
                        post.idx = data["id"] as! Int64
                        post.title = data["title"] as! String
                        post.category = data["category"] as! String
                        post.content = data["content"] as! String
                        post.picture_url = data["picture_url"] as! String
                        // Reactions
                        post.likes = (data["likes"] as! String).count > 0 ? Int(data["likes"] as! String)! : 0
                        post.loves = (data["loves"] as! String).count > 0 ? Int(data["loves"] as! String)! : 0
                        post.hahas = (data["haha"] as! String).count > 0 ? Int(data["haha"] as! String)! : 0
                        post.wows = (data["wow"] as! String).count > 0 ? Int(data["wow"] as! String)! : 0
                        post.sads = (data["sad"] as! String).count > 0 ? Int(data["sad"] as! String)! : 0
                        post.angrys = (data["angry"] as! String).count > 0 ? Int(data["angry"] as! String)! : 0
                        post.reactions = (data["reactions"] as! String).count > 0 ? Int(data["reactions"] as! String)! : 0
                        post.my_feeling = data["liked"] as! String
                        
                        post.comments = Int64(data["comments"] as! String)!
                        post.scheduled_time = data["scheduled_time"] as! String
                        post.posted_time = data["posted_time"] as! String
                        if data["liked"] as! String == "yes"{
                            post.isLiked = true
                        }else {
                            post.isLiked = false
                        }
                        post.status = data["status"] as! String
                        post.sch_status = data["sch_status"] as! String
                        handleCallback(post, result_code)
                    }else{
                        handleCallback(nil, result_code)
                    }
                }else {
                    handleCallback(nil, "Server issue")
                }
            }
        }
    }
    
    
    static func getComments(post_id: Int64, member_id: Int64, handleCallback: @escaping ([Comment]?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "post_id":String(post_id),
            "member_id":String(member_id),
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "getcomments", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                let result_code = json["result_code"].stringValue
                if(result_code == "0"){
                    var comments = [Comment]()
                    
                    let dataArray = json["data"].arrayObject as! [[String: Any]]
                    
                    for data in dataArray{
                        
                        let json = JSON(data)
                        
                        var data = json["comment"].object as! [String: Any]
                        let comment = Comment()
                        comment.idx = data["id"] as! Int64
                        comment.post_id = Int64(data["post_id"] as! String)!
                        comment.comment = data["comment_text"] as! String
                        comment.image_url = data["image_url"] as! String
                        comment.commented_time = data["commented_time"] as! String
                        comment.status = data["status"] as! String
                        
                        // Reactions
                        comment.likes = (data["likes"] as! String).count > 0 ? Int(data["likes"] as! String)! : 0
                        comment.loves = (data["loves"] as! String).count > 0 ? Int(data["loves"] as! String)! : 0
                        comment.hahas = (data["haha"] as! String).count > 0 ? Int(data["haha"] as! String)! : 0
                        comment.wows = (data["wow"] as! String).count > 0 ? Int(data["wow"] as! String)! : 0
                        comment.sads = (data["sad"] as! String).count > 0 ? Int(data["sad"] as! String)! : 0
                        comment.angrys = (data["angry"] as! String).count > 0 ? Int(data["angry"] as! String)! : 0
                        comment.reactions = (data["reactions"] as! String).count > 0 ? Int(data["reactions"] as! String)! : 0
                        comment.my_feeling = data["liked"] as! String
                        comment.comments = Int64(data["comments"] as! String)!
                        
                        data = json["member"].object as! [String: Any]
                        let user = User()
                        user.idx = data["id"] as! Int64
                        user.admin_id = Int64(data["admin_id"] as! String)!
                        user.name = data["name"] as! String
                        user.email = data["email"] as! String
                        user.password = data["password"] as! String
                        user.photo_url = data["photo_url"] as! String
                        user.phone_number = data["phone_number"] as! String
                        user.city = data["city"] as! String
                        user.address = data["address"] as! String
                        user.lat = data["lat"] as! String
                        user.lng = data["lng"] as! String
                        user.cohort = data["cohort"] as! String
                        user.registered_time = data["registered_time"] as! String
                        user.fcm_token = data["fcm_token"] as! String
                        user.status = data["status"] as! String
                        user.status2 = data["status2"] as! String
                        
                        comment.user = user
                        
                        comments.append(comment)
                    }
                    
                    handleCallback(comments, "0")
                    
                }else if result_code == "1" {
                    handleCallback(nil, result_code)
                }
                else{
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    
    static func reactComment(member_id:Int64, comment_id:Int64, feeling:String, handleCallback: @escaping (Comment?, String) -> ())
    {
        let params = [
            "member_id": String(member_id),
            "comment_id": String(comment_id),
            "feeling": feeling,
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "react_comment", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure {
                handleCallback(nil, "Server issue")
            } else {
                let json = JSON(response.result.value!)
                NSLog("React comment response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    if result_code == "0"{
                        var data = json["comment"].object as! [String: Any]
                        let comment = Comment()
                        comment.idx = data["id"] as! Int64
                        comment.post_id = Int64(data["post_id"] as! String)!
                        comment.comment = data["comment_text"] as! String
                        comment.image_url = data["image_url"] as! String
                        comment.commented_time = data["commented_time"] as! String
                        comment.status = data["status"] as! String
                        
                        // Reactions
                        comment.likes = (data["likes"] as! String).count > 0 ? Int(data["likes"] as! String)! : 0
                        comment.loves = (data["loves"] as! String).count > 0 ? Int(data["loves"] as! String)! : 0
                        comment.hahas = (data["haha"] as! String).count > 0 ? Int(data["haha"] as! String)! : 0
                        comment.wows = (data["wow"] as! String).count > 0 ? Int(data["wow"] as! String)! : 0
                        comment.sads = (data["sad"] as! String).count > 0 ? Int(data["sad"] as! String)! : 0
                        comment.angrys = (data["angry"] as! String).count > 0 ? Int(data["angry"] as! String)! : 0
                        comment.reactions = (data["reactions"] as! String).count > 0 ? Int(data["reactions"] as! String)! : 0
                        comment.my_feeling = data["liked"] as! String
                        comment.comments = Int64(data["comments"] as! String)!
                        
                        handleCallback(comment, result_code)
                    }else{
                        handleCallback(nil, result_code)
                    }
                }else {
                    handleCallback(nil, "Server issue")
                }
            }
        }
    }
    
    
    static func deletePost(post_id:Int64, handleCallback: @escaping (String) -> ())
    {
        //NSLog(url)
        let params = [
            "post_id": String(post_id),
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "deletepost", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("SEND MESSAGE response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    handleCallback(result_code)
                }else {
                    handleCallback("Server issue")
                }
            }
        }
    }
    
    static func deleteComment(comment_id:Int64, handleCallback: @escaping (String) -> ())
    {
        //NSLog(url)
        let params = [
            "comment_id": String(comment_id),
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "deletecomment", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("SEND MESSAGE response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    handleCallback(result_code)
                }else {
                    handleCallback("Server issue")
                }
            }
        }
    }
    
    static func getPostPictures(post_id: Int64, handleCallback: @escaping ([PostPicture]?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "post_id":String(post_id)
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "getpostpictures", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                let result_code = json["result_code"].stringValue
                if(result_code == "0"){
                    var pics = [PostPicture]()
                    
                    let dataArray = json["data"].arrayObject as! [[String: Any]]
                    
                    for data in dataArray{
                        
                        let pic = PostPicture()
                        pic.idx = data["id"] as! Int64
                        pic.post_id = Int64(data["post_id"] as! String)!
                        pic.image_url = data["picture_url"] as! String
                        
                        pics.append(pic)
                    }
                    
                    handleCallback(pics, "0")
                    
                }
                else{
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    
    func postImageArrayRequestWithURL(withUrl strURL: String,withParam postParam: Dictionary<String, Any>,withImages imageArray:NSMutableArray,completion:@escaping (_ isSuccess: Bool, _ response:NSDictionary) -> Void)
    {
        
        Alamofire.upload(multipartFormData: { (MultipartFormData) in
            
            // Here is your Image Array
            for image in imageArray
            {
                let imageData = image as! Data
                
                MultipartFormData.append(imageData, withName:"file" + String(imageArray.index(of: image)), fileName: String(NSDate().timeIntervalSince1970) + ".jpg", mimeType: "image/jpg")
            }
            
            // Here is your Post paramaters
            for (key, value) in postParam
            {
                MultipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
            
        }, usingThreshold: UInt64.init(), to: strURL, method: .post) { (result) in
            
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    
                    if response.response?.statusCode == 200
                    {
                        let json = response.result.value as? NSDictionary
                        
                        completion(true,json!);
                    }
                    else
                    {
                        completion(false,[:]);
                    }
                }
                
            case .failure(let encodingError):
                print(encodingError)
                
                completion(false,[:]);
            }
            
        }
    }
    
    static func deletePostPicture(picture_id:Int64, post_id:Int64, handleCallback: @escaping (String) -> ())
    {
        //NSLog(url)
        let params = [
            "picture_id": String(picture_id),
            "post_id": String(post_id)
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "delpostpicture", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("SEND MESSAGE response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    handleCallback(result_code)
                }else {
                    handleCallback("Server issue")
                }
            }
        }
    }
    
    
    static func getLikes(post_id: Int64, handleCallback: @escaping ([User]?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "post_id":String(post_id)
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "getlikes", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                let result_code = json["result_code"].stringValue
                if(result_code == "0"){
                    var users = [User]()
                    
                    var dataArray = json["data"].arrayObject as! [[String: Any]]
                    for data in dataArray{
                        let user = User()
                        user.idx = data["id"] as! Int64
                        user.admin_id = Int64(data["admin_id"] as! String)!
                        user.name = data["name"] as! String
                        user.email = data["email"] as! String
                        user.password = data["password"] as! String
                        user.photo_url = data["photo_url"] as! String
                        user.phone_number = data["phone_number"] as! String
                        user.city = data["city"] as! String
                        user.address = data["address"] as! String
                        user.lat = data["lat"] as! String
                        user.lng = data["lng"] as! String
                        user.cohort = data["cohort"] as! String
                        user.post_feeling = data["post_feeling"] as! String
                        user.registered_time = data["registered_time"] as! String
                        user.fcm_token = data["fcm_token"] as! String
                        user.status = data["status"] as! String
                        user.status2 = data["status2"] as! String
                        
                        users.append(user)
                    }
                    
                    handleCallback(users, "0")
                    
                }else if result_code == "1" {
                    handleCallback(nil, result_code)
                }
                else{
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    
    static func getReceivedMessages(member_id: Int64, handleCallback: @escaping ([Message]?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "member_id":String(member_id)
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "getreceivedmessages", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                let result_code = json["result_code"].stringValue
                if(result_code == "0"){
                    var messages = [Message]()
                    
                    let dataArray = json["data"].arrayObject as! [[String: Any]]
                    
                    for data in dataArray{
                        
                        let json = JSON(data)
                        
                        var data = json["noti"].object as! [String: Any]
                        let message = Message()
                        message.idx = data["id"] as! Int64
                        message.user_id = Int64(data["member_id"] as! String)!
                        message.message = data["message"] as! String
                        message.messaged_time = data["notified_time"] as! String
                        message.status = data["status"] as! String
                        
                        
                        data = json["sender"].object as! [String: Any]
                        let user = User()
                        user.idx = data["id"] as! Int64
                        user.admin_id = Int64(data["admin_id"] as! String)!
                        user.name = data["name"] as! String
                        user.email = data["email"] as! String
                        user.password = data["password"] as! String
                        user.photo_url = data["photo_url"] as! String
                        user.phone_number = data["phone_number"] as! String
                        user.city = data["city"] as! String
                        user.address = data["address"] as! String
                        user.lat = data["lat"] as! String
                        user.lng = data["lng"] as! String
                        user.cohort = data["cohort"] as! String
                        user.registered_time = data["registered_time"] as! String
                        user.fcm_token = data["fcm_token"] as! String
                        user.status = data["status"] as! String
                        user.status2 = data["status2"] as! String
                        
                        message.sender = user
                        
                        messages.append(message)
                    }
                    
                    handleCallback(messages, "0")
                    
                }else if result_code == "1" {
                    handleCallback(nil, result_code)
                }
                else{
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    static func deleteMessage(message_id:Int64, option:String, handleCallback: @escaping (String) -> ())
    {
        //NSLog(url)
        let params = [
            "message_id": String(message_id),
            "option": option
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "delmessage", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("SEND MESSAGE response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    handleCallback(result_code)
                }else {
                    handleCallback("Server issue")
                }
            }
        }
    }
    
    static func processNewMessage(message_id:Int64, handleCallback: @escaping (String) -> ())
    {
        //NSLog(url)
        let params = [
            "message_id": String(message_id)
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "processnewmessage", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("SEND MESSAGE response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    handleCallback(result_code)
                }else {
                    handleCallback("Server issue")
                }
            }
        }
    }
    
    
    static func getSentMessages(member_id: Int64, handleCallback: @escaping ([Message]?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "member_id":String(member_id)
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "getsentmessages", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                let result_code = json["result_code"].stringValue
                if(result_code == "0"){
                    var messages = [Message]()
                    
                    let dataArray = json["data"].arrayObject as! [[String: Any]]
                    
                    for data in dataArray{
                        
                        let json = JSON(data)
                        
                        var data = json["noti"].object as! [String: Any]
                        let message = Message()
                        message.idx = data["id"] as! Int64
                        message.user_id = Int64(data["member_id"] as! String)!
                        message.message = data["message"] as! String
                        message.messaged_time = data["notified_time"] as! String
                        message.status = data["status"] as! String
                        
                        
                        data = json["sender"].object as! [String: Any]
                        let user = User()
                        user.idx = data["id"] as! Int64
                        user.admin_id = Int64(data["admin_id"] as! String)!
                        user.name = data["name"] as! String
                        user.email = data["email"] as! String
                        user.password = data["password"] as! String
                        user.photo_url = data["photo_url"] as! String
                        user.phone_number = data["phone_number"] as! String
                        user.city = data["city"] as! String
                        user.address = data["address"] as! String
                        user.lat = data["lat"] as! String
                        user.lng = data["lng"] as! String
                        user.cohort = data["cohort"] as! String
                        user.registered_time = data["registered_time"] as! String
                        user.fcm_token = data["fcm_token"] as! String
                        user.status = data["status"] as! String
                        user.status2 = data["status2"] as! String
                        
                        message.sender = user
                        
                        messages.append(message)
                    }
                    
                    handleCallback(messages, "0")
                    
                }else if result_code == "1" {
                    handleCallback(nil, result_code)
                }
                else{
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    static func replyMessage(me_id:Int64, member_id:Int64, message_id:Int64, message:String, handleCallback: @escaping (String) -> ())
    {
        //NSLog(url)
        let params = [
            "me_id": String(me_id),
            "member_id" : String(member_id),
            "message_id": String(message_id),
            "message" : message
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "replymessage", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("SEND MESSAGE response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    handleCallback(result_code)
                }else {
                    handleCallback("Server issue")
                }
            }
        }
    }
    
    
    static func getMessageHistory(message_id: Int64, handleCallback: @escaping ([Message]?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "message_id":String(message_id)
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "messagehistory", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                let result_code = json["result_code"].stringValue
                if(result_code == "0"){
                    var messages = [Message]()
                    
                    let dataArray = json["data"].arrayObject as! [[String: Any]]
                    
                    for data in dataArray{
                        
                        let json = JSON(data)
                        
                        var data = json["noti"].object as! [String: Any]
                        let message = Message()
                        message.idx = data["id"] as! Int64
                        message.user_id = Int64(data["member_id"] as! String)!
                        message.message = data["message"] as! String
                        message.messaged_time = data["notified_time"] as! String
                        message.status = data["status"] as! String
                        
                        
                        data = json["sender"].object as! [String: Any]
                        let user = User()
                        user.idx = data["id"] as! Int64
                        user.admin_id = Int64(data["admin_id"] as! String)!
                        user.name = data["name"] as! String
                        user.email = data["email"] as! String
                        user.password = data["password"] as! String
                        user.photo_url = data["photo_url"] as! String
                        user.phone_number = data["phone_number"] as! String
                        user.city = data["city"] as! String
                        user.address = data["address"] as! String
                        user.lat = data["lat"] as! String
                        user.lng = data["lng"] as! String
                        user.cohort = data["cohort"] as! String
                        user.registered_time = data["registered_time"] as! String
                        user.fcm_token = data["fcm_token"] as! String
                        user.status = data["status"] as! String
                        user.status2 = data["status2"] as! String
                        
                        message.sender = user
                        
                        messages.append(message)
                    }
                    
                    handleCallback(messages, "0")
                    
                }else {
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    
    static func getUnreadCount(me_id:Int64, handleCallback: @escaping (String, String) -> ())
    {
        //NSLog(url)
        let params = [
            "me_id": String(me_id)
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "newnotis", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("", "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("SEND MESSAGE response: \(json)")
                let result_code = json["result_code"].stringValue
                let unreads = json["unreads"].stringValue
                if result_code != nil{
                    handleCallback(unreads, result_code)
                }else {
                    handleCallback("", "Server issue")
                }
            }
        }
    }
    
    
    static func getConferences(member_id: Int64, handleCallback: @escaping ([Conference]?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "me_id":String(member_id)
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "getconfs", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                let result_code = json["result_code"].stringValue
                if(result_code == "0"){
                    var confs = [Conference]()
                    
                    var dataArray = json["data"].arrayObject as! [[String: Any]]
                    for data in dataArray{
                        let conf = Conference()
                        conf.idx = data["id"] as! Int64
                        conf.user_id = Int64(data["member_id"] as! String)!
                        var gid = data["group_id"] as! String
                        if gid == ""{
                            gid = "0"
                        }
                        conf.group_id = Int64(gid)!
                        conf.name = data["name"] as! String
                        conf.cohort = data["cohort"] as! String
                        conf.code = data["code"] as! String
                        conf.type = data["type"] as! String
                        conf.video_url = data["video_url"] as! String
                        conf.participants = Int64(data["participants"] as! String)!
                        conf.event_time = data["event_time"] as! String
                        conf.created_time = data["created_time"] as! String
                        conf.duration = data["duration"] as! String
                        conf.likes = Int64(data["likes"] as! String)!
                        conf.group_name = data["gname"] as! String
                        conf.status = data["status"] as! String
                        
                        confs.append(conf)
                    }
                    
                    handleCallback(confs, "0")
                    
                }else if result_code == "1" {
                    handleCallback(nil, result_code)
                }
                else{
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    
    static func changePassword(email:String, old_password:String, new_password:String, handleCallback: @escaping (String) -> ())
    {
        //NSLog(url)
        let params = [
            "email" : email,
            "oldpassword" : old_password,
            "newpassword" : new_password
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "changepassword", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("SEND MESSAGE response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    handleCallback(result_code)
                }else {
                    handleCallback("Server issue")
                }
            }
        }
    }
    
    
    static func openConference(member_id: Int64, conf_id: Int64, handleCallback: @escaping ([User]?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "member_id":String(member_id),
            "conf_id" : String(conf_id)
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "openconference", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                let result_code = json["result_code"].stringValue
                if(result_code == "0"){
                    var users = [User]()
                    
                    let dataArray = json["users"].arrayObject as! [[String: Any]]
                    
                    for data in dataArray{
                        
                        let user = User()
                        user.idx = data["id"] as! Int64
                        user.admin_id = Int64(data["admin_id"] as! String)!
                        user.name = data["name"] as! String
                        user.email = data["email"] as! String
                        user.password = data["password"] as! String
                        user.photo_url = data["photo_url"] as! String
                        user.phone_number = data["phone_number"] as! String
                        user.city = data["city"] as! String
                        user.address = data["address"] as! String
                        user.lat = data["lat"] as! String
                        user.lng = data["lng"] as! String
                        user.cohort = data["cohort"] as! String
                        user.registered_time = data["registered_time"] as! String
                        user.fcm_token = data["fcm_token"] as! String
                        user.status = data["status"] as! String
                        user.status2 = data["status2"] as! String
                        
                        users.append(user)
                    }
                    
                    handleCallback(users, "0")
                    
                }else if result_code == "1" {
                    handleCallback(nil, result_code)
                }
                else{
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    static func getGroupMembers(member_id: Int64, group_id: Int64, handleCallback: @escaping ([User]?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "member_id":String(member_id),
            "group_id" : String(group_id)
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "getgroupmembers", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                let result_code = json["result_code"].stringValue
                if(result_code == "0"){
                    var users = [User]()
                    
                    let dataArray = json["users"].arrayObject as! [[String: Any]]
                    
                    for data in dataArray{
                        
                        let user = User()
                        user.idx = data["id"] as! Int64
                        user.admin_id = Int64(data["admin_id"] as! String)!
                        user.name = data["name"] as! String
                        user.email = data["email"] as! String
                        user.password = data["password"] as! String
                        user.photo_url = data["photo_url"] as! String
                        user.phone_number = data["phone_number"] as! String
                        user.city = data["city"] as! String
                        user.address = data["address"] as! String
                        user.lat = data["lat"] as! String
                        user.lng = data["lng"] as! String
                        user.cohort = data["cohort"] as! String
                        user.registered_time = data["registered_time"] as! String
                        user.fcm_token = data["fcm_token"] as! String
                        user.status = data["status"] as! String
                        user.status2 = data["status2"] as! String
                        
                        users.append(user)
                    }
                    
                    handleCallback(users, "0")
                    
                }else if result_code == "1" {
                    handleCallback(nil, result_code)
                }
                else{
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    static func getGroupConferences(member_id: Int64, group_id:Int64, cohort:String, handleCallback: @escaping ([Conference]?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "me_id":String(member_id),
            "group_id":String(group_id),
            "cohort":cohort
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "groupconfs", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                let result_code = json["result_code"].stringValue
                if(result_code == "0"){
                    var confs = [Conference]()
                    
                    var dataArray = json["data"].arrayObject as! [[String: Any]]
                    for data in dataArray{
                        let conf = Conference()
                        conf.idx = data["id"] as! Int64
                        conf.user_id = Int64(data["member_id"] as! String)!
                        var gid = data["group_id"] as! String
                        if gid == ""{
                            gid = "0"
                        }
                        conf.group_id = Int64(gid)!
                        conf.name = data["name"] as! String
                        conf.cohort = data["cohort"] as! String
                        conf.code = data["code"] as! String
                        conf.type = data["type"] as! String
                        conf.video_url = data["video_url"] as! String
                        conf.participants = Int64(data["participants"] as! String)!
                        conf.event_time = data["event_time"] as! String
                        conf.created_time = data["created_time"] as! String
                        conf.duration = data["duration"] as! String
                        conf.likes = Int64(data["likes"] as! String)!
                        conf.group_name = data["gname"] as! String
                        conf.status = data["status"] as! String
                        
                        confs.append(conf)
                    }
                    
                    handleCallback(confs, "0")
                    
                }else if result_code == "1" {
                    handleCallback(nil, result_code)
                }
                else{
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    static func notifyGroupChatMembers(member_id:Int64, group_id:Int64, cohort:String, message:String, members:String, handleCallback: @escaping (String) -> ())
    {
        //NSLog(url)
        let params = [
            "member_id": String(member_id),
            "group_id" : String(group_id),
            "cohort": cohort,
            "message" : message,
            "members" : members
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "notifygroupchatmembers", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("SEND MESSAGE response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    handleCallback(result_code)
                }else {
                    handleCallback("Server issue")
                }
            }
        }
    }
    
    static func sendChatPush(receiver_id:Int64, sender_id:Int64, message:String, handleCallback: @escaping (String) -> ())
    {
        //NSLog(url)
        let params = [
            "receiver_id": String(receiver_id),
            "sender_id" : String(sender_id),
            "message" : message
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "sendfcmpush", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("SEND MESSAGE response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    handleCallback(result_code)
                }else {
                    handleCallback("Server issue")
                }
            }
        }
    }
    
    
    static func requestVideoCall(receiver_id:Int64, sender_id:Int64, alias:String, action:String, handleCallback: @escaping (String) -> ())
    {
        //NSLog(url)
        let params = [
            "receiver_id": String(receiver_id),
            "sender_id" : String(sender_id),
            "alias" : alias,
            "action" : action
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "requestvideocall", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("SEND MESSAGE response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    handleCallback(result_code)
                }else {
                    handleCallback("Server issue")
                }
            }
        }
    }
    
    static func readTerms(member_id:Int64, handleCallback: @escaping (String) -> ())
    {
        //NSLog(url)
        let params = [
            "member_id": String(member_id)
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "readterms", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("SEND MESSAGE response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    handleCallback(result_code)
                }else {
                    handleCallback("Server issue")
                }
            }
        }
    }
    
    static func reportMember(member_id:Int64, reporter_id:Int64, message:String, handleCallback: @escaping (String) -> ())
    {
        //NSLog(url)
        let params = [
            "member_id": String(member_id),
            "reporter_id": String(reporter_id),
            "message": message
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "reportmember", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("SEND MESSAGE response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    handleCallback(result_code)
                }else {
                    handleCallback("Server issue")
                }
            }
        }
    }
    
    
    
    static func getPostLinks(content: String, handleCallback: @escaping ([PostPreview]?, String) -> ())
    {        
        let params = [
            "content": content
        ] as [String : Any]
        
        Alamofire.request("https://www.vacay.company/mothers/bbbbb", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else {
                let json = JSON(response.result.value!)
//                NSLog("\(json)")
                let result = json["result"].stringValue
                if(result == "success"){
                    var prevs = [PostPreview]()
                    let prevJsonArray = json["data"].arrayObject as! [[String: Any]]
                    for prevdata in prevJsonArray{
                        let prev = PostPreview()
                        prev.title = prevdata["title"] as! String
                        prev.description = prevdata["description"] as! String
                        prev.image_url = prevdata["image_url"] as! String
                        prev.icon_url = prevdata["icon_url"] as! String
                        prev.site_url = prevdata["site_url"] as! String
                        prevs.append(prev)
                    }
                    
                    handleCallback(prevs, "success")
                    
                }
                
            }
        }
    }
    
    
    static func refreshPosts(member_id: Int64, num:Int64, handleCallback: @escaping ([Post]?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "member_id":String(member_id),
            "num":String(num),
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "xxxxxxxxxx", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
//                NSLog("\(json)")
                let result_code = json["result_code"].stringValue
                if(result_code == "0"){
                    var posts = [Post]()
                    
                    let dataArray = json["posts"].arrayObject as! [[String: Any]]
                    for data in dataArray{
                        
                        let json = JSON(data)
                        
                        var data = json["post"].object as! [String: Any]
                        let post = Post()
                        post.idx = data["id"] as! Int64
                        post.title = data["title"] as! String
                        post.category = data["category"] as! String
                        post.content = data["content"] as! String
                        post.picture_url = data["picture_url"] as! String
                        // Reactions
                        post.likes = (data["likes"] as! String).count > 0 ? Int(data["likes"] as! String)! : 0
                        post.loves = (data["loves"] as! String).count > 0 ? Int(data["loves"] as! String)! : 0
                        post.hahas = (data["haha"] as! String).count > 0 ? Int(data["haha"] as! String)! : 0
                        post.wows = (data["wow"] as! String).count > 0 ? Int(data["wow"] as! String)! : 0
                        post.sads = (data["sad"] as! String).count > 0 ? Int(data["sad"] as! String)! : 0
                        post.angrys = (data["angry"] as! String).count > 0 ? Int(data["angry"] as! String)! : 0
                        post.reactions = (data["reactions"] as! String).count > 0 ? Int(data["reactions"] as! String)! : 0
                        post.my_feeling = data["liked"] as! String
                        
                        post.comments = Int64(data["comments"] as! String)!
                        post.scheduled_time = data["scheduled_time"] as! String
                        post.posted_time = data["posted_time"] as! String
                        if data["liked"] as! String == "yes"{
                            post.isLiked = true
                        }else {
                            post.isLiked = false
                        }
                        post.status = data["status"] as! String
                        post.sch_status = data["sch_status"] as! String
                        
                        
                        data = json["member"].object as! [String: Any]
                        let user = User()
                        user.idx = data["id"] as! Int64
                        user.admin_id = Int64(data["admin_id"] as! String)!
                        user.name = data["name"] as! String
                        user.email = data["email"] as! String
                        user.password = data["password"] as! String
                        user.photo_url = data["photo_url"] as! String
                        user.phone_number = data["phone_number"] as! String
                        user.city = data["city"] as! String
                        user.address = data["address"] as! String
                        user.lat = data["lat"] as! String
                        user.lng = data["lng"] as! String
                        user.cohort = data["cohort"] as! String
                        user.registered_time = data["registered_time"] as! String
                        user.fcm_token = data["fcm_token"] as! String
                        user.status = data["status"] as! String
                        user.status2 = data["status2"] as! String
                        
                        post.user = user
                        
                        let pics = json["pics"].stringValue
                        let pic_count = Int(pics)
                        
                        post.pictures = pic_count!
                        
                        var prevs = [PostPreview]()
                        let prevJsonArray = json["prevs"].arrayObject as! [[String: Any]]
                        for prevdata in prevJsonArray{
                            let prev = PostPreview()
                            prev.idx = prevdata["id"] as! Int64
                            prev.post_id = Int64(prevdata["post_id"] as! String)!
                            prev.title = prevdata["title"] as! String
                            prev.description = prevdata["description"] as! String
                            prev.image_url = prevdata["image_url"] as! String
                            prev.icon_url = prevdata["icon_url"] as! String
                            prev.site_url = prevdata["site_url"] as! String
                            prevs.append(prev)
                        }
                        post.previews = prevs
                        
                        var comments = [Comment]()
                        let commentJsonArray = json["comments"].arrayObject as! [[String: Any]]
                        for commentObj in commentJsonArray {
                            var cdata = commentObj["comment"] as! [String: Any]
                            let comment = Comment()
                            comment.idx = cdata["id"] as! Int64
                            comment.post_id = Int64(cdata["post_id"] as! String)!
                            comment.comment = cdata["comment_text"] as! String
                            
                            var udata = commentObj["commented_member"] as! [String: Any]
                            let user = User()
                            user.idx = udata["id"] as! Int64
                            user.admin_id = Int64(udata["admin_id"] as! String)!
                            user.name = udata["name"] as! String
                            user.photo_url = udata["photo_url"] as! String
                            comment.user = user
                            comments.append(comment)
                        }
                        post.comment_list = comments
                        
                        posts.append(post)
                    }
                    
                    handleCallback(posts, "0")
                    
                }else if result_code == "1" {
                    handleCallback(nil, result_code)
                }
                else{
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    
    static func refreshUserPosts(me_id: Int64, member_id: Int64, num:Int64, handleCallback: @escaping ([Post]?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "me_id":String(me_id),
            "member_id":String(member_id),
            "num":String(num),
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "yyyyyyyyyy", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
//                NSLog("\(json)")
                let result_code = json["result_code"].stringValue
                if(result_code == "0"){
                    var posts = [Post]()
                    
                    let dataArray = json["posts"].arrayObject as! [[String: Any]]
                    for data in dataArray{
                        
                        let json = JSON(data)
                        
                        var data = json["post"].object as! [String: Any]
                        let post = Post()
                        post.idx = data["id"] as! Int64
                        post.title = data["title"] as! String
                        post.category = data["category"] as! String
                        post.content = data["content"] as! String
                        post.picture_url = data["picture_url"] as! String
                        // Reactions
                        post.likes = (data["likes"] as! String).count > 0 ? Int(data["likes"] as! String)! : 0
                        post.loves = (data["loves"] as! String).count > 0 ? Int(data["loves"] as! String)! : 0
                        post.hahas = (data["haha"] as! String).count > 0 ? Int(data["haha"] as! String)! : 0
                        post.wows = (data["wow"] as! String).count > 0 ? Int(data["wow"] as! String)! : 0
                        post.sads = (data["sad"] as! String).count > 0 ? Int(data["sad"] as! String)! : 0
                        post.angrys = (data["angry"] as! String).count > 0 ? Int(data["angry"] as! String)! : 0
                        post.reactions = (data["reactions"] as! String).count > 0 ? Int(data["reactions"] as! String)! : 0
                        post.my_feeling = data["liked"] as! String
                        
                        post.comments = Int64(data["comments"] as! String)!
                        post.scheduled_time = data["scheduled_time"] as! String
                        post.posted_time = data["posted_time"] as! String
                        if data["liked"] as! String == "yes"{
                            post.isLiked = true
                        }else {
                            post.isLiked = false
                        }
                        post.status = data["status"] as! String
                        post.sch_status = data["sch_status"] as! String
                        
                        
                        data = json["member"].object as! [String: Any]
                        let user = User()
                        user.idx = data["id"] as! Int64
                        user.admin_id = Int64(data["admin_id"] as! String)!
                        user.name = data["name"] as! String
                        user.email = data["email"] as! String
                        user.password = data["password"] as! String
                        user.photo_url = data["photo_url"] as! String
                        user.phone_number = data["phone_number"] as! String
                        user.city = data["city"] as! String
                        user.address = data["address"] as! String
                        user.lat = data["lat"] as! String
                        user.lng = data["lng"] as! String
                        user.cohort = data["cohort"] as! String
                        user.registered_time = data["registered_time"] as! String
                        user.fcm_token = data["fcm_token"] as! String
                        user.status = data["status"] as! String
                        user.status2 = data["status2"] as! String
                        
                        post.user = user
                        
                        let pics = json["pics"].stringValue
                        let pic_count = Int(pics)
                        
                        post.pictures = pic_count!
                        
                        var prevs = [PostPreview]()
                        let prevJsonArray = json["prevs"].arrayObject as! [[String: Any]]
                        for prevdata in prevJsonArray{
                            let prev = PostPreview()
                            prev.idx = prevdata["id"] as! Int64
                            prev.post_id = Int64(prevdata["post_id"] as! String)!
                            prev.title = prevdata["title"] as! String
                            prev.description = prevdata["description"] as! String
                            prev.image_url = prevdata["image_url"] as! String
                            prev.icon_url = prevdata["icon_url"] as! String
                            prev.site_url = prevdata["site_url"] as! String
                            prevs.append(prev)
                        }
                        post.previews = prevs
                        
                        posts.append(post)
                    }
                    
                    handleCallback(posts, "0")
                    
                }else if result_code == "1" {
                    handleCallback(nil, result_code)
                }
                else{
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    
    static func getgroupnames(admin_id:Int64, handleCallback: @escaping (String?, String) -> ())
    {
        //NSLog(url)
        let params = [
            "admin_id": String(admin_id),
            ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "ugroupnames", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback("", "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("group names response: \(json)")
                let result_code = json["result_code"].stringValue
                if result_code != nil{
                    if result_code == "0" {
                        let group_names = json["group_names"].stringValue
                        handleCallback(group_names, result_code)
                    }else { handleCallback("", "server issue") }
                }else {
                    handleCallback("", "Server issue")
                }
            }
        }
    }
    
    
    static func getComidaPosts(member_id: Int64, handleCallback: @escaping ([Post]?, [User]?, String) -> ())
    {
        //NSLog(url)
        
        let params = [
            "member_id":String(member_id),
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "comidaposts", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, nil, "Server issue")
            }
            else
            {
                let json = JSON(response.result.value!)
                let result_code = json["result_code"].stringValue
                if(result_code == "0"){
                    var posts = [Post]()
                    var users = [User]()
                    
                    var dataArray = json["users"].arrayObject as! [[String: Any]]
                    for data in dataArray{
                        let user = User()
                        user.idx = data["id"] as! Int64
                        user.admin_id = Int64(data["admin_id"] as! String)!
                        user.name = data["name"] as! String
                        user.email = data["email"] as! String
                        user.password = data["password"] as! String
                        user.photo_url = data["photo_url"] as! String
                        user.phone_number = data["phone_number"] as! String
                        user.city = data["city"] as! String
                        user.address = data["address"] as! String
                        user.lat = data["lat"] as! String
                        user.lng = data["lng"] as! String
                        user.cohort = data["cohort"] as! String
                        user.registered_time = data["registered_time"] as! String
                        user.fcm_token = data["fcm_token"] as! String
                        user.username = data["username"] as! String
                        user.status = data["status"] as! String
                        user.status2 = data["status2"] as! String
                        
                        users.append(user)
                    }
                    
                    dataArray = json["posts"].arrayObject as! [[String: Any]]
                    for data in dataArray{
                        
                        let json = JSON(data)
                        
                        var data = json["post"].object as! [String: Any]
                        let post = Post()
                        post.idx = data["id"] as! Int64
                        post.title = data["title"] as! String
                        post.category = data["category"] as! String
                        post.content = data["content"] as! String
                        post.picture_url = data["picture_url"] as! String
                        // Reactions
                        post.likes = (data["likes"] as! String).count > 0 ? Int(data["likes"] as! String)! : 0
                        post.loves = (data["loves"] as! String).count > 0 ? Int(data["loves"] as! String)! : 0
                        post.hahas = (data["haha"] as! String).count > 0 ? Int(data["haha"] as! String)! : 0
                        post.wows = (data["wow"] as! String).count > 0 ? Int(data["wow"] as! String)! : 0
                        post.sads = (data["sad"] as! String).count > 0 ? Int(data["sad"] as! String)! : 0
                        post.angrys = (data["angry"] as! String).count > 0 ? Int(data["angry"] as! String)! : 0
                        post.reactions = (data["reactions"] as! String).count > 0 ? Int(data["reactions"] as! String)! : 0
                        post.my_feeling = data["liked"] as! String
                        
                        post.comments = Int64(data["comments"] as! String)!
                        post.scheduled_time = data["scheduled_time"] as! String
                        post.posted_time = data["posted_time"] as! String
                        if data["liked"] as! String == "yes"{
                            post.isLiked = true
                        }else {
                            post.isLiked = false
                        }
                        post.status = data["status"] as! String
                        post.sch_status = data["sch_status"] as! String
                        
                        
                        data = json["member"].object as! [String: Any]
                        let user = User()
                        user.idx = data["id"] as! Int64
                        user.admin_id = Int64(data["admin_id"] as! String)!
                        user.name = data["name"] as! String
                        user.email = data["email"] as! String
                        user.password = data["password"] as! String
                        user.photo_url = data["photo_url"] as! String
                        user.phone_number = data["phone_number"] as! String
                        user.city = data["city"] as! String
                        user.address = data["address"] as! String
                        user.lat = data["lat"] as! String
                        user.lng = data["lng"] as! String
                        user.cohort = data["cohort"] as! String
                        user.registered_time = data["registered_time"] as! String
                        user.fcm_token = data["fcm_token"] as! String
                        user.status = data["status"] as! String
                        user.status2 = data["status2"] as! String
                        
                        post.user = user
                        
                        let pics = json["pics"].stringValue
                        let pic_count = Int(pics)
                        
                        post.pictures = pic_count!
                        
                        var prevs = [PostPreview]()
                        let prevJsonArray = json["prevs"].arrayObject as! [[String: Any]]
                        for prevdata in prevJsonArray{
                            let prev = PostPreview()
                            prev.idx = prevdata["id"] as! Int64
                            prev.post_id = Int64(prevdata["post_id"] as! String)!
                            prev.title = prevdata["title"] as! String
                            prev.description = prevdata["description"] as! String
                            prev.image_url = prevdata["image_url"] as! String
                            prev.icon_url = prevdata["icon_url"] as! String
                            prev.site_url = prevdata["site_url"] as! String
                            prevs.append(prev)
                        }
                        post.previews = prevs
                        
                        var comments = [Comment]()
                        let commentJsonArray = json["comments"].arrayObject as! [[String: Any]]
                        for commentObj in commentJsonArray {
                            var cdata = commentObj["comment"] as! [String: Any]
                            let comment = Comment()
                            comment.idx = cdata["id"] as! Int64
                            comment.post_id = Int64(cdata["post_id"] as! String)!
                            comment.comment = cdata["comment_text"] as! String
                            
                            var udata = commentObj["commented_member"] as! [String: Any]
                            let user = User()
                            user.idx = udata["id"] as! Int64
                            user.admin_id = Int64(udata["admin_id"] as! String)!
                            user.name = udata["name"] as! String
                            user.photo_url = udata["photo_url"] as! String
                            comment.user = user
                            comments.append(comment)
                        }
                        post.comment_list = comments
                        
                        posts.append(post)
                    }
                    
                    handleCallback(posts, users, "0")
                    
                }else if result_code == "1" {
                    handleCallback(nil, nil, result_code)
                }
                else{
                    handleCallback(nil, nil, "Server issue")
                }
                
            }
        }
    }
    
    
    static func getFoodResources(admin_id: Int64, handleCallback: @escaping ([FoodResource]?, String) -> ())
    {
        let params = [
            "admin_id": String(admin_id)
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "foodresourcelist", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                let result_code = json["result_code"].stringValue
                if(result_code == "0"){
                    var frs = [FoodResource]()
                    
                    let dataArray = json["data"].arrayObject as! [[String: Any]]
                    
                    for data in dataArray {
                        let fr = FoodResource()
                        fr.idx = data["id"] as! Int64
                        fr.title = data["title"] as! String
                        fr.description = data["content"] as! String
                        fr.image_url = data["image_url"] as! String
                        fr.category = data["category"] as! String
                        fr.group = data["group"] as! String
                        fr.location = data["location"] as! String
                        fr.lat = data["lat"] as! String
                        fr.lng = data["lng"] as! String
                        fr.site_url = data["link"] as! String
                        fr.daily_meal = data["daily_meal"] as! String
                        frs.append(fr)
                    }
                    
                    handleCallback(frs, "0")
                    
                }
                else{
                    handleCallback(nil, "Server issue")
                }
                
            }
        }
    }
    
    
    static func getRecipes(admin_id: Int64, category:String, handleCallback: @escaping ([Recipe]?, String) -> ()) {
        let params = [
            "admin_id": String(admin_id),
            "category": category,
        ] as [String : Any]
        
        Alamofire.request(ReqConst.SERVER_URL + "recipelist", method: .post, parameters: params).responseJSON { response in
            
            if response.result.isFailure{
                handleCallback(nil, "Server issue")
            }
            else {
                let json = JSON(response.result.value!)
                NSLog("\(json)")
                let result_code = json["result_code"].stringValue
                if(result_code == "0") {
                    var rs = [Recipe]()
                    let dataArray = json["data"].arrayObject as! [[String: Any]]
                    for data in dataArray {
                        let r = Recipe()
                        r.idx = data["id"] as! Int64
                        r.title = data["title"] as! String
                        r.description = data["description"] as! String
                        r.image_url = data["image_url"] as! String
                        r.icon_url = data["icon_url"] as! String
                        r.site_url = data["site_url"] as! String
                        rs.append(r)
                    }
                    handleCallback(rs, "0")
                }
                else{
                    handleCallback(nil, "Server issue")
                }                
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}










































