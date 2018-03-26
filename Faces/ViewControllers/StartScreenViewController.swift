//
//  StartScreenViewController.swift
//  Faces
//
//  Created by Евгений Левин on 26.03.2018.
//  Copyright © 2018 levin inc. All rights reserved.
//

import UIKit

class StartScreenViewController: UIViewController, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var CameraButton: UIButton!
    @IBOutlet weak var SettingsButton: UIButton!
    
    let animationController = CustomAnimationController(withPresentedDelay: 0.6, withDismissedDelay: 0.0, withDuration: 0.5)
    
    @IBAction func unwindToStartScreen(segue: UIStoryboardSegue) {}
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        SettingsButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - UIViewControllerTransitioningDelegate
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCameraViewController" {
            let toViewController = segue.destination as UIViewController
            toViewController.transitioningDelegate = self.animationController
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
