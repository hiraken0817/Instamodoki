//
//  User.swift
//  InstagramFirebase
//
//  Created by 平尾健太 on 2021/02/07.
//

import Foundation

struct User{
    let uid:String
    let username:String
    let profileImageUrl:String
    let intoroduce:String
    lazy var hasFollowed:Bool = false
    
    init(uid:String,dictionary:[String:Any]) {
        self.uid = uid
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.intoroduce = dictionary["intoroduce"] as? String ?? ""
    }
}

