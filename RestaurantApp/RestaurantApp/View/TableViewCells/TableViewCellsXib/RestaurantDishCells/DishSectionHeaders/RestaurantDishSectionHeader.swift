//
//  RestaurantSectionHeader.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 05/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

//Protocol for header configuraiton modes
protocol RestaurantDishSectionHeaderDelegate {
    func changeModes(mode: DishDetailModes?)
}


class RestaurantDishSectionHeader : UITableViewCell {

    @IBOutlet var buttonDetailModes: [UIButton]!
    
    var delegate : RestaurantDishSectionHeaderDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    //MARK:- IBAction
    @IBAction func changeModesAction(_ sender: UIButton) {
        
        for button in buttonDetailModes{
            if button.tag == sender.tag{
                button.setTitleColor(UIColor.modesButtonSelectedText, for: .normal)
                button.backgroundColor = UIColor.modesButtonSelectedBackground
            }else{
                button.setTitleColor(UIColor.modeButtonUnselectedText, for: .normal)
                button.backgroundColor = UIColor.modeButtonUnselectedBackground
            }
        }
        if sender.tag == 1{
            delegate?.changeModes(mode: .description)
        }else if sender.tag == 2{
            delegate?.changeModes(mode: .nutrients)
        }else if sender.tag == 3 {
            delegate?.changeModes(mode: .ingredients)
        }
    }

}
