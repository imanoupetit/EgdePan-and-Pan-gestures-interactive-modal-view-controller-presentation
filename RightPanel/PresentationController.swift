
/* Sources:
 - https://developer.apple.com/library/ios/samplecode/LookInside/Introduction/Intro.html#//apple_ref/doc/uid/TP40014643
 - https://developer.apple.com/library/content/samplecode/CustomTransitions/Introduction/Intro.html#//apple_ref/doc/uid/TP40015158
 */


import UIKit

class PresentationController: UIPresentationController {
    
    let dimmingView = UIView()
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        // Set dimming view transparency
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        // Add a tap gesture recognizer for dimming view in order to dismiss the settings view controller
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        dimmingView.addGestureRecognizer(tapGestureRecognizer)
        
        // Add pan gesture that will dismiss the settings view controller
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(interactiveTransitionRecognizerAction(_:)))
        dimmingView.addGestureRecognizer(panGestureRecognizer)
    }
    
    // MARK: - User interaction
    
    /**
     Selector linked to tapGestureRecognizer that will proceed a non-interactive dismiss of the view controller
     */
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            // Before to dismiss the presented view controller, we have to reset the transition delagate properties
            guard let transitionDelegate = presentedViewController.transitioningDelegate as? TransitionDelegate else { return }
            transitionDelegate.gestureRecognizer = nil
            transitionDelegate.targetEdge = UIRectEdge.left
            presentedViewController.dismiss(animated: true, completion: nil)
        }
    }

    /**
     Selector linked to panGestureRecognizer that will proceed a interactive dismiss of the view controller
     */
    @objc func interactiveTransitionRecognizerAction(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            // Before to dismiss the presented view controller, we have to reset the transition delagate properties
            guard let transitionDelegate = presentedViewController.transitioningDelegate as? TransitionDelegate else { return }
            transitionDelegate.gestureRecognizer = sender
            transitionDelegate.targetEdge = UIRectEdge.left
            presentedViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    // The frame rectangle to assign to the presented view at the end of the animations.
    override var frameOfPresentedViewInContainerView : CGRect {
        // return a controller that has the appropriate width and has a lateral right origin
        guard let containerBounds = containerView?.bounds else { fatalError() }
        
        let presentedViewSize = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerBounds.size)
        let presentedViewOrigin = CGPoint(x: containerBounds.size.width - presentedViewSize.width, y: CGSize.zero.height)
        return CGRect(origin: presentedViewOrigin, size: presentedViewSize)
    }
    
    override func containerViewWillLayoutSubviews() {
        // Before layout, make sure our dimmingView and presentedView have the correct frame
        // called when collectionTraits change
        dimmingView.frame = containerView!.bounds
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        // We always want a size that's a 4/5th of our container width, and just as tall as the container
        return CGSize(width: parentSize.width / 5 * 4, height: parentSize.height)
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        dimmingView.alpha = 0.0
        containerView?.addSubview(dimmingView)
        
        let transition: (UIViewControllerTransitionCoordinatorContext) -> Void = { _ in self.dimmingView.alpha = 1.0 }
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: transition, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        
        let transition: (UIViewControllerTransitionCoordinatorContext) -> Void = { _ in self.dimmingView.alpha = 0.0 }
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: transition, completion: nil)
    }
    
}
