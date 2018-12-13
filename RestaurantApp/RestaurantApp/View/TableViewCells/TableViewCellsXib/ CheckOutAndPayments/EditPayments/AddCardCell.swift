//
//  AddCardCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 15/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

//MARK:- Various cell events
protocol  AddCardCellDelegate{
    func didTapOnAddCardCheck(row: Int)
}

class AddCardCell: UITableViewCell {
    //MARK:- IB outlet
    @IBOutlet weak var viewInCell: UIView!
    @IBOutlet weak var checkButton: UIButton!
    
    var row : Int?
    var dataSource : Payments = Payments(){
        didSet{
            if dataSource.isCheck{
                self.checkButton.setImage(#imageLiteral(resourceName: "checkMark"), for: .normal)
            }else{
                self.checkButton.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
                self.viewInCell.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 5.0)
            }
        }
    }
    var delegate : AddCardCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        DispatchQueue.main.async {
            self.viewInCell.addBorder(toSide: .left, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
            self.viewInCell.addBorder(toSide: .right, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
