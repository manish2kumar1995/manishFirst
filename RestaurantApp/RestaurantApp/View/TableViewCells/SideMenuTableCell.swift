//
//  SideMenuTableCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 19/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class SideMenuTableCell: UITableViewCell {
    
    //MARK:- ib outlets
    @IBOutlet weak var menuOptionIcon: UIImageView!
    @IBOutlet weak var labelOptionName: UILabel!

    var dataSource : [String:Any] = [String:Any](){
        didSet{
            self.menuOptionIcon.image = UIImage.init(named: (dataSource["menuLogo"] as? String) ?? "")
            self.labelOptionName.text = (dataSource["menuName"] as? String) ?? ""
         }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
