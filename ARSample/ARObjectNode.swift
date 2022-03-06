//
//  ARObjectNode.swift
//  ARSample
//  
//  Created by ji-no on R 4/02/05
//  
//

import SceneKit

class ARObjectNode: SCNNode {
    private(set) var modelRoot = SCNNode()
    var boundingBoxNode: SCNNode?
    var sizeText = NodeSizeText()
    var outsideEdge = NodeOutsideEdge()

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
        case boundingBox
        case outsideEdge
        case sizeLabel
    }
    private var state: State = .idle {
        didSet {
            boundingBoxNode?.removeFromParentNode()
            boundingBoxNode = nil
            outsideEdge.hide()
            sizeText.hide()

            switch state {
            case .idle:
                break
            case .boundingBox:
                showBoundingBox()
            case .outsideEdge:
                outsideEdge.show()
            case .sizeLabel:
                sizeText.show()
            }
        }
    }

    init(type: ObjectType = .AirForce, position: SCNVector3) {
        super.init()
        sizeText.targetNode = modelRoot
        outsideEdge.targetNode = modelRoot

        var scale = 1.0
        switch type {
        case .AirForce:
            scale = 0.01
        case .ChairSwan:
            scale = 0.003
        case .Teapot:
            scale = 0.01
        case .ToyBiplane:
            scale = 0.01
        }
        modelRoot.loadUsdz(name: type.rawValue)
        modelRoot.scale = SCNVector3(scale, scale, scale)
        addChildNode(modelRoot)
        self.name = type.rawValue
        self.spawn(position: position)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(cameraPosition: SCNVector3) {
        sizeText.updateSizeText(cameraPosition: cameraPosition)
        outsideEdge.updateEdge(cameraPosition: cameraPosition)
    }
    
    func showBoundingBox() {
        let box = SCNBox(
            width: CGFloat(modelRoot.boundingBoxSize.x),
            height: CGFloat(modelRoot.boundingBoxSize.y),
            length: CGFloat(modelRoot.boundingBoxSize.z),
            chamferRadius: 0
        )
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.init(red: 0, green: 1, blue: 0, alpha: 0.5)
        for i in 0...5 {
            box.insertMaterial(material, at: i)
        }
        let boxNode = SCNNode(geometry: box)
        boxNode.position = modelRoot.boundingBoxCenter
        addChildNode(boxNode)
        boundingBoxNode = boxNode
    }

    private func spawn(position: SCNVector3) {
        self.position = position
        
        let toScale = CGFloat(self.scale.x)
        self.scale = SCNVector3(0, 0, 0)
        let action = SCNAction.scale(to: toScale, duration: 0.2)
        self.runAction(action, forKey: nil) { [weak self] in
            self?.state = .sizeLabel
        }
    }
    
    func isSelected() -> Bool {
        return state != .idle
    }

    func select() {
        switch state {
        case .idle:
            state = .sizeLabel
        case .sizeLabel:
            state = .outsideEdge
        case .outsideEdge:
            state = .boundingBox
        case .boundingBox:
            state = .idle
        }
    }
    
    func cancel() {
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
        let options: [SCNSceneSource.LoadingOption : Any] = [
            .createNormalsIfAbsent: true,
            .checkConsistency: true,
            .flattenScene: true,
            .strictConformance: true,
            .convertUnitsToMeters: 1,
            .convertToYUp: true,
            .preserveOriginalTopology: false
        ]
        let scene = try! SCNScene(url: url, options: options)
        for child in scene.rootNode.childNodes {
            child.geometry?.firstMaterial?.lightingModel = .physicallyBased
            addChildNode(child)
        }
    }
    
    var boundingBoxSize: SCNVector3 {
        return SCNVector3(
            x: (boundingBox.max.x - boundingBox.min.x) * scale.x,
            y: (boundingBox.max.y - boundingBox.min.y) * scale.y,
            z: (boundingBox.max.z - boundingBox.min.z) * scale.z
        )
    }

    var boundingBoxCenter: SCNVector3 {
        return SCNVector3(
            x: (boundingBox.max.x + boundingBox.min.x) * 0.5 * scale.x,
            y: (boundingBox.max.y + boundingBox.min.y) * 0.5 * scale.y,
            z: (boundingBox.max.z + boundingBox.min.z) * 0.5 * scale.z
        )
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
