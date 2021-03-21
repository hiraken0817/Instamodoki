//
//  UserProfileHeader.swift
//  InstagramFirebase
//
//  Created by 平尾健太 on 2021/01/29.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

protocol UserProfileHeaderDelegate {
    func didChangeToListView()
    func didChangeToGridView()
    func didEdit(user:User)
    func startStory()
}

protocol FollowerDelegate{
    func didTapfollower(followerUserId:[String])
}

protocol FollowingDelegate{
    func didTapfollowing(followingUserId:[String])
}

class UserProfileHeader :UICollectionViewCell{
    
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "followOrUnfollow")
    
    var delegate:UserProfileHeaderDelegate?
    
    var followerDelegate:FollowerDelegate?
    var followingDelegate:FollowingDelegate?
    
    var user:User?{
        didSet{//最後に処理
            guard let profileImageUrl = user?.profileImageUrl else { return }
            profileImageView.loadImage(urlString: profileImageUrl)
            usernameLabel.text = user?.username
            
            introductionLabel.text = user?.intoroduce
            
            if introductionLabel.text == "" {
                
                editProfileFollowButton.anchor(top: usernameLabel.bottomAnchor,
                                               left: leftAnchor,
                                               bottom: nil,
                                               right: rightAnchor,
                                               paddingTop: 8,
                                               paddingLeft: 12,
                                               paddingBottom: 0,
                                               paddingRight: 12,
                                               width: 0,
                                               height: 34)
                
            }else{
            
                introductionLabel.anchor(top: usernameLabel.bottomAnchor,
                                         left: leftAnchor,
                                         bottom: nil,
                                         right: rightAnchor,
                                         paddingTop: 12,
                                         paddingLeft: 12,
                                         paddingBottom: 0,
                                         paddingRight: 12,
                                         width: 0,
                                         height: 0)
                
                editProfileFollowButton.anchor(top: introductionLabel.bottomAnchor,
                                               left: leftAnchor,
                                               bottom: nil,
                                               right: rightAnchor,
                                               paddingTop: 12,
                                               paddingLeft: 12,
                                               paddingBottom: 0,
                                               paddingRight: 12,
                                               width: 0,
                                               height: 34)
                
            }
            
            setupEditFollowButton()
            setupBottomToolBar()
            
            
        }
    }
    
    var postCount:Int?{
        didSet{
            let count = String(postCount!)
            let attributeText = NSMutableAttributedString(string: count + "\n", attributes:[ NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize:16)])
            attributeText.append(NSAttributedString(string: "投稿",
                                                    attributes: [NSAttributedString.Key.foregroundColor:UIColor.lightGray,
                                                                 NSAttributedString.Key.font:UIFont.systemFont(ofSize:14)]))
            postLabel.attributedText = attributeText
        }
    }
    
    var followingUserId = [String](){
        didSet{
            let count = String(followingUserId.count)
            let attributeText = NSMutableAttributedString(string: count + "\n", attributes:[ NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize:16)])
            attributeText.append(NSAttributedString(string: "フォロー中",
                                                    attributes: [NSAttributedString.Key.foregroundColor:UIColor.lightGray,
                                                                 NSAttributedString.Key.font:UIFont.systemFont(ofSize:14)]))
            followingLabel.attributedText = attributeText
        }
    }
    
    var followerUserId = [String](){
        didSet{
            let count = String(followerUserId.count)
            let attributeText = NSMutableAttributedString(string: count + "\n", attributes:[ NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize:16)])
            attributeText.append(NSAttributedString(string: "フォロワー",
                                                    attributes: [NSAttributedString.Key.foregroundColor:UIColor.lightGray,
                                                                 NSAttributedString.Key.font:UIFont.systemFont(ofSize:14)]))
            followersLabel.attributedText = attributeText
        }
    }
    
    fileprivate func setupEditFollowButton(){
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        guard let userId = user?.uid else { return }
        
        if currentLoggedInUserId == userId{
            //プロフィールの編集
            
            
        }else{
            //フォロー、アンフォロー
            
            let ref = Firestore.firestore().collection("following").document(currentLoggedInUserId)
                .collection("followingUser").document(userId)
            
            
            ref.getDocument() { (document, err) in
                if let err = err{
                    print("フォロー情報の取得失敗:",err)
                    return
                }
                
                //ドキュメントの有無
                if let document = document, document.exists{
                    //フォローしている
                    self.setupFollowStyle()
                    
                } else {
                    //フォローしていない
                    
                    self.setupUnFollowStyle()
                }
            }
            
        }
        
    }
    
    let profileImageView:CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = .white
        return iv
    }()
    
    lazy var gridButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.grid.3x3"), for: .normal)
        button.addTarget(self, action: #selector(handleChangeToGridView), for: .touchUpInside)
        button.tintColor = UIColor.mainPurple()
        return button
    }()
    
    @objc func handleChangeToGridView(){
        gridButton.tintColor = UIColor.mainPurple()
        listButton.tintColor = UIColor(white: 0, alpha: 0.2)
        bookmarkButton.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.didChangeToGridView()
    }
    
    lazy var listButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        button.addTarget(self, action: #selector(handleChangeToListView), for: .touchUpInside)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    @objc func handleChangeToListView(){
        gridButton.tintColor = UIColor(white: 0, alpha: 0.2)
        listButton.tintColor = UIColor.mainPurple()
        bookmarkButton.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.didChangeToListView()
    }
    
    lazy var bookmarkButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bookmark"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        button.addTarget(self, action: #selector(handleChangeToBookmarkView), for: .touchUpInside)
        return button
    }()
    
    @objc func handleChangeToBookmarkView(){
        gridButton.tintColor = UIColor(white: 0, alpha: 0.2)
        listButton.tintColor = UIColor(white: 0, alpha: 0.2)
        bookmarkButton.tintColor = UIColor.mainPurple()
    }
    
    let usernameLabel:UILabel = {
        let label = UILabel()
        label.text = "読み込み中..."
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    lazy var postLabel:UILabel = {
        let label = UILabel()
        
        let attributeText = NSMutableAttributedString(string: "\n", attributes:[ NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize:16)])
        attributeText.append(NSAttributedString(string: "投稿",
                                                attributes: [NSAttributedString.Key.foregroundColor:UIColor.lightGray,
                                                             NSAttributedString.Key.font:UIFont.systemFont(ofSize:14)]))
        label.attributedText = attributeText
        label.numberOfLines = 0//初期値は１
        label.textAlignment = .center
        
        label.isUserInteractionEnabled = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handlePost))
        
        label.addGestureRecognizer(tapGestureRecognizer)
        
        return label
    }()
    
    @objc func handlePost(){
        print("投稿")
        gridButton.tintColor = UIColor(white: 0, alpha: 0.2)
        listButton.tintColor = UIColor.mainPurple()
        bookmarkButton.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.didChangeToListView()
    }
    
    
    lazy var followersLabel:UILabel = {
        let label = UILabel()
        
        label.numberOfLines = 0
        let attributeText = NSMutableAttributedString(string: "\n", attributes:[ NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize:16)])
        attributeText.append(NSAttributedString(string: "フォロワー",
                                                attributes: [NSAttributedString.Key.foregroundColor:UIColor.lightGray,
                                                             NSAttributedString.Key.font:UIFont.systemFont(ofSize:14)]))
        label.attributedText = attributeText
        label.textAlignment = .center
        
        label.isUserInteractionEnabled = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleFollowerButton))
        label.addGestureRecognizer(tapGestureRecognizer)
    
        return label
    }()
    
    @objc func handleFollowerButton(){
        print("フォロワーボタン")
        followerDelegate?.didTapfollower(followerUserId: followerUserId)
    }

    lazy var followingLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        let attributeText = NSMutableAttributedString(string: "\n", attributes:[ NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize:16)])
        attributeText.append(NSAttributedString(string: "フォロー中",
                                                attributes: [NSAttributedString.Key.foregroundColor:UIColor.lightGray,
                                                             NSAttributedString.Key.font:UIFont.systemFont(ofSize:14)]))
        label.attributedText = attributeText
        label.textAlignment = .center
        
        label.isUserInteractionEnabled = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleFollowingButton))
        
        label.addGestureRecognizer(tapGestureRecognizer)
        
        return label
    }()
    
    lazy var introductionLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    @objc func handleFollowingButton(){
        print("フォロー中のユーザー")
        followingDelegate?.didTapfollowing(followingUserId: followingUserId)
    }

    lazy var editProfileFollowButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("プロフィールを編集する", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(handleEditProfileOrFollow), for: .touchUpInside)
        return button
    }()

    @objc func handleEditProfileOrFollow(){
        
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        
        guard let userId = user?.uid else { return }
        
        if currentLoggedInUserId == userId{
        
            self.delegate?.didEdit(user: user!)
            return
        }
        
        let followingRef = Firestore.firestore().collection("following").document(currentLoggedInUserId).collection("followingUser").document(userId)
        
        let followerRef = Firestore.firestore().collection("follower").document(userId).collection("followerUser").document(currentLoggedInUserId)
        
        if editProfileFollowButton.titleLabel?.text == "フォロー中"{
            //フォローしている
            followingRef.delete(){ [weak self] err in
                guard let weakSelf = self else { return }
                if let err = err{
                    print("アンフォロー失敗",err)
                    return
                }
                print("アンフォロー成功")
                
                followerRef.delete(){ err in
                    if let err = err{
                        print("フォロワー解除失敗",err)
                        return
                    }
                    print("解除成功")
                    
                    
                }
                weakSelf.setupUnFollowStyle()
                
            }
        }else{
            //フォローしていない
            let values = ["flg":1]
            followingRef.setData(values) { [weak self] (err) in
                
                guard let weakSelf = self else { return }
                
                if let err = err {
                    print("フォロー失敗:",err)
                    return
                }
                
                followerRef.setData(values){ err in
                    if let err = err{
                        print("フォロワー登録失敗",err)
                        return
                    }
                    print("登録成功")
                    
                }
                
                weakSelf.setupFollowStyle()
            }
        }
        NotificationCenter.default.post(name: UserProfileHeader.updateFeedNotificationName, object: nil)
    }
    
    
    lazy var storyPlusView:CustomImageView = {

        let iv = CustomImageView(image: UIImage(systemName: "person.crop.circle.fill"))
        iv.layer.borderColor = UIColor.systemGray4.cgColor
        iv.layer.borderWidth = 1
        iv.tintColor = .mainPurple()
        
        iv.contentMode = .scaleAspectFit
        
        iv.isUserInteractionEnabled = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleStory))
        
        iv.addGestureRecognizer(tapGestureRecognizer)
    
        return iv
    }()
    
    @objc func handleStory(){
        print("story")
        delegate?.startStory()

    }
    
    let plusView:UIImageView = {
       let plus = UIImageView(image: UIImage(systemName: "plus.circle.fill"))
        plus.tintColor = .systemGreen
        plus.backgroundColor = .white
        
        return plus
    }()
    
    let storyLabel:UILabel = {
       let label = UILabel()
        label.text = "ストーリーズ"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    let separateLine : UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.lightGray
        return line
    }()
    
    
