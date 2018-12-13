//
//  PaymentsSectionHesder.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 07/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit


class PaymentsSectionHesder: UITableViewCell {
    
    //MARK:- IB Outlets
    @IBOutlet weak var leadingConstraintBackView: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraintBackView: NSLayoutConstraint!
    @IBOutlet weak var buttonToggle: UIButton!
    @IBOutlet weak var viewInCell: UIView!
    @IBOutlet weak var labelSectionTitle: UILabel!
    
    var section = Int()
    
    var dataSource : PaymentScetionInfoClass = PaymentScetionInfoClass() {
        didSet{
            self.section = self.dataSource.section
            let expand = self.dataSource.isExpanded
            if expand!{
                self.buttonToggle.setImage(#imageLiteral(resourceName: "roundNewUpArrow"), for: .normal)
                self.labelSectionTitle.textColor = UIColor.borderedRed
            }else{
                self.buttonToggle.setImage(#imageLiteral(resourceName: "roundNewDownArrow"), for: .normal)
                self.labelSectionTitle.textColor = UIColor.disabledGray
                
            }
            DispatchQueue.main.async {
                if self.section == 0{
                    self.viewInCell.roundCorners(corners: [.topLeft, .topRight], radius: 5.0)
                }
                if expand!{
                    DispatchQueue.main.async {
                        self.viewInCell.roundCorners(corners: [.topLeft, .topRight], radius: 5.0)
                        self.viewInCell.addBorder(toSide: .left, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
                        self.viewInCell.addBorder(toSide: .right, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
                        self.viewInCell.addBorder(toSide: .top, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
                    }
                }else{
                    DispatchQueue.main.async {
                        self.viewInCell.layer.cornerRadius = 5.0
                        self.viewInCell.addBorder(toSide: .left, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
                        self.viewInCell.addBorder(toSide: .right, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
                        self.viewInCell.addBorder(toSide: .top, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.viewInCell.clipsToBounds = true
        DispatchQueue.main.async {
            self.viewInCell.layer.cornerRadius = 5.0
            self.viewInCell.addBorder(toSide: .left, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
            self.viewInCell.addBorder(toSide: .right, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
            self.viewInCell.addBorder(toSide: .top, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
