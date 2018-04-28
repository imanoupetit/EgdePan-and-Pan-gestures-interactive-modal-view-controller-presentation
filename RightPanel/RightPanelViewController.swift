
import UIKit

class RightPanelViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addGesture()
    }
    
    // MARK: - Gestures
    
    func addGesture() {
        // Add screen edge pan gesture that will dismiss the settings view controller
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(interactiveTransitionRecognizerAction(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
        
        // We want both tableView's vertical drag gesture and panGestureRecognizer to work wisely together thanks to UIGestureRecognizerDelegate
        //panGestureRecognizer.delegate = self
    }

    /*
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // If y velocity is greater than x velocity, we want the tableView's drag gesture, otherwise, we wand our dismissal horizontal pan gesture to proceed
        // !!! It seems that this implementation is no more required with Xcode 8 / Swift 3 as both gestures work wisely one with the other
        guard let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        let velocity = gestureRecognizer.velocity(in: view)
        return abs(velocity.x) >= abs(velocity.y)
    }
    */
    
    // MARK: - User interaction
    
//    @IBAction func btnProfilTapped(_ sender: Any) {
//        performSegue(withIdentifier: "ShowRightPanel", sender: sender)
//    }
    
    /**
     Selector linked to gestureRecognizer that will proceed a interactive dismiss of the view controller
     */
    @objc func interactiveTransitionRecognizerAction(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            // Before to dismiss the presented view controller, we have to reset the transition delagate properties
            guard let transitionDelegate = transitioningDelegate as? TransitionDelegate else { return }
            transitionDelegate.gestureRecognizer = sender
            transitionDelegate.targetEdge = UIRectEdge.left
            dismiss(animated: true, completion: nil)
        }
    }

}
