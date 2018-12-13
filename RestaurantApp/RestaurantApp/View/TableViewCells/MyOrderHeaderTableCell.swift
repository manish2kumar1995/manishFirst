//
//  MyOrderHeaderTableCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 05/10/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class MyOrderHeaderTableCell: UITableViewCell {

    @IBOutlet weak var imageLogoView: UIImageView!
    @IBOutlet weak var labelOrderNumber: UILabel!
    @IBOutlet weak var labelHotelName: UILabel!
    @IBOutlet weak var labelDeliveryAddress: UILabel!
    @IBOutlet weak var labelOrderOn: UILabel!
    @IBOutlet weak var buttonReview: UIButton!
    
    var stringOrderOnSub = ""
    var stringOrderOnMain = "Ordered on : "
    var stringDeliveryMain = "Delivery address : "
    var stringDeliverySub = ""

    var dataSource : [String:Any] = [:]{
        didSet{
            self.labelDeliveryAddress.text = "\(((dataSource["address"] as? String) ?? "" )), \((dataSource["city"] as? String) ?? "" ), \((dataSource["country"] as? String) ?? "" )"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.buttonReview.layer.cornerRadius = 5.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func getAttributeString(main: String, sub: String) -> NSMutableAttributedString {
        let combination = NSMutableAttributedString()
        let orderMainString = self.getMainAttributeString(main: main)
        let orderSubString = self.getSubAttributeString(sub: sub)
        combination.append(orderMainString)
        combination.append(orderSubString)
        return combination
    }
    
    func getMainAttributeString(main : String) -> NSAttributedString {
        let range = (main as NSString).range(of: main)
        
        let myMutableString = NSMutableAttributedString(string: main)
        myMutableString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.black , range: range)
        myMutableString.addAttribute(NSAttributedStringKey.font, value: UIFont.boldSystemFont(ofSize: 12.0) , range: range)
        return myMutableString
    }
    
    func getSubAttributeString(sub : String) -> NSAttributedString {
        
        let range = (sub as NSString).range(of: sub)
        
        let myMutableString = NSMutableAttributedString(string: sub)
        myMutableString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.modeButtonUnselectedText , range: range)
        myMutableString.addAttribute(NSAttributedStringKey.font, value:UIFont.gouthamRegular ?? UIFont.systemFont(ofSize: 12.0) , range: range)
        return myMutableString
        
    }
    
    func initializeContent(){
        self.labelOrderOn.attributedText = self.getAttributeString(main:stringOrderOnMain , sub: stringOrderOnSub)
        self.labelDeliveryAddress.attributedText = self.getAttributeString(main:stringDeliveryMain , sub: stringDeliverySub)
    }
    
    
}
