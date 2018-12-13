//
//  filterHeaderTableViewCell.swift
//  Restuarant App
//
//  Created by Canopusnew on 8/28/18.
//  Copyright © 2018 Canopusnew. All rights reserved.
//

import UIKit

class FilterHeaderTableViewCell: UITableViewCell {
   
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var imageViewIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
