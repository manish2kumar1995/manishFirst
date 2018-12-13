//
//  ExpectedDeliveryCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 14/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class ExpectedDeliveryCell: UITableViewCell {
   
    @IBOutlet weak var viewInCell: UIView!
    
    @IBOutlet weak var labelExpectedDelivery: UILabel!
    @IBOutlet weak var labelDeliveryAddress: UILabel!
    
    var data : [String:Any] = [String:Any](){
        didSet{
            self.labelDeliveryAddress.text = "\((data["address"] as? String) ?? ""), \((data["city"] as? String) ?? "")"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.viewInCell.layer.cornerRadius = 5
            self.viewInCell.layer.borderWidth = 0.4
            self.viewInCell.layer.borderColor = UIColor.lightGray.cgColor
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initDelivery(deliveryData : [String:Any]){
        let date = (deliveryData["date"] as? String) ?? ""
        let expectedTime = (deliveryData["expectedTime"] as? String) ?? ""
        
        let dateArray = date.components(separatedBy: "-")
        
        let dateAsString = expectedTime
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        
        let dateTime = dateFormatter.date(from: dateAsString)
        dateFormatter.dateFormat = "h:mm a"
        let timeFormat = dateFormatter.string(from: dateTime!)

        self.labelExpectedDelivery.text = "\(dateArray.first ?? "")/\(dateArray[1])/\(dateArray.last ?? "") \(timeFormat)"
    }
}
