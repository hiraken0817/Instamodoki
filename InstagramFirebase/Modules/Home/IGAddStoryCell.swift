//
//  IGAddStoryCell.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/6/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import UIKit

final class IGAddStoryCell: UICollectionViewCell {
    
    //MARK: - Overriden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadUIElements()
        installLayoutConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - iVars
    private let addStoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.alpha = 0.5
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    public var userDetails: (String,String)? {
        didSet {
            if let details = userDetails {
                addStoryLabel.text = details.0
                profileImageView.imageView.setImage(url: details.1)
            }
        }
    }
    
    private let profileImageView: IGRoundedView = {
        let roundedView = IGRoundedView()
        roundedView.translatesAutoresizingMaskIntoConstraints = false
        roundedView.enableBorder(enabled: false)
        return roundedView
    }()
    
    lazy var addImageView: UIImageView = {
        
        let iv = UIImageView(image: UIImage(systemName: "plus.circle.fill"))
        iv.tintColor = .systemGreen
        iv.backgroundColor = .white
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 20/2
        iv.layer.borderWidth = 2.0
        iv.layer.borderColor = UIColor.white.cgColor
        iv.clipsToBounds = true
        return iv
    }()
    
    //MARK: - Private functions
    private func loadUIElements() {
        addSubview(addStoryLabel)
        addSubview(profileImageView)
        addSubview(addImageView)
    }
    private func installLayoutConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 68),
            profileImageView.heightAnchor.constraint(equalToConstant: 68),
            profileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            profileImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor)])
        
        NSLayoutConstraint.activate([
            addStoryLabel.leftAnchor.constraint(equalTo: self.leftAnchor),
            addStoryLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
            addStoryLabel.topAnchor.constraint(equalTo: self.profileImageView.bottomAnchor, constant: 2),
            addStoryLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            addStoryLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)])
        
        NSLayoutConstraint.activate([
            addImageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5),
            addImageView.widthAnchor.constraint(equalToConstant: 20),
            addImageView.heightAnchor.constraint(equalToConstant: 20),
            addImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -25)])
        
        layoutIfNeeded()
    }
}
