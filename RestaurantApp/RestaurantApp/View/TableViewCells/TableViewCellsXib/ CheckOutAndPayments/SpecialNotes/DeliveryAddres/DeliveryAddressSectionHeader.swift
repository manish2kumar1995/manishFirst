//
//  DeliveryAddressSectionHeader.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 07/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

//Protocol for Cell events
protocol DeliveryAddressSectionHeaderDelegate {
    func didTapOnEditAction()
    func reloadTable()
}

class DeliveryAddressSectionHeader: UITableViewCell {
    
    //MARK:- IB Outlets
    @IBOutlet weak var labelAddress: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var labelDeliveryAddress: UILabel!
    @IBOutlet weak var viewInCell: UIView!
    
    var section = 5
    var dataSource : PaymentScetionInfoClass = PaymentScetionInfoClass(){
        didSet{
            self.section = dataSource.section
            let expand = dataSource.isExpanded
            if expand!{
                DispatchQueue.main.async {
                    
                    self.viewInCell.roundCorners(corners: [.topLeft, .topRight], radius: 5.0)
                    self.viewInCell.addBorder(toSide: .left, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
                    self.viewInCell.addBorder(toSide: .right, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
                    self.viewInCell.addBorder(toSide: .top, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
                }
            }else{
                self.viewInCell.layer.cornerRadius = 5.0
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.labelAddress.text = UserShared.shared.currentAddress
        
        if !UserShared.shared.isKnownUser{
            self.labelAddress.isHidden = true
            self.editButton.isHidden = true
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}



