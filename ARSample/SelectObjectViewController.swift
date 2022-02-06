//
//  SelectObjectViewController.swift
//  ARSample
//  
//  Created by ji-no on R 4/02/06
//  
//

import UIKit

class SelectObjectViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var items = ObjectNode.ObjectType.all
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let width = (collectionView.frame.width - 20) / 3
        let height = width + 21
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = .init(width: width, height: height)
            collectionView.collectionViewLayout = flowLayout
        }
    }

    @IBAction func onTapCloseButton(_ sender: Any) {
        dismiss(animated: true)
    }

}

extension SelectObjectViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectObject", for: indexPath) as! SelectObjectCollectionViewCell
        let item = items[indexPath.row]
        cell.item = item
        return cell
    }
    
}

extension SelectObjectViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        let parent = presentingViewController as? ARViewController
        parent?.spawn(item)
        dismiss(animated: true)
    }

}
