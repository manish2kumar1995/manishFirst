//
//  ShortReviewCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 30/08/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
import HCSStarRatingView

class ShortReviewCell: UITableViewCell {

    //MARK:- IBOutlet
    //@IBOutlet weak var starView: CosmosView!
    @IBOutlet weak var labelReview: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var viewInCell: UIView!

    @IBOutlet weak var starView: HCSStarRatingView!
    var dataSource : RestaurantReview.RestaurantShortReview = RestaurantReview.RestaurantShortReview(data: [:])  {
        didSet{
            self.starView.filledStarImage = UIImage.init(named: "coloredStarIcon")
            self.starView.emptyStarImage = UIImage.init(named: "fadeStarIcon")
            self.labelName.text = dataSource.name
            self.labelReview.text = dataSource.reviewDetail
            self.labelDate.text = dataSource.reviewDate
            self.starView.value = CGFloat(((dataSource.starRating) as NSString).doubleValue)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.viewInCell.layer.cornerRadius = 5
            self.viewInCell.layer.borderWidth = 0.4
            self.viewInCell.layer.borderColor = UIColor.lightGray.cgColor
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
