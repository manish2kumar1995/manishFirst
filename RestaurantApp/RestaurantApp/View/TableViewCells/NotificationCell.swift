//
//  NotificationCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 01/10/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    @IBOutlet weak var onOffSwitch: UISwitch!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var iconImageVIew: UIImageView!
    
    var row = Int()
    var dataSource : NotificationDetail = NotificationDetail(){
        didSet{
            self.labelTitle.text = dataSource.title
            self.iconImageVIew.image = UIImage.init(named: dataSource.imageNamed)
            if dataSource.state{
                self.onOffSwitch.isOn = true
            }else{
                self.onOffSwitch.isOn = false
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.onOffSwitch.backgroundColor = UIColor.viewBackgroundGray
        self.onOffSwitch.layer.cornerRadius = self.onOffSwitch.frame.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func onOffSwitchAction(_ sender: UISwitch) {
        if sender.isOn{
            if row == 0{
                UserDefaults.standard.set(true, forKey: "notificationState")
            }else{
                UserDefaults.standard.set(true, forKey: "emailState")
            }
        }else{
            if row == 0{
                UserDefaults.standard.set(false, forKey: "notificationState")
            }else{
                UserDefaults.standard.set(false, forKey: "emailState")
            }
        }
    }
}
