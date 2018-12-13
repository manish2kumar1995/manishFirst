//
//  SpecialNotesTableCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 12/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class SpecialNotesTableCell: UITableViewCell {
    
    //MARK:- IB Outlets
    @IBOutlet weak var specialNotesTextVIew: KMPlaceholderTextView!
    @IBOutlet weak var viewInCell: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        DispatchQueue.main.async {
            self.viewInCell.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 5.0)
            self.viewInCell.addBorder(toSide: .left, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
            self.viewInCell.addBorder(toSide: .right, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
            self.viewInCell.addBorder(toSide: .bottom, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
