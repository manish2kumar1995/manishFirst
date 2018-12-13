//
//  RestaurantIngredientsCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 05/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

protocol RestaurantIngredientsCellDelegate{
    func didTapOnToggleButton(cell:RestaurantIngredientsCell?)
}

class RestaurantIngredientsCell: UITableViewCell {
    
    //MARK:- IBOutlet
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var viewInCell: UIView!
    @IBOutlet weak var dropDownButton: UIButton!
    @IBOutlet weak var descriptionLabelHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var viewInCellHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionLabelBottomConstraint: NSLayoutConstraint!
    
    var delegate : RestaurantIngredientsCellDelegate?
    var dataSource : RestaurantDishDetail.DishIngredients = RestaurantDishDetail.DishIngredients(data: [:]){
        didSet{
            self.labelName.text = dataSource.ingredientsName
            self.labelDescription.text = dataSource.description
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.viewInCell.layer.cornerRadius = 5
        self.viewInCell.layer.borderWidth = 0.4
        self.viewInCell.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    //MARK:- Button methods
    @IBAction func tapOnOpencloseAction(_ sender: Any) {
        
        if descriptionLabelHeightConstraints.constant <= 0.0{
            descriptionLabelHeightConstraints.constant = (self.labelDescription.text?.height(constraintedWidth: self.frame.width - 70.0, font: UIFont.systemFont(ofSize: 11.0)))!
            viewInCellHeightConstraint.constant = viewInCellHeightConstraint.constant + descriptionLabelHeightConstraints.constant + 10
            self.descriptionLabelBottomConstraint.constant = 10
            self.labelName.textColor = UIColor.borderedRed
            self.dropDownButton.setImage(#imageLiteral(resourceName: "coloredUpArrow"), for: .normal)
        }else{
            descriptionLabelHeightConstraints.constant = 0.0
            viewInCellHeightConstraint.constant = 45.0
            self.descriptionLabelBottomConstraint.constant = 0
             self.labelName.textColor = UIColor.blackishGray
            self.dropDownButton.setImage(#imageLiteral(resourceName: "fadeDownArrow"), for: .normal)
        }
        delegate?.didTapOnToggleButton(cell: self)
    }
}


