//
//  MyBasketTableFooter.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 06/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class MyBasketTableFooter: UITableViewCell {
    
    //IBOutlets
    @IBOutlet weak var labelSubTotal: UILabel!
    @IBOutlet weak var viewInCell: UIView!
    @IBOutlet weak var labelTotal: UILabel!
    @IBOutlet weak var labelDeliveryFee: UILabel!
    
    var count = 0
    
    var dataSource : [[String:MyBasketData]] = [[String:MyBasketData]](){
        didSet{
            let currencyType = (UserDefaults.standard.value(forKey: "Currency") as? String) ?? "QAR"
            self.labelSubTotal.text = "\(UserShared.shared.myBasketModel.totalQAR) \(currencyType)"
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //Config UI based work
        DispatchQueue.main.async {
            self.viewInCell.layer.cornerRadius = 5
            self.viewInCell.layer.borderWidth = 0.4
            self.viewInCell.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initializeFooter(data:[String:Any]){
        //            price =             {
        //                currency = QAR;
        //                deliveryFee = 0;
        //                discount = 0;
        //                subTotal = 600;
        //                total = 600;
        //            };
        
        self.labelSubTotal.text = "\((data["subTotal"] as? CGFloat) ?? 0.0) \((data["currency"] as? String) ?? "")"
        
        self.labelDeliveryFee.text = "\((data["deliveryFee"] as? CGFloat) ?? 0.0) \((data["currency"] as? String) ?? "")"
        self.labelTotal.text = "\((data["total"] as? CGFloat) ?? 0.0) \((data["currency"] as? String) ?? "")"
    }
}
