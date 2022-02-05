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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpScene()
    }

}

