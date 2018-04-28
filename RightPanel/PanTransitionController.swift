
import UIKit

/* Sources:
 - https://developer.apple.com/library/ios/samplecode/LookInside/Introduction/Intro.html#//apple_ref/doc/uid/TP40014643
 - https://developer.apple.com/library/content/samplecode/CustomTransitions/Introduction/Intro.html#//apple_ref/doc/uid/TP40015158
 */

class PanTransitionController: UIPercentDrivenInteractiveTransition {
    
    var transitionContext: UIViewControllerContextTransitioning?
    let gestureRecognizer: UIPanGestureRecognizer
    let edge: UIRectEdge
    
    private override init() {
        fatalError("init() has not been implemented")
    }
    
    init(gestureRecognizer: UIPanGestureRecognizer, edgeForDragging edge: UIRectEdge) {
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
    func percentForGesture(_ gesture: UIPanGestureRecognizer) -> CGFloat {
        guard let view = gesture.view else { return 0 }
        
        // return an appropriate percentage from gesture's translationInView
        // TODO: this only works for left and right gestures. Fix it for up and down gestures
        let translation = gesture.translation(in: view)
        let percentage  = translation.x / view.bounds.width
        return percentage
    }
    
    @objc func gestureRecognizeDidUpdate(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            // The Began state is handled by the view controllers. In response to the gesture recognizer transitioning to this state, they will trigger the presentation or dismissal
            break
        case .changed:
            // We have been dragging! Update the transition context accordingly
            update(percentForGesture(gestureRecognizer))
        case .ended:
            // Dragging has finished. Complete or cancel, depending on how far we've dragged
            percentForGesture(gestureRecognizer) >= 0.3 ? finish() : cancel()
        default:
            // Something happened. cancel the transition
            cancel()
        }
    }
    
}
