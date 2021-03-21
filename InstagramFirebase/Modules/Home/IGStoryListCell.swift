//
//  IGStoryListCell.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/6/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import UIKit

final class IGStoryListCell: UICollectionViewCell {
    
    //MARK: - Public iVars
    public var story: IGStory? {
        didSet {
            self.storyProfileNameLabel.text = story?.user.name
            if let picture = story?.user.picture {
                self.storyProfileImageView.imageView.setImage(url: picture)
            }
        }
    }
    public var userDetails: (String,String)? {
        didSet {
            if let details = userDetails {
                self.storyProfileNameLabel.text = details.0
                self.storyProfileImageView.imageView.setImage(url: details.1)
            }
        }
    }
    
    //MARK: -  Private ivars
    private let storyProfileImageView: IGRoundedView = {
        let roundedView = IGRoundedView()
        roundedView.contentMode = .scaleAspectFit
        roundedView.translatesAutoresizingMaskIntoConstraints = false
        return roundedView
    }()
    
    private let storyProfileNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
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
    
    //MARK:- Private functions
    private func loadUIElements() {
        addSubview(storyProfileImageView)
        addSubview(storyProfileNameLabel)
    }
    private func installLayoutConstraints() {
        NSLayoutConstraint.activate([
            storyProfileImageView.widthAnchor.constraint(equalToConstant: 68),
            storyProfileImageView.heightAnchor.constraint(equalToConstant: 68),
            storyProfileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            storyProfileImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor)])

        NSLayoutConstraint.activate([
            storyProfileNameLabel.leftAnchor.constraint(equalTo: self.leftAnchor),
            storyProfileNameLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
            storyProfileNameLabel.topAnchor.constraint(equalTo: self.storyProfileImageView.bottomAnchor, constant: 2),
            storyProfileNameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            storyProfileNameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)])
        
        layoutIfNeeded()
    }
}
