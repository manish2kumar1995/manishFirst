//
//  AddCouponCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 07/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

protocol AddCouponCellDelegate{
    func didTapOnApplyButton(couponCode : String)
}

class AddCouponCell: UITableViewCell {
    
    //MARK:- IBOutlets
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var couponCodeTextField: TextField!
    @IBOutlet weak var viewInCell: UIView!
    
    var delegate : AddCouponCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.viewInCell.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 5.0)
            self.viewInCell.addBorder(toSide: .left, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
            self.viewInCell.addBorder(toSide: .right, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
            self.viewInCell.addBorder(toSide: .bottom, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
            self.applyButton.layer.cornerRadius = 5
            
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func applyButtonAction(_ sender: Any) {
        self.delegate?.didTapOnApplyButton(couponCode: self.couponCodeTextField.text ?? "")
    }
}
