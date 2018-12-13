//
//  BasicInfocell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 25/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class BasicInfocell: UITableViewCell {
    
    //MARK:- IB outlet
    @IBOutlet weak var InfoDetailIcon: UIImageView!
    @IBOutlet weak var labelSubTitle: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    
    //Data source
    var dataSource : BasicInfo = BasicInfo(){
        didSet{
            self.InfoDetailIcon.image = UIImage.init(named: dataSource.infoMenuIcon)
            self.labelTitle.text = dataSource.infoTitle
            self.labelSubTitle.text = dataSource.infoSubTitle
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
