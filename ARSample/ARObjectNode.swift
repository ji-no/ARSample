//
//  ARObjectNode.swift
//  ARSample
//  
//  Created by ji-no on R 4/02/05
//  
//

import SceneKit

class ARObjectNode: SCNNode {

    // https://developer.apple.com/jp/augmented-reality/quick-look/
    enum ObjectType: String {
        case AirForce
        case ChairSwan
        case Teapot
        case ToyBiplane
        
        static var all: [ObjectType] = [
            .AirForce,
            .ChairSwan,
            .Teapot,
            .ToyBiplane
        ]
    }
    
    enum State {
        case idle
        case selected
    }
    private var state: State = .idle

    init(type: ObjectType = .AirForce, position: SCNVector3) {
        super.init()
        
        var scale = 1.0
        switch type {
        case .AirForce:
            loadUsdz(name: type.rawValue)
            scale = 0.01
        case .ChairSwan:
            loadUsdz(name: type.rawValue)
            scale = 0.003
        case .Teapot:
            loadUsdz(name: type.rawValue)
            scale = 0.01
        case .ToyBiplane:
            loadUsdz(name: type.rawValue)
            scale = 0.01
        }
        self.scale = SCNVector3(scale, scale, scale)
        self.name = type.rawValue
        self.spawn(position: position)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func spawn(position: SCNVector3) {
        self.position = position
        
        let toScale = CGFloat(self.scale.x)
        self.scale = SCNVector3(0, 0, 0)
        let action = SCNAction.scale(to: toScale, duration: 0.2)
        self.runAction(action, forKey: nil) { [weak self] in
            self?.state = .selected
        }
    }
    
    func isSelected() -> Bool {
        return state == .selected
    }

    func select() {
        guard state == .idle else { return }

        state = .selected
    }
    
    func cancel() {
        guard state == .selected else { return }

        state = .idle
    }
    
    func removeObject() {
        removeAllActions()
        let action = SCNAction.scale(to: 0, duration: 0.2)
        self.runAction(action, forKey: nil) { [weak self] in
            self?.removeFromParentNode()
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
    
    func asObjectNode() -> ARObjectNode? {
        if let objectNode = self as? ARObjectNode {
            return objectNode
        }
        
        var parent = self.parent
        while parent != nil {
            if let objectNode = parent as? ARObjectNode {
                return objectNode
            }
            parent = parent?.parent
        }
        return nil
    }

}
