//
//  MyBasketTableCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 06/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
import SDWebImage

//Protocol for Cell events
protocol MyBasketTableCellDelegate {
    func didTapOnDecreaseCount(cell:MyBasketTableCell?)
    func didTapOnIncreaseCount(cell:MyBasketTableCell?)
    func didTapOnRemoveCell(cell:MyBasketTableCell?)
}

class MyBasketTableCell: UITableViewCell {
    
    //MARK:- IBoutlets
    @IBOutlet weak var labelCount: UILabel!
    @IBOutlet weak var labelDishName: UILabel!
    @IBOutlet weak var menuIconImage: UIImageView!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelSauceHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelSteakHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var labelSauce: UILabel!
    @IBOutlet weak var labelSteak: UILabel!
    var dataSource : [String:MyBasketData] = [String:MyBasketData](){
        didSet{
            self.imageViewWidthConstraint.constant = 65.0
            let data = dataSource.values.first!
            self.menuIconImage.sd_setImage(with: URL(string: data.menuLogoImage), placeholderImage: UIImage(named: "logo"))
            self.labelPrice.text = "\(data.basketPrice) \((UserDefaults.standard.value(forKey: "Currency") as? String) ?? "QAR")"
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
            
            self.labelCount.text = "\(data.count)"
        }
    }
    
    var delegate : MyBasketTableCellDelegate?
    var dataOption = [Int:MyOptionData]()
    var row = Int()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initializeForOptions(data : [Int:MyOptionData]){
        self.imageViewWidthConstraint.constant = 0.0
        self.dataOption = data
        let dataForOption = data.values.first!
        self.labelPrice.text = "\(dataForOption.price) \((UserDefaults.standard.value(forKey: "Currency") as? String) ?? "QAR")"
        self.labelDishName.text = dataForOption.name
        self.labelCount.text = "\(dataForOption.count)"
    }
    
    //MARK:- Button Actions
    @IBAction func IncreaseDecreaseAction(_ sender: UIButton) {
        if sender.tag == 1{
            if Int(self.labelCount.text!)! > 0 {
                delegate?.didTapOnDecreaseCount(cell: self)
            }
        }else{
            delegate?.didTapOnIncreaseCount(cell: self)
        }
    }
    
    @IBAction func removeAction(_ sender: Any) {
        delegate?.didTapOnRemoveCell(cell: self)
    }
}
