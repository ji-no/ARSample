//
//  NodeSizeText.swift
//  SceneKitSample
//  
//  Created by ji-no on R 4/02/28
//  
//

import SceneKit

class NodeSizeText {
    class Vertex {
        var node: SCNNode
        var relatedNodes: [SCNNode] = []
        
        init(_ position: SCNVector3) {
            node = SCNNode()
            node.position = position
        }
    }
    class SideArrow {
        var node: SCNNode
        var textNode: SCNNode?

        init(_ node: SCNNode) {
            self.node = node
        }
    }

    weak var targetNode: SCNNode?
    private var vertices: [Vertex] = []
    private var sideArrows: [SideArrow] = []
    private var arrowColor: UIColor = .init(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
    private var edgeRadius: Float = 0.001

    func show() {
        createSizeText()
    }

    func hide() {
        vertices.forEach { vertex in
            vertex.node.removeFromParentNode()
            vertex.relatedNodes.forEach { $0.removeFromParentNode() }
        }
        vertices = []

        sideArrows.forEach { arrow in
            arrow.node.removeFromParentNode()
            arrow.textNode?.removeFromParentNode()
        }
    }

    func updateSizeText(cameraPosition: SCNVector3) {
        vertices.flatMap { $0.relatedNodes }.forEach { $0.isHidden = false }
        let sortedVertices = vertices
            .map { ($0, distance($0.node.convertPosition($0.node.position, to: nil), cameraPosition)) }
            .sorted { a, b in a.1 < b.1 }
            .map { $0.0 }
        sortedVertices.first?.relatedNodes.forEach { $0.isHidden = true}
        sortedVertices.last?.relatedNodes.forEach { $0.isHidden = true}

        sideArrows
            .map { ($0, distance($0.node.convertPosition($0.node.position, to: nil), cameraPosition)) }
            .sorted { a, b in a.1 < b.1 }
            .enumerated()
            .forEach { it in
                it.element.0.node.isHidden = it.offset != 1
                it.element.0.textNode?.isHidden = it.offset != 1
            }
    }

    private func createSizeText() {
        guard let targetNode = targetNode else { return }
        
        createVertices(targetNode: targetNode)
        createTopArrows(targetNode: targetNode)
        createSideArrows(targetNode: targetNode)
        createWidthText(targetNode: targetNode)
        createDepthText(targetNode: targetNode)
        createHeightText(targetNode: targetNode)
    }

    private func createVertices(targetNode: SCNNode) {
        let boundingBoxSize = targetNode.boundingBoxSize
        let boundingBoxCenter = targetNode.boundingBoxCenter
        
        vertices = [
            SCNVector3(x: 1, y: 1, z: 1),
            SCNVector3(x: 1, y: 1, z: -1),
            SCNVector3(x: -1, y: 1, z: 1),
            SCNVector3(x: -1, y: 1, z: -1),
            SCNVector3(x: 1, y: -1, z: 1),
            SCNVector3(x: 1, y: -1, z: -1),
            SCNVector3(x: -1, y: -1, z: 1),
            SCNVector3(x: -1, y: -1, z: -1),
        ].map { point in
            let vertex = Vertex(.init(
                x: boundingBoxCenter.x + boundingBoxSize.x * 0.5 * point.x,
                y: boundingBoxCenter.y + boundingBoxSize.y * 0.5 * point.y,
                z: boundingBoxCenter.z + boundingBoxSize.z * 0.5 * point.z
            ))
            targetNode.parent?.addChildNode(vertex.node)
            return vertex
        }
        
    }

    private func createTopArrows(targetNode: SCNNode) {
        let boundingBoxSize = targetNode.boundingBoxSize
        let boundingBoxCenter = targetNode.boundingBoxCenter
        let radius: Float = edgeRadius

        let parameters: [(height: Float, axis: SCNVector3, position: SCNVector3, vertices: [Int])] = [
            (height: boundingBoxSize.x, axis: .init(x: 0, y: 0, z: 1), position: .init(x: 0, y: 1, z: 1), vertices: [0, 2]),
            (height: boundingBoxSize.x, axis: .init(x: 0, y: 0, z: 1), position: .init(x: 0, y: 1, z: -1), vertices: [1, 3]),
            (height: boundingBoxSize.z, axis: .init(x: 1, y: 0, z: 0), position: .init(x: 1, y: 1, z: 0), vertices: [0, 1]),
            (height: boundingBoxSize.z, axis: .init(x: 1, y: 0, z: 0), position: .init(x: -1, y: 1, z: 0), vertices: [2, 3]),
        ]

        parameters.forEach { height, axis, position, vertexIndexes in
            let node = createArrow(height: height - radius * 6)
            node.eulerAngles = axis * (-.pi * 0.5)
            node.position = boundingBoxCenter + SCNVector3(
                x: (boundingBoxSize.x * 0.5 + radius) * position.x,
                y: (boundingBoxSize.y * 0.5 + radius) * position.y,
                z: (boundingBoxSize.z * 0.5 + radius) * position.z
            )
            targetNode.parent?.addChildNode(node)
            vertexIndexes.forEach { index in
                vertices[index].relatedNodes.append(node)
            }
        }
    }

    private func createSideArrows(targetNode: SCNNode) {
        let boundingBoxSize = targetNode.boundingBoxSize
        let boundingBoxCenter = targetNode.boundingBoxCenter
        let radius: Float = edgeRadius

        let parameters: [SCNVector3] = [
            .init(x: 1, y: 0, z: 1),
            .init(x: 1, y: 0, z: -1),
            .init(x: -1, y: 0, z: 1),
            .init(x: -1, y: 0, z: -1)
        ]

        sideArrows = parameters.map { position in
            let node = createArrow(height: boundingBoxSize.y - radius * 6)
            node.position = boundingBoxCenter + SCNVector3(
                x: (boundingBoxSize.x * 0.5 + radius) * position.x,
                y: (boundingBoxSize.y * 0.5 + radius) * position.y,
                z: (boundingBoxSize.z * 0.5 + radius) * position.z
            )
            targetNode.parent?.addChildNode(node)
            return .init(node)
        }
    }

    private func createArrow(height: Float) -> SCNNode {
        let material = SCNMaterial()
        material.diffuse.contents = arrowColor

        let cylinderRadius: CGFloat = CGFloat(edgeRadius)
        let cylinder = SCNCylinder(radius: cylinderRadius, height: CGFloat(height))
        cylinder.insertMaterial(material, at: 0)
        let cylinderNode = SCNNode(geometry: cylinder)
        
        let coneRadius: CGFloat = CGFloat(edgeRadius * 3)
        let coneHeight: CGFloat = CGFloat(edgeRadius * 6)
        let cone = SCNCone(topRadius: 0, bottomRadius: coneRadius, height: coneHeight)
        cone.insertMaterial(material, at: 0)
        cone.insertMaterial(material, at: 1)
        let coneNode = SCNNode(geometry: cone)
        coneNode.position.y = height * 0.5
        
        let coneNode2: SCNNode = coneNode.clone()
        coneNode2.eulerAngles = .init(x: .pi, y: 0, z: 0)
        coneNode2.position.y = -height * 0.5

        let node = SCNNode()
        node.addChildNode(cylinderNode)
        node.addChildNode(coneNode)
        node.addChildNode(coneNode2)
        
        return node
    }

    private func createWidthText(targetNode: SCNNode) {
        let boundingBoxSize = targetNode.boundingBoxSize
        let boundingBoxCenter = targetNode.boundingBoxCenter

        let positions: [(position: SCNVector3, vertices: [Int])] = [
            (.init(x: 0, y: 1, z: 1), vertices: [0, 2]),
            (.init(x: 0, y: 1, z: -1), vertices: [1, 3])
        ]
        
        positions.forEach { position, vertexIndexes in
            let textNode = create(text: String.init(format: "w:%.2f", boundingBoxSize.x), targetNode: targetNode)
            textNode.position = boundingBoxCenter + SCNVector3(
                x: (boundingBoxSize.x * 0.5) * position.x,
                y: (boundingBoxSize.y * 0.5) * position.y,
                z: (boundingBoxSize.z * 0.5) * position.z
            )
            textNode.position.y += textNode.boundingBoxSize.y * 0.5
            if position.z > 0 {
                textNode.position.z += textNode.boundingBoxSize.x * 0.5
            } else {
                textNode.position.z -= textNode.boundingBoxSize.x * 0.5
            }
            vertexIndexes.forEach { index in
                vertices[index].relatedNodes.append(textNode)
            }
        }
    }

    private func createDepthText(targetNode: SCNNode) {
        let boundingBoxSize = targetNode.boundingBoxSize
        let boundingBoxCenter = targetNode.boundingBoxCenter

        let positions: [(position: SCNVector3, vertices: [Int])] = [
            (.init(x: 1, y: 1, z: 0), vertices: [0, 1]),
             (.init(x: -1, y: 1, z: 0), vertices: [2, 3])
        ]

        positions.forEach { position, vertexIndexes in
            let textNode = create(text: String.init(format: "d:%.2f", boundingBoxSize.z), targetNode: targetNode)
            textNode.position = boundingBoxCenter + SCNVector3(
                x: (boundingBoxSize.x * 0.5) * position.x,
                y: (boundingBoxSize.y * 0.5) * position.y,
                z: (boundingBoxSize.z * 0.5) * position.z
            )
            textNode.position.y += textNode.boundingBoxSize.y * 0.5
            if position.x > 0 {
                textNode.position.x += textNode.boundingBoxSize.x * 0.5
            } else {
                textNode.position.x -= textNode.boundingBoxSize.x * 0.5
            }
            vertexIndexes.forEach { index in
                vertices[index].relatedNodes.append(textNode)
            }
        }
    }

    private func createHeightText(targetNode: SCNNode) {
        let boundingBoxSize = targetNode.boundingBoxSize
        let boundingBoxCenter = targetNode.boundingBoxCenter

        let positions: [SCNVector3] = [
            .init(x: 1, y: 0, z: 1),
            .init(x: 1, y: 0, z: -1),
            .init(x: -1, y: 0, z: 1),
            .init(x: -1, y: 0, z: -1)
        ]

        positions.enumerated().forEach { index, position in
            let textNode = create(text: String.init(format: "h:%.2f", boundingBoxSize.y), targetNode: targetNode)
            textNode.position = boundingBoxCenter + SCNVector3(
                x: (boundingBoxSize.x * 0.5) * position.x,
                y: (boundingBoxSize.y * 0.5) * position.y,
                z: (boundingBoxSize.z * 0.5) * position.z
            )
            if position.x > 0 {
                textNode.position.x += textNode.boundingBoxSize.x * 0.6 / sqrt(2)
            } else {
                textNode.position.x -= textNode.boundingBoxSize.x * 0.6 / sqrt(2)
            }
            if position.z > 0 {
                textNode.position.z += textNode.boundingBoxSize.x * 0.6 / sqrt(2)
            } else {
                textNode.position.z -= textNode.boundingBoxSize.x * 0.6 / sqrt(2)
            }
            sideArrows[index].textNode = textNode
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

