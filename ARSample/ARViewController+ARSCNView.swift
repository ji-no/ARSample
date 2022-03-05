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
        setLight()
        
        cursor.isHidden = true
        sceneView.scene.rootNode.addChildNode(cursor)
    }
    
    func spawn(_ type: ARObjectNode.ObjectType) {
        let position = cursor.position
        let objectNode = ARObjectNode(type: type, position: position)
        self.sceneView.scene.rootNode.addChildNode(objectNode)
        self.selectObject(objectNode)
    }

    func removeObject() {
        if let objectNode = selectedObject {
            selectObject(nil)
            objectNode.removeObject()
        }
    }

    func selectObject(_ objectNode: ARObjectNode?) {
        if selectedObject == objectNode {
            selectedObject?.select()
        } else {
            selectedObject?.cancel()
            objectNode?.select()
            selectedObject = objectNode
        }
        
        if let selectedObject = self.selectedObject {
            objectNameLabel.isHidden = false
            objectNameLabel.text = selectedObject.name
            removeButton.isHidden = false
            selectButton.isHidden = false
            selectButton.setTitle(selectedObject.isSelected() ? "deselect" : "select", for: .normal)

            cursor.position = selectedObject.position
            cursor.select(size: selectedObject.modelRoot.boundingBoxSize)

        } else {
            objectNameLabel.isHidden = true
            removeButton.isHidden = true
            selectButton.isHidden = true
            cursor.unselect()
        }
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

    private func setLight() {
        let light = SCNLight()
        light.type = .directional
        light.spotInnerAngle = 90
        light.spotOuterAngle = 90
        light.castsShadow = true
        light.zNear = 0
        light.zFar = 10
        light.shadowMode = .deferred
        light.forcesBackFaceCasters = true
        light.shadowColor = UIColor.black.withAlphaComponent(0.3)

        let lightNode = SCNNode()
        lightNode.name = "directionalLight"
        lightNode.light = light
        lightNode.eulerAngles = SCNVector3Make(Float(-Double.pi / 2), 0, 0)
        sceneView.scene.rootNode.addChildNode(lightNode)
    }

}

// MARK: - UIGestureRecognizer action

extension ARViewController {

    @objc private func onTapScene(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        selectObject(hitObjectNode(location: location))
    }

    @objc private func onSwipeScene(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            let location = sender.location(in: sceneView)
            if let objectNode = hitObjectNode(location: location) {
                selectObject(objectNode)
            }
            if let position = sceneView.realWorldVector(for: location) {
                if let selectedObject = selectedObject {
                    if selectedObject.isSelected() == false {
                        selectedObject.select()
                    }
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
        if selectedObject?.isSelected() == false {
            selectedObject?.select()
        }
        rotateObject(selectedObject, rotation: Float(sender.rotation))
        sender.rotation = 0
    }
    
    private func translateObject(_ objectNode: ARObjectNode?, position: SCNVector3) {
        guard let objectNode = objectNode else { return }
        guard let swipeStartPosition = self.swipeStartPosition else { return }
        guard let swipeStartObjectPosition = self.swipeStartObjectPosition else { return }
        
        let newPosition = swipeStartObjectPosition + position - swipeStartPosition

        objectNode.position.x = newPosition.x
        objectNode.position.z = newPosition.z
        
        cursor.position.x = newPosition.x
        cursor.position.z = newPosition.z
    }
    
    private func rotateObject(_ objectNode: ARObjectNode?, rotation: Float) {
        guard let objectNode = objectNode else { return }

        let currentAngles = objectNode.eulerAngles
        let newEulerAngles = SCNVector3(currentAngles.x, currentAngles.y - rotation, currentAngles.z)
        objectNode.eulerAngles = newEulerAngles
    }
    

    private func hitObjectNode(location: CGPoint) -> ARObjectNode? {
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
        if let pointOfView = sceneView.pointOfView {
            selectedObject?.update(cameraPosition: pointOfView.position)
        }

        if selectedObject == nil {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                if let worldTransform = self.sceneView.realWorldTransform(for: self.screenCenter) {
                    if self.selectedObject == nil {
                        self.cursor.simdTransform = worldTransform
                    }
                }
            }
        }
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
            self.cursor.isHidden = false
        })
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        planeAnchor.updatePlaneGeometryNode(on: node)

        if let lightEstimate = sceneView.session.currentFrame?.lightEstimate {
            if let lightNode = sceneView.scene.rootNode.childNode(withName: "directionalLight", recursively: false) {
                lightNode.light?.intensity = lightEstimate.ambientIntensity
                lightNode.light?.temperature = lightEstimate.ambientColorTemperature
            }
        }
        
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
