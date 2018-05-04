//
//  ViewController.swift
//  Faces
//
//  Created by Евгений Левин on 23.02.2018.
//  Copyright © 2018 levin inc. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision
import CoreData

import RxSwift
import Async
import PKHUD

class CameraViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var BackToStartScreenButton: UIButton!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    var disposeBag = DisposeBag()
    var faces = [Face]()
    var bounds  = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    var model = ModelManager.loadModel()!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        
        bounds = sceneView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
        
        
        Observable<Int>.interval(0.2, scheduler: SerialDispatchQueueScheduler(qos: .default))
            .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
            .concatMap{ _ in  self.faceObservation() }
            .flatMap{ Observable.from($0) }
            .flatMap{ self.faceClassification(face: $0.observation, image: $0.image, frame: $0.frame) }
            .subscribe { [unowned self] event in
                guard let element = event.element else {
                    print("No element available")
                    return
                }
                self.updateNode(classes: element.classes, position: element.position, frame: element.frame)
            }
            .disposed(by: disposeBag)
        
        Observable<Int>.interval(1.0, scheduler: SerialDispatchQueueScheduler(qos: .default))
            .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
            .subscribe { [unowned self] _ in
                
                self.faces.filter{ $0.updated.isAfter(seconds: 1.5) && !$0.hidden }.forEach{ face in
                    print("Hide node: \(face.name)")
                    Async.main { face.node.hide() }
                }
            }
            .disposed(by: disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disposeBag = DisposeBag()
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        
        switch camera.trackingState {
        case .limited(.initializing):
            PKHUD.sharedHUD.contentView = PKHUDProgressView(title: "Dancing with bear", subtitle: nil)
            PKHUD.sharedHUD.show()
        case .notAvailable:
            print("Not available")
        default:
            PKHUD.sharedHUD.contentView = PKHUDSuccessView(title: "Ready", subtitle: nil)
            PKHUD.sharedHUD.show()
            PKHUD.sharedHUD.hide(afterDelay: 0.7)
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    
    //MARK: - Face detections
    
    private func faceObservation() -> Observable<[(observation: VNFaceObservation, image: CIImage, frame: ARFrame)]> {
        return Observable<[(observation: VNFaceObservation, image: CIImage, frame: ARFrame)]>.create {observer in
            guard let frame = self.sceneView.session.currentFrame else {
                print("No frame available.")
                observer.onCompleted()
                return Disposables.create()
            }
            
            // Create and rotate image
            let image = CIImage(cvPixelBuffer: frame.capturedImage).rotate
            
            let facesRequest = VNDetectFaceRectanglesRequest { (request, error) in
                guard error == nil else {
                    print("[ERROR] Face request error: \(error!.localizedDescription)")
                    observer.onCompleted()
                    return
                }
                
                guard let observations = request.results as? [VNFaceObservation] else {
                    print("[WARN] No face observations")
                    observer.onCompleted()
                    return
                }
                
                // Map response
                let response = observations.map({ (face) -> (observation: VNFaceObservation, image: CIImage, frame: ARFrame) in
                    return (observation: face, image: image, frame: frame)
                })
                observer.onNext(response)
                observer.onCompleted()
                
            }
            try? VNImageRequestHandler(ciImage: image).perform([facesRequest])
            
            return Disposables.create()
        }
    }
    
    private func faceClassification(face: VNFaceObservation, image: CIImage, frame: ARFrame) -> Observable<(classes: [VNClassificationObservation], position: SCNVector3, frame: ARFrame)> {
        return Observable<(classes: [VNClassificationObservation], position: SCNVector3, frame: ARFrame)>.create{ observer in
            
            // Determine position of the face
            let boundingBox = self.transformBoundingBox(face.boundingBox)
            guard let worldCoord = self.normalizeWorldCoord(boundingBox) else {
                print("[INFO] No feature point found")
                observer.onCompleted()
                return Disposables.create()
            }
            
            // Create Classification request
            let request = VNCoreMLRequest(model: self.model, completionHandler: { request, error in
                guard error == nil else {
                    print("[ERROR] ML request error: \(error!.localizedDescription)")
                    observer.onCompleted()
                    return
                }
                
                guard let classifications = request.results as? [VNClassificationObservation] else { // request.results - the collection of VNObservations generated by the processing of the request.
                    print("[WARN] No classifications")
                    observer.onCompleted()
                    return
                }
                
                observer.onNext((classes: classifications, position: worldCoord, frame: frame))
                observer.onCompleted()
            })
            request.imageCropAndScaleOption = .scaleFit // scale to size required by algorithm
            
            do {
                let pixel = image.cropImage(toFace: face)
                try VNImageRequestHandler(ciImage: pixel, options: [:]).perform([request])
            } catch {
                print("[ERROR] ML request handler error: \(error.localizedDescription)")
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    private func updateNode(classes: [VNClassificationObservation], position: SCNVector3, frame: ARFrame) {
        guard let person = classes.first else {
            print("[WARN] No classification found")
            return
        }
        
        let second = classes[1]
        let name = person.identifier
        print("""
            [INFO]
                FIRST
                confidence: \(person.confidence) for \(person.identifier)
                SECOND
                confidence: \(second.confidence) for \(second.identifier)
            """)
        if person.confidence < 0.60 || person.identifier == "unknown" {
            print("[INFO] Not so sure")
            return
        }
        
        // Filter for existent face
        let results = self.faces.filter{ $0.name == name && $0.timestamp != frame.timestamp }
            .sorted{ $0.node.position.distance(toVector: position) < $1.node.position.distance(toVector: position) }
        
        // Create new face
        guard let existentFace = results.first else {
            let node = SCNNode(withText: name, position: position)
            
            Async.main {
                self.sceneView.scene.rootNode.addChildNode(node)
                node.show()
                
            }
            let face = Face.init(name: name, node: node, timestamp: frame.timestamp)
            self.faces.append(face)
            return
        }
        
        // Update existent face
        Async.main {
            
            // Filter for face that's already displayed
            if let displayFace = results.filter({ !$0.hidden }).first  {
                
                let distance = displayFace.node.position.distance(toVector: position)
                if(distance >= 0.03 ) {
                    displayFace.node.move(position)
                }
                displayFace.timestamp = frame.timestamp
                
            } else {
                existentFace.node.position = position
                existentFace.node.show()
                existentFace.timestamp = frame.timestamp
            }
        }
    }
    
    /// Transform bounding box according to device orientation
    ///
    /// - Parameter boundingBox: of the face
    /// - Returns: transformed bounding box
    private func transformBoundingBox(_ boundingBox: CGRect) -> CGRect {
        var size: CGSize
        var origin: CGPoint
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            size = CGSize(width: boundingBox.width * bounds.height,
                          height: boundingBox.height * bounds.width)
        default:
            size = CGSize(width: boundingBox.width * bounds.width,
                          height: boundingBox.height * bounds.height)
        }
        
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            origin = CGPoint(x: boundingBox.minY * bounds.width,
                             y: boundingBox.minX * bounds.height)
        case .landscapeRight:
            origin = CGPoint(x: (1 - boundingBox.maxY) * bounds.width,
                             y: (1 - boundingBox.maxX) * bounds.height)
        case .portraitUpsideDown:
            origin = CGPoint(x: (1 - boundingBox.maxX) * bounds.width,
                             y: boundingBox.minY * bounds.height)
        default:
            origin = CGPoint(x: boundingBox.minX * bounds.width,
                             y: (1 - boundingBox.maxY) * bounds.height)
        }
        
        return CGRect(origin: origin, size: size)
    }
    
    /// In order to get stable vectors, we determine multiple coordinates within an interval.
    ///
    /// - Parameters:
    ///   - boundingBox: Rect of the face on the screen
    /// - Returns: the normalized vector
    private func normalizeWorldCoord(_ boundingBox: CGRect) -> SCNVector3? {
        
        var array: [SCNVector3] = []
        Array(0...2).forEach{_ in
            if let position = determineWorldCoord(boundingBox) {
                array.append(position)
            }
            usleep(12000) // .012 seconds
        }
        
        if array.isEmpty {
            return nil
        }
        
        return SCNVector3.center(array)
    }
    
    /// Determine the vector from the position on the screen.
    ///
    /// - Parameter boundingBox: Rect of the face on the screen
    /// - Returns: the vector in the sceneView
    private func determineWorldCoord(_ boundingBox: CGRect) -> SCNVector3? {
        let arHitTestResults = sceneView.hitTest(CGPoint(x: boundingBox.midX, y: boundingBox.midY), types: [.featurePoint])
        
        // Filter results that are to close
        if let closestResult = arHitTestResults.filter({ $0.distance > 0.10 }).first {
//            print("vector distance: \(closestResult.distance)")
            return SCNVector3.positionFromTransform(closestResult.worldTransform)
        }
        return nil
    }
}
