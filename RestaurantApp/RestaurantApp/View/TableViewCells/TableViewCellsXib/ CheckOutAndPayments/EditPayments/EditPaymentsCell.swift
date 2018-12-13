//
//  EditPaymentsCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 11/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

//Protocol for Cell events
protocol EditPaymentsCellDelegate {
    func didTapOnCrossButton(row : Int)
    func didTapCheckButton(row : Int)
}

class EditPaymentsCell: UITableViewCell {
    
    //MARK:- IB Outlets
    @IBOutlet weak var buttonCross: UIButton!
    @IBOutlet weak var buttonCheck: UIButton!
    @IBOutlet weak var labelCardNumber: UILabel!
    @IBOutlet weak var labelMonthYear: UILabel!
    @IBOutlet weak var labelMethodName: UILabel!
    
    var row : Int?
    var delegate : EditPaymentsCellDelegate?
    
    var dataSource : Payments = Payments(){
        didSet{
            if dataSource.methodsName.isEqualToString(find: "Cash on delivery"){
                self.buttonCross.isHidden = true
                self.labelCardNumber.isHidden = true
            }else{
                self.buttonCross.isHidden = false
                self.labelCardNumber.isHidden = false
            }
            let last4 = String(dataSource.cardNumber.suffix(4))
            self.labelMethodName.text = dataSource.methodsName
            self.labelCardNumber.text = "****\(last4 ) "
            self.labelMonthYear.text = dataSource.monthYear
            
            if dataSource.isCheck{
                self.buttonCheck.setImage(#imageLiteral(resourceName: "checkMark"), for: .normal)
            }else{
                self.buttonCheck.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            }
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

//MARK:- Button Action
extension EditPaymentsCell {
    
    @IBAction func buttonCrossAction(_ sender: UIButton) {
        self.delegate?.didTapOnCrossButton(row: self.row!)
    }
    
    @IBAction func buttonCheckAction(_ sender: UIButton) {
        self.delegate?.didTapCheckButton(row: self.row!)
    }
}
