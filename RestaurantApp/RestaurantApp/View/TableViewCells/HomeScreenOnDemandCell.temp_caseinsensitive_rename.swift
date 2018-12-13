//
//  homeScreenOnDemandCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 28/08/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class HomeScreenOnDemandCell: UITableViewCell {

    @IBOutlet weak var viewInCell: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    
    var data : [String:Any]!  {
        didSet{
            self.descriptionLabel.text = data["description"] as? String
            self.iconImageView.image = UIImage(named: data["logoImage"] as! String)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            cell.numberLabel.layer.masksToBounds = true
            cell.numberLabel.layer.cornerRadius = 12.5
            cell.viewInCell.layer.cornerRadius = 5
            cell.viewInCell.layer.borderWidth = 1
            cell.viewInCell.layer.borderColor = UIColor.init(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0).cgColor
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
