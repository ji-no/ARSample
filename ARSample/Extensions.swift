//
//  Extensions.swift
//  ARSample
//  
//  Created by ji-no on R 4/02/05
//  
//

import ARKit

// MARK: - SCNView Extensions
extension SCNView {
    
    private func enableEnvironmentMapWithIntensity(_ intensity: CGFloat) {
        scene?.lightingEnvironment.intensity = intensity
    }

    func updateLightingEnvironment(for frame: ARFrame) {
        // If light estimation is enabled, update the intensity of the model's lights and the environment map
        let intensity: CGFloat
        if let lightEstimate = frame.lightEstimate {
            intensity = lightEstimate.ambientIntensity / 400
        } else {
            intensity = 2
        }
        DispatchQueue.main.async(execute: {
            self.enableEnvironmentMapWithIntensity(intensity)
        })
    }

}

// MARK: - ARSCNView Extensions
extension ARSCNView {

    func realWorldVector(for location: CGPoint) -> SCNVector3? {
        if let raycast = raycastQuery(from: location,
                                      allowing: .estimatedPlane,
                                      alignment: .any) {
            if let result = session.raycast(raycast).first {
                return SCNVector3(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
            }
        }
        return nil
    }

    func realWorldTransform(for location: CGPoint) -> simd_float4x4? {
        guard let raycast = raycastQuery(from: location, allowing: .existingPlaneGeometry, alignment: .any) else { return nil }
        guard let result = session.raycast(raycast).first(where: { $0.target == .existingPlaneGeometry }) else { return nil }
        guard result.anchor is ARPlaneAnchor else { return nil }

        return result.worldTransform
    }

}

// MARK: - ARPlaneAnchor Extensions
extension ARPlaneAnchor {
    
    @discardableResult
    func addPlaneNode(on node: SCNNode, geometry: SCNGeometry, contents: Any) -> SCNNode {
        guard let material = geometry.materials.first else { fatalError() }
        
        if let program = contents as? SCNProgram {
            material.program = program
        } else {
            material.diffuse.contents = contents
        }
        
        let planeNode = SCNNode(geometry: geometry)
        
        DispatchQueue.main.async(execute: {
            node.addChildNode(planeNode)
        })
        
        return planeNode
    }

    @available(iOS 11.3, *)
    func findPlaneGeometryNode(on node: SCNNode) -> SCNNode? {
        for childNode in node.childNodes {
            if childNode.geometry as? ARSCNPlaneGeometry != nil {
                return childNode
            }
        }
        return nil
    }

    @available(iOS 11.3, *)
    func updatePlaneGeometryNode(on node: SCNNode) {
        DispatchQueue.main.async(execute: {
            guard let planeGeometry = self.findPlaneGeometryNode(on: node)?.geometry as? ARSCNPlaneGeometry else { return }
            planeGeometry.update(from: self.geometry)
        })
    }

}

// MARK: - ARCamera.TrackingState Extensions
extension ARCamera.TrackingState {

    public var description: String {
        switch self {
        case .notAvailable:
            return "Tracking is not available."
        case .normal:
            return "Tracking is normal."
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                return "Tracking is limited due to a excessive motion of the camera."
            case .insufficientFeatures:
                return "Tracking is limited due to a lack of features visible to the camera."
            case .initializing:
                return "Tracking is limited due to initialization in progress."
            case .relocalizing:
                return "Tracking is limited due to a relocalization in progress."
            @unknown default:
                return "Tracking is limited due to @unknown."
            }
        }
    }

}
