//
//  CustomAnimationPresentor.swift
//  InstagramFirebase
//
//  Created by 平尾健太 on 2021/02/14.
//

import UIKit

class CustomAnimationPresentor:NSObject, UIViewControllerAnimatedTransitioning{
    //アニメーションの時間をここに書く
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        
        return 0.5
    }
    
    //ここでアニメーションの具体的な内容を書く
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        //アニメーションの実態となるコンテナビューを作成
        let containerView = transitionContext.containerView
        
        //遷移元ビューコントローラー
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        guard let toView = transitionContext.view(forKey: .to) else { return }
        
        //アニメーションの実体となるContainerViewに必要なものを追加する
        containerView.addSubview(toView)
        
        let startingFrame = CGRect(x: -toView.frame.width,
                                   y: 0,
                                   width: toView.frame.width,
                                   height: toView.frame.height)
        
        toView.frame = startingFrame
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .curveEaseInOut,
                       animations: {
                        
                        toView.frame = CGRect(x: 0,
                                              y: 0,
                                              width: toView.frame.width,
                                              height: toView.frame.height)
                        
                        fromView.frame = CGRect(x: fromView.frame.width, y: 0, width: fromView.frame.width, height: fromView.frame.height)
                        
                       }){ (_) in
            transitionContext.completeTransition(true)
            
        }
        
        transitionContext.completeTransition(true)
    }
}
