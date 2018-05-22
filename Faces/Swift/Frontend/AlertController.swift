//
//  AlertController.swift
//  Faces
//
//  Created by Евгений Левин on 13.04.2018.
//  Copyright © 2018 levin inc. All rights reserved.
//

import UIKit

class AlertController {
    static func createAlertControllerWithProgressView(withTitle title: String?, withMessage message: String?) -> (UIAlertController, UIProgressView) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.frame = CGRect(x: 0, y: 57, width: 270, height: 0)
        
        alertController.view.addSubview(progressView)
        progressView.setProgress(0, animated: true)
        
        return (alertController, progressView)
    }
    
    static func showMessageAlert(onViewController viewController: UIViewController, withTitle title: String?, withMessage message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString(NSLocalizedString("OK", comment: ""), comment: ""), style: .cancel, handler: nil))
        viewController.present(alertController, animated: true, completion: nil)
    }
}
