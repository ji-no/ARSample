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
    let DEFAULT_COLOR = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
    
    override init() {
        super.init()

        let material = SCNMaterial()
        material.diffuse.contents = DEFAULT_COLOR
        
        let rootNode = SCNNode()

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

}
