//
//  DescriptionReviewCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 30/08/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
import HCSStarRatingView

class DescriptionReviewCell: UITableViewCell {
    
    //MARK:- IBOutlets
   // @IBOutlet weak var starView: CosmosView!
    @IBOutlet weak var labelInteriorReview: UILabel!
    @IBOutlet weak var starView: HCSStarRatingView!
    @IBOutlet weak var labelOuterReview: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelRestaurantName: UILabel!
    @IBOutlet weak var labelOuterName: UILabel!
    @IBOutlet weak var viewInteriorInCell: UIView!
    @IBOutlet weak var viewOuterInCell: UIView!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    
    var dataSource : RestaurantReview.RestaurantDetailReview = RestaurantReview.RestaurantDetailReview()  {
        didSet{
            self.starView.filledStarImage = UIImage.init(named: "coloredStarIcon")
            self.starView.emptyStarImage = UIImage.init(named: "fadeStarIcon")
            self.starView.value = CGFloat(CFloat(((dataSource.starRating) as NSString).doubleValue))
            self.labelOuterReview.text = dataSource.outerReview
            self.labelInteriorReview.text = dataSource.interiorReview
            self.labelDate.text = dataSource.reviewDate
            self.labelRestaurantName.text = dataSource.restaurantName
            self.labelOuterName.text = dataSource.name
            self.configUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.viewOuterInCell.layer.cornerRadius = 5
            self.viewInteriorInCell.layer.cornerRadius = 5
            self.viewOuterInCell.layer.borderWidth = 0.4
            self.viewOuterInCell.layer.borderColor = UIColor.lightGray.cgColor
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configUI(){
        self.imageViewBottomConstraint.constant = (self.labelInteriorReview.text?.height(constraintedWidth: self.frame.size.width - 169, font: UIFont.systemFont(ofSize: 11.0)))!
    }
    
}
