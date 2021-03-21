//
//  LikeListController.swift
//  InstagramFirebase
//
//  Created by 平尾健太 on 2021/03/12.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

class LikeListController:UICollectionViewController,UICollectionViewDelegateFlowLayout,FollowFollowerCellDelegate{
    
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "UpdateLikeList")
    
    let cellId = "cellId"
    
    var delegate:FollowFollowerCell?
    
    var userId:String?
    
    var filteredUsers = [User]()
    var users = [User]()
    
    var likeMember = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        
        collectionView.register(FollowFollowerCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView.alwaysBounceVertical = true
        
        self.navigationItem.title = "いいねしたユーザー"
        self.navigationController?.navigationBar.tintColor = UIColor.mainPurple()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        filteredUsers.removeAll()
        users.removeAll()
        fetchUsers()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if !filteredUsers.isEmpty {
            let user = filteredUsers[indexPath.item]
            let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
            userProfileController.userId = user.uid
            navigationController?.pushViewController(userProfileController, animated: true)
        }
    }
    
    fileprivate func fetchUsers(){
        print(likeMember)

        guard  let currentUid = Auth.auth().currentUser?.uid else { return }
        
        for uid in likeMember {
            
            //フォローしているユーザーのユーザー情報を取得する
            Firestore.firestore().collection("users").document(uid).getDocument(source: .cache) { [weak self] (document, error) in
                
                guard let weakSelf = self else { return }
                if let document = document {
                    
                    let userDictionary = document.data()
                    var user = User(uid: uid,dictionary: userDictionary!)
                    
                    //                        print(currentUid)
                    //                        print(document.documentID)
                    
                    //フォローしているユーザーをログインしているユーザーがフォローしているかどうか調べる
                    let ref = Firestore.firestore().collection("following").document(currentUid).collection("followingUser").document(document.documentID)
                    
                    ref.getDocument() { (document, err) in
                        
                        if let err = err{
                            print("フォロー情報の取得失敗:",err)
                            return
                        }
                        
                        //ドキュメントの有無
                        if let document = document, document.exists,document.data()?["flg"] as! Int == 1 {
                            //フォロー
                            user.hasFollowed = true
                            print("follow")
                        } else {
                            //フォローしていない
                            user.hasFollowed = false
                            print("notfollow")
                        }
                        
                        weakSelf.users.append(user)
                        
                        //名前順abcd順に並び替え
                        weakSelf.users.sort(by: {(u1,u2) -> Bool in
                            return u1.username.compare(u2.username) == .orderedAscending
                        })
                        
                        weakSelf.filteredUsers = self!.users
                        weakSelf.collectionView.reloadData()
                    }
                    
                } else {
                    print("Document does not exist in cache")
                }
            }
            
            
            
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("filteredUsers.count:",filteredUsers.count)
        return filteredUsers.count
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FollowFollowerCell
        cell.user = filteredUsers[indexPath.item]
        
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 66)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func didFollowOrUnfollow(for cell: FollowFollowerCell) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        var userInfo = self.filteredUsers[indexPath.item]
        print(userInfo.hasFollowed)
        
        let userId = userInfo.uid
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let values = ["flg":1] as [String : Any]
        
        //trueの時0に変える
        let followOrUnfollow = userInfo.hasFollowed
        
        let followingRef = Firestore.firestore().collection("following").document(currentUid).collection("followingUser").document(userId)
        
        
        let followerRef = Firestore.firestore().collection("follower").document(userId).collection("followerUser").document(currentUid)
        
        if followOrUnfollow{
            //ログイン中のユーザがフォローしているuserId
            followingRef.delete(){ err in
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
            }
        }else{
            followingRef.setData(values) { err in
                
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
                
            }
        }
        
        userInfo.hasFollowed = !userInfo.hasFollowed//true,falseを逆にする
        
        self.filteredUsers[indexPath.item] = userInfo
        
        self.collectionView?.reloadItems(at: [indexPath])//一部更新
        
        //        NotificationCenter.default.post(name: FollowingController.updateFeedNotificationName, object: nil)
        
    }
    
}


