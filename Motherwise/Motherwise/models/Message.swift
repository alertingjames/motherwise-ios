//
//  Message.swift
//  Motherwise
//
//  Created by Andre on 9/5/20.
//  Copyright © 2020 Motherwise. All rights reserved.
//

import Foundation

class Message {
    var idx:Int64 = 0
    var user_id:Int64 = 0
    var sender:User!
    var message:String = ""
    var messaged_time:String = ""
    var status:String = ""
    
    var role:String = ""
    var type:String = ""
    var id:String = ""
    var mes_id:Int64 = 0
    
    var key:String = ""
    var timestamp:Int64 = 0
}

var gMessage:Message = Message()
