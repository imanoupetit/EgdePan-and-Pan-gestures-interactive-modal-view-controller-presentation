//
//  ViewController.swift
//  RightPanel
//
//  Created by Imanou Petit on 12/01/2017.
//  Copyright © 2017 Imanou Petit. All rights reserved.
//

import UIKit

/*
 - Give storyboard segue an identifier: "ShowRightPanel"
 - Set storyboard segue kind: "present modally"
 */

class ViewController: UIViewController {

    // delegate for custom transition segue
    lazy var transitionDelegate: TransitionDelegate = TransitionDelegate()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add screen edge pan gesture that will present the rightMenuViewController
        let gestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(interactiveTransitionRecognizerAction(_:)))
        gestureRecognizer.edges = UIRectEdge.right
        view.addGestureRecognizer(gestureRecognizer)
    }

    // MARK: - User interaction
    
    /**
     Selector linked to gestureRecognizer that will present the Settings view controller
     */
    @objc func interactiveTransitionRecognizerAction(_ sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .began {
            performSegue(withIdentifier: "ShowRightPanel", sender: sender)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowRightPanel" {
            transitionDelegate.gestureRecognizer = sender as? UIScreenEdgePanGestureRecognizer
            transitionDelegate.targetEdge = UIRectEdge.right
            
            let rightMenuViewController = segue.destination as! RightPanelViewController
            rightMenuViewController.transitioningDelegate = transitionDelegate
            rightMenuViewController.modalPresentationStyle = .custom
        }
    }

}
