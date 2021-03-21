//
//  ViewController.swift
//  InstagramFirebase
//
//  Created by 平尾健太 on 2021/01/13.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class SignUpController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK:パーツとその処理
    let plusPhotoButton:UIButton = {
        let button = UIButton(type:.system)
        
        button.setImage(UIImage(systemName: "person.crop.circle.fill"), for: .normal)
        button.tintColor = UIColor.mainPurple()
        
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        
        button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        
        return button
    }()
    
    @objc func handlePlusPhoto(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[.editedImage] as? UIImage {
            plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[.originalImage] as? UIImage {
            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width/2
        plusPhotoButton.layer.masksToBounds = true//trueにしないとcornerRadiusが反映されない
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    let emailTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.autocapitalizationType = .none
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChangde), for: .editingChanged)
        return tf
        
    }()
    
    let usernameTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "name"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChangde), for: .editingChanged)
        return tf
        
    }()
    
    let passwordTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "password"
        tf.isSecureTextEntry = true//パスワードを見えないようにする
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChangde), for: .editingChanged)
        return tf
        
    }()
    
    let signUpButon:UIButton = {
        let button = UIButton(type:.system)
        button.setTitle("登録", for: .normal)
        button.backgroundColor = UIColor.subPurple()
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)//ボタンの文字の色
        
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.isEnabled = false
        
        return button
    }()
    
    let alreadyHaveAccountButton:UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "すでにアカウントをお持ちの場合　",
                                                        attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize:14),
                                                                     NSAttributedString.Key.foregroundColor:UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "ログイン",
                                                  attributes: [NSAttributedString.Key.foregroundColor:UIColor.mainPurple(),
                                                               NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize:14)]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleAlreadyHaveAccount), for: .touchUpInside)
        return button
    }()
    
    @objc func handleAlreadyHaveAccount(){
        _ = navigationController?.popViewController(animated: true)//ひとつ前のviewControllerに戻る
    }
    
    @objc func handleTextInputChangde(){
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && usernameTextField.text?.count ?? 0 > 0 &&
            passwordTextField.text?.count ?? 0 > 0
        if isFormValid {
            signUpButon.backgroundColor = UIColor.mainPurple()
            signUpButon.isEnabled = true
        }else{
            signUpButon.backgroundColor = UIColor.subPurple()
            signUpButon.isEnabled = false
        }
    }
    
    //MARK:サインアップ
    @objc func handleSignUp(){
        guard let email = emailTextField.text, email.count > 0 else { return }
        guard let password = passwordTextField.text, password.count >= 6 else { return }
        guard  let username = usernameTextField.text, username.count > 0 else { return }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (res,error) in
            if let err = error {
                print("ユーザーの作成失敗:", err)
                return
            }
            
            let image = self.plusPhotoButton.imageView?.image
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
                    print(profileImageUrl)
                    guard let uid = res?.user.uid else { return }
                    
                    print("ユーザーの作成功:",uid)
                    
                    let values = ["username":username,
                                  "profileImageUrl":profileImageUrl]
                    
                    Firestore.firestore().collection("users").document(uid).setData(values) { (err) in
                        
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
            
        })
    }
    //MARK:ViewdidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(top: nil,
                                        left: view.leftAnchor,
                                        bottom: view.bottomAnchor,
                                        right: view.rightAnchor,
                                        paddingTop: 0,
                                        paddingLeft: 0,
                                        paddingBottom: -30,
                                        paddingRight: 0,
                                        width: 0,
                                        height: 50)
        view.addSubview(plusPhotoButton);//ボタンの追加
        
        plusPhotoButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 120, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 150, height: 150)
        
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true//viewの横方向の中心
        
        setupInputFields()
        
    }
    //MARK:スタックビューの操作
    fileprivate func setupInputFields(){
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField,usernameTextField,passwordTextField,signUpButon])//スタックに追加するviewを配列にして追加
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.distribution = .fillEqually//同じ幅で分断
        stackView.axis = .vertical//これがないと縦に分断される
        stackView.spacing = 10
        
        view.addSubview(stackView)
        
        stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 200)
    }
}

