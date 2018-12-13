//
//  SettingTableCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 19/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class SettingTableCell: UITableViewCell {
    
    //MARK:- IB outlets
    @IBOutlet weak var settingOptioIcon: UIImageView!
    @IBOutlet weak var labelSettingSubtitle: UILabel!
    @IBOutlet weak var labelSettingTitle: UILabel!
    
    var dataSource : Settings = Settings(){
        didSet{
            self.settingOptioIcon.image = UIImage.init(named: dataSource.settingIcon)
            self.labelSettingTitle.text = dataSource.settingTitle
            self.labelSettingSubtitle.text = dataSource.settingSubTitle
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
