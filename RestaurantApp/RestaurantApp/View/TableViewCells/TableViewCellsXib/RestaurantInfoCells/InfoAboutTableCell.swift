//
//  InfoAboutTableCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 29/08/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class InfoAboutTableCell: UITableViewCell {
    
    @IBOutlet weak var labelRestaurantName: UILabel!
    @IBOutlet weak var labelAbout: UILabel!
    @IBOutlet weak var viewInCell: UIView!
   
    var dataSource : RestaurantInfo.RestaurantAboutInfo = RestaurantInfo.RestaurantAboutInfo()  {
        didSet{
            self.labelRestaurantName.text = dataSource.restaurantTitle
            self.labelAbout.text = dataSource.restaurantAbout
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        DispatchQueue.main.async {
            self.viewInCell.layer.cornerRadius = 5
            self.viewInCell.layer.borderWidth = 0.4
            self.viewInCell.layer.borderColor = UIColor.lightGray.cgColor
        }
        self.configInfoLabel()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
 
    //MARK:- Config info labels
    func configInfoLabel(){
        let stringAbout = "Mauris id dignissim purus, a fringila ex. Sed rhoncus ex at commodo tempus. Morbi a maximus lorem. Pelintesque non dolor tincidunt. pulvinar dolor in, rutrum erat. Cras nec odio tempor, rutrum risus a sagittis turpis.\n\n"
        
        let myString = NSMutableAttributedString(string: stringAbout)
        let stringAbout2 = "Mauris id dignissim purus, a fringila ex. Sed rhoncus ex at commodo tempus. Morbi a maximus lorem. Pelintesque non dolor tincidunt."
        let boldString = self.configureAttributedText(fullString: stringAbout2, fontSize: 11)
        let combination = NSMutableAttributedString()
        combination.append(myString)
        combination.append(boldString)
        
        self.labelAbout.attributedText = combination
    }
    
    func configureAttributedText(fullString: String, fontSize: Double) -> NSMutableAttributedString {
        let range = (fullString as NSString).range(of: fullString)
        var myMutableString = NSMutableAttributedString()
        
        myMutableString = NSMutableAttributedString(string: fullString)
        myMutableString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.darkGray , range: range)
        return myMutableString
    }
    
}
