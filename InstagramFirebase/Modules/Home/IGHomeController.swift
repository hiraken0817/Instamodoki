//
//  IGHomeController.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/6/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

//let DEL_CACHE_ENABLED = false

final class IGHomeController: UIViewController {
    
    //MARK: - iVars
    private var _view: IGHomeViewCell{return view as! IGHomeViewCell}
    private var viewModel: IGHomeViewModel = IGHomeViewModel()
    
    //MARK: - Overridden functions
    override func loadView() {
        super.loadView()
        view = IGHomeViewCell(frame: UIScreen.main.bounds)
        _view.storyCollectionView.delegate = self
        _view.storyCollectionView.dataSource = self
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var navigationItem: UINavigationItem {
        let navigationItem = UINavigationItem()
       
        if DEL_CACHE_ENABLED {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Del.CACHE", style: .done, target: self, action: #selector(clearImageCache))
            navigationItem.rightBarButtonItem?.tintColor = UIColor.init(red: 203.0/255, green: 69.0/255, blue: 168.0/255, alpha: 1.0)
        }
        return navigationItem
    }
    
    //MARK: - Private functions
    @objc private func clearImageCache() {
        IGCache.shared.removeAllObjects()
    }
}

//MARK: - Extension|UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
extension IGHomeController: UICollectionViewDelegate,UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItemsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGAddStoryCell.reuseIdentifier, for: indexPath) as? IGAddStoryCell else { fatalError() }
            
            let loginUser = Auth.auth().currentUser?.uid
            var userImage:String?
            Firestore.fetchUserWithUID(uid: loginUser!, completion: {
                (user) in
                userImage = user.profileImageUrl
                cell.userDetails = ("ストーリーズ",userImage!)
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
            let cameraController = CameraController()
            cameraController.modalPresentationStyle = .fullScreen
            present(cameraController,animated: true,completion: nil)
        }else {
            DispatchQueue.main.async {
                if let stories = self.viewModel.getStories(), let stories_copy = try? stories.copy() {
                    let storyPreviewScene = IGStoryPreviewController.init(stories: stories_copy, handPickedStoryIndex:  indexPath.row-1)
                    self.present(storyPreviewScene, animated: true, completion: nil)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return indexPath.row == 0 ? CGSize(width: 80, height: 100) : CGSize(width: 80, height: 100)
    }
}
