//
//  AdressActionSheetCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 12/1/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
import MRCountryPicker

class AdressActionSheetCell: UITableViewCell {
    
    @IBOutlet weak var labelAddress: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var buttonLoc: UIButton!
    
    var index : Int?
    var dataSource : AddressStruct = AddressStruct(data: [:]){
        didSet{
            self.labelAddress.text = "\(dataSource.aptNo), \(dataSource.address)"
        }
    }
    var phoneData : PhoneStruct?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initUIForPhones(data : PhoneStruct){
        self.phoneData = data
        self.labelAddress.text = data.phoneNumber
        self.iconImageView.image = UIImage(named: "SwiftCountryPicker.bundle/Images/\(data.countryCode.uppercased())", in: Bundle(for: MRCountryPicker.self), compatibleWith: nil)
    }
}
