//
//  ARViewController.swift
//  
//  
//  Created by ji-no on R 4/02/05
//  
//

import ARKit

class ARViewController: UIViewController {
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var statusLabel: UILabel!
    
    var selectedObject: ObjectNode?
    var swipeStartObjectPosition: SCNVector3?
    var swipeStartPosition: SCNVector3?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpScene()
    }

}

