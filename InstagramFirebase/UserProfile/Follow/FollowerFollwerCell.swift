//
//  followerFollwerCell.swift
//  InstagramFirebase
//
//  Created by 平尾健太 on 2021/03/01.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

protocol FollowFollowerCellDelegate {
    
    func didFollowOrUnfollow(for cell:FollowFollowerCell)
}

class FollowFollowerCell: UICollectionViewCell {
    
    
    
    var delegate:FollowFollowerCellDelegate?
    
    var user:User? {
        didSet{
            usernameLabel.text = user?.username
            guard let profileImageUrl = user?.profileImageUrl else { return }
            profileImageView.loadImage(urlString: profileImageUrl)
            
            if user?.hasFollowed == true{
                self.setupFollowStyle()
            }else{
                guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
                guard let userId = user?.uid else { return }
                if currentLoggedInUserId == userId{
                    self.followUnfollowButton.isHidden = true
                    
                }else{
                    self.setupUnFollowStyle()
                }
            }
        }
    }
    
    lazy var followUnfollowButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("フォローする", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor.mainPurple().cgColor
        button.backgroundColor = .mainPurple()
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(handleFollowOrUnFollow), for: .touchUpInside)
        return button
    }()
    
    @objc func handleFollowOrUnFollow(){
        print("follow or un follow")
        delegate?.didFollowOrUnfollow(for: self)
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
        addSubview(followUnfollowButton)
        
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
        
        followUnfollowButton.anchor(top: nil,
                                    left: nil,
                                    bottom: nil,
                                    right: rightAnchor,
                                    paddingTop: 0,
                                    paddingLeft: 0,
                                    paddingBottom: 0,
                                    paddingRight: 10,
                                    width: 120,
                                    height: 35)
        
        followUnfollowButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        

    }

    fileprivate func setupFollowStyle(){
        self.followUnfollowButton.setTitle("フォロー中", for: .normal)
        self.followUnfollowButton.backgroundColor = .white
        self.followUnfollowButton.setTitleColor(.black, for: .normal)
        self.followUnfollowButton.layer.borderColor = UIColor.systemGray.cgColor
    }
    
    fileprivate func setupUnFollowStyle(){
        self.followUnfollowButton.setTitle("フォローする", for: .normal)
        self.followUnfollowButton.backgroundColor = UIColor.mainPurple()
        self.followUnfollowButton.setTitleColor(.white, for: .normal)
        self.followUnfollowButton.layer.borderColor = UIColor.mainPurple().cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

