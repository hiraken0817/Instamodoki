//
//  SharePhotoController.swift
//  InstagramFirebase
//
//  Created by 平尾健太 on 2021/02/05.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

class SharePhotoController: UIViewController {
    
    var selectedImage:UIImage?{
        didSet{
            self.imageView.image = selectedImage
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "シェア", style: .plain, target: self, action: #selector(handleShare))
        
        setupImageAndTextViews()
    }
    
    let imageView :UIImageView = {
       let iv = UIImageView()
        iv.backgroundColor = .white
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let textView:UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        return tv
    }()
    
    fileprivate func setupImageAndTextViews(){
        let containerView = UIView()
        containerView.backgroundColor = .white
        
        view.addSubview(containerView)
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                             left: view.leftAnchor,
                             bottom: nil,
                             right: view.rightAnchor,
                             paddingTop: 0,
                             paddingLeft: 0,
                             paddingBottom: 0,
                             paddingRight: 0,
                             width: 0,
                             height: 100)
        
        containerView.addSubview(imageView)
        imageView.anchor(top: containerView.topAnchor,
                         left: containerView.leftAnchor,
                         bottom: containerView.bottomAnchor,
                         right: nil,
                         paddingTop: 8,
                         paddingLeft: 8,
                         paddingBottom: -8,
                         paddingRight: 0,
                         width: 84,
                         height: 84)
        containerView.addSubview(textView)
        textView.anchor(top: containerView.topAnchor,
                        left: imageView.rightAnchor,
                        bottom: containerView.bottomAnchor,
                        right: containerView.rightAnchor,
                        paddingTop: 0,
                        paddingLeft: 4,
                        paddingBottom: 0,
                        paddingRight: 0,
                        width: 0,
                        height: 0)
        
        
    }
    
    @objc func handleShare(){
        guard let caption = textView.text,caption.utf16.count > 0 else { return }
        guard let image = selectedImage else { return }
        
        guard let updateData = image.jpegData(compressionQuality: 0.5) else { return }//画像データの変換
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        let filename = NSUUID().uuidString//ランダムな文字列生成
        let storageRef = Storage.storage().reference().child("posts").child(filename)
        
        storageRef.putData(updateData, metadata: nil){
            (metadata,err) in
            if let err = err{
                print("写真のアップロード失敗 :",err)
                return
            }
            storageRef.downloadURL { (url, err) in//urlの取得
                if let err = err {
                    print("Firestorageからのダウンロードに失敗\(err)")
                    
                    return
                }
                
                
                guard let profileImageUrl = url?.absoluteString else { return }
                print("成功",profileImageUrl)

                self.saveToDatabaseWithImageUrl(imageUrl: profileImageUrl)
            }
        }
    }
    
    //IDを割り当てる関数
    func randomString(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
    
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "update")
    
    fileprivate func saveToDatabaseWithImageUrl(imageUrl:String){
        guard let postImage = selectedImage else { return }
        guard let caption = textView.text else { return }
        
        let userPostId = randomString(length: 20)
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userPostRef = Firestore.firestore().collection("posts").document(uid).collection("photos").document(userPostId)
        
        let values = ["imageUrl": imageUrl,
                      "caption":caption,
                      "imageWidth":postImage.size.width,
                      "creationDate":Date().timeIntervalSince1970] as [String : Any]
        
        userPostRef.setData(values){ (err) in
            if let err = err {
                print("ポスト失敗",err)
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                return
            }
            self.dismiss(animated: true, completion: nil)
            
            NotificationCenter.default.post(name: SharePhotoController.updateFeedNotificationName, object: nil)
        }
    }
    
    

    override var prefersStatusBarHidden: Bool{
        return true
    }
    
}
