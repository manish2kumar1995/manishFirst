//
//  OrderSectionFooter.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 07/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class OrderSectionFooter: UITableViewCell {
    
    //MARK:- IB Outlets
    @IBOutlet weak var viewInCell: UIView!
    @IBOutlet weak var labelTotal: UILabel!
    @IBOutlet weak var labelSubTotal: UILabel!
    @IBOutlet weak var labelDeliveryFee: UILabel!
    
    var dataSource : [String:Any] = [String:Any](){
        didSet{
            let currencyType = (UserDefaults.standard.value(forKey: "Currency") as? String) ?? "QAR"
            self.labelSubTotal.text = "\( dataSource["subTotal"] ?? "") \(currencyType)"
            self.labelDeliveryFee.text = "\(dataSource["deliveryFee"] ?? "") \(currencyType)"
            self.labelTotal.text = "\((dataSource["subTotal"] as? CGFloat)! + (dataSource["deliveryFee"] as? CGFloat)!) \(currencyType)"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //Config UI based work
       // DispatchQueue.main.async {
            self.contentView.layoutIfNeeded()
            self.viewInCell.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 5.0)
            self.viewInCell.addBorder(toSide: .left, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
            self.viewInCell.addBorder(toSide: .right, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
            self.viewInCell.addBorder(toSide: .bottom, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
            self.contentView.layoutSubviews()
            
       // }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
