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
    let id: Int
    let node: SCNNode
    var hidden: Bool {
        get {
            return node.opacity != 1
        }
    }
    
    var timestamp: TimeInterval {
        didSet {
            updated = Date()
        }
    }
    private(set) var updated = Date()
    
    init(id: Int, node: SCNNode, timestamp: TimeInterval) {
        self.id = id
        self.node = node
        self.timestamp = timestamp
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
