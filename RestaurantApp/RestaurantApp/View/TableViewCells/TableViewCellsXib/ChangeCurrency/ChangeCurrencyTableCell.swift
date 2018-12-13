//
//  ChangeCurrencyTableCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 21/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

//MARK:- various cell events
protocol ChangeCurrencyTableCellDelegate {
    func didTapOnCheckButton(row: Int)
}

class ChangeCurrencyTableCell: UITableViewCell {

    //MARK:- IB outlets
    @IBOutlet weak var buttonCheck: UIButton!
    @IBOutlet weak var labelSubTitle: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    
    var delegate : ChangeCurrencyTableCellDelegate?
    var row: Int?
    var dataSource : Currency = Currency(){
        didSet{
            self.labelTitle.text = dataSource.title
            self.labelSubTitle.text = dataSource.subTitle
            self.row = dataSource.row
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
    
    @IBAction func checkButtonAction(_ sender: UIButton) {
        self.delegate?.didTapOnCheckButton(row: self.row!)
    }
    
}
