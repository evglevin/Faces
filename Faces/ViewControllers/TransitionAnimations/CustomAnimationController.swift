//
//  TransitionManager.swift
//  Faces
//
//  Created by Евгений Левин on 26.03.2018.
//  Copyright © 2018 levin inc. All rights reserved.
//

import UIKit

class CustomAnimationController: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    var delay: TimeInterval
    let presentedDelay: TimeInterval
    let dismissedDelay: TimeInterval
    let duration: TimeInterval
    var presenting = true
    
    init(withDelay delay: TimeInterval, withDuration duration: TimeInterval) {
        self.delay = delay
        self.presentedDelay = delay
        self.dismissedDelay = delay
        self.duration = duration
    }
    
    init(withPresentedDelay presentedDelay: TimeInterval, withDismissedDelay dismissedDelay: TimeInterval, withDuration duration: TimeInterval) {
        self.delay = presentedDelay
        self.presentedDelay = presentedDelay
        self.dismissedDelay = dismissedDelay
        self.duration = duration
    }
    
    // MARK: - UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        let offScreenRight = CGAffineTransform(translationX: container.frame.width, y: 0)
        let offScreenLeft = CGAffineTransform(translationX: -container.frame.width, y: 0)
        
        if self.presenting {
            toView.transform = offScreenRight
        } else {
            toView.transform = offScreenLeft
        }
        
        container.addSubview(toView)
        container.addSubview(fromView)
        
        UIView.animate(withDuration: duration, delay: delay, options: [], animations: { () -> Void in
            if self.presenting {
                fromView.transform = offScreenLeft
            } else {
                fromView.transform = offScreenRight
            }
            toView.transform = .identity
        }) { (finished) -> Void in
            transitionContext.completeTransition(true)
        }
    }
    
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = true
        delay = presentedDelay
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = false
        delay = dismissedDelay
        return self
    }
}
