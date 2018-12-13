//
//  SerachSortTableCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 28/08/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
import HCSStarRatingView
import SDWebImage

class SearchSortTableCell: UITableViewCell {

    //MARK:- IBOutlets
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingStar: HCSStarRatingView!    
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var specialityImageView: UIImageView!
    @IBOutlet weak var specialityLabel: UILabel!
    @IBOutlet weak var timeImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    
    var dataSource : RestaurantLists = RestaurantLists(data: [:])  {
        didSet{
            self.ratingStar.filledStarImage = UIImage.init(named: "coloredStarIcon")
            self.ratingStar.emptyStarImage = UIImage.init(named: "fadeStarIcon")
            self.titleLabel.text = dataSource.restaurantTitle
            self.logoImageView.sd_setShowActivityIndicatorView(true)
            self.logoImageView.sd_setIndicatorStyle(.gray)
            self.logoImageView.sd_setImage(with: URL(string: dataSource.restaurantLogo), placeholderImage: UIImage(named: "logo"))
            self.ratingStar.value = dataSource.restaurantStar
            self.ratingLabel.text = dataSource.restaurantRatingCount
            self.specialityLabel.text = dataSource.restaurantSpeciality
            let distance = String(format: "%.2f", dataSource.restaurantDistance)
            self.distanceLabel.text = "\(distance)\(((UserDefaults.standard.value(forKey: "Units") as? String) ?? "KM").lowercased())"
            self.timeLabel.text = dataSource.deliveryTime
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
