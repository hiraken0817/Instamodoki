//
//  UserSearchCell.swift
//  InstagramFirebase
//
//  Created by 平尾健太 on 2021/02/08.
//

import UIKit

class UserSearchCell: UICollectionViewCell {
    
    var user:User? {
        didSet{
            usernameLabel.text = user?.username
            guard let profileImageUrl = user?.profileImageUrl else { return }
            profileImageView.loadImage(urlString: profileImageUrl)
        }
    }
    
    let profileImageView:CustomImageView = {
       let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let usernameLabel:UILabel = {
       let label = UILabel()
        label.text = "読み込み中..."
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        addSubview(usernameLabel)
        
        profileImageView.anchor(top: nil,
                                left: leftAnchor,
                                bottom: nil,
                                right: nil,
                                paddingTop: 0,
                                paddingLeft: 8,
                                paddingBottom: 0,
                                paddingRight: 0,
                                width: 50,
                                height: 50)
        
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 25
        
        usernameLabel.anchor(top: topAnchor,
                                left: profileImageView.rightAnchor,
                                bottom: bottomAnchor,
                                right: rightAnchor,
                                paddingTop: 0,
                                paddingLeft: 8,
                                paddingBottom: 0,
                                paddingRight: 0,
                                width: 0,
                                height: 0)
        
        let separtorView = UIView()
        separtorView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        addSubview(separtorView)
        separtorView.anchor(top: nil,
                            left: usernameLabel.leftAnchor,
                            bottom: bottomAnchor,
                            right: rightAnchor,
                            paddingTop: 0,
                            paddingLeft: 0,
                            paddingBottom: 0,
                            paddingRight: 5,
                            width: 0,
                            height: 0.5)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
