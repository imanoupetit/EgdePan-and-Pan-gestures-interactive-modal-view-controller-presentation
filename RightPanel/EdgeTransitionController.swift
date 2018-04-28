
/* Sources:
 - https://developer.apple.com/library/ios/samplecode/LookInside/Introduction/Intro.html#//apple_ref/doc/uid/TP40014643
 - https://developer.apple.com/library/content/samplecode/CustomTransitions/Introduction/Intro.html#//apple_ref/doc/uid/TP40015158
 */

import UIKit

class EdgeTransitionController: UIPercentDrivenInteractiveTransition {
    
    var transitionContext: UIViewControllerContextTransitioning?
    let gestureRecognizer: UIScreenEdgePanGestureRecognizer
    let edge: UIRectEdge
    let toggleLimit: CGFloat = 0.5
    
    private override init() {
        fatalError("init() has not been implemented")
    }
    
    init(gestureRecognizer: UIScreenEdgePanGestureRecognizer, edgeForDragging edge: UIRectEdge) {
        // Early escape if edges is of type `All` or `None`
        // gestureRecognizer should be a subset of [.Top, .Bottom, .Left, .Right] but not an exact copy (definition of strict subset)
        assert(edge.isStrictSubset(of: [.top, .bottom, .left, .right]), "edgeForDragging must be one of UIRectEdge.top, .bottom, .left or .right.")

        self.gestureRecognizer = gestureRecognizer
        self.edge = edge
        
        super.init()
        
        gestureRecognizer.addTarget(self, action: #selector(gestureRecognizeDidUpdate(_:)))
    }
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        super.startInteractiveTransition(transitionContext)
        // Save the transitionContext for later
        self.transitionContext = transitionContext
    }
    
    // MARK: - Custom methods
    
    /**
     Returns the offset of the pan gesture recognizer from the edge of the screen as a percentage of the transition container view's width or height. This is the percent completed for the interactive transition.
     */
    func percentForGesture(_ gesture: UIScreenEdgePanGestureRecognizer) -> CGFloat {
        // Because view controllers will be sliding on and off screen as part of the animation, we want to base our calculations in the coordinate space of the view that will not be moving: the containerView of the transition context
        guard let transitionContainerView = transitionContext?.containerView else { return 0 }
        let locationInSourceView = gesture.location(in: transitionContainerView)
        
        // Figure out what percentage we've gone
        let width = transitionContainerView.bounds.width
        let height = transitionContainerView.bounds.height
        
        // Return an appropriate percentage based on which edge we're dragging from
        switch edge {
        case UIRectEdge.right:  return (width - locationInSourceView.x) / width
        case UIRectEdge.left:   return locationInSourceView.x / width
        case UIRectEdge.bottom: return (height - locationInSourceView.y) / height
        case UIRectEdge.top:    return locationInSourceView.y / height
        default:                return 0
        }
    }
    
    @objc func gestureRecognizeDidUpdate(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            // The Began state is handled by the view controllers. In response to the gesture recognizer transitioning to this state, they will trigger the presentation or dismissal
            break
        case .changed:
            // We have been dragging! Update the transition context accordingly
            update(percentForGesture(gestureRecognizer))
        case .ended:
            // Dragging has finished. Complete or cancel, depending on how far we've dragged
            percentForGesture(gestureRecognizer) >= toggleLimit ? finish() : cancel()
        default:
            // Something happened. cancel the transition
            cancel()
        }
    }
    
}
