//
//  SortByTableViewCell.swift
//  Restuarant App
//
//  Created by Canopusnew on 8/28/18.
//  Copyright © 2018 Canopusnew. All rights reserved.
//

import UIKit

class SortByTableViewCell: UITableViewCell {

    //MARK:- IB outlets
    @IBOutlet var imageViewIcon: UIImageView!
    @IBOutlet var labelTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
