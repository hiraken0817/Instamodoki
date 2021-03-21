//
//  UserSearchController.swift
//  InstagramFirebase
//
//  Created by 平尾健太 on 2021/02/08.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class UserSearchController:UICollectionViewController,UICollectionViewDelegateFlowLayout,UISearchBarDelegate{
    
    let cellId = "cellId"
    
    lazy var searchBar:UISearchBar = {
       let sb = UISearchBar()
        sb.autocapitalizationType = .none
        sb.placeholder = "検索"
        sb.delegate = self//lazyにしないといけない
        return sb
    }()
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{
            filteredUsers = users
        }else{
            filteredUsers = self.users.filter{ (user) -> Bool in
                return user.username.lowercased().contains(searchText.lowercased())
            }
        }
        self.collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        self.navigationController?.navigationBar.barTintColor = .white
        let navBar = navigationController?.navigationBar
        
        navigationController?.navigationBar.addSubview(searchBar)
        searchBar.anchor(top: navBar?.topAnchor,
                         left: navBar?.leftAnchor,
                         bottom: navBar?.bottomAnchor,
                         right: navBar?.rightAnchor,
                         paddingTop: 0,
                         paddingLeft: 8,
                         paddingBottom: 0,
                         paddingRight: 8,
                         width: 0,
                         height: 0)
        
        collectionView.register(UserSearchCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag//ドラッグでキーボードをしまう
        
        fetchUsers()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.isHidden = false
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        searchBar.isHidden = true
        searchBar.resignFirstResponder()//キーボードしまう
        let user = filteredUsers[indexPath.item]

        let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.userId = user.uid
        navigationController?.pushViewController(userProfileController, animated: true)
    }
    
    var filteredUsers = [User]()
    var users = [User]()
    fileprivate func fetchUsers(){
        Firestore.firestore().collection("users").getDocuments(){ (snapshot, err) in
            if let err = err {
                print("ユーザー情報の取得に失敗しました: \(err)")
                return
            }
            for document in snapshot!.documents {
                
                let uid = document.documentID
                
                if uid == Auth.auth().currentUser?.uid{
//                    print("検索結果から自分を外す")
                    continue
                }
                
                let userDictionary = document.data()
                let user = User(uid: uid,dictionary: userDictionary)
                self.users.append(user)
                
            }
            
            //名前順abcd順に並び替え
            self.users.sort(by: {(u1,u2) -> Bool in
                return u1.username.compare(u2.username) == .orderedAscending
            })
            
            self.filteredUsers = self.users
            self.collectionView.reloadData()
            
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserSearchCell
        cell.user = filteredUsers[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 66)
    }
}
