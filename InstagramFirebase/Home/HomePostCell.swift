//
//  HomePostCell.swift
//  InstagramFirebase
//
//  Created by 平尾健太 on 2021/02/07.
//

import UIKit
import FRHyperLabel

protocol HomePostCellDelegate {
    func didTapComment(post:Post)
    func didLike(for cell:HomePostCell)
    func didLikeMember(likeMember:[String])
    func didTapUserImage(post:Post)
}

class HomePostCell: UICollectionViewCell {
    
    var delegate:HomePostCellDelegate?
    
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

            setupAttributedCaption()
                
        }
    }
    
    fileprivate func setupAttributedCaption(){
        guard let post = self.post else { return }
        
        let timeAgoDisplay = post.creationDate.timeAgoDisplay()
        dateLabel.text = timeAgoDisplay
        
        
        let attributeText = NSMutableAttributedString(string: "",
                                               attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize:0)])
        
        //ここにいいねの表示処理
        if post.likeMember.count != 0{
            attributeText.append(NSAttributedString(string: "いいね！: ", attributes:[ NSAttributedString.Key.font:UIFont.systemFont(ofSize:14)]))
            
            attributeText.append(NSAttributedString(string: "\(post.likeMember.count)人\n", attributes:[ NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize:14)]))
        }
        
        attributeText.append(NSAttributedString(string: post.user.username, attributes:[ NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize:14)]))
        
        attributeText.append(NSAttributedString(string: "  \(post.caption)",
                                                attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize:14)]))
        
        attributeText.append(NSAttributedString(string: "\n\n",
                                                attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize:4)]))
        
        
        captionLabel.attributedText = attributeText
        captionLabel.setLinkForSubstring("いいね！: ", withAttribute: [NSAttributedString.Key.foregroundColor: UIColor.black], andLinkHandler:  { [weak self] label, string in
              print("いいねメンバーに画面遷移")
            guard let weakSelf = self else { return }
            
            weakSelf.delegate?.didLikeMember(likeMember: post.likeMember)
            
        })
    }
    
    lazy var userProfileImageView:CustomImageView = {
       let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .white
        
        iv.isUserInteractionEnabled = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleUserProfile))
        
        iv.addGestureRecognizer(tapGestureRecognizer)
        return iv
    }()
    
    @objc func handleUserProfile(){
        print("プロフィールに移動")
        guard let post = post else { return }
        
        delegate?.didTapUserImage(post: post)
    }
    
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
        print("handlelike")
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
    
    
    let captionLabel:FRHyperLabel = {
        let label = FRHyperLabel()
        
        label.numberOfLines = 0
        return label
    }()
    
    let dateLabel:UILabel = {
       let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(userProfileImageView)
        addSubview(usernameLabel)
        addSubview(optionsButton)
        addSubview(photoImageView)
        addSubview(dateLabel)
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
        
        dateLabel.anchor(top: nil,
                         left: leftAnchor,
                         bottom: bottomAnchor,
                         right: nil,
                         paddingTop: 0,
                         paddingLeft: 8,
                         paddingBottom: 0,
                         paddingRight: 0,
                         width: 0,
                         height: 0)
        
        captionLabel.anchor(top: likeButton.bottomAnchor,
                            left: leftAnchor,
                            bottom: dateLabel.topAnchor,
                            right: rightAnchor,
                            paddingTop: 0,
                            paddingLeft: 8,
                            paddingBottom: 0,
                            paddingRight: 8,
                            width: 0,
                            height: 60)
        
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
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
