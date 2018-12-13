//
//  CountryPickerCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 11/27/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class CountryPickerCell: UITableViewCell {
    
    //MARK:- IB Outlet
    @IBOutlet weak var labelCountryName: UILabel!
    @IBOutlet weak var countryImageView: UIImageView!
    
    var dataSource : CountryFormat = CountryFormat(code: "", name: "", phoneCode: ""){
        didSet{
            self.labelCountryName.text = "\(dataSource.name ?? "") (\(dataSource.phoneCode ?? ""))"
            self.countryImageView.image = dataSource.flag
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
