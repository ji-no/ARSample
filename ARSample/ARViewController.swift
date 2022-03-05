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
    
    var selectedObject: ARObjectNode?
    var swipeStartObjectPosition: SCNVector3?
    var swipeStartPosition: SCNVector3?
    var cursor = CursorNode()
    lazy var screenCenter: CGPoint = {
        return CGPoint(x: sceneView.frame.width / 2, y: sceneView.frame.height / 2)
    }()
    
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
