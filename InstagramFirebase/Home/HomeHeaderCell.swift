//
//  HomeHeaderCell.swift
//  InstagramFirebase
//
//  Created by 平尾健太 on 2021/03/16.
//

import UIKit

protocol HomeHeaderDelegate {
    
    func startStory()
}

class HomeHeaderCell:UICollectionViewCell{
    
    var user:User?{
        didSet{
            storyPlusView.loadImage(urlString: user!.profileImageUrl)
           
        }
    }
    
    var delegate:HomeHeaderDelegate?
    
    lazy var storyPlusView:CustomImageView = {

        let iv = CustomImageView(image: UIImage(systemName: "person.crop.circle.fill"))
        
        iv.tintColor = .mainPurple()
        
        iv.contentMode = .scaleAspectFit
        
        iv.isUserInteractionEnabled = true
        iv.clipsToBounds = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleStory))
        
        iv.addGestureRecognizer(tapGestureRecognizer)
    
        return iv
    }()
    
    @objc func handleStory(){
        print("story")
        delegate?.startStory()

    }
    
    let plusView:UIImageView = {
       let plus = UIImageView(image: UIImage(systemName: "plus.circle.fill"))
        plus.tintColor = .systemGreen
        plus.backgroundColor = .white
        
        return plus
    }()
    
    let storyLabel:UILabel = {
       let label = UILabel()
        label.text = "ストーリーズ"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(storyPlusView)
        addSubview(plusView)
        addSubview(storyLabel)
        
        storyPlusView.anchor(top: topAnchor,
                               left: leftAnchor,
                               bottom: nil,
                               right: nil,
                               paddingTop: 12,
                               paddingLeft: 12,
                               paddingBottom: 0,
                               paddingRight: 0,
                               width: 80,
                               height: 80)
        
        storyPlusView.layer.cornerRadius = 80/2
        
        plusView.anchor(top: storyPlusView.topAnchor,
                        left: storyPlusView.leftAnchor,
                        bottom: nil,
                        right: nil,
                        paddingTop: 55,
                        paddingLeft: 55,
                        paddingBottom: 0,
                        paddingRight: 0,
                        width: 25,
                        height: 25)
        
        plusView.layer.cornerRadius = 25/2
        
        
        storyLabel.anchor(top: storyPlusView.bottomAnchor,
                          left: storyPlusView.leftAnchor,
                          bottom: nil,
                          right: storyPlusView.rightAnchor,
                          paddingTop: 4,
                          paddingLeft: 0,
                          paddingBottom: 0,
                          paddingRight: 0,
                          width: 80,
                          height: 0)
        
        let separateLine = UIView()
        separateLine.backgroundColor = .systemGray4
        
        addSubview(separateLine)
        separateLine.anchor(top: nil,
                            left: leftAnchor,
                            bottom: bottomAnchor,
                            right: rightAnchor,
                            paddingTop: 0,
                            paddingLeft: 0,
                            paddingBottom: 0,
                            paddingRight: 0,
                            width: 0,
                            height: 0.3)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
