//
//  PaymentMethodsCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 07/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

//Protocol for Cell events
protocol  PaymentMethodsCellDelegate{
    func didTapOnCheckButton(row : Int , section : Int)
}

class PaymentMethodsCell: UITableViewCell {
    
    //MARK:- IBOutlets
    @IBOutlet weak var buttonCheck: UIButton!
    @IBOutlet weak var viewInCell: UIView!
    @IBOutlet weak var paymentMethodsImageIcon: UIImageView!
    @IBOutlet weak var labelPaymentMethods: UILabel!
    @IBOutlet weak var labelCardNumber: UILabel!
    
    var delegate : PaymentMethodsCellDelegate?
    var row : Int?
    var section : Int?
    var dataSource : Payments = Payments(){
        didSet{
            self.labelPaymentMethods.text = dataSource.methodsName
            let last4 = String(dataSource.cardNumber.suffix(4))
            self.labelCardNumber.text = "****\(last4 ) \(dataSource.monthYear )"
            if dataSource.isCheck{
                self.buttonCheck.setImage(#imageLiteral(resourceName: "checkMark"), for: .normal)
            }else{
                self.buttonCheck.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
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
    
    //MARK:- Button action
    @IBAction func buttonCheckAction(_ sender: UIButton) {
        self.delegate?.didTapOnCheckButton(row: self.row ?? 0, section: self.section!)
    }
}
