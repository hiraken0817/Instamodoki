//
//  CommentCell.swift
//  InstagramFirebase
//
//  Created by 平尾健太 on 2021/02/15.
//

import UIKit

class CommentCell: UICollectionViewCell {
    
    var comment :Comment? {
        didSet{
            guard let comment = comment else { return }
            
            let timeAgoDisplay = comment.creationDate.timeAgoDisplay()
            
            let attributedText = NSMutableAttributedString(string: comment.user.username,
                                                           attributes:[NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize:14)])
            attributedText.append(NSAttributedString(string:" " + comment.text,attributes:[NSAttributedString.Key.font:UIFont.systemFont(ofSize:14)]))
            
            attributedText.append(NSAttributedString(string: "\n\n",
                                                    attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize:4)]))
            
            attributedText.append(NSAttributedString(string: timeAgoDisplay,attributes:[NSAttributedString.Key.font:UIFont.systemFont(ofSize:14),NSAttributedString.Key.foregroundColor:UIColor.systemGray]))
            
            textView.attributedText = attributedText

            profileImageView.loadImage(urlString: comment.user.profileImageUrl)
        }
    }
    
    let textView:UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.isScrollEnabled = false
        textView.backgroundColor = .white
        return textView
    }()
    
    let profileImageView:CustomImageView = {
       let iv = CustomImageView()
        iv.backgroundColor = .white
        iv.clipsToBounds = true//トリミング
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor,
                                left: leftAnchor,
                                bottom: nil,
                                right: nil,
                                paddingTop: 8,
                                paddingLeft: 8,
                                paddingBottom: 0,
                                paddingRight: 0,
                                width: 40,
                                height: 40)
        
        profileImageView.layer.cornerRadius = 40/2
        
        addSubview(textView)
        
        textView.anchor(top: topAnchor,
                         left: profileImageView.rightAnchor,
                         bottom: bottomAnchor,
                         right: rightAnchor,
                         paddingTop: 4,
                         paddingLeft: 4,
                         paddingBottom: -4,
                         paddingRight: 4,
                         width: 0,
                         height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
