//
//  SelectPlanTypeCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 11/27/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
protocol SelectPlanTypeCellDelegate {
    func didTapOnSelect()
}

class SelectPlanTypeCell: UICollectionViewCell {
    
    //MARK:- IB Outlets
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var buttonSelectPlan: UIButton!
    @IBOutlet weak var labelPerMonth: UILabel!
    @IBOutlet weak var labelCalories: UILabel!
    
    
    var delegate : SelectPlanTypeCellDelegate?
    var dataSource : SelectPlan = SelectPlan(data:[:]){
        didSet{
            self.labelPrice.text = "\(dataSource.totalPrice) \(dataSource.currency.uppercased())"
            self.labelName.text = dataSource.name
            self.labelDescription.text = dataSource.description
            self.labelCalories.text = "\(dataSource.totalCalories)"
            self.labelPerMonth.text = "For \(dataSource.duration) \(dataSource.interval)\n \(dataSource.daysPerWeek) days per week"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.buttonSelectPlan.layer.cornerRadius = self.buttonSelectPlan.frame.size.height/2
    }
    
    @IBAction func selectPlanAction(_ sender: Any) {
        self.delegate?.didTapOnSelect()
    }
}
