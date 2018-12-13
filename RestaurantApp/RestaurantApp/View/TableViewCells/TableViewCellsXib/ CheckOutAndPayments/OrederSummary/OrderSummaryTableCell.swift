//
//  OrderSummaryTableCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 07/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class OrderSummaryTableCell: UITableViewCell {
    //MARK:- IB Outlets
    @IBOutlet weak var viewInCell: UIView!
    @IBOutlet weak var laeblDishName: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    
    @IBOutlet weak var labelSauceHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelSteakHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelSauce: UILabel!
    @IBOutlet weak var labelSteak: UILabel!
    //Preparing UI
    var dataSource : [String:MyBasketData] = [String:MyBasketData](){
        didSet{
            let data = dataSource.values.first!
            let dishName = data.menuTitle
            let count = data.count
            self.laeblDishName.text = "\(count)x \(dishName)"
            self.labelPrice.text = "\(data.basketPrice)  \((UserDefaults.standard.value(forKey: "Currency") as? String) ?? "QAR")"
            
            let titleData = data.menuTitle.components(separatedBy: ",")
            self.laeblDishName.text = "\(count)x \(titleData.first ?? "")"
            if !titleData[1].isEmpty{
                self.labelSteak.text = "+ \(titleData[1])"
                self.labelSteakHeightConstraint.constant = 14.5
            }else{
                self.labelSteakHeightConstraint.constant = 0.0
            }
            
            if !titleData[2].isEmpty{
                self.labelSauce.text = "+ \(titleData[2])"
                self.labelSauceHeightConstraint.constant = 14.5
            }else{
                self.labelSauceHeightConstraint.constant = 0.0
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.viewInCell.addBorder(toSide: .left, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
            self.viewInCell.addBorder(toSide: .right, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //To initialize with option data
    func initializeWithOptionData(data: [Int:MyOptionData]){
        let dataOption = data.values.first!
        let optionName = dataOption.name
        let count = dataOption.count
        self.laeblDishName.text = "\(count)x \(optionName)"
        self.labelPrice.text = "\(dataOption.basketPrice)  \((UserDefaults.standard.value(forKey: "Currency") as? String) ?? "QAR")"
    }
}
