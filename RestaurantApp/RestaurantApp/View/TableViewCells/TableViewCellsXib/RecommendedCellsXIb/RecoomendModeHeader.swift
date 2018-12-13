//
//  RecoomendModeHeader.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 12/5/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

protocol RecoomendModeHeaderDelegate {
    func changeModes(mode: RecommendMode?)
}

class RecoomendModeHeader: UITableViewCell {
    
    @IBOutlet weak var labelCalories: UILabel!
    @IBOutlet var buttonModes: [UIButton]!
    
    var delegate : RecoomendModeHeaderDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func changeRecommenMode(_ sender: UIButton) {
        for button in buttonModes{
            if button.tag == sender.tag{
                button.setTitleColor(UIColor.white, for: .normal)
                button.backgroundColor = UIColor.borderedRed
            }else{
                button.setTitleColor(UIColor.modeButtonUnselectedText, for: .normal)
                button.backgroundColor = UIColor.buttonBackgroundGray
            }
        }
        if sender.tag == 1{
            delegate?.changeModes(mode: .schedule)
        }else if sender.tag == 2{
            delegate?.changeModes(mode: .nutrients)
        }else if sender.tag == 3 {
            delegate?.changeModes(mode: .dishTypes)
        }
    }
}
