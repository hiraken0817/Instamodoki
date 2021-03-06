//
//  PhotoSelectionCell.swift
//  InstagramFirebase
//
//  Created by 平尾健太 on 2021/02/04.
//

import UIKit

class PhotoSelectorCell: UICollectionViewCell {
    
    let photoImageView:UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .lightGray
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true//枠内にトリミング
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(photoImageView)
        photoImageView.anchor(top: topAnchor,
                              left: leftAnchor,
                              bottom: bottomAnchor,
                              right: rightAnchor,
                              paddingTop: 0,
                              paddingLeft: 0,
                              paddingBottom: 0,
                              paddingRight: 0,
                              width: 0,
                              height: 0 )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
