//
//  Comment.swift
//  InstagramFirebase
//
//  Created by 平尾健太 on 2021/02/15.
//

import Foundation

struct Comment{
    
    let user:User
    
    let uid: String
    let text: String
    let creationDate:Date
    
    init(user:User,dictionary:[String:Any]){
        self.user = user
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
}
