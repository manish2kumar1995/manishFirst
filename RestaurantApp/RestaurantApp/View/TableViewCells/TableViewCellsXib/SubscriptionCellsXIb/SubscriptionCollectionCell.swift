//
//  SubscriptionCollectionCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 11/21/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

protocol  SubscriptionCollectionCellDelegate{
    func didTapOnSelectPlan(cell:SubscriptionCollectionCell)
}

class SubscriptionCollectionCell: UICollectionViewCell {
    //MARK:- IB Outlet
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var buttonSelectPlan: UIButton!
    
    var delegate : SubscriptionCollectionCellDelegate?
    var dataSource : SubscriptionCatagory = SubscriptionCatagory(data: [:]){
        didSet{
            self.labelName.text = dataSource.name
            self.labelDescription.text = dataSource.description
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.buttonSelectPlan.layer.cornerRadius = self.buttonSelectPlan.frame.size.height/2
    }
    
    @IBAction func selectButtonAction(_ sender: Any) {
        self.delegate?.didTapOnSelectPlan(cell : self)
    }
}
