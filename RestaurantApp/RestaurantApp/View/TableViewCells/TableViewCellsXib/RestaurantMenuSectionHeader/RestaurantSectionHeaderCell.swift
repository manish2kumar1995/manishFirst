//
//  RestaurantSectionHeaderCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 01/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

//Protocol for cell events
protocol RestaurantsSectionHeaderDelegate {
    func changeModes(mode: RestaurantMode?)
    func didTapOnFilter()
    func didTapOnSort()
}

class RestaurantSectionHeaderCell: UITableViewCell {
    
    @IBOutlet weak var buttonSort: UIButton!
    @IBOutlet weak var buttonFilter: UIButton!
    @IBOutlet var buttonModes: [UIButton]!
    
    @IBOutlet weak var labelFoodType: UILabel!
    var delegate : RestaurantsSectionHeaderDelegate?
    var mode : RestaurantMode?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.buttonSort.layer.borderWidth = 1
            self.buttonSort.layer.borderColor = UIColor.borderedRed.cgColor
            self.buttonSort.layer.cornerRadius = self.buttonSort.frame.size.height/2
            
            self.buttonFilter.layer.borderWidth = 1
            self.buttonFilter.layer.borderColor = UIColor.borderedRed.cgColor
            self.buttonFilter.layer.cornerRadius = self.buttonFilter.frame.size.height/2
        }
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    //MARK:- IBActions
    @IBAction func restaurantModeActions(_ sender: UIButton) {
        for button in buttonModes{
            if button.tag == sender.tag{
                button.setTitleColor(UIColor.modesButtonSelectedText, for: .normal)
                button.backgroundColor = UIColor.modesButtonSelectedBackground
            }else{
                button.setTitleColor(UIColor.modeButtonUnselectedText, for: .normal)
                button.backgroundColor = UIColor.modeButtonUnselectedBackground
            }
        }
        if sender.tag == 1{
            delegate?.changeModes(mode: .menu)
        }else if sender.tag == 2{
            delegate?.changeModes(mode: .review)
        }else if sender.tag == 3 {
            delegate?.changeModes(mode: .info)
        }
        
    }
    
    @IBAction func sortAction(_ sender: UIButton) {
        delegate?.didTapOnSort()
    }
    
    @IBAction func filterAction(_ sender: UIButton) {
        delegate?.didTapOnFilter()
    }
}
