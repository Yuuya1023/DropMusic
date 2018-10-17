//
//  AudioPlayerPresentationController.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import Foundation
import UIKit

class AudioPlayerPresentationController: UIPresentationController {
    
    var swipe: UISwipeGestureRecognizer? = nil

    // 表示トランジション開始前に呼ばれる
    override func presentationTransitionWillBegin() {
//        guard let containerView = containerView else {
//            return
//        }
        
        swipe = UISwipeGestureRecognizer(target: self, action: #selector(selectorSwipe(_:)))
        swipe?.direction = .down
        presentedViewController.view?.addGestureRecognizer(swipe!)
        // トランジションを実行
//        presentedViewController.transitionCoordinator?.animate(alongsideTransition: {[weak self] context in
//            self?.closeButton.alpha = 0.7
//            }, completion:nil)
    }
    
    // 非表示トランジション開始前に呼ばれる
    override func dismissalTransitionWillBegin() {
//        presentedViewController.transitionCoordinator?.animate(alongsideTransition: {[weak self] context in
//            self?.closeButton.alpha = 0.0
//            }, completion:nil)
    }
    
    // 非表示トランジション開始後に呼ばれる
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            presentedViewController.view?.removeGestureRecognizer(swipe!)
        }
    }
    
    // 子のコンテナサイズを返す
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: parentSize.width, height: parentSize.height)
    }
    
    // 呼び出し先のView Controllerのframeを返す
    override var frameOfPresentedViewInContainerView: CGRect {
        var presentedViewFrame = CGRect()
        let containerBounds = containerView!.bounds
        let childContentSize = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerBounds.size)
        presentedViewFrame.size = childContentSize
//        presentedViewFrame.origin.x = margin.x / 2.0
//        presentedViewFrame.origin.y = margin.y / 2.0
        
        return presentedViewFrame
    }
    
    // レイアウト開始前に呼ばれる
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
//        presentedView?.layer.cornerRadius = 10
        presentedView?.clipsToBounds = true
    }
    
    // レイアウト開始後に呼ばれる
    override func containerViewDidLayoutSubviews() {
    }
    
    // MARK: -
    @objc func selectorTouchCloseButton(_ sender: UIButton) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    @objc func selectorSwipe(_ sender: UISwipeGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
}
