//
//  AddCuisineTableCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 11/17/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

protocol AddCuisineTableCellDelegate {
    func didTapOnAddCell(cell : AddCuisineTableCell)
}

class AddCuisineTableCell: UITableViewCell {
    
    @IBOutlet weak var buttonCheck: UIButton!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var logoWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var logoImageView: UIImageView!
    
    var delegate : AddCuisineTableCellDelegate?
    var cuisineObject : CuisineData?
    
    var data : String = ""{
        didSet{
            
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func addButtonAction(_ sender: Any) {
        self.delegate?.didTapOnAddCell(cell: self)
    }
    
    func initializeContent(data: [String], item: String){
        
    }
}
