//
//  MainTabBarController.swift
//  InstagramFirebase
//
//  Created by 平尾健太 on 2021/01/17.
//

import UIKit
import FirebaseAuth

// スクロールを持つプロトコル
protocol ScrollableProtocol {
    func scrollToTop()
}

class MainTabBarController: UITabBarController ,UITabBarControllerDelegate{
    
    var shouldScroll = false
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let index = viewControllers?.firstIndex(of:viewController)
        if index == 2{//プラスボタンを押した時バーが移動しない
            
            let layout = UICollectionViewFlowLayout()
            let photoSelectorController = PhotoSelectorController(collectionViewLayout: layout)
            let navController = UINavigationController(rootViewController: photoSelectorController)
            present(navController, animated: true, completion: nil)
            
            return false//falseだとボタンが反応しない
        }
        
        self.shouldScroll = false
        // 表示しているvcがnavigationControllerルートのときはスクロールさせる
        // ルート以外は、navigationControllerの戻る機能を優先しスクロールさせない
        if let navigationController: UINavigationController = viewController as? UINavigationController {
            let visibleVC = navigationController.visibleViewController!
            if let index = navigationController.viewControllers.firstIndex(of: visibleVC), index == 0 {
                shouldScroll = true
            }
        }
        // 遷移を許可するためのtrueを返す
        return true
    }
    
    // didSelectで、選択されたタブが、前回と同様なら、shouldSelectの結果(shouldScroll)も考慮し、スクロールさせる
    var lastSelectedIndex = 0
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController)  {
        guard self.shouldScroll else { return }
        
        if self.lastSelectedIndex == tabBarController.selectedIndex  {
            if let navigationController: UINavigationController = viewController as? UINavigationController {
                
                let visibleVC = navigationController.visibleViewController!
                if let scrollableVC = visibleVC as? ScrollableProtocol {
                    scrollableVC.scrollToTop()
                }
                
            }
        }
        self.lastSelectedIndex = tabBarController.selectedIndex
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        UITabBar.appearance().barTintColor = .white
        
        if Auth.auth().currentUser == nil{
            DispatchQueue.main.async {
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            }
            return
        }
        setupViewContoroller()
        
        
    }
    
    func setupViewContoroller(){
        //home
        let homeNavController = templateNavController(unselectedImage: UIImage(systemName: "house")! , selectedImage: UIImage(systemName: "house.fill")!,
                                                      rootViewController: HomeController2())
        
        
        
        //search
        let searchNavController = templateNavController(unselectedImage: UIImage(systemName: "magnifyingglass")!, selectedImage: UIImage(systemName: "magnifyingglass")!,rootViewController: UserSearchController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        //plus
        let plusNavController = templateNavController(unselectedImage: UIImage(systemName: "plus.square")!, selectedImage: UIImage(systemName: "plus.square.fill")!)
        
        //like
        
        let likeNavController = templateNavController(unselectedImage: UIImage(systemName: "suit.heart")!, selectedImage: UIImage(systemName: "suit.heart.fill")!,
                                                      rootViewController: LikePostController(collectionViewLayout:UICollectionViewFlowLayout()))
        
        //user profile
        
        let layout = UICollectionViewFlowLayout()
        let userProfileController = UserProfileController(collectionViewLayout: layout)
        
        let userProfileNavController = UINavigationController(rootViewController: userProfileController)
        
        
        
        userProfileNavController.tabBarItem.image = UIImage(systemName: "person")
        userProfileNavController.tabBarItem.selectedImage = UIImage(systemName: "person.fill")
        
        tabBar.tintColor = .black
        
        viewControllers = [homeNavController,
                           searchNavController,
                           plusNavController,
                           likeNavController,
                           userProfileNavController]
        
        //tabbar内のアイコンの位置調整
        guard let items = tabBar.items else { return }
        
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
        }
        
    }
    
    fileprivate func templateNavController(unselectedImage:UIImage,
                                           selectedImage:UIImage,rootViewController:UIViewController = UIViewController()) -> UINavigationController{
        let viewContoroller = rootViewController
        let navController = UINavigationController(rootViewController: viewContoroller)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        return navController
    }
}
