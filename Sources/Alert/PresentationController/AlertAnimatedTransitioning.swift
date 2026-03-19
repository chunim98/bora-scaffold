//
//  AlertAnimatedTransitioning.swift
//  BoraScaffold
//
//  Created by 신정욱 on 2/23/26.
//

import UIKit

final class AlertAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: AnimationType
    
    enum AnimationType { case present, dismiss }
    
    // MARK: Properties
    
    private let animationType: AnimationType
    
    // MARK: Life Cycle
    
    init(_ animationType: AnimationType) {
        self.animationType = animationType
        super.init()
    }
    
    // MARK: UIViewControllerAnimatedTransitioning
    
    /// 애니메이션 지속 시간 설정
    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        return 0.5
    }
    
    /// 실제 애니메이션 설정
    func animateTransition(
        using transitionContext: UIViewControllerContextTransitioning
    ) {
        switch animationType {
        case .present: animatePresentation(transitionContext)
        case .dismiss: animateDismissal(transitionContext)
        }
    }
    
    // MARK: Private Helpers
    
    private func animatePresentation(
        _ context: UIViewControllerContextTransitioning
    ) {
        guard let view = context.view(forKey: .to),
              let vc = context.viewController(forKey: .to)
        else { context.completeTransition(false); return }
        
        context.containerView.addSubview(view)
        
        view.frame = context.finalFrame(for: vc)
        view.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
        view.alpha = 0
        
        UIView.animate(
            withDuration: transitionDuration(using: context),
            delay: .zero,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            view.transform = .identity
            view.alpha = 1
            
        } completion: { finished in
            context.completeTransition(finished && !context.transitionWasCancelled)
        }
    }
    
    private func animateDismissal(
        _ context: UIViewControllerContextTransitioning
    ) {
        guard let view = context.view(forKey: .from)
        else { context.completeTransition(false); return }
        
        UIView.animate(
            withDuration: transitionDuration(using: context),
            delay: .zero,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            view.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
            view.alpha = 0
            
        } completion: { finished in
            view.removeFromSuperview()
            context.completeTransition(finished && !context.transitionWasCancelled)
        }
    }
}
