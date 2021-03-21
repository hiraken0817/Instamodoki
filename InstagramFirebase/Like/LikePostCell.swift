//
//  LikeControllerCell.swift
//  InstagramFirebase
//
//  Created by 平尾健太 on 2021/02/28.
//

import Foundation

import UIKit

protocol LikePostCellDelegate {
    func didTapComment(post:Post)
    func didLike(for cell:LikePostCell)
}

class LikePostCell: UICollectionViewCell {
    
    var delegate:LikePostCellDelegate?
    
    var post:Post?{
        didSet{
            
            guard let postImageUrl = post?.imageUrl else { return }
            photoImageView.loadImage(urlString: postImageUrl)//画像の表示
            
            if post?.hasLiked == true{
                likeButton.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
                likeButton.tintColor = .systemPink
            }else{
                likeButton.setImage(UIImage(systemName: "suit.heart"), for: .normal)
                likeButton.tintColor = .black
            }

            
            usernameLabel.text = post?.user.username
            guard let profileImageUrl = post?.user.profileImageUrl else { return }
            
            userProfileImageView.loadImage(urlString:profileImageUrl)
//            captionLabel.text = post?.caption
            setupAttributedCaption()
                
        }
    }
    
    fileprivate func setupAttributedCaption(){
        guard let post = self.post else { return }
        let attributeText = NSMutableAttributedString(string: post.user.username, attributes:[ NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize:14)])
        attributeText.append(NSAttributedString(string: "  \(post.caption)",
                                                attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize:14)]))
        attributeText.append(NSAttributedString(string: "\n\n",
                                                attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize:4)]))
        
        let timeAgoDisplay = post.creationDate.timeAgoDisplay()
        attributeText.append(NSAttributedString(string: timeAgoDisplay,
                                                attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize:14),NSAttributedString.Key.foregroundColor:UIColor.lightGray]))
        captionLabel.attributedText = attributeText
    }
    
    let userProfileImageView:CustomImageView = {
       let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .blue
        return iv
    }()
    
    let usernameLabel:UILabel = {
        let label = UILabel()
        label.text = "username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let optionsButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("•••", for: .normal)
        button.setTitleColor(.black, for: .normal)
       return button
    }()
    
    let photoImageView:CustomImageView = {
       let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    lazy var likeButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "suit.heart"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return button
    }()
    
    @objc func handleLike(){
        print("like")
        delegate?.didLike(for: self)
    }
    
    lazy var commentButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "message"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return button
    }()
    
    @objc func handleComment(){
        print("コメント欄を見る")
        guard let post = post else { return }
        
        delegate?.didTapComment(post: post)
        
    }
    
    let sendMessageButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "paperplane"), for: .normal)
        button.tintColor = .black

        return button
    }()
    
    let bookmarkButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bookmark"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    let captionLabel:UILabel = {
        let label = UILabel()
        
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(userProfileImageView)
        addSubview(usernameLabel)
        addSubview(optionsButton)
        addSubview(photoImageView)
        addSubview(captionLabel)
        userProfileImageView.anchor(top: topAnchor,
                                    left: leftAnchor,
                                    bottom: nil,
                                    right: nil,
                                    paddingTop: 8,
                                    paddingLeft: 8,
                                    paddingBottom: 0,
                                    paddingRight: 0,
                                    width: 40,
                                    height: 40)
        userProfileImageView.layer.cornerRadius = 40/2
        
       
        usernameLabel.anchor(top: topAnchor,
                             left: userProfileImageView.rightAnchor,
                             bottom: photoImageView.topAnchor,
                             right: optionsButton.leftAnchor,
                             paddingTop: 0,
                             paddingLeft: 8,
                             paddingBottom: 0,
                             paddingRight: 0,
                             width: 0,
                             height: 0)
        
        optionsButton.anchor(top: topAnchor,
                             left: nil,
                             bottom: photoImageView.topAnchor,
                             right: rightAnchor,
                             paddingTop: 0,
                             paddingLeft: 0,
                             paddingBottom: 0,
                             paddingRight: 3,
                             width: 44,
                             height: 0)
        
        photoImageView.anchor(top: userProfileImageView.bottomAnchor,
                              left: leftAnchor,
                              bottom: nil,
                              right: rightAnchor,
                              paddingTop: 8,
                              paddingLeft: 0,
                              paddingBottom: 0,
                              paddingRight: 0,
                              width: 0,
                              height: 0)
        photoImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true//画像の下の空間を開ける
       
        setupActionButtons()
        
        captionLabel.anchor(top: likeButton.bottomAnchor,
                            left: leftAnchor,
                            bottom: bottomAnchor,
                            right: rightAnchor,
                            paddingTop: 0,
                            paddingLeft: 8,
                            paddingBottom: 0,
                            paddingRight: 8,
                            width: 0,
                            height: 0)
    }
    
    fileprivate func setupActionButtons(){
        let stackView = UIStackView(arrangedSubviews: [likeButton,commentButton,sendMessageButton])
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.anchor(top: photoImageView.bottomAnchor,
                         left: leftAnchor,
                         bottom: nil,
                         right: nil,
                         paddingTop: 0,
                         paddingLeft: 8,
                         paddingBottom: 0,
                         paddingRight: 0,
                         width: 120,
                         height: 50)
        addSubview(bookmarkButton)
        bookmarkButton.anchor(top: photoImageView.bottomAnchor,
                              left: nil,
                              bottom: nil,
                              right: rightAnchor,
                              paddingTop: 0,
                              paddingLeft: 0,
                              paddingBottom: 0,
                              paddingRight: 5,
                              width: 40,
                              height: 50)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
