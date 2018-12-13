//
//  OrderConfirmedTableHeader.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 14/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class OrderConfirmedTableHeader: UITableViewCell {
    
    @IBOutlet weak var statusImageVIew: UIImageView!
    @IBOutlet weak var labelStatus: UILabel!

    @IBOutlet weak var labelOrderNumber: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        let animation = CATransition()
        animation.delegate = self
        animation.duration = 2
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = "rippleEffect"
        statusImageVIew.layer.add(animation, forKey: nil)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension OrderConfirmedTableHeader : CAAnimationDelegate{
    
}
