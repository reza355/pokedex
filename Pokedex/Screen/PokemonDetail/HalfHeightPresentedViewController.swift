//
//  HalfHeightPresentedViewController.swift
//  Pokedex
//
//  Created by Fathureza Januarza on 08/08/24.
//

import Foundation
import UIKit

final class HalfHeightPresentationController: UIPresentationController {
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        let height = containerView.bounds.height / 2
        let originY = containerView.bounds.height - height
        return CGRect(x: 0, y: originY, width: containerView.bounds.width, height: height)
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        
        let dimmingView = UIView(frame: containerView.bounds)
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimmingView.alpha = 0
        containerView.insertSubview(dimmingView, at: 0)
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            dimmingView.alpha = 1
        }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        guard let containerView = containerView, let dimmingView = containerView.subviews.first else { return }
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            dimmingView.alpha = 0
        }, completion: { _ in
            dimmingView.removeFromSuperview()
        })
    }
}
