//
//  UserProfileEditController.swift
//  InstagramFirebase
//
//  Created by 平尾健太 on 2021/03/14.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

class UserProfileEditController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    
    var user:User?{
        didSet{
            guard let profileImageUrl = user?.profileImageUrl else { return }
            
            guard let url = URL(string: profileImageUrl) else { return }
            
            URLSession.shared.dataTask(with: url){ [weak self] (data,response,err)
                in
                
                if let err = err{
                    print("画像の取得に失敗しました",err)
                    return
                }
                
                guard let imageData = data else { return }
                
                let photoImage = UIImage(data: imageData)
                
                imageCache[url.absoluteString] = photoImage
                
                DispatchQueue.main.async { [self] in//非同期処理
                    self!.editPhotoButton.setImage(photoImage, for: .normal)
                    self!.editPhotoButton.layer.cornerRadius = self!.editPhotoButton.frame.width/2
                    self!.editPhotoButton.layer.masksToBounds = true//trueにしないとcornerRadiusが反映されない
                }
                
            }.resume()
            
            let count = String((user?.intoroduce.utf16.count)! as Int)
            wordCountLabel.text = "\(count)/150"
            
            introduceTextView.text = user?.intoroduce
            
            nameTextField.text = user?.username
        }
    }
    
    fileprivate var maxWordCount: Int = 150 //最大文字数
    
    lazy var editPhotoButton:UIButton = {
        let button = UIButton(type:.custom)
        
        button.setImage(UIImage(systemName: "person.crop.circle.fill"), for: .normal)
        button.tintColor = UIColor.mainPurple()
        
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        
        button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        
        return button
    }()
    
    lazy var wordCountLabel:UILabel = {
        let label = UILabel()
        label.text = "0/150"
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    
    @objc func handlePlusPhoto(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[.editedImage] as? UIImage {
            editPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[.originalImage] as? UIImage {
            editPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        editPhotoButton.layer.cornerRadius = editPhotoButton.frame.width/2
        editPhotoButton.layer.masksToBounds = true//trueにしないとcornerRadiusが反映されない
        
        dismiss(animated: true, completion: nil)
    }
    
    lazy var editPhotoText:UILabel = {
        let label = UILabel()
        label.text = "プロフィール写真を変更する"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .mainPurple()
        return label
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "名前"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    let introduceLabel: UILabel = {
        let label = UILabel()
        label.text = "自己紹介"
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    let nameTextField:UITextField = {
        let tf = UITextField()
        tf.autocapitalizationType = .none
        tf.font = UIFont.systemFont(ofSize: 16)
        return tf
    }()
    
    let introduceTextView:UITextView = {
        let tv = UITextView()
        tv.autocapitalizationType = .none
        tv.returnKeyType = .done
        tv.font = UIFont.systemFont(ofSize: 16)
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationButtons()
        
        view.addSubview(editPhotoButton)
        view.addSubview(editPhotoText)
        
        self.introduceTextView.delegate = self
        
        editPhotoButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        
        editPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true//viewの横方向の中心
        
        editPhotoText.anchor(top: editPhotoButton.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        editPhotoText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true//viewの横方向の中心
        
        let separateLine = UIView()
        separateLine.backgroundColor = .systemGray
        
        view.addSubview(separateLine)
        
        separateLine.anchor(top: editPhotoText.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.3)
        
        view.addSubview(nameLabel)
        nameLabel.anchor(top: separateLine.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 90, height: 0)
        
        view.addSubview(nameTextField)
        nameTextField.anchor(top: separateLine.bottomAnchor, left: nameLabel.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        let separateLine2 = UIView()
        separateLine2.backgroundColor = .systemGray
        
        view.addSubview(separateLine2)
        
        separateLine2.anchor(top: nameTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 15, paddingLeft: 100, paddingBottom: 0, paddingRight: 10, width: 0, height: 0.3)
        
        view.addSubview(introduceLabel)
        introduceLabel.anchor(top: nameLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 90, height: 0)
        
        view.addSubview(introduceTextView)
        introduceTextView.anchor(top: separateLine2.bottomAnchor, left: introduceLabel.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft:  0, paddingBottom: 0, paddingRight: 8, width: 0, height: 120)
        
        let separateLine3 = UIView()
        separateLine3.backgroundColor = .systemGray
        
        view.addSubview(separateLine3)
        
        separateLine3.anchor(top: introduceTextView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 15, paddingLeft: 100, paddingBottom: 0, paddingRight: 10, width: 0, height: 0.3)
        
        view.addSubview(wordCountLabel)
        wordCountLabel.anchor(top:separateLine3.bottomAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 6, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        
        
        //下にスワイプでキーボードを下げる
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        swipeDownGesture.direction = .down
        self.view.addGestureRecognizer(swipeDownGesture)
        
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    
    fileprivate func setupNavigationButtons(){
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = .mainPurple()
        navigationItem.title = "プロフィール編集"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完了", style: .plain, target: self, action: #selector(handleComplete))
    }
    
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    //MARK:編集
    @objc func handleComplete(){
        guard let uid = user?.uid else { return }
        guard let username = nameTextField.text, username.count > 0 else { return }
        guard let introduce = introduceTextView.text, introduce.count >= 0 else { return }
        
        let image = editPhotoButton.imageView?.image
        guard let uploadData = image?.jpegData(compressionQuality: 0.3) else { return }//画像データの変換
        
        let filename = NSUUID().uuidString//uuid(ランダムに生成される文字列)の生成
        let storageRef = Storage.storage().reference().child("profile_image").child(filename)
        
        storageRef.putData(uploadData,metadata: nil,completion: { (metadata,err) in
            
            if let err = err {
                print("ストレージへの保存に失敗しました",err)
                return
            }
            print("保存成功")
            
            storageRef.downloadURL { (url, err) in//urlの取得
                
                if let err = err {
                    print("Firestorageからのダウンロードに失敗しました。\(err)")
                    return
                }
                
                guard let profileImageUrl = url?.absoluteString else { return }
                
                print("ユーザーの作成功:",uid)
                
                let values = ["username":username,
                              "profileImageUrl":profileImageUrl,
                              "intoroduce":introduce]
                
                Firestore.firestore().collection("users").document(uid).updateData(values) { (err) in
                    
                    if let err = err {
                        print("ユーザーの作成失敗:",err)
                        return
                    }
                    print("ユーザー名保存成功")
                    guard let mainTabBarController = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController as? MainTabBarController else { return }//
                    mainTabBarController.setupViewContoroller()//setupControllerを呼び出す
                    
                    self.dismiss(animated: true, completion: nil)//ログインコントローラーを閉じる
                }
            }
            
        })
        
    }
    
}

extension UserProfileEditController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + (text.count - range.length) <= maxWordCount
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.wordCountLabel.text = "\(textView.text.count)/\(maxWordCount)"
    }
    
    
}