//    @objc func handleStoryPlus(){
//        print("handleStoryPlus")
//    }

    override init(frame:CGRect){
        super.init(frame:frame)
        backgroundColor = .white
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor,
                                left: self.leftAnchor,
                                bottom: nil,
                                right: nil,
                                paddingTop: 12,
                                paddingLeft: 15,
                                paddingBottom: 0,
                                paddingRight: 0,
                                width: 90,
                                height: 90)
        
        profileImageView.layer.cornerRadius = 90/2
        profileImageView.clipsToBounds = true
        
        addSubview(editProfileFollowButton)
        addSubview(introductionLabel)
        
        setupBottomToolBar()
        
        addSubview(usernameLabel)
        
        usernameLabel.anchor(top: profileImageView.bottomAnchor,
                             left: leftAnchor,
                             bottom: nil,
                             right: rightAnchor,
                             paddingTop: 12,
                             paddingLeft: 12,
                             paddingBottom: 0,
                             paddingRight: 12,
                             width: 0,
                             height: 0)
        
        
        storyPlusView.layer.cornerRadius = 80/2
        storyPlusView.clipsToBounds = true
        
        plusView.layer.cornerRadius = 25/2
        plusView.clipsToBounds = true
        
        
    }
    
    
    fileprivate func setupBottomToolBar(){
        
        let topDividerView = UIView()
        topDividerView.backgroundColor = UIColor.lightGray
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = UIColor.lightGray
        
        let stackView = UIStackView(arrangedSubviews: [gridButton,listButton])
        
        stackView.axis = .horizontal//横並び
        stackView.distribution = .fillEqually//均等な幅にする
        
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        addSubview(stackView)
        
        setupProfileStatusView()
        
        let loginUid = Auth.auth().currentUser?.uid
        guard let currentUid = user?.uid else { return }
        
        if loginUid == currentUid{
            addSubview(separateLine)
            addSubview(storyPlusView)
            addSubview(plusView)
            addSubview(storyLabel)
            separateLine.anchor(top: editProfileFollowButton.bottomAnchor,
                                  left: leftAnchor,
                                  bottom: nil,
                                  right: rightAnchor,
                                  paddingTop: 12,
                                  paddingLeft:12,
                                  paddingBottom: 0,
                                  paddingRight: 12,
                                  width: 0,
                                  height: 0.5)
            
            storyPlusView.anchor(top: separateLine.bottomAnchor,
                                   left: leftAnchor,
                                   bottom: nil,
                                   right: nil,
                                   paddingTop: 12,
                                   paddingLeft: 12,
                                   paddingBottom: 0,
                                   paddingRight: 0,
                                   width: 80,
                                   height: 80)
            
            plusView.anchor(top: storyPlusView.topAnchor,
                            left: storyPlusView.leftAnchor,
                            bottom: nil,
                            right: nil,
                            paddingTop: 55,
                            paddingLeft: 55,
                            paddingBottom: 0,
                            paddingRight: 0,
                            width: 25,
                            height: 25)
            
            storyLabel.anchor(top: storyPlusView.bottomAnchor,
                              left: storyPlusView.leftAnchor,
                              bottom: nil,
                              right: storyPlusView.rightAnchor,
                              paddingTop: 4,
                              paddingLeft: 0,
                              paddingBottom: 0,
                              paddingRight: 0,
                              width: 80,
                              height: 0)
            
            
        stackView.anchor(top: storyLabel.bottomAnchor,
                         left: leftAnchor,
                         bottom: bottomAnchor,
                         right: rightAnchor,
                         paddingTop: 12,
                         paddingLeft: 0,
                         paddingBottom: 0,
                         paddingRight: 0,
                         width: 0,
                         height: 50)
            storyPlusView.loadImage(urlString: user!.profileImageUrl)
            
        }else{
            stackView.anchor(top: editProfileFollowButton.bottomAnchor,
                             left: leftAnchor,
                             bottom: bottomAnchor,
                             right: rightAnchor,
                             paddingTop: 12,
                             paddingLeft: 0,
                             paddingBottom: 0,
                             paddingRight: 0,
                             width: 0,
                             height: 50)
        }
        
        topDividerView.anchor(top: stackView.topAnchor,
                              left: leftAnchor,
                              bottom: nil,
                              right: rightAnchor,
                              paddingTop: 0,
                              paddingLeft: 0,
                              paddingBottom: 0,
                              paddingRight: 0,
                              width: 0,
                              height: 0.5)
        
        bottomDividerView.anchor(top: nil,
                                 left: leftAnchor,
                                 bottom: stackView.bottomAnchor,
                                 right: rightAnchor,
                                 paddingTop: 0,
                                 paddingLeft: 0,
                                 paddingBottom: 0,
                                 paddingRight: 0,
                                 width: 0,
                                 height: 0.5)
        
    }
        
    fileprivate func setupProfileStatusView(){
        let stackView = UIStackView(arrangedSubviews: [postLabel,followersLabel,followingLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.anchor(top: topAnchor,
                         left: profileImageView.rightAnchor,
                         bottom: nil,
                         right: rightAnchor,
                         paddingTop: 40,
                         paddingLeft: 5,
                         paddingBottom: 0,
                         paddingRight: 12,
                         width: 0,
                         height: 0)
    }
    
    fileprivate func setupFollowStyle(){
        self.editProfileFollowButton.setTitle("フォロー中", for: .normal)
        self.editProfileFollowButton.backgroundColor = .white
        self.editProfileFollowButton.setTitleColor(.black, for: .normal)
        self.editProfileFollowButton.layer.borderColor = UIColor.systemGray.cgColor
    }
    
    fileprivate func setupUnFollowStyle(){
        self.editProfileFollowButton.setTitle("フォローする", for: .normal)
        self.editProfileFollowButton.backgroundColor = UIColor.mainPurple()
        self.editProfileFollowButton.setTitleColor(.white, for: .normal)
        self.editProfileFollowButton.layer.borderColor = UIColor.mainPurple().cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
