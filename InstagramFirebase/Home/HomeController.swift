//
//  HomeController.swift
//  InstagramFirebase
//
//  Created by 平尾健太 on 2021/02/07.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class HomeController: UICollectionViewController,UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    var HomePosts = [Post]()
    
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "UpdateFeed")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        
        collectionView.register(HomeHeaderCell.self,forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier:"storyHeaderId")
        
        collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        setupNavigationItem()
        fetchAllPosts()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharePhotoController.updateFeedNotificationName, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: UserProfileController.updateFeedNotificationName, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefresh), name: UserProfileHeader.updateFeedNotificationName, object: nil)
    }
    
    
    @objc func handleRefresh(){
        HomePosts.removeAll()
        fetchAllPosts()
        self.collectionView.refreshControl?.endRefreshing()
        //        print("リフレッシュ")
    }
    
    @objc func handleUpdateFeed(){
        //        print("リロード")
        handleRefresh()
    }
    
    fileprivate func fetchFollowingUserIds(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("following").document(uid).collection("followingUser").getDocuments(){ [weak self] (querySnapshot, err) in
            
            guard let weakSelf = self else { return }
            
            if let err = err {
                print("idの取得失敗: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    Firestore.fetchUserWithUID(uid: document.documentID, completion: {
                        (user) in
                        weakSelf.fetchPostsWithUser(user: user)
                    })
                    
                }
            }
        }
    }
    
    fileprivate func fetchPosts(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        //自分の投稿を反映
        Firestore.fetchUserWithUID(uid: uid){ [weak self] (user) in
            guard let weakSelf = self else { return }
            weakSelf.fetchPostsWithUser(user: user)
        }
    }
    
    fileprivate func fetchAllPosts(){
        fetchPosts()
        fetchFollowingUserIds()
    }
    
    fileprivate func fetchPostsWithUser(user:User){
        let photosRef = Firestore.firestore().collection("posts").document(user.uid).collection("photos")
        
        photosRef.order(by: "creationDate", descending: true).getDocuments(){ [weak self] (snapshots, err) in
            
            
            
            if let err = err {
                print("写真情報の取得に失敗しました。\(err)")
                return
            }
            
            for document in snapshots!.documents {
                let dictionary = document.data()
                let postId = document.documentID
                var likeMembers = [String]()
                
                let likeMemberRef = Firestore.firestore().collection("likedPost").document(postId).collection("likeUser")
                likeMemberRef.getDocuments(){
                    [weak self] (snapshots, err) in
                    
                    
                    if let err = err {
                        print("写真情報の取得に失敗しました。\(err)")
                        return
                    }
                    
                    for document in snapshots!.documents {
                        likeMembers.append(document.documentID)
                    }
                    
                    var post = Post(user:user,dictionary: dictionary, likeMember: likeMembers)
                    likeMembers.removeAll()
                    post.id = postId
                    guard let uid = Auth.auth().currentUser?.uid else { return }
                    
                    let ref = Firestore.firestore().collection("likes").document(uid).collection("like").document(document.documentID)
                    
                    ref.getDocument() { [weak self] (document, err) in
                        
                        guard let weakSelf = self else { return }
                        
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
                        
                        weakSelf.HomePosts.append(post)
                        //post内の並び替え
                        weakSelf.HomePosts.sort(by: {(p1,p2) -> Bool in
                            return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                        })
                        weakSelf.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    func setupNavigationItem(){
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        let titleImageView = UIImageView(image: UIImage(named: "instamodoki_2"))
        titleImageView.frame = CGRect(x: 0, y: 0, width: titleView.frame.width, height: titleView.frame.height)
        titleView.addSubview(titleImageView)
        navigationItem.titleView = titleView
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "camera"), style: .plain, target:self , action:#selector(handleCamera) )
        navigationItem.leftBarButtonItem!.tintColor = .black
        self.navigationController?.navigationBar.barTintColor = .white
    }
    
    @objc func handleCamera(){
        let cameraController = CameraController()
        cameraController.modalPresentationStyle = .fullScreen
        present(cameraController,animated: true,completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height:CGFloat = 40 + 8 + 8//username userprofileImageの分
        height += view.frame.width
        height += 50
        height += 60
        height += 14
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("section:",section)
        return HomePosts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        print("indexPath",indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell
        
        //        print("index:",indexPath.item)
        if !HomePosts.isEmpty {//この処理を行わないと、範囲外のindexpath.itemが参照されるためエラーが起こる
            cell.post = HomePosts[indexPath.item]//このタイミングでdidSetが発動する
        }
        cell.delegate = self
        return cell
    }
    
    //MARK:ヘッダーの情報埋め込み
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                     withReuseIdentifier: "storyHeaderId",
                                                                     for: indexPath) as! HomeHeaderCell//強制ダウンキャスト
        header.delegate = self
        
        let loginUid = Auth.auth().currentUser?.uid
        
        Firestore.fetchUserWithUID(uid: loginUid!, completion:{ (user) in
            
            header.user = user
            
        })
        
        
        return header
    }
    
  
    
    //これでヘッダーのスペース確保
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: view.frame.width, height:120 )
    }
    
    
    
}


extension HomeController: HomePostCellDelegate,HomeHeaderDelegate,ScrollableProtocol{
    
    func didLikeMember(likeMember: [String]) {
        let likeListController = LikeListController(collectionViewLayout:UICollectionViewFlowLayout())
        likeListController.likeMember = likeMember
        navigationController?.pushViewController(likeListController, animated: true)
    }
    
    func didTapUserImage(post: Post) {
        let userProfileController = UserProfileController(collectionViewLayout:UICollectionViewFlowLayout())
        userProfileController.userId = post.user.uid
        navigationController?.pushViewController(userProfileController, animated: true)
    }
    
    
    func didTapComment(post: Post) {
        let commentsController = CommentsController(collectionViewLayout:UICollectionViewFlowLayout())
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    func didLike(for cell: HomePostCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        var post = self.HomePosts[indexPath.item]
        
        guard let postId = post.id else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let values = ["flg":post.hasLiked == true ? 0 : 1,
                      "uid":post.user.uid] as [String : Any]
        
        let likeOrUnlike = post.hasLiked == true ? 0 : 1
        
        let likesRef = Firestore.firestore().collection("likes").document(currentUid).collection("like").document(postId)
        let likedRef = Firestore.firestore().collection("likedPost").document(postId).collection("likeUser").document(currentUid)
        
        if likeOrUnlike == 1{
            likesRef.setData(values){ (err) in
                
                if let err = err {
                    print("ERR:",err)
                    return
                }
                
                likedRef.setData(values){ (err) in
                    
                    if let err = err {
                        print("ERR:",err)
                        return
                    }
                }
            }
            print("ライク成功")
            
            post.likeMember.append(currentUid)
            
        }else{
            likesRef.delete(){ err in
                if let err = err{
                    print("アンライク失敗",err)
                    return
                }
                
                likedRef.delete(){ err in
                    if let err = err{
                        print("アンライク失敗",err)
                        return
                    }
                    print("アンライクー成功")
                }
            }
            post.likeMember.removeAll(where: {$0 == currentUid})
            
        }
        
        post.hasLiked = !post.hasLiked//true,falseを逆にする
        
        self.HomePosts[indexPath.item] = post
        
        self.collectionView?.reloadItems(at: [indexPath])//一部更新
        
        NotificationCenter.default.post(name: HomeController.updateFeedNotificationName, object: nil)
        
    }
    
    func scrollToTop() {
        let indexPath = IndexPath(row: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
    }
    
    func startStory() {
        let cameraController = UINavigationController(rootViewController: HomeController2())
        cameraController.modalPresentationStyle = .fullScreen
        cameraController.navigationBar.isTranslucent = false
        present(cameraController,animated: true,completion: nil)
    }
    
}
