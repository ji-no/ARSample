//
//  ARViewController+ARSCNView.swift
//  ARSample
//  
//  Created by ji-no on R 4/02/05
//  
//

import ARKit

extension ARViewController {

    func setUpScene() {
        sceneView.delegate = self
        sceneView.scene = SCNScene()
        sceneView.debugOptions = [SCNDebugOptions.showFeaturePoints]
        
        runSession()
        setUpGesture()
    }

    private func runSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    private func setUpGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapScene(_:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onSwipeScene(_:)))
        sceneView.addGestureRecognizer(panGestureRecognizer)
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(onRotationScene(_:)))
        sceneView.addGestureRecognizer(rotationGestureRecognizer)
    }

}

// MARK: - UIGestureRecognizer action

extension ARViewController {

    @objc private func onTapScene(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        let objectNode = hitObjectNode(location: location)
        if let objectNode = objectNode {
            selectObject(objectNode)
            return
        } else if selectedObject != nil {
            selectedObject?.cancel()
            selectedObject = nil
            return
        }

        if let position = sceneView.realWorldVector(for: location) {
            let objectNode = ObjectNode(type: .airForce)
            objectNode.name = "object"
            objectNode.position = position
            DispatchQueue.main.async(execute: {
                self.sceneView.scene.rootNode.addChildNode(objectNode)
            })
        }
    }

    @objc private func onSwipeScene(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            let location = sender.location(in: sceneView)
            let objectNode = hitObjectNode(location: location)
            selectObject(objectNode)
            if let position = sceneView.realWorldVector(for: location) {
                if let selectedObject = selectedObject {
                    swipeStartPosition = position
                    swipeStartObjectPosition = selectedObject.position
                }
            }

        case .changed:
            let location = sender.location(in: sceneView)
            if let position = sceneView.realWorldVector(for: location) {
                translateObject(selectedObject, position: position)
            }

        default:
            break
        }
    }
    
    @objc private func onRotationScene(_ sender: UIRotationGestureRecognizer) {
        rotateObject(selectedObject, rotation: Float(sender.rotation))
        sender.rotation = 0
    }


    private func selectObject(_ objectNode: ObjectNode?) {
        guard let objectNode = objectNode else { return }
        guard selectedObject != objectNode else { return }
        
        selectedObject?.cancel()
        objectNode.select()
        selectedObject = objectNode
    }
    
    private func translateObject(_ objectNode: ObjectNode?, position: SCNVector3) {
        guard let objectNode = objectNode else { return }
        guard let swipeStartPosition = self.swipeStartPosition else { return }
        guard let swipeStartObjectPosition = self.swipeStartObjectPosition else { return }
        
        let newPosition = swipeStartObjectPosition + position - swipeStartPosition

        objectNode.position.x = newPosition.x
        objectNode.position.z = newPosition.z
    }
    
    private func rotateObject(_ objectNode: ObjectNode?, rotation: Float) {
        guard let objectNode = objectNode else { return }

        let currentAngles = objectNode.eulerAngles
        let newEulerAngles = SCNVector3(currentAngles.x, currentAngles.y - rotation, currentAngles.z)
        objectNode.eulerAngles = newEulerAngles
    }
    

    private func hitObjectNode(location: CGPoint) -> ObjectNode? {
        let results = sceneView.hitTest(location, options: [SCNHitTestOption.searchMode : SCNHitTestSearchMode.all.rawValue])
        return results
            .compactMap { $0.node.asObjectNode() }
            .first
   }
}


// MARK: - ARSCNViewDelegate

extension ARViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let frame = sceneView.session.currentFrame else {return}
        sceneView.updateLightingEnvironment(for: frame)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        statusLabel.text = camera.trackingState.description
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        guard let planeGeoemtry = ARSCNPlaneGeometry(device: sceneView.device!) else { fatalError() }
        planeAnchor.addPlaneNode(on: node, geometry: planeGeoemtry, contents: UIColor.yellow.withAlphaComponent(0.1))
        
        DispatchQueue.main.async(execute: {
            self.statusLabel.text = "a new node has been mapped."
        })
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        planeAnchor.updatePlaneGeometryNode(on: node)
        
        DispatchQueue.main.async(execute: {
            self.statusLabel.text = "a node has been updated."
        })
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        planeAnchor.findPlaneGeometryNode(on: node)?.removeFromParentNode()
        
        DispatchQueue.main.async(execute: {
            self.statusLabel.text = "a mapped node has been removed."
        })
    }
}
