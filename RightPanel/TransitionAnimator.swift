
/* Sources:
- https://developer.apple.com/library/ios/samplecode/LookInside/Introduction/Intro.html#//apple_ref/doc/uid/TP40014643
- https://developer.apple.com/library/content/samplecode/CustomTransitions/Introduction/Intro.html#//apple_ref/doc/uid/TP40015158
 */

import UIKit

class TransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let targetEdge: UIRectEdge

    init(edgeForDragging targetEdge: UIRectEdge) {
        self.targetEdge = targetEdge
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // In iOS 8, the viewForKey: method was introduced to get views that the animator manipulates. This method should be preferred over accessing the view of the fromViewController/toViewController directly
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let containerView = transitionContext.containerView
        
        let fromView: UIView
        let toView: UIView
        
        if transitionContext is UIViewControllerTransitionCoordinatorContext {
            fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
            toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        } else {
            fromView = fromViewController.view
            toView = toViewController.view
        }
        
        // If this is a presentation, toViewController corresponds to the presented view controller and its presentingViewController will be fromViewController. Otherwise, this is a dismissal.
        let isPresenting = toViewController.presentingViewController == fromViewController

        let fromFrame = transitionContext.initialFrame(for: fromViewController)
        let toFrame = transitionContext.finalFrame(for: toViewController)
        
        // Based on our configured targetEdge, derive a normalized vector that will be used to offset the frame of the presented view controller.
        let offset: CGVector
        switch targetEdge {
        case UIRectEdge.top:
            offset = CGVector(dx: 0, dy: 1)
        case UIRectEdge.bottom:
            offset = CGVector(dx: 0, dy: -1)
        case UIRectEdge.left:
            offset = CGVector(dx: 1, dy: 0)
        case UIRectEdge.right:
            offset = CGVector(dx: -1, dy: 0)
        default:
            fatalError("targetEdge must be one of UIRectEdge.Top, .Bottom, .Left, or .Right")
        }
        
        if isPresenting {
            // For a presentation, the toView starts off-screen and slides in.
            fromView.frame = fromFrame
            toView.frame = toFrame.offsetBy(dx: toFrame.size.width * offset.dx * -1, dy: toFrame.size.height * offset.dy * -1)
        } else {
            fromView.frame = fromFrame
            toView.frame = toFrame
        }
        
        // We are responsible for adding the incoming view to the containerView for the presentation.
        if isPresenting {
            containerView.addSubview(toView)
        }
        
        // Set parameters for animation
        let duration = transitionDuration(using: transitionContext)
        let animations: () -> Void = {
            if isPresenting {
                toView.frame = toFrame
            } else {
                // For a dismissal, the fromView slides off the screen
                fromView.frame = fromFrame.offsetBy(dx: fromFrame.size.width * offset.dx, dy: fromFrame.size.height * offset.dy);
            }
        }
        let completion: (Bool) -> Void = { _ in
            // When we complete, tell the transition context passing along the BOOL that indicates whether the transition finished or not
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

        UIView.animate(withDuration: duration, animations: animations, completion: completion)
    }
    
}
