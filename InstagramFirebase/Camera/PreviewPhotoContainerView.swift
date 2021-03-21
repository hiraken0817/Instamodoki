//
//  PreviewPhotoContainerView.swift
//  InstagramFirebase
//
//  Created by 平尾健太 on 2021/02/14.
//

import UIKit
import Photos

class PreviewPhotoContainerView: UIView {
    
    let previewImageView :UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    let cancelButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "multiply"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    @objc func handleCancel(){
        self.removeFromSuperview()
        
    }
    
    let saveButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.arrow.down"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()
    
    @objc func handleSave(){
        let library = PHPhotoLibrary.shared()
        
        guard let previewImage = previewImageView.image else { return }
        
        library.performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from:previewImage )
            
        }){ (success,err) in
            if let err = err {
                print("ライブラリーへの保存に失敗:",err)
                return
            }
            
            DispatchQueue.main.async {
                let savedLabel = UILabel()
                savedLabel.text = "保存しました"
                savedLabel.font = UIFont.boldSystemFont(ofSize: 18)
                savedLabel.textColor = .white
                savedLabel.textAlignment = .center
                savedLabel.numberOfLines = 0
                savedLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
                savedLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
                savedLabel.layer.cornerRadius = 10
                savedLabel.center = self.center
                self.addSubview(savedLabel)
                savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
                UIView.animate(withDuration: 0.5,
                    delay: 0,
                    options: .curveEaseOut,
                    animations: {
                        savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
                        
                    },
                    completion: { (completed) in
                        //completed
                        UIView.animate(withDuration: 0.5,
                                       delay: 0.75,
                                       usingSpringWithDamping: 0.5,
                                       initialSpringVelocity: 0.5,
                                       options: .curveEaseOut,
                                       animations: {
                                        savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                                        
                                       },
                                       completion: { (_) in
                                        savedLabel.removeFromSuperview()
                                        
                                       })
                        
                    })
                
            }
            
            
        }
    }
    
    override init(frame:CGRect){
        super.init(frame: frame)
        backgroundColor = .black
        addSubview(previewImageView)
        previewImageView.contentMode = .scaleAspectFill
        previewImageView.anchor(top: safeAreaLayoutGuide.topAnchor,
                                left: leftAnchor,
                                bottom: safeAreaLayoutGuide.bottomAnchor,
                                right: rightAnchor,
                                paddingTop: 0,
                                paddingLeft: 0,
                                paddingBottom: 0,
                                paddingRight: 0,
                                width: 0,
                                height: 0)
        
        addSubview(cancelButton)
        cancelButton.anchor(top: topAnchor,
                             left: nil,
                             bottom: nil,
                             right: rightAnchor,
                             paddingTop: 45,
                             paddingLeft: 0,
                             paddingBottom: 0,
                             paddingRight: 22,
                             width: 25,
                             height: 25)
        
        addSubview(saveButton)
        saveButton.anchor(top: nil,
                          left: leftAnchor,
                          bottom: bottomAnchor,
                          right: nil,
                          paddingTop: 0,
                          paddingLeft: 22,
                          paddingBottom: -45,
                          paddingRight: 0,
                          width: 40,
                          height: 40)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
