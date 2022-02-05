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
    }

}

// MARK: - UIGestureRecognizer action

extension ARViewController {

    @objc private func onTapScene(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: sceneView)

        let results = sceneView.hitTest(point, options: [SCNHitTestOption.searchMode : SCNHitTestSearchMode.all.rawValue])
        let objectNode = results
            .compactMap { $0.node.asObjectNode() }
            .first
        if let objectNode = objectNode {
            objectNode.tap()
            return
        }

        if let raycast = sceneView.raycastQuery(from: point,
                                                allowing: .estimatedPlane,
                                                alignment: .any) {
            if let result = sceneView.session.raycast(raycast).first {
                let transform = result.worldTransform
                let thirdColumn = transform.columns.3
                
                let objectNode = ObjectNode(type: .airForce)
                objectNode.name = "object"
                objectNode.position = SCNVector3(thirdColumn.x, thirdColumn.y, thirdColumn.z)
                DispatchQueue.main.async(execute: {
                    self.sceneView.scene.rootNode.addChildNode(objectNode)
                })
            }
        }
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
