//
//  SelectObjectCollectionViewCell.swift
//  ARSample
//  
//  Created by ji-no on R 4/02/06
//  
//

import UIKit

class SelectObjectCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var item: ARObjectNode.ObjectType? {
        didSet {
            guard let item = self.item else { return }
            nameLabel.text = item.rawValue
            thumbnailImageView.image = UIImage(named: item.rawValue)
        }
    }
}
