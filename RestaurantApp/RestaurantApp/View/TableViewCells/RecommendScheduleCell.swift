//
//  RecommendScheduleCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 12/5/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class RecommendScheduleCell: UITableViewCell {

    @IBOutlet weak var labelWeekCount: UILabel!
    @IBOutlet weak var labelWeek: UILabel!
    
    var startDate = Date()
    var endDate = Date()
   
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func dayRangeOf(weekOfYear: Int, for date: Date) -> Range<Date>{
        let calendar = Calendar.current
        let year = calendar.component(.yearForWeekOfYear, from: date)
        let startComponents = DateComponents(weekOfYear: weekOfYear, yearForWeekOfYear: year)
        let startDate = calendar.date(from: startComponents)!
        let endComponents = DateComponents(day:7, second: -1)
        let endDate = calendar.date(byAdding: endComponents, to: startDate)!
        return startDate..<endDate
    }
    
    func getStartDateOfWeek(weekOfYear: Int, for date: Date) -> Date{
        let calendar = Calendar.current
        let year = calendar.component(.yearForWeekOfYear, from: date)
        let startComponents = DateComponents(weekOfYear: weekOfYear, yearForWeekOfYear: year)
        let startDate = calendar.date(from: startComponents)!
        return startDate.startOfWeek!
    }
    
    func getEndDateOfWeek(weekOfYear: Int, for date: Date) -> Date{
        let calendar = Calendar.current
        let year = calendar.component(.yearForWeekOfYear, from: date)
        let startComponents = DateComponents(weekOfYear: weekOfYear, yearForWeekOfYear: year)
        let startDate = calendar.date(from: startComponents)!
        let endComponents = DateComponents(day:7, second: -1)
        let endDate = calendar.date(byAdding: endComponents, to: startDate)!
        return endDate.endOfWeek!
    }
    
    func weeks() -> Int {
        let weekRange = NSCalendar.current.range(of: .weekOfYear, in: .yearForWeekOfYear, for: Date())
        return weekRange?.count ?? 0
    }
    
    func getDateStringFormat(date:Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.dateFormat = "EE dd MMM"
        let currentDateString: String = dateFormatter.string(from: date)
        print("Current date is \(currentDateString)")
        return currentDateString
    }
    
    func configWeeks(index : Int){
        let weekOfTheYear = Calendar.current.component(.weekOfYear, from: Date.init(timeIntervalSinceNow: 0))

        let startDate = self.getStartDateOfWeek(weekOfYear: (weekOfTheYear + index), for: Date())
        let endDate = self.getEndDateOfWeek(weekOfYear: (weekOfTheYear + index), for: Date())
        
        self.startDate = startDate
        self.endDate = endDate
        let startDateString = self.getDateStringFormat(date: startDate)
        let endDateString = self.getDateStringFormat(date: endDate)
        self.labelWeek.text = "\(startDateString) - \(endDateString)"
    }
}
