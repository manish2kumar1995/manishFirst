//
//  MyAccountModeSection.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 25/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

protocol  MyAccountModeSectionDelegate{
    func changeProfileMode(mode: ProfileInfoMode?)
}


class MyAccountModeSection: UITableViewCell {

    var delegate : MyAccountModeSectionDelegate?
    
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet var buttonProfileModes: [UIButton]!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

//MARK:- IBACtion
extension MyAccountModeSection{
    
    @IBAction func profileModeActions(_ sender: UIButton) {
        for button in buttonProfileModes{
            if button.tag == sender.tag{
                button.setTitleColor(UIColor.white, for: .normal)
                button.backgroundColor = UIColor.borderedRed
            }else{
                button.setTitleColor(UIColor.modeButtonUnselectedText, for: .normal)
                button.backgroundColor = UIColor.modeButtonUnselectedBackground
            }
        }
        if sender.tag == 1{
            delegate?.changeProfileMode(mode: .info)
        }else if sender.tag == 2{
            delegate?.changeProfileMode(mode: .preferences)
        }else if sender.tag == 3 {
            delegate?.changeProfileMode(mode: .goals)
        }
    }
}
