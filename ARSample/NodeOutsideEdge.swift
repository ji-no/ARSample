//
//  NodeOutsideEdge.swift
//  SceneKitSample
//  
//  Created by ji-no on R 4/02/28
//  
//

import SceneKit

class NodeOutsideEdge {
    class Vertex {
        var node: SCNNode
        var edges: [SCNNode] = []
        
        init(_ position: SCNVector3) {
//            let sphere = SCNSphere(radius: 0.005)
//            let material = SCNMaterial()
//            material.diffuse.contents = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
//            sphere.insertMaterial(material, at: 0)
//            node = SCNNode(geometry: sphere)
            node = SCNNode()
            node.position = position
        }
    }
    
    weak var targetNode: SCNNode?
    private var vertices: [Vertex] = []
    private var edges: [SCNNode] = []

    private var color: UIColor = .init(red: 0, green: 1, blue: 1, alpha: 1)
    private var edgeRadius: Float {
        return 0.001
    }

    func show() {
        createEdge()
    }
    
    func hide() {
        vertices.forEach { vertex in
            vertex.node.removeFromParentNode()
        }
        vertices = []
        edges.forEach { edge in
            edge.removeFromParentNode()
        }
        edges = []
    }
    
    func updateEdge(cameraPosition: SCNVector3) {
        edges.forEach { $0.isHidden = false }
        let sortedVertices = vertices
            .map { ($0, distance($0.node.convertPosition($0.node.position, to: nil), cameraPosition)) }
            .sorted { a, b in a.1 < b.1 }
            .map { $0.0 }
        sortedVertices.first?.edges.forEach { $0.isHidden = true}
        sortedVertices.last?.edges.forEach { $0.isHidden = true}
    }

    private func createEdge() {
        guard let targetNode = targetNode else { return }

        createVertices(targetNode: targetNode)
        createTopEdges(targetNode: targetNode)
        createBottomEdges(targetNode: targetNode)
        createSideEdges(targetNode: targetNode)
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

    private func createTopEdges(targetNode: SCNNode) {
        let boundingBoxSize = targetNode.boundingBoxSize
        let boundingBoxCenter = targetNode.boundingBoxCenter

        let radius: Float = edgeRadius
        let cylinder = SCNCylinder(radius: CGFloat(radius), height: 1)
        let material = SCNMaterial()
        material.diffuse.contents = color
        cylinder.insertMaterial(material, at: 0)

        let parameters: [(height: Float, axis: SCNVector3, position: SCNVector3, vertices: [Int])] = [
            (height: boundingBoxSize.x, axis: .init(x: 0, y: 0, z: 1), position: .init(x: 0, y: 1, z: 1), vertices: [0, 2]),
            (height: boundingBoxSize.x, axis: .init(x: 0, y: 0, z: 1), position: .init(x: 0, y: 1, z: -1), vertices: [1, 3]),
            (height: boundingBoxSize.z, axis: .init(x: 1, y: 0, z: 0), position: .init(x: 1, y: 1, z: 0), vertices: [0, 1]),
            (height: boundingBoxSize.z, axis: .init(x: 1, y: 0, z: 0), position: .init(x: -1, y: 1, z: 0), vertices: [2, 3]),
        ]

        parameters.forEach { height, axis, position, vertexIndexes in
            let node = SCNNode(geometry: cylinder)
            node.scale = SCNVector3(x: 1, y: height + radius * 2, z: 1)
            node.eulerAngles = axis * (-.pi * 0.5)
            node.position = boundingBoxCenter + SCNVector3(
                x: (boundingBoxSize.x * 0.5 + radius) * position.x,
                y: (boundingBoxSize.y * 0.5 + radius) * position.y,
                z: (boundingBoxSize.z * 0.5 + radius) * position.z
            )
            targetNode.parent?.addChildNode(node)
            edges.append(node)
            vertexIndexes.forEach { index in
                vertices[index].edges.append(node)
            }
        }
    }

    private func createBottomEdges(targetNode: SCNNode) {
        let boundingBoxSize = targetNode.boundingBoxSize
        let boundingBoxCenter = targetNode.boundingBoxCenter
        
        let radius: Float = edgeRadius
        let cylinder = SCNCylinder(radius: CGFloat(radius), height: 1)
        let material = SCNMaterial()
        material.diffuse.contents = color
        cylinder.insertMaterial(material, at: 0)

        let parameters: [(height: Float, axis: SCNVector3, position: SCNVector3, vertices: [Int])] = [
            (height: boundingBoxSize.x, axis: .init(x: 0, y: 0, z: 1), position: .init(x: 0, y: -1, z: 1), vertices: [4, 6]),
            (height: boundingBoxSize.x, axis: .init(x: 0, y: 0, z: 1), position: .init(x: 0, y: -1, z: -1), vertices: [5, 7]),
            (height: boundingBoxSize.z, axis: .init(x: 1, y: 0, z: 0), position: .init(x: 1, y: -1, z: 0), vertices: [4, 5]),
            (height: boundingBoxSize.z, axis: .init(x: 1, y: 0, z: 0), position: .init(x: -1, y: -1, z: 0), vertices: [6, 7]),
        ]

        parameters.forEach { height, axis, position, vertexIndexes in
            let node = SCNNode(geometry: cylinder)
            node.scale = SCNVector3(x: 1, y: height + radius * 2, z: 1)
            node.eulerAngles = axis * (-.pi * 0.5)
            node.position = boundingBoxCenter + SCNVector3(
                x: (boundingBoxSize.x * 0.5 + radius) * position.x,
                y: (boundingBoxSize.y * 0.5 + radius) * position.y,
                z: (boundingBoxSize.z * 0.5 + radius) * position.z
            )
            targetNode.parent?.addChildNode(node)
            edges.append(node)
            vertexIndexes.forEach { index in
                vertices[index].edges.append(node)
            }
        }
    }

    private func createSideEdges(targetNode: SCNNode) {
        let boundingBoxSize = targetNode.boundingBoxSize
        let boundingBoxCenter = targetNode.boundingBoxCenter
        
        let radius: Float = edgeRadius
        let cylinder = SCNCylinder(radius: CGFloat(radius), height: 1)
        let material = SCNMaterial()
        material.diffuse.contents = color
        cylinder.insertMaterial(material, at: 0)

        let parameters: [(position: SCNVector3, vertices: [Int])] = [
            (position: .init(x: 1, y: 0, z: 1), vertices: [0, 4]),
            (position: .init(x: 1, y: 0, z: -1), vertices: [1, 5]),
            (position: .init(x: -1, y: 0, z: 1), vertices: [2, 6]),
            (position: .init(x: -1, y: 0, z: -1), vertices: [3, 7]),
        ]

        parameters.forEach { position, vertexIndexes in
            let node = SCNNode(geometry: cylinder)
            node.scale = SCNVector3(x: 1, y: boundingBoxSize.y + radius * 2, z: 1)
            node.position = boundingBoxCenter + SCNVector3(
                x: (boundingBoxSize.x * 0.5 + radius) * position.x,
                y: (boundingBoxSize.y * 0.5 + radius) * position.y,
                z: (boundingBoxSize.z * 0.5 + radius) * position.z
            )
            targetNode.parent?.addChildNode(node)
            edges.append(node)
            vertexIndexes.forEach { index in
                vertices[index].edges.append(node)
            }
        }
    }

}
