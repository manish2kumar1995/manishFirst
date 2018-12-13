//
//  CashOnDeliveryCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 07/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

//Protocol for Cell events
protocol  CashOnDeliveryCellDelegate{
    func didTapOnCheckFromCashOnDelivery(row: Int, section: Int)
}

class CashOnDeliveryCell: UITableViewCell {
    
    //MARK:- IBOutlets
    @IBOutlet weak var viewInCell: UIView!
    @IBOutlet weak var buttonCheck: UIButton!
    @IBOutlet weak var imageIconCOD: UIImageView!
    @IBOutlet weak var labelCashOnDelivery: UILabel!
    
    var row : Int?
    var section : Int?
    var delegate : CashOnDeliveryCellDelegate?
    var dataSource : Payments = Payments(){
        didSet{
            self.labelCashOnDelivery.text = dataSource.methodsName
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
    
    //MARK:- check button action
    @IBAction func buttonCheckAction(_ sender: UIButton) {
        self.delegate?.didTapOnCheckFromCashOnDelivery(row: self.row!, section: self.section!)
    }
}
