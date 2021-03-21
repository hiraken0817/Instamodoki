//
//  ComementsController.swift
//  InstagramFirebase
//
//  Created by 平尾健太 on 2021/02/14.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class CommentsController: UICollectionViewController,UICollectionViewDelegateFlowLayout,CommentInputAccessoryViewDelegate{

    var post:Post?
    private let cellId = "cellId"
    
    var comments = [Comment]()
    var captionComment:Comment?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)//スクロールバーをテキストフィールドに重ならないようにする
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        
        self.collectionView!.register(CommentCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(CommentHeader.self,forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier:"headerId")
        
        self.navigationController?.navigationBar.tintColor = UIColor.mainPurple()
        navigationItem.title = "コメント"
        
        fetchComments()
    }
    
    fileprivate func fetchComments(){
        guard let postId = self.post?.id else { return }
        let ref = Firestore.firestore().collection("comments").document(postId).collection("comment")
        ref.order(by: "creationDate", descending: false).getDocuments(){ [weak self] (snapshot, err) in
            guard let weakSelf = self else { return }
            if let err = err {
                print("ユーザー情報の取得に失敗しました: \(err)")
                return
            }
            for document in snapshot!.documents {
                
                let dictionary = document.data()
                
                guard let uid = dictionary["uid"] as? String else { return }
                
                Firestore.fetchUserWithUID(uid: uid, completion:{ (user) in
                    let comment = Comment(user: user, dictionary: dictionary)
                    
                    weakSelf.comments.append(comment)
                    
                    print(weakSelf.comments)
                    
                    weakSelf.comments.sort(by: {(p1,p2) -> Bool in
                        return p1.creationDate.compare(p2.creationDate) == .orderedAscending
                    })
                    
                    weakSelf.collectionView.reloadData()
                    
                    
                })
                
            }
        }
        
    }
    //画面に表示される直前に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    //画面から非表示になる前に表示
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    lazy var containerView:CommentInputAccessoryView = {
        
        let frame = CGRect(x:0, y: 0, width: view.frame.width, height: 50)
        let commentInputAccessoryView = CommentInputAccessoryView(frame:frame)
        commentInputAccessoryView.delegate = self
        return commentInputAccessoryView
    
    }()
    
    func didSubmit(for comment: String) {
//        print("submitid",post?.id! ?? "")
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let postId = post?.id! ?? ""
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let commentPostRef = Firestore.firestore().collection("comments").document(postId).collection("comment").document()

        let values = ["text":comment,
                      "creationDate":Date().timeIntervalSince1970,
                      "uid":uid] as [String:Any]
        

        commentPostRef.setData(values){ [weak self] (err) in
            guard let weakSelf = self else { return }
            if let err = err {
                print("ポスト失敗",err)
                return
            }
            print("成功")
            
            weakSelf.containerView.clearCommentTextField()
            
            Firestore.fetchUserWithUID(uid: currentUid, completion:{ (user) in
                let comment = Comment(user: user, dictionary: values)
                
                weakSelf.comments.append(comment)
                
//                print(weakSelf.comments)
                
                weakSelf.comments.sort(by: {(p1,p2) -> Bool in
                    return p1.creationDate.compare(p2.creationDate) == .orderedAscending
                })
                
                weakSelf.collectionView.reloadData()
                
                
            })
        }
        
    }
    
    //コメント打ち込み時に呼び出される
    override var inputAccessoryView: UIView?{
        get{//値が呼び出される時に発動する
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }

    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return comments.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentCell
    
        cell.comment = self.comments[indexPath.item]
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //高さの調整
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentCell(frame: frame)
        dummyCell.comment = comments[indexPath.item]
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        let height = max(40 + 8 + 8,estimatedSize.height)
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                     withReuseIdentifier: "headerId",
                                                                        for: indexPath) as! CommentHeader//強制ダウンキャスト
        let date = post!.creationDate as Date
        print("header:",date)
        
        let dictionary = ["text":post!.caption as String,
                          "uid":(post?.user.uid)! as String,
                          "creationDate":post!.creationDate.timeIntervalSince1970] as [String : Any]
        
        captionComment = Comment(user: post!.user, dictionary: dictionary as [String : Any])
        header.captionComment = captionComment
        
        return header
    }
    
    //これでヘッダーのスペース確保
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if let headerView = collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader).first as? CommentHeader {
            // Layout to get the right dimensions
            headerView.layoutIfNeeded()

            // Automagically get the right height
            let height = headerView.contentView.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize).height

            // return the correct size
            return CGSize(width: collectionView.frame.width, height: height)
        }
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentHeader(frame: frame)
        
        let dictionary = ["text":post?.caption,"uid":post?.user.uid]
        
        dummyCell.captionComment = Comment(user: post!.user, dictionary: dictionary as [String : Any])
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        let height = max(40 + 8 + 8 + 4,estimatedSize.height)
        
        return CGSize(width: view.frame.width, height: height)
        
    }

}
