//
//  AddOptionTableCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 04/10/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
//MARK:- Various cell events
protocol AddOptionTableCellDelegate {
    func didTapOnCheck(section : Int?, row : Int?)
}

class AddOptionTableCell: UITableViewCell {

    @IBOutlet weak var buttonCheck: UIButton!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    
    var section : Int?
    var row : Int?
    var delegate : AddOptionTableCellDelegate?
    var dataSource : SectionData = SectionData(data: [:]){
        didSet{
            self.labelTitle.text = dataSource.title
            self.labelPrice.text = "\((UserDefaults.standard.value(forKey: "Currency") as? String) ?? "QAR") \(dataSource.price)"
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

    @IBAction func checkButtonAction(_ sender: UIButton) {
        self.delegate?.didTapOnCheck(section: self.section!, row:self.row )
    }
}
