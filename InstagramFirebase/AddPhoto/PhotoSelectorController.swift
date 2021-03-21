//
//  PhotoSelectorController.swift
//  InstagramFirebase
//
//  Created by 平尾健太 on 2021/02/03.
//

import UIKit
import Photos//photosframework

class PhotoSelectorController:UICollectionViewController,UICollectionViewDelegateFlowLayout{
    
    let cellId = "cellId"
    let headerId = "headerId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        
        setupNavigationButtons()
        
        collectionView?.register(PhotoSelectorCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(PhotoSelectorHeader.self,forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier:headerId )
        
        fetchPhotos()
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print(indexPath)
        self.selectedImage = images[indexPath.item]
        self.collectionView.reloadData()
        
        let indexPath = IndexPath(item:0,section:0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated:true )//選択すると上にいく
        
        
    }
    
    var selectedImage:UIImage?
    var images = [UIImage]()
    var assets = [PHAsset]()
    
    fileprivate func assetsFetchOptions() -> PHFetchOptions{
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 32
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)//新しい順にソート
        fetchOptions.sortDescriptors = [sortDescriptor]
        return fetchOptions
    }
    
    fileprivate func fetchPhotos(){
        let allPhotos = PHAsset.fetchAssets(with: .image,options: assetsFetchOptions())
        
        DispatchQueue.global(qos: .background).async {
            
            allPhotos.enumerateObjects({ (asset,count,stop) in
                
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                
                imageManager.requestImage(for: asset,
                                          targetSize: targetSize,
                                          contentMode: .aspectFit,
                                          options: options,
                                          resultHandler: {
                                            (image,info) in
                                            //                                        print(image)
                                            if let image = image {
                                                self.images.append(image)//images配列にimageを格納
                                                self.assets.append(asset)
                                                if self.selectedImage == nil {//header部分の初期画像
                                                    self.selectedImage = image
                                                }
                                            }
                                            
                                            if count == allPhotos.count - 1{//全ての画像を読み込んだら
                                                DispatchQueue.main.async {
                                                    self.collectionView.reloadData()//再更新し、画像を表示させる
                                                }
                                                
                                            }
                                          })
            })
            
        }
        
        
        
        
    }
    
    //headerその下のセルの間のスペース
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: width)
    }
    
    var header:PhotoSelectorHeader?
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! PhotoSelectorHeader
        
        self.header = header//グローバル変数にheaderを格納
        
        header.photoImageView.image = selectedImage
        
        if let selectedImage = selectedImage{
            if let index = self.images.firstIndex(of:selectedImage){
                let selectedAsset = self.assets[index]
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 600, height: 600)//headerの画質は良くする
                imageManager.requestImage(for: selectedAsset,
                                          targetSize: targetSize,
                                          contentMode: .default,
                                          options: nil,
                                          resultHandler: { (image,info) in
                                            header.photoImageView.image = image
                                            
                                          })
            }
        }
        
        
        
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PhotoSelectorCell
        cell.photoImageView.image = images[indexPath.item]
        return cell
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    
    
    fileprivate func setupNavigationButtons(){
        navigationController?.navigationBar.tintColor = .mainPurple()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "次へ", style: .plain, target: self, action: #selector(handleNext))
    }
    @objc func handleNext(){
//        print("hadling next ")
        let sharePhotoController = SharePhotoController()
        sharePhotoController.selectedImage = header?.photoImageView.image//sharephotoController内にあるselectedimageに値を入れる
        navigationController?.pushViewController(sharePhotoController, animated: true)
        
    }
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
}
