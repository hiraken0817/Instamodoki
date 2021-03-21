//
//  UserProfileController.swift
//  InstagramFirebase
//
//  Created by 平尾健太 on 2021/01/17.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class UserProfileController:UICollectionViewController,UICollectionViewDelegateFlowLayout,UserProfileHeaderDelegate,HomePostCellDelegate,FollowerDelegate,FollowingDelegate,ScrollableProtocol{
    
    
    
    var user:User?
    
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "Update")
    
    let cellId = "cellId"
    let homePostCellId = "homePostCellId"
    
    var userId:String?
    
    var isGridView = true
    
    var isFinishedPaging = false
    var profilePosts = [Post]()
    
    var followingUid = [String]()
    var followerUid = [String]()
    
    func didChangeToListView() {
        isGridView = false
        collectionView.reloadData()
    }
    
    func didChangeToGridView() {
        isGridView = true
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        
        fetchUser()
        
        collectionView.backgroundColor = .white
        
        collectionView.register(UserProfileHeader.self,forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier:"headerId")
        
        collectionView.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier:cellId )
        
        collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: homePostCellId)
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.tintColor = UIColor.mainPurple()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: HomeController.updateFeedNotificationName, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharePhotoController.updateFeedNotificationName, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: FollowingController.updateFeedNotificationName, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: FollowerController.updateFeedNotificationName, object: nil)
        
    }
    
    @objc func handleRefresh(){
        print("リフレッシュ")
        profilePosts.removeAll()
        followerUid.removeAll()
        followingUid.removeAll()
        
        fetchUser()
        self.collectionView.refreshControl?.endRefreshing()
    }
    
    @objc func handleUpdateFeed(){
        print("アップデート")
        handleRefresh()
    }
    
    fileprivate func pagenatePosts(){
        guard let uid = self.user?.uid else { return }
        
        let photosRef = Firestore.firestore().collection("posts").document(uid).collection("photos")
        
        photosRef.order(by: "creationDate", descending: true).getDocuments(){ [weak self] (snapshots, err) in
            
            guard let weakSelf = self else { return }
            
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
                    (snapshots, err) in
                    
                    if let err = err {
                        print("写真情報の取得に失敗しました。\(err)")
                        return
                    }
                    
                    for document in snapshots!.documents {
                        likeMembers.append(document.documentID)
                    }
                    
                    guard let user = weakSelf.user else { return }
                    
                    var post = Post(user: user, dictionary: dictionary, likeMember: likeMembers)
                    likeMembers.removeAll()
                    post.id = postId
                    
                    guard let uid = Auth.auth().currentUser?.uid else { return }
                    
                    let ref = Firestore.firestore().collection("likes").document(uid).collection("like").document(document.documentID)
                    
                    ref.getDocument() { (document, err) in
                        if let err = err{
                            print("フォロー情報の取得失敗:",err)
                            return
                        }
                        
                        //ドキュメントの有無
                        if let document = document, document.exists,document.data()?["flg"] as! Int == 1 {
                            //
                            //いいね
                            post.hasLiked = true
                        } else {
                            //
                            //いいねしていない
                            post.hasLiked = false
                        }
                        
                        weakSelf.profilePosts.append(post)
                        //post内の並び替え
                        weakSelf.profilePosts.sort(by: {(p1,p2) -> Bool in
                            return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                        })
                        weakSelf.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    fileprivate func setupLogOutButton(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(handleLogOut))
        navigationItem.rightBarButtonItem!.tintColor = .black
    }
    
    @objc func handleLogOut(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "ログアウト", style: .destructive, handler: { (_) in
            do{
                try Auth.auth().signOut()
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
                
            }
            catch let signOutErr{
                print("サインアウトに失敗しました:",signOutErr)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return profilePosts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if isGridView{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell
            
            if !profilePosts.isEmpty {//この処理を行わないと、範囲外のindexpath.itemが参照されるためエラーが起こる
                cell.post = profilePosts[indexPath.item]//このタイミングでdidSetが発動する
            }
            
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCellId, for: indexPath) as! HomePostCell
            
            if !profilePosts.isEmpty {//この処理を行わないと、範囲外のindexpath.itemが参照されるためエラーが起こる
                cell.post = profilePosts[indexPath.item]//このタイミングでdidSetが発動する
            }
            cell.delegate = self
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if isGridView{
            let width = (view.frame.width - 2) / 3
            return CGSize(width: width, height: width)
        }else {
            var height:CGFloat = 40 + 8 + 8//username userprofileImageの分
            height += view.frame.width
            height += 50
            height += 60
            height += 14
            
            return CGSize(width: view.frame.width, height: height)
            
        }
    }
    
    //MARK:ヘッダーの情報埋め込み
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                     withReuseIdentifier: "headerId",
                                                                     for: indexPath) as! UserProfileHeader//強制ダウンキャスト
        
        header.followerDelegate = self
        header.followingDelegate = self
        
        header.user = self.user
        
        header.postCount = profilePosts.count 
        header.delegate = self
        header.followingUserId = followingUid
        header.followerUserId = followerUid
        
        return header
    }
    
    //これでヘッダーのスペース確保
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        //        return CGSize(width: view.frame.width, height: 350)
        
        if let headerView = collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader).first as? UserProfileHeader {
            // Layout to get the right dimensions
            headerView.layoutIfNeeded()
            
            // Automagically get the right height
            let height = headerView.contentView.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize).height
            
            // return the correct size
            return CGSize(width: collectionView.frame.width, height: height)
        }
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = UserProfileHeader(frame: frame)
        
        dummyCell.user = self.user
        
        let targetSize = CGSize(width: view.frame.width, height: 500)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        let height = max(222,estimatedSize.height)
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    //MARK:フォロー中の情報読み込み
    fileprivate func fetchFollowingUserId(){
        guard let uid = self.user?.uid else { return }
        followingUid.removeAll()
        Firestore.firestore().collection("following").document(uid).collection("followingUser").getDocuments(){ [weak self] (querySnapshot, err) in
            
            guard let weakSelf = self else { return }
            
            if let err = err {
                print("idの取得失敗: \(err)")
                return
            } else {
                
                for document in querySnapshot!.documents {
                    
                    if document.data()["flg"] as! Int == 1{
                        
                        let followingUid = document.documentID
                        
                        weakSelf.followingUid.append(followingUid)
                        weakSelf.collectionView.reloadData()
                    }
                    
                }
                
            }
        }
    }
    
    //MARK:フォロワー情報読み込み
    fileprivate func fetchFollowerUserIds(){
        guard let uid = self.user?.uid else { return }
        followerUid.removeAll()
        Firestore.firestore().collection("follower").document(uid).collection("followerUser").getDocuments(){ [weak self] (querySnapshot, err) in
            
            guard let weakSelf = self else { return }
            
            if let err = err {
                print("idの取得失敗: \(err)")
                return
            } else {
                for document in querySnapshot!.documents {
                    if document.data()["flg"] as! Int == 1{
                        
                        let fuid = document.documentID
                        //                       print("フォロワー：",fuid)
                        weakSelf.followerUid.append(fuid)
                        weakSelf.collectionView.reloadData()
                    }
                }
                
            }
        }
    }
    
    //MARK:ユーザー情報反映
    private func fetchUser(){
        let uid = userId ?? (Auth.auth().currentUser?.uid ?? "")
        
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        
        Firestore.fetchUserWithUID(uid: uid){ [weak self] (user) in
            guard let weakSelf = self else { return }
            weakSelf.user = user
            
            weakSelf.navigationItem.title = weakSelf.user?.username//タイトルにユーザー名を入れる
            weakSelf.pagenatePosts()
            
            weakSelf.fetchFollowingUserId()
            weakSelf.fetchFollowerUserIds()
            
            weakSelf.collectionView.reloadData()
            if currentLoggedInUserId == user.uid{
                weakSelf.setupLogOutButton()
            }
            
        }
        
    }
    
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
        
        var post = self.profilePosts[indexPath.item]
        
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
        
        self.profilePosts[indexPath.item] = post
        
        self.collectionView?.reloadItems(at: [indexPath])//一部更新
        
        NotificationCenter.default.post(name: UserProfileController.updateFeedNotificationName, object: nil)
        
    }
    
    func didTapfollower(followerUserId: [String]) {
        let followerController = FollowerController(collectionViewLayout:UICollectionViewFlowLayout())
        followerController.userId = self.user?.uid
        navigationController?.pushViewController(followerController, animated: true)
    }
    
    func didTapfollowing(followingUserId: [String]) {
        let followingController = FollowingController(collectionViewLayout:UICollectionViewFlowLayout())
        followingController.userId = self.user?.uid
        navigationController?.pushViewController(followingController, animated: true)
    }
    
    func scrollToTop() {
        let indexPath = IndexPath(row: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
    }
    
    func didEdit(user: User) {
        let userProfileEdit = UserProfileEditController()
        
        let navController = UINavigationController(rootViewController: userProfileEdit)
        navController.modalPresentationStyle = .fullScreen
        userProfileEdit.user = self.user
        present(navController, animated: true, completion: nil)
    }
    
    func startStory() {
        let cameraController = CameraController()
        cameraController.modalPresentationStyle = .fullScreen
        present(cameraController,animated: true,completion: nil)
    }
    
}


