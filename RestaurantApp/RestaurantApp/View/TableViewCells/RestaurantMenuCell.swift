//
//  RestaurantMenuCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 29/08/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
import SDWebImage

//Protocols for cell events
protocol RestaurantMenuCellDelegate{
    func didTapOnAddButton(cell:RestaurantMenuCell?, data : MenuItems?)
}

class RestaurantMenuCell: UITableViewCell {
    
    //MARK:- IBOutlets
    @IBOutlet weak var menuLogoImageView: UIImageView!
    @IBOutlet weak var viewRightButton: UIView!
    @IBOutlet weak var labelMenuTitle: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var buttonAdd: MyButton!
    
    var delegate : RestaurantMenuCellDelegate?
    var dataSource:MenuItems = MenuItems(data: [:]){
        didSet{
            self.labelMenuTitle.text = dataSource.menuTitle
            self.menuLogoImageView.sd_setShowActivityIndicatorView(true)
            self.menuLogoImageView.sd_setIndicatorStyle(.gray)
            self.menuLogoImageView.sd_setImage(with: URL(string: dataSource.menuLogoImage), placeholderImage: UIImage(named: "logo"))
            self.likesLabel.text = "\(dataSource.totalCalories) k"
            self.labelPrice.text = "\(dataSource.menuPrice) \((UserDefaults.standard.value(forKey: "Currency") as? String) ?? "QAR")"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //Config UI based work
        DispatchQueue.main.async {
            self.buttonAdd.layer.cornerRadius = self.buttonAdd.frame.size.height/2
            self.viewRightButton.layer.borderWidth = 1
            self.viewRightButton.layer.borderColor = UIColor.borderedRed.cgColor
            self.viewRightButton.layer.cornerRadius = 15.0
        }
        self.buttonAdd.addedTouchArea = 40
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func buttonAddAction(_ sender: Any) {
        self.delegate?.didTapOnAddButton(cell: self, data : self.dataSource)
    }
    
    func initForWeek(data:WeekStruct){
        self.labelMenuTitle.text = data.name
        self.likesLabel.text = data.likes
        self.menuLogoImageView.image = UIImage.init(named: data.imageName)
    }
}
