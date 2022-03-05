//
//  CursorNode.swift
//  ARSample
//  
//  Created by ji-no on R 4/03/05
//  
//

import SceneKit

class CursorNode: SCNNode {

    let SHAKE_THRESHOLD: Float = 0.01
    let FLOATING_Y: Float = 0.01
    let DEFAULT_SCALE: Float = 0.1
    let DEFAULT_COLOR = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    
    var rootNode = SCNNode()
    var material: SCNMaterial?
    
    override init() {
        super.init()

        let material = SCNMaterial()
        material.diffuse.contents = DEFAULT_COLOR
        self.material = material

        let outerTube = SCNTube(innerRadius: 0.475, outerRadius: 0.5, height: 0)
        outerTube.insertMaterial(material, at: 0)
        let outerNode = SCNNode(geometry: outerTube)
        rootNode.addChildNode(outerNode)

        let innerTube = SCNTube(innerRadius: 0.0, outerRadius: 0.25, height: 0)
        innerTube.insertMaterial(material, at: 0)
        let innerNode = SCNNode(geometry: innerTube)
        rootNode.addChildNode(innerNode)
        
        rootNode.scale = .init(x: DEFAULT_SCALE, y: 1, z: DEFAULT_SCALE)
        rootNode.position.y = FLOATING_Y

        addChildNode(rootNode)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func select(size: SCNVector3) {
        material?.diffuse.contents = UIColor.cyan

        let centerScale = CGFloat(sqrt(pow(size.x, 2) + pow(size.z, 2)))
        let scaleUpAction = SCNAction.scale(to: centerScale * 1.1, duration: 1)
        scaleUpAction.timingMode = .easeInEaseOut
        let scaleDownAction = SCNAction.scale(to: centerScale * 0.9, duration: 1)
        scaleDownAction.timingMode = .easeInEaseOut
        let action = SCNAction.sequence([scaleUpAction, scaleDownAction])
        rootNode.runAction(SCNAction.repeatForever(action))
    }
    
    func unselect() {
        rootNode.removeAllActions()
        material?.diffuse.contents = DEFAULT_COLOR
        rootNode.scale = .init(x: DEFAULT_SCALE, y: 1, z: DEFAULT_SCALE)
    }

}
