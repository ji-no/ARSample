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
    @IBOutlet weak var objectNameLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var selectButton: UIButton!
    
    var selectedObject: ObjectNode?
    var swipeStartObjectPosition: SCNVector3?
    var swipeStartPosition: SCNVector3?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpScene()
    }

    @IBAction func onTapRemoveButton(_ sender: Any) {
        removeObject()
    }

    @IBAction func onTapSelectButton(_ sender: Any) {
        selectObject(selectedObject)
    }

}
