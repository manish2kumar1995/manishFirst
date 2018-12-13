//
//  PreferenceGoalTableCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 26/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

//MARK:- Protocol for cell events
protocol  PreferenceGoalTableCellDelegate{
    func didTapOnCheckButton(section : Int?, row : Int?)
}

class PreferenceGoalTableCell: UITableViewCell {
    //MARK:- IB outlet
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var buttonCheck: UIButton!
    
    
    var section : Int?
    var row : Int?
    var delegate : PreferenceGoalTableCellDelegate?
    var dataSource : sectionFilterData = sectionFilterData(){
        didSet{
            self.labelTitle.text = dataSource.title
            if dataSource.isCheck{
                self.labelTitle.textColor = UIColor.black
                self.buttonCheck.setImage(#imageLiteral(resourceName: "checkMark"), for: .normal)
            }else{
                self.buttonCheck.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
                self.labelTitle.textColor = UIColor.gray
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func buttonCheckAction(_ sender: UIButton) {
        self.delegate?.didTapOnCheckButton(section: self.section!, row : self.row!)
    }
}
