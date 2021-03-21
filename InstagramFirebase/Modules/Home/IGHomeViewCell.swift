//
//  IGHomeView.swift
//  InstagramStories
//
//  Created by  Boominadha Prakash on 01/11/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

protocol IGHomeViewCellDelegate{
    func didTapAddStory()
    func didTapWatchStory(viewModel:IGHomeViewModel,indexPath: IndexPath)
}

class IGHomeViewCell: UITableViewCell {
    
    private var viewModel: IGHomeViewModel = IGHomeViewModel()
    
    var delegate :IGHomeViewCellDelegate?
    
    //MARK: - iVars
    lazy var layout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 100, height: 100)
        return flowLayout
    }()
    
    //ヘッダー
    lazy var storyCollectionView: UICollectionView = {
        let cv = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.register(IGStoryListCell.self, forCellWithReuseIdentifier: IGStoryListCell.reuseIdentifier)
        cv.register(IGAddStoryCell.self, forCellWithReuseIdentifier: IGAddStoryCell.reuseIdentifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    //MARK: - Overridden functions
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier )
        backgroundColor = UIColor.rgb(from: 0xEFEFF4)
        
        installLayoutConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Private functions
    
    private func installLayoutConstraints(){
        addSubview(storyCollectionView)

        storyCollectionView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
    }
}




extension IGHomeViewCell: UICollectionViewDelegate,UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItemsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGAddStoryCell.reuseIdentifier, for: indexPath) as? IGAddStoryCell else { fatalError() }
            let loginUser = Auth.auth().currentUser?.uid
            
            Firestore.fetchUserWithUID(uid: loginUser!, completion: {
                (user) in
                let userImage:String = user.profileImageUrl
                cell.userDetails = ("ストーリーズ",userImage)//ここに自分のプロフィール画像を入れる
            })
            
            return cell
        }else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGStoryListCell.reuseIdentifier,for: indexPath) as? IGStoryListCell else { fatalError() }
            let story = viewModel.cellForItemAt(indexPath: indexPath)
            cell.story = story
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            delegate?.didTapAddStory()
//            let cameraController = CameraController()
//            cameraController.modalPresentationStyle = .fullScreen
//            present(cameraController,animated: true,completion: nil)
        }else {
            
            delegate?.didTapWatchStory(viewModel: viewModel, indexPath: indexPath)
//            DispatchQueue.main.async {
//                if let stories = self.viewModel.getStories(), let stories_copy = try? stories.copy() {
//                    let storyPreviewScene = IGStoryPreviewController.init(stories: stories_copy, handPickedStoryIndex:  indexPath.row-1)
//                    self.present(storyPreviewScene, animated: true, completion: nil)
//                }
//            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return indexPath.row == 0 ? CGSize(width: 80, height: 100) : CGSize(width: 80, height: 100)
    }
}
