//
//  RestaurantOpeningTimingCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 01/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class RestaurantOpeningTimingCell: UITableViewCell {
    
    @IBOutlet weak var viewInCell: UIView!
    @IBOutlet weak var labelSunday: UILabel!
    @IBOutlet weak var labelMonday: UILabel!
    @IBOutlet weak var labelTuesday: UILabel!
    @IBOutlet weak var labelwednesday: UILabel!
    @IBOutlet weak var labelThursday: UILabel!
    @IBOutlet weak var labelFriday: UILabel!
    @IBOutlet weak var labelSaturday: UILabel!
    
    var dataSource : [RestaurantInfo.RestaurantTimingStruct] = [RestaurantInfo.RestaurantTimingStruct(data: [:])]{
        didSet{
            
            for data in dataSource {
                
                switch data.day {
                case "Sunday":
                    self.labelSunday.text = "\(data.startHour) - \(data.endHour)"
                case "Monday":
                    self.labelMonday.text = "\(data.startHour) - \(data.endHour)"
                case "Tuesday":
                    self.labelTuesday.text = "\(data.startHour) - \(data.endHour)"
                case "Wednesday":
                    self.labelwednesday.text = "\(data.startHour) - \(data.endHour)"
                case "Thursday":
                    self.labelThursday.text = "\(data.startHour) - \(data.endHour)"
                case "Friday":
                    self.labelFriday.text = "\(data.startHour) - \(data.endHour)"
                case "Saturday":
                    self.labelSaturday.text = "\(data.startHour) - \(data.endHour)"
                default:
                    print("NO match")
                }
            }
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
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
