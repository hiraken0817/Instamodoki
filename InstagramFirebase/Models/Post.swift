//
//  Post.swift
//  InstagramFirebase
//
//  Created by 平尾健太 on 2021/02/06.
//

import Foundation

struct Post{
    var id:String?
    
    let user:User
    let imageUrl:String
    let caption:String
    let creationDate:Date
    
    var likeMember = [String]()
    
    lazy var hasLiked:Bool = false
    
    
    
    init(user:User,dictionary:[String:Any],likeMember:[String]) {
        self.user = user
        self.likeMember = likeMember
        
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.caption = dictionary["caption"] as? String ?? ""
        
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
}
