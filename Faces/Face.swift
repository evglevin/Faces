//
//  Face.swift
//  Faces
//
//  Created by Евгений Левин on 23.02.2018.
//  Copyright © 2018 levin inc. All rights reserved.
//

import Foundation
import ARKit

class Face {
    let name: String
    let node: SCNNode
    var hidden: Bool {
        get {
            return node.opacity != 1
        }
    }
    
    var timeStamp: TimeInterval {
        didSet {
            updated = Date()
        }
    }
    private(set) var updated = Date()
    
    init(name: String, node: SCNNode, timeStamp: TimeInterval) {
        self.name = name
        self.node = node
        self.timeStamp = timeStamp
    }
}

extension Date {
    func isAfter(seconds: Double) -> Bool {
        let elapsed = Date.init().timeIntervalSince(self)
        
        if elapsed > seconds {
            return true
        }
        return false
    }
}
