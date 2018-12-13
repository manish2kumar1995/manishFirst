//
//  NutritionCollectionCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 05/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
import HGCircularSlider

class NutritionCollectionCell: UICollectionViewCell {
    
    //MARK:- IBOutlet
    @IBOutlet weak var nutrientPercentageView: CircularSlider!
    @IBOutlet weak var labelNutrientsName: UILabel!
    @IBOutlet weak var labelPercentage: UILabel!
    
    var dataSource : RestaurantDishDetail.DishNutrients = RestaurantDishDetail.DishNutrients(nutrients: "", percentage:0.0, text: ""){
        didSet{
            
            self.labelNutrientsName.text = dataSource.nutrientsName
            self.labelPercentage.text = dataSource.textToShow
            self.nutrientPercentageView.maximumValue = 100
            self.nutrientPercentageView.minimumValue = 0
            self.nutrientPercentageView.endPointValue = 99.99
            self.nutrientPercentageView.trackColor = UIColor.borderedRed
            self.nutrientPercentageView.backtrackLineWidth = 1.0
            self.nutrientPercentageView.trackColor = UIColor.lightGray
            self.nutrientPercentageView.thumbRadius = 0.0

       //     self.labelPercentage.attributedText = self.configurePieChartView(view:self.nutrientPercentageView, text:String(format: "%.2f", dataSource.percentage ))
        }
    }
    
    
    func configurePieChartView(view: CircularSlider, text: String) -> NSMutableAttributedString {
        let attribPercentage = NSMutableAttributedString.init(string: "%")
        attribPercentage.addAttribute(NSAttributedStringKey.font, value: UIFont.boldSystemFont(ofSize: 12) as Any, range: NSRange(location: 0, length: 1))
        let attribString = NSMutableAttributedString.init(string: text)
        let range = (text as NSString).range(of: text)
        attribString.addAttribute(NSAttributedStringKey.font, value: UIFont.boldSystemFont(ofSize: 25) as Any, range: range)
        let combination = NSMutableAttributedString()
        combination.append(attribString)
        combination.append(attribPercentage)
        view.maximumValue = 100
        view.minimumValue = 0
        view.endPointValue = CGFloat(Double("99.99") ?? 0)
        view.trackColor = UIColor.borderedRed
        view.backtrackLineWidth = 1.0
        view.trackColor = UIColor.lightGray
        view.thumbRadius = 0.0
        return combination
    }
}
