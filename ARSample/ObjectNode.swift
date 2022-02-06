//
//  ObjectNode.swift
//  ARSample
//  
//  Created by ji-no on R 4/02/05
//  
//

import SceneKit

class ObjectNode: SCNNode {

    // https://developer.apple.com/jp/augmented-reality/quick-look/
    enum ObjectType {
        case airForce
    }
    
    enum State {
        case idle
        case selected
        case canceling
    }
    private var state: State = .idle
    private var startPositionY: Float = 0.0

    init(type: ObjectType = .airForce) {
        super.init()
        
        var scale = 1.0
        switch type {
        case .airForce:
            loadUsdz(name: "AirForce")
            scale = 0.01
        }
        self.scale = SCNVector3(scale, scale, scale)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func select() {
        guard state == .idle else { return }

        state = .selected
        riseAction()
    }
    
    func cancel() {
        guard state == .selected else { return }

        state = .canceling
        removeAllActions()
        falldownAction()
    }
    
    private func riseAction() {
        startPositionY = position.y

        let rise = SCNAction.moveBy(x: 0, y: 0.1, z: 0, duration: 0.5)
        rise.timingMode = .easeInEaseOut
        self.runAction(rise, forKey: nil) { [weak self] in
            self?.floatingAction()
        }
    }
    
    private func floatingAction() {
        let down = SCNAction.moveBy(x: 0, y: -0.03, z: 0, duration: 1)
        down.timingMode = .easeInEaseOut
        let up = SCNAction.moveBy(x: 0, y: 0.03, z: 0, duration: 1)
        up.timingMode = .easeInEaseOut

        let floating = SCNAction.sequence([down,up])
        self.runAction(floating, forKey: nil) { [weak self] in
            self?.floatingAction()
        }
    }
    
    private func falldownAction() {
        let fallY = startPositionY - self.position.y
        let fall = SCNAction.move(by: SCNVector3(0, fallY, 0), duration: 0.3)
        let up = SCNAction.move(by: SCNVector3(0, 0.02, 0), duration: 0.1)
        let down = SCNAction.move(by: SCNVector3(0, -0.02, 0), duration: 0.1)
        fall.timingMode = .easeIn
        up.timingMode = .easeOut
        down.timingMode = .easeIn
        let falldown = SCNAction.sequence([fall,up,down])
        self.runAction(falldown, forKey: nil) { [weak self] in
            self?.state = .idle
        }
    }

}

extension SCNNode {

    func loadUsdz(name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "usdz") else { fatalError() }
        let scene = try! SCNScene(url: url, options: [.checkConsistency: true])
        for child in scene.rootNode.childNodes {
            child.geometry?.firstMaterial?.lightingModel = .physicallyBased
            addChildNode(child)
        }
    }
    
    func asObjectNode() -> ObjectNode? {
        if let objectNode = self as? ObjectNode {
            return objectNode
        }
        
        var parent = self.parent
        while parent != nil {
            if let objectNode = parent as? ObjectNode {
                return objectNode
            }
            parent = parent?.parent
        }
        return nil
    }

}
