//
//  YourOrderCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 14/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class YourOrderCell: UITableViewCell {

    //MARK:- IB Outlets
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var labelCount: UILabel!
    @IBOutlet weak var labelDishName: UILabel!
    @IBOutlet weak var dishIcon: UIImageView!
    @IBOutlet weak var imageViewWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var labelSauceHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelSteakHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelSauce: UILabel!
    @IBOutlet weak var labelSteak: UILabel!
    
    var dataSource : [String:MyBasketData] = [String:MyBasketData](){
        didSet{
            let data = dataSource.values.first!
            self.dishIcon.sd_setImage(with: URL(string: data.menuLogoImage), placeholderImage: UIImage(named: "logo"))

            self.labelPrice.text = "\(data.basketPrice) \((UserDefaults.standard.value(forKey: "Currency") as? String) ?? "QAR")"
            self.labelCount.text = "x\(data.count)"
            
            let titleData = data.menuTitle.components(separatedBy: ",")
            self.labelDishName.text = titleData.first
            if !titleData[1].isEmpty{
                self.labelSteak.text = "+ \(titleData[1])"
                self.labelSteakHeightConstraint.constant = 13.5
            }else{
                self.labelSteakHeightConstraint.constant = 0.0
            }
            
            if !titleData[2].isEmpty{
                self.labelSauce.text = "+ \(titleData[2])"
                self.labelSauceHeightConstraint.constant = 13.5
            }else{
                self.labelSauceHeightConstraint.constant = 0.0
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initializeCellItems(data:DishData){
        self.dishIcon.sd_setImage(with: URL(string: data.dishImage), placeholderImage: UIImage(named: "logo"))
        
        self.labelPrice.text = "\(data.total) \((UserDefaults.standard.value(forKey: "Currency") as? String) ?? "QAR")"
        self.labelCount.text = "x\(data.quantity)"
        
        let titleData = data.optionsNames
        self.labelDishName.text = data.name
        
        if data.optionsNames.count != 0{
        for index in 0..<data.optionsNames.count{
            if index == 0{
                if !data.optionsNames[0].isEmpty{
                    self.labelSteak.text = "+ \(titleData[0])"
                    self.labelSteakHeightConstraint.constant = 13.5
                }else{
                    self.labelSteakHeightConstraint.constant = 0.0
                    
                }
            }else{
                self.labelSteakHeightConstraint.constant = 0.0
            }
            
            if index == 1{
                if !data.optionsNames[1].isEmpty{
                    self.labelSauce.text = "+ \(titleData[1])"
                    self.labelSauceHeightConstraint.constant = 13.5
                }else{
                    self.labelSauceHeightConstraint.constant = 0.0
                }
            }else{
                self.labelSauceHeightConstraint.constant = 0.0
            }
         }
        }else{
            self.labelSteakHeightConstraint.constant = 0.0
            self.labelSauceHeightConstraint.constant = 0.0
        }
    }
    
    //To initialize for option data
    func initializeWithOptionData(data: [Int:MyOptionData]){
        self.imageViewWidthConstraints.constant = 0.0
        let dataOption = data.values.first!
        self.labelPrice.text = "\(dataOption.basketPrice) \((UserDefaults.standard.value(forKey: "Currency") as? String) ?? "QAR")"
        self.labelDishName.text = dataOption.name
        self.labelCount.text = "x\(dataOption.count)"
    }
}
