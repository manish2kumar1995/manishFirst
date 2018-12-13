//
//  RestaurantDishDescriptionCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 05/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class RestaurantDishDescriptionCell: UITableViewCell {

    //MARK:- IBOtlets
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var labelName: UILabel!
    
    var dataSource : RestaurantDishDetail.DishDescription = RestaurantDishDetail.DishDescription(name: "", description: ""){
        didSet{
            self.labelDescription.text = dataSource.description
            self.labelName.text = dataSource.name
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
