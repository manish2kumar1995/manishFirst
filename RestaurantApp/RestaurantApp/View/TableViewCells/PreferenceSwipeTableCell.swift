//
//  PreferenceSwipeTableCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 11/19/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
import SwipeCellKit
import MRCountryPicker

class PreferenceSwipeTableCell: SwipeTableViewCell {
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var imageWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var flagImageVIew: UIImageView!
    var section : Int?
    var row : Int?
    var dataSource : CuisineData = CuisineData(data: [:], index: 0){
        didSet{
            self.labelTitle.text = dataSource.restaurantTitle
            self.imageWidthConstraints.constant =  0.0
            self.flagImageVIew.image = nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageWidthConstraints.constant =  0.0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initAttributes(address : CuisineData){
        let array = address.restaurantTitle.components(separatedBy: ",")
        self.labelTitle.text = "\(array.first ?? "")  \(array[1])"
        self.imageWidthConstraints.constant =  0.0
        self.flagImageVIew.image = nil
    }
    
    func initForContact(data: CuisineData, code : String){
        self.labelTitle.text = data.restaurantTitle
        self.imageWidthConstraints.constant =  20.0
        self.flagImageVIew.image = UIImage(named: "SwiftCountryPicker.bundle/Images/\(code.uppercased())", in: Bundle(for: MRCountryPicker.self), compatibleWith: nil)
    }
}
