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
    @IBOutlet weak var updateModelButton: UIButton!
    
    
    // MARK: Animations
    let animationController = CustomAnimationController(withPresentedDelay: 0.6, withDismissedDelay: 0.0, withDuration: 0.5)
    
    @IBAction func unwindToStartScreen(segue: UIStoryboardSegue) {}
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
                AlertController.showMessageAlert(onViewController: self, withTitle: "Please configure a model in the settings", withMessage: nil)
                return false
            }
            return true
        }
        return true
    }
    

}
