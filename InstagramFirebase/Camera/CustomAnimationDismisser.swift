//
//  CustomAnimationDismisser.swift
//  InstagramFirebase
//
//  Created by 平尾健太 on 2021/02/14.
//

import UIKit

class CustomAnimationDismisser: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        //アニメーションの時間をここに書く
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //ここでアニメーションの具体的な内容を書く
        let containerView = transitionContext.containerView
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        guard let toView = transitionContext.view(forKey: .to) else { return }
        
        containerView.addSubview(toView)
       
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                       animations: {
                        fromView.frame = CGRect(x: -fromView.frame.width,
                                                y: 0,
                                                width: fromView.frame.width,
                                                height: fromView.frame.height)
                        
                        toView.frame = CGRect(x: 0,
                                              y: 0,
                                              width: fromView.frame.width,
                                              height: fromView.frame.height)
                       }){ (_) in
            transitionContext.completeTransition(true)
        }
    }
}
