//
//  NodeSizeText.swift
//  SceneKitSample
//  
//  Created by ji-no on R 4/02/28
//  
//

import SceneKit

class NodeSizeText {
    weak var targetNode: SCNNode?
    var widthTextNodes: [SCNNode] = []
    var depthTextNodes: [SCNNode] = []
    var heightTextNodes: [SCNNode] = []

    func show() {
        createSizeText()
    }

    func hide() {
        (widthTextNodes + depthTextNodes + heightTextNodes).forEach { node in
            node.removeFromParentNode()
        }
        widthTextNodes = []
        depthTextNodes = []
        heightTextNodes = []
    }

    func updateSizeText(cameraPosition: SCNVector3) {
        widthTextNodes
            .map { ($0, distance($0.convertPosition($0.position, to: nil), cameraPosition)) }
            .sorted { a, b in a.1 < b.1 }
            .enumerated()
            .forEach { it in
                it.element.0.isHidden = it.offset != 0
            }
        depthTextNodes
            .map { ($0, distance($0.convertPosition($0.position, to: nil), cameraPosition)) }
            .sorted { a, b in a.1 < b.1 }
            .enumerated()
            .forEach { it in
                it.element.0.isHidden = it.offset != 0
            }
        heightTextNodes
            .map { ($0, distance($0.convertPosition($0.position, to: nil), cameraPosition)) }
            .sorted { a, b in a.1 < b.1 }
            .enumerated()
            .forEach { it in
                it.element.0.isHidden = it.offset != 1
            }
    }

    func createSizeText() {
        guard let targetNode = targetNode else { return }
        
        createWidthText(targetNode: targetNode)
        createDepthText(targetNode: targetNode)
        createHeightText(targetNode: targetNode)
    }
    
    private func createWidthText(targetNode: SCNNode) {
        let boundingBoxSize = targetNode.boundingBoxSize
        let boundingBoxCenter = targetNode.boundingBoxCenter

        let positions = [
            SCNVector3(
                x: 0,
                y: -boundingBoxSize.y * 0.5,
                z: boundingBoxSize.z * 0.5
            ),
            SCNVector3(
                x: 0,
                y: -boundingBoxSize.y * 0.5,
                z: -boundingBoxSize.z * 0.5
            )
        ]
        
        widthTextNodes = positions.map { pos in
            let textNode = create(text: String.init(format: "w:%.2f", boundingBoxSize.x), targetNode: targetNode)
            textNode.position = boundingBoxCenter + pos
            textNode.position.y += textNode.boundingBoxSize.y * 0.5
            if pos.z > 0 {
                textNode.position.z += textNode.boundingBoxSize.x * 0.5
            } else {
                textNode.position.z -= textNode.boundingBoxSize.x * 0.5
            }
            return textNode
        }
    }

    private func createDepthText(targetNode: SCNNode) {
        let boundingBoxSize = targetNode.boundingBoxSize
        let boundingBoxCenter = targetNode.boundingBoxCenter

        let positions = [
            SCNVector3(
                x: boundingBoxSize.x * 0.5,
                y: -boundingBoxSize.y * 0.5,
                z: 0
            ),
            SCNVector3(
                x: -boundingBoxSize.x * 0.5,
                y: -boundingBoxSize.y * 0.5,
                z: 0
            )
        ]

        depthTextNodes = positions.map { pos in
            let textNode = create(text: String.init(format: "d:%.2f", boundingBoxSize.z), targetNode: targetNode)
            textNode.position = boundingBoxCenter + pos
            textNode.position.y += textNode.boundingBoxSize.y * 0.5
            if pos.x > 0 {
                textNode.position.x += textNode.boundingBoxSize.x * 0.5
            } else {
                textNode.position.x -= textNode.boundingBoxSize.x * 0.5
            }
            return textNode
        }
    }

    private func createHeightText(targetNode: SCNNode) {
        let boundingBoxSize = targetNode.boundingBoxSize
        let boundingBoxCenter = targetNode.boundingBoxCenter

        let positions = [
            SCNVector3(
                x: -boundingBoxSize.x * 0.5,
                y: 0,
                z: boundingBoxSize.z * 0.5
            ),
            SCNVector3(
                x: boundingBoxSize.x * 0.5,
                y: 0,
                z: boundingBoxSize.z * 0.5
            ),
            SCNVector3(
                x: +boundingBoxSize.x * 0.5,
                y: 0,
                z: -boundingBoxSize.z * 0.5
            ),
            SCNVector3(
                x: -boundingBoxSize.x * 0.5,
                y: 0,
                z: -boundingBoxSize.z * 0.5
            ),
        ]

        heightTextNodes = positions.map { pos in
            let textNode = create(text: String.init(format: "h:%.2f", boundingBoxSize.y), targetNode: targetNode)
            textNode.position = boundingBoxCenter + pos
            if pos.x > 0 {
                textNode.position.x += textNode.boundingBoxSize.x * 0.6 / sqrt(2)
            } else {
                textNode.position.x -= textNode.boundingBoxSize.x * 0.6 / sqrt(2)
            }
            if pos.z > 0 {
                textNode.position.z += textNode.boundingBoxSize.x * 0.6 / sqrt(2)
            } else {
                textNode.position.z -= textNode.boundingBoxSize.x * 0.6 / sqrt(2)
            }
            return textNode
        }
    }

    private func create(text: String, targetNode: SCNNode) -> SCNNode {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.init(red: 1, green: 0, blue: 0, alpha: 1)

        let scnText = SCNText(string: text, extrusionDepth: 0.2)
        for i in 0...5 {
            scnText.insertMaterial(material, at: i)
        }
        
        let scale: Float = 0.002

        let textNode = SCNNode(geometry: scnText)
        textNode.scale = .init(x: scale, y: scale, z: scale)
        textNode.position = .init(
            x: -textNode.boundingBoxCenter.x,
            y: -textNode.boundingBoxCenter.y,
            z: -textNode.boundingBoxCenter.z
        )
        
        let plane = SCNPlane(width: CGFloat(textNode.boundingBoxSize.x + 0.01), height: CGFloat(textNode.boundingBoxSize.y + 0.01))
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = UIColor.white
        plane.insertMaterial(planeMaterial, at: 0)
        let planeNode = SCNNode(geometry: plane)
        
        let node = SCNNode()
        node.addChildNode(textNode)
        node.addChildNode(planeNode)
        let billboardConstraint = SCNBillboardConstraint()
        node.constraints = [billboardConstraint]
        node.position = targetNode.position
        targetNode.parent?.addChildNode(node)
        
        return node
    }

}

