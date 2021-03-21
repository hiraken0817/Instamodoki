//
//  HomeController.swift
//  InstagramFirebase
//
//  Created by 平尾健太 on 2021/02/07.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

let DEL_CACHE_ENABLED = false

class HomeController2: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    //MARK: - iVars
    
    let cellId = "cell"
    
    var HomePosts = [Post]()
    
    
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "UpdateFeed")
    
    //テーブルビューインスタンス作成
    var postTableView: UITableView = {
        let tv = UITableView()
        
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
        view.backgroundColor = .white
        
        
        view.addSubview(postTableView)
        
        postTableView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        postTableView.separatorStyle = .none
        postTableView.delaysContentTouches = false
        
        postTableView.delegate      =   self
        postTableView.dataSource    =   self
        
        //        view = IGHomeViewCell(frame: UIScreen.main.bounds)
        
        
        //        tableView.register(HomeHeaderCell.self,forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier:"storyHeaderId")
        
        postTableView.register(HomePostCell2.self, forCellReuseIdentifier: cellId)
        postTableView.register(IGHomeViewCell.self, forCellReuseIdentifier: "story")
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        postTableView.refreshControl = refreshControl
        
        setupNavigationItem()
        fetchAllPosts()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharePhotoController.updateFeedNotificationName, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: UserProfileController.updateFeedNotificationName, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefresh), name: UserProfileHeader.updateFeedNotificationName, object: nil)
    }
    
    //    override var navigationItem: UINavigationItem {
    //        let navigationItem = UINavigationItem()
    //
    //        if DEL_CACHE_ENABLED {
    //            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Del.CACHE", style: .done, target: self, action: #selector(clearImageCache))
    //            navigationItem.rightBarButtonItem?.tintColor = UIColor.init(red: 203.0/255, green: 69.0/255, blue: 168.0/255, alpha: 1.0)
    //        }
    //        return navigationItem
    //    }
    
    //MARK: - Private functions
    @objc private func clearImageCache() {
        IGCache.shared.removeAllObjects()
    }
    
    @objc func handleRefresh(){
        HomePosts.removeAll()
        fetchAllPosts()
        self.postTableView.refreshControl?.endRefreshing()
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
                        weakSelf.postTableView.reloadData()
                    }
                }
            }
        }
    }
    
    func setupNavigationItem(){
        print("処理済み")
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        let titleImageView = UIImageView(image: UIImage(named: "instamodoki_2"))
        titleImageView.frame = CGRect(x: 0, y: 0, width: titleView.frame.width, height: titleView.frame.height)
        titleView.addSubview(titleImageView)
        navigationItem.titleView = titleView
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "camera"), style: .plain, target:self , action:#selector(handleCamera) )
        navigationItem.leftBarButtonItem?.tintColor = .black
        self.navigationController?.navigationBar.barTintColor = .white
    }
    
    @objc func handleCamera(){
        let cameraController = CameraController()
        cameraController.modalPresentationStyle = .fullScreen
        present(cameraController,animated: true,completion: nil)
    }
    
    func tableView(_ tableView: UICollectionView, layout tableViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height:CGFloat = 40 + 8 + 8//username userprofileImageの分
        height += view.frame.width
        height += 50
        height += 60
        height += 24
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    
}


extension HomeController2: HomePostCell2Delegate,ScrollableProtocol{
    
    func didTapComment(post: Post) {
        let commentsController = CommentsController(collectionViewLayout:UICollectionViewFlowLayout())
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    func didLike(for cell: HomePostCell2) {
        guard let indexPath = postTableView.indexPath(for: cell) else { return }
        
        var post = self.HomePosts[indexPath.item - 1]
        
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
        
        self.HomePosts[indexPath.item - 1] = post
        
        self.postTableView.reloadRows(at: [indexPath], with: .fade)//一部更新
        
        NotificationCenter.default.post(name: HomeController.updateFeedNotificationName, object: nil)
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
    
    func scrollToTop() {
        let indexPath = IndexPath(row: 0, section: 0)
        postTableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    
    
}

extension HomeController2:UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HomePosts.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            //Left Detailスタイル
            let cell = tableView.dequeueReusableCell(withIdentifier: "story", for: indexPath) as! IGHomeViewCell
            cell.contentView.isUserInteractionEnabled = false
            cell.delegate = self
            return cell
        } else{
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! HomePostCell2
            
            if !HomePosts.isEmpty {//この処理を行わないと、範囲外のindexpath.itemが参照されるためエラーが起こる
                
                cell.post = HomePosts[indexPath.row-1]//このタイミングでdidSetが発動する
                
            }
            cell.contentView.isUserInteractionEnabled = false
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 100
        }else{
            var height:CGFloat = 40 + 8 + 8//username userprofileImageの分
            height += view.frame.width
            height += 50
            height += 60
            height += 24
            
            return height
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        
        return false
    }
    
}

extension HomeController2:IGHomeViewCellDelegate{
    func didTapWatchStory(viewModel: IGHomeViewModel,indexPath:IndexPath) {
        DispatchQueue.main.async {
            if let stories = viewModel.getStories(), let stories_copy = try? stories.copy() {
                let storyPreviewScene = IGStoryPreviewController.init(stories: stories_copy, handPickedStoryIndex:  indexPath.row-1)
                self.present(storyPreviewScene, animated: true, completion: nil)
            }
        }
    }
    
    func didTapAddStory() {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "カメラを起動", style: .destructive, handler: { (_) in
            let cameraController = CameraController()
            cameraController.modalPresentationStyle = .fullScreen
            self.present(cameraController,animated: true,completion: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "カメラロールから選択", style: .destructive, handler: { (_) in
            let imagePickerController = UIImagePickerController()
            imagePickerController.modalPresentationStyle = .fullScreen
            imagePickerController.delegate = self
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
        
        
    }
}
