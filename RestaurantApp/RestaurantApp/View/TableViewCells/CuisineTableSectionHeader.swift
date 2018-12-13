//
//  CuisineTableSectionHeader.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 11/17/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

protocol CuisineTableSectionHeaderDelegate {
    func didTapOnAdd(section : Int)
}
class CuisineTableSectionHeader: UITableViewCell {

    @IBOutlet weak var labelTitle: UILabel!
    
    var section : Int?
    var row : Int?
    var delegate : CuisineTableSectionHeaderDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func buttonAddAction(_ sender: Any) {
        self.delegate?.didTapOnAdd(section : self.section ?? 0)
    }
}
