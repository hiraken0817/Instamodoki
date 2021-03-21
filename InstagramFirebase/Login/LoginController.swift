//
//  LoginController.swift
//  InstagramFirebase
//
//  Created by 平尾健太 on 2021/01/31.
//

import UIKit
import FirebaseAuth

class LoginController:UIViewController{
    
    let logoContainerView:UIView = {
       let view = UIView()
        let logoImageView = UIImageView(image: UIImage(named: "instamodoki_2"))

        logoImageView.contentMode = .scaleAspectFill
        
        view.addSubview(logoImageView)
        logoImageView.anchor(top: view.topAnchor,
                             left:nil,
                             bottom:nil,
                             right: nil,
                             paddingTop: 150,
                             paddingLeft: 0,
                             paddingBottom: 0,
                             paddingRight: 0,
                             width: 200,
                             height: 50)
        
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        view.backgroundColor = .white
        return view
    }()
    
    let emailTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.text = "dummy8@gmail.com"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChangde), for: .editingChanged)
        return tf
        
    }()
    
    let passwordTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "password"
        tf.text = "123456"
        tf.isSecureTextEntry = true//パスワードを見えないようにする
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChangde), for: .editingChanged)
        return tf
        
    }()
    
    @objc func handleTextInputChangde(){
        let isFormValid = emailTextField.text?.count ?? 0 > 0 &&
            passwordTextField.text?.count ?? 0 > 0
        if isFormValid {
            loginButon.backgroundColor = UIColor.mainPurple()
            loginButon.isEnabled = true
        }else{
            loginButon.backgroundColor = UIColor.subPurple()
            loginButon.isEnabled = false
            
        }
    }
    
    let loginButon:UIButton = {
        let button = UIButton(type:.system)
        button.setTitle("ログイン", for: .normal)
        button.backgroundColor = UIColor.subPurple()
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)//ボタンの文字の色
        
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.isEnabled = false
        
        return button
    }()
    
    @objc func handleLogin(){
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, err) in
            if let err = err{
                print("ログイン失敗:",err)
                return
            }
            
            print("ログインに成功しました。")
            guard let mainTabBarController = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController as? MainTabBarController else { return }//
            mainTabBarController.setupViewContoroller()//setupControllerを呼び出す
            self.dismiss(animated: true, completion: nil)
            
        }
    }
    
    let dontHaveAccountButton:UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "アカウントを持っていない場合　",
                                                        attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize:14),
                                                                     NSAttributedString.Key.foregroundColor:UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "登録はこちら",
                                                attributes: [NSAttributedString.Key.foregroundColor:UIColor.mainPurple(),
                                                             NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize:14)]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    @objc func handleShowSignUp(){
        let signUpController = SignUpController()
        navigationController?.pushViewController(signUpController, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(logoContainerView)
        logoContainerView.anchor(top: view.topAnchor,
                                 left: view.leftAnchor,
                                 bottom: nil,
                                 right: view.rightAnchor,
                                 paddingTop: 0,
                                 paddingLeft: 0,
                                 paddingBottom: 0,
                                 paddingRight: 0,
                                 width: 0,
                                 height: 230)
        view.backgroundColor = .white
        
        navigationController?.isNavigationBarHidden = true
    
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(top: nil,
                            left: view.leftAnchor,
                            bottom: view.bottomAnchor,
                            right: view.rightAnchor,
                            paddingTop: 0,
                            paddingLeft: 0,
                            paddingBottom: -30,
                            paddingRight: 0,
                            width: 0,
                            height: 50)
        
        setupInputFields()
        
    }
    
    fileprivate func setupInputFields(){
        let stackView = UIStackView(arrangedSubviews: [emailTextField,passwordTextField,loginButon])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        stackView.anchor(top: logoContainerView.bottomAnchor,
                         left: view.leftAnchor,
                         bottom: nil,
                         right: view.rightAnchor,
                         paddingTop: 40,
                         paddingLeft: 40,
                         paddingBottom: 0,
                         paddingRight: 40,
                         width: 0,
                         height: 140)
    }

}
