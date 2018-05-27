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
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var peopleButton: UIButton!
    
    
    // MARK: Animations
    let animationController = CustomAnimationController(withPresentedDelay: 0.6, withDismissedDelay: 0.0, withDuration: 0.5)
    
    @IBAction func unwindToStartScreen(segue: UIStoryboardSegue) {}
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let topColor = #colorLiteral(red: 0.03137254902, green: 0.7921568627, blue: 1, alpha: 1)
        let bottomColor = #colorLiteral(red: 0.1137254902, green: 0.4392156863, blue: 0.9450980392, alpha: 1)
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
        self.view.layer.addSublayer(gradientLayer)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
