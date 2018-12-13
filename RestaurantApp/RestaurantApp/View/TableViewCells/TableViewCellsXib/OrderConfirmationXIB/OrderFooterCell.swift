//
//  orderFooterCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 14/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class OrderFooterCell: UITableViewCell {
    
    //MARK:- IB outlet
    @IBOutlet weak var labelTotal: UILabel!
    @IBOutlet weak var buttonContactAkly: UIButton!
    @IBOutlet weak var buttonContact: UIButton!
    @IBOutlet weak var labelDeliveryFee: UILabel!
    @IBOutlet weak var labelSubtotal: UILabel!
    
    //Custom attribute
    let yourAttributes : [NSAttributedStringKey: Any] = [
        NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14),
        NSAttributedStringKey.foregroundColor : UIColor.borderedRed,
        NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            let attributeString = NSMutableAttributedString(string: "Contact Restaurant",
                                                            attributes: self.yourAttributes)
            self.buttonContact.setAttributedTitle(attributeString, for: .normal)
            
            let attributeStringPart = NSMutableAttributedString(string: "Contact Akly Support",
                                                                attributes: self.yourAttributes)
            self.buttonContactAkly.setAttributedTitle(attributeStringPart, for: .normal)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
