//
//  ShowingsViewTransitionAnimator.swift
//  Cinema
//
//  Created by Marius on 2021-02-03.
//  Copyright © 2021 Marius. All rights reserved.
//

import UIKit

/// Custom transition between`MovieViewController` and `ShowingsViewController`.
final class ShowingsViewTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var isPushing: Bool
    let duration = TimeInterval(UINavigationController.hideShowBarDuration)

    init(isPushing: Bool) {
        self.isPushing = isPushing
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView

        guard let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) else { return }
        guard let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) else { return }

        let movieView = isPushing ? fromView : toView
        let showingsView = isPushing ? toView : fromView

        if isPushing {
            container.addSubview(showingsView)
            showingsView.frame.origin.x += showingsView.frame.width
            showingsView.alpha = 0
        } else {
            container.insertSubview(movieView, belowSubview: showingsView)
        }

        let image = showingsView.subviews.first { type(of: $0) == NetworkImageView.self }
        image?.isHidden = true

        let color = showingsView.backgroundColor
        showingsView.backgroundColor = .clear

        UIView.animate(withDuration: duration) { [self] in
            if isPushing {
                showingsView.frame.origin.x -= showingsView.frame.width
                showingsView.alpha = 1
            } else {
                showingsView.frame.origin.x += showingsView.frame.width
                showingsView.alpha = 0
            }
        } completion: { _ in
            image?.isHidden = false
            showingsView.backgroundColor = color
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
