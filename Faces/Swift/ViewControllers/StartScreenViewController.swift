//
//  StartScreenViewController.swift
//  Faces
//
//  Created by Евгений Левин on 26.03.2018.
//  Copyright © 2018 levin inc. All rights reserved.
//

import UIKit

class StartScreenViewController: UIViewController {

    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var peopleButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    
    // MARK: Animations
    let animationController = CustomAnimationController(withPresentedDelay: 0.6, withDismissedDelay: 0.0, withDuration: 0.5)
    
    @IBAction func unwindToStartScreen(segue: UIStoryboardSegue) {}
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeBorders(forButton: cameraButton)
        makeBorders(forButton: peopleButton)
        makeBorders(forButton: settingsButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func makeBorders(forButton button: UIButton) {
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "cameraViewController" {
            let toViewController = segue.destination as UIViewController
            toViewController.transitioningDelegate = self.animationController
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "cameraViewController" {
            guard ModelManager.loadModel() != nil else {
                AlertController.showMessageAlert(onViewController: self, withTitle: NSLocalizedString("Please configure a model in the settings", comment: ""), withMessage: nil)
                return false
            }
            return true
        }
        return true
    }
    

}
