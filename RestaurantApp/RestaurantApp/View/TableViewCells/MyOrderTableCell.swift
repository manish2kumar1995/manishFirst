//
//  MyOrderTableCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 06/10/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class MyOrderTableCell: UITableViewCell {

    @IBOutlet weak var viewInCell: UIView!
    @IBOutlet weak var labelTotalPrice: UILabel!
    @IBOutlet weak var labelDeliveryDate: UILabel!
    @IBOutlet weak var labelTotalCart: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var menuImage: UIImageView!
    
    @IBOutlet weak var labelOrderNumber: UILabel!
    var dataSource : MyOrderData = MyOrderData(data: [:]){
        didSet{
            self.menuImage.sd_setImage(with: URL(string: dataSource.imageIcon), placeholderImage: UIImage(named: ""))
            self.menuImage.sd_setShowActivityIndicatorView(true)
            self.menuImage.sd_setIndicatorStyle(.gray)
            let dataArray = dataSource.dateDelivery.components(separatedBy: "-")
            self.labelDeliveryDate.text = "\(dataArray.last ?? "") \(getMonthString(month:dataArray[1])) \(dataArray.first ?? "")"

            self.labelTotalCart.text = "\(dataSource.cartCount)"
            self.labelTitle.text = dataSource.name
            self.labelTotalPrice.text = "\((UserDefaults.standard.value(forKey: "Currency") as? String) ?? "QAR") \(dataSource.price)"
            
            if dataSource.status == .accepted{
                self.statusImageView.image = UIImage.init(named: "newAccepted")
            }else if dataSource.status == .onWay{
                self.statusImageView.image = UIImage.init(named: "newOnTheWayOrder")
            }else if dataSource.status == .cooking{
                self.statusImageView.image = UIImage.init(named: "newCooking")
            }else if dataSource.status == .cancel{
                self.statusImageView.image = UIImage.init(named: "cancelIcon")
            }else if dataSource.status == .pending{
                self.statusImageView.image = UIImage.init(named: "newPending")
            }else if dataSource.status == .rejected{
                self.statusImageView.image = UIImage.init(named: "newRejected")
            }else if dataSource.status == .ready{
                self.statusImageView.image = UIImage.init(named: "newReady")
            }else if dataSource.status == .completed{
                self.statusImageView.image = UIImage.init(named: "newCompleted")
            }else if dataSource.status == .archived{
                self.statusImageView.image = UIImage.init(named: "newArchieved")
            }
            
            self.labelOrderNumber.text = "#\(dataSource.orderId)"
//            else{
//                self.statusImageView.image = UIImage.init(named: "cancelIcon")
//            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //Adding shadow to bottom view
        self.viewInCell.layer.masksToBounds = false
        self.viewInCell.layer.shadowRadius = 3.0
        self.viewInCell.layer.shadowColor = UIColor.disabledLightGray.cgColor
        self.viewInCell.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        self.viewInCell.layer.shadowOpacity = 1.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func getMonthString(month : String) -> String{
        switch month {
        case "01":
            return "Jan"
        case "02":
            return "Feb"
        case "03":
            return "Mar"
        case "04":
            return "Apr"
        case "05":
            return "May"
        case "06":
            return "June"
        case "07":
            return "Jul"
        case "08":
            return "Aug"
        case "09":
            return "Sep"
        case "10":
            return "Oct"
        case "11":
            return "Nov"
        case "12":
            return "Dec"
        default:
            return ""
        }
    }
}
