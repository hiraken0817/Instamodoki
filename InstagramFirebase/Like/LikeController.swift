//
//  LikeController.swift
//  InstagramFirebase
//
//  Created by 平尾健太 on 2021/02/28.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LikePostController: UICollectionViewController,UICollectionViewDelegateFlowLayout, LikePostCellDelegate {
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharePhotoController.updateFeedNotificationName, object: nil)
        
        collectionView.backgroundColor = .white
        collectionView.register(LikePostCell.self, forCellWithReuseIdentifier: cellId)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        navigationItem.title = "いいね!"
        self.navigationController?.navigationBar.barTintColor = .white
        posts.removeAll()
        fetchLikes()
        
        
    }
    
    @objc func handleRefresh(){
        posts.removeAll()
        fetchLikes()
    }
    
    @objc func handleUpdateFeed(){
        handleRefresh()
    }
    
    fileprivate func fetchLikes(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("likes").document(uid).collection("like").getDocuments(){ (querySnapshot, err) in
            if let err = err {
                print("idの取得失敗: \(err)")
            } else {
                for document in querySnapshot!.documents {
//                    print("Like:",document.data()["uid"]!)
                    let likeUid = document.data()["uid"] as! String
                    let flg = document.data()["flg"] as! Int
                    let postId = document.documentID
                    Firestore.fetchUserWithUID(uid: likeUid, completion: {
                        (user) in
                        
                        if flg == 1{
                            
                            self.fetchPostsWithLike(user: user,postId: postId)
                            
                        }
                        
                    })
                }
            }
        }
    }
    
    
    var posts = [Post]()
    
    fileprivate func fetchPostsWithLike(user:User,postId:String){
        let photosRef = Firestore.firestore().collection("posts").document(user.uid).collection("photos").document(postId)
        
        //        photosRef.order(by: "creationDate", descending: true).getDocuments(){ (snapshots, err) in
        
        photosRef.getDocument(source: .cache) { (document, error) in
            if let document = document {
                let dictionary = document.data()!
                
                let likeMember = ["a","b","c"]
                var post = Post(user:user,dictionary: dictionary, likeMember: likeMember)
                post.id = document.documentID
                guard let uid = Auth.auth().currentUser?.uid else { return }
                
                let ref = Firestore.firestore().collection("likes").document(uid).collection("like").document(document.documentID)
                
                ref.getDocument() { (document, err) in
                    if let err = err{
                        print("フォロー情報の取得失敗:",err)
                        return
                    }
                    
                    //ドキュメントの有無
                    if let document = document, document.exists,document.data()?["flg"] as! Int == 1 {
                        
                        //いいね
                        post.hasLiked = true
                    } else {
                        //いいねしていない
                        post.hasLiked = false
                    }
                    
                    self.posts.append(post)
                    //post内の並び替え
                    self.posts.sort(by: {(p1,p2) -> Bool in
                        return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                    })
                    self.collectionView.reloadData()
                }
                
                self.collectionView.refreshControl?.endRefreshing()
                
            } else {
                print("Document does not exist in cache")
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height:CGFloat = 40 + 8 + 8//username userprofileImageの分
        height += view.frame.width
        height += 50
        height += 60
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! LikePostCell
        
        //        print("index:",indexPath.item)
        if !posts.isEmpty {//この処理を行わないと、範囲外のindexpath.itemが参照されるためエラーが起こる
            cell.post = posts[indexPath.item]//このタイミングでdidSetが発動する
        }
        cell.delegate = self
        return cell
    }
    
    func didTapComment(post: Post) {
        print(post.caption)
        let commentsController = CommentsController(collectionViewLayout:UICollectionViewFlowLayout())
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    func didLike(for cell: LikePostCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        //        print(indexPath.item)
        var post = self.posts[indexPath.item]
        //        print(post.caption)
        guard let postId = post.id else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let values = ["flg":post.hasLiked == true ? 0 : 1,
                      "uid":post.user.uid] as [String : Any]//trueの時いいねを外す
        
        let ref = Firestore.firestore().collection("likes").document(uid).collection("like").document(postId)
        
        ref.setData(values){ (err) in
            
            if let err = err {
                print("いいね失敗:",err)
                return
            }
            
            post.hasLiked = !post.hasLiked//true,falseを逆にする
            print(post.hasLiked == true ?"いいね":"notいいね")
            self.posts[indexPath.item] = post
            self.collectionView?.reloadItems(at: [indexPath])//一部更新
            
        }
        
    }
    
}
