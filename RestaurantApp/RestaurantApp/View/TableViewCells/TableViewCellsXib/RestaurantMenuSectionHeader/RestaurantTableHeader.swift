//
//  RestaurantInfoHeader.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 29/08/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class RestaurantTableHeader: UITableViewHeaderFooterView {
    
    @IBOutlet weak var outerRatingView: UIView!
    @IBOutlet weak var innerRatingView: UIView!
    @IBOutlet weak var labelRating: UILabel!
    @IBOutlet weak var menuIconImage: UIImageView!
    @IBOutlet weak var labelClassification: UILabel!
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        DispatchQueue.main.async {
            self.innerRatingView.layer.cornerRadius = self.outerRatingView.frame.size.height/2
            self.innerRatingView.layer.borderWidth = 1
            self.innerRatingView.layer.borderColor = UIColor.borderedRed.cgColor
            self.outerRatingView.layer.cornerRadius = self.outerRatingView.frame.size.height/2
        }
    }
    
    
}
