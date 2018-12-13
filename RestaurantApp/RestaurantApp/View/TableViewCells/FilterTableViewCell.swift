//
//  FilterTableViewCell.swift
//  Restuarant App
//
//  Created by Canopusnew on 8/28/18.
//  Copyright © 2018 Canopusnew. All rights reserved.
//

import UIKit

//Protocol for cell events
protocol FilterTableViewCellDelegate {
    func didToggleRadioButton(_ indexPath: IndexPath)
}

class FilterTableViewCell: UITableViewCell {
    
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var buttonRadio: UIButton!

    var delegate: FilterTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //Custom Methods
    func initCellItem() {
        let deselectedImage = UIImage(named: "cubeUncheck")
        let selectedImage = UIImage(named: "cubeCheck")
        buttonRadio.setImage(deselectedImage, for: .normal)
        buttonRadio.setImage(selectedImage, for: .selected)
        buttonRadio.addTarget(self, action: #selector(self.radioButtonTapped), for: .touchUpInside)
    }

    @objc func radioButtonTapped(_ radioButton: UIButton) {
        let isSelected = !self.buttonRadio.isSelected
        self.buttonRadio.isSelected = isSelected
        if isSelected {
          //  deselectOtherButton()
        }
        let tableView = self.superview as! UITableView
        let tappedCellIndexPath = tableView.indexPath(for: self)!
        delegate?.didToggleRadioButton(tappedCellIndexPath)
    }
}
