//
//  GlobalUtilities.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 04/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import Foundation
import UIKit


public enum RestaurantMode {
    case menu
    case review
    case info
}

public enum RecommendMode {
    case schedule
    case nutrients
    case dishTypes
}

public enum DishDetailModes {
    case description
    case nutrients
    case ingredients
}

public enum ProfileInfoMode{
    case info
    case preferences
    case goals
}

public enum FoodStatus{
    case onWay
    case cooking
    case cancel
    case pending
    case accepted
    case rejected
    case ready
    case completed
    case archived
}

public struct Messages{
    static let internetUnavailable = "Internet Connection not available"
}

extension String {
    
    //Get height for particular UILabel
    func height(constraintedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.text = self
        label.font = font
        label.sizeToFit()
        return label.frame.height
    }
    
    //To match eqaulity among strings
    func isEqualToString(find: String) -> Bool {
        return String(format: self) == find
    }
    
    
    func trim() -> String{
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func getLocalizedString(text : String) -> String {
        return text.forLocalized(lang: UserDefaults.standard.value(forKey: "Language") as! String)
    }
    
    func forLocalized(lang: String) -> String {
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        let bundle = Bundle(path: path!)
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
    
    //To validate email
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    func lowercasingFirstLetter() -> String {
        return prefix(1).lowercased() + dropFirst()
    }
    
    mutating func lowercaseFirstLetter(){
        self = self.lowercasingFirstLetter()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension UIView{
    func makeBlurr(){
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.alpha = 0.8;
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
    }
}

extension UITextField{
    func setLeftIcon(_ icon: UIImage) {
        
        let padding = 8
        let size = 15
        let outerView = UIView(frame: CGRect(x: 0, y: 10, width: size+padding, height: size) )
        let iconView  = UIImageView(frame: CGRect(x: 20, y: 0, width: 15, height: 15))
        iconView.image = icon
        outerView.addSubview(iconView)
        
        leftView = outerView
        leftViewMode = .always
    }
    
    func setRightIcon(_ icon: UIImage){
        let size = 20
        let outerView = UIView(frame: CGRect(x: -10, y: 0, width: size+5, height: size) )
        let iconView  = UIImageView(frame: CGRect(x: -10, y: 0, width: size+5, height: size))
        iconView.image = icon
        outerView.addSubview(iconView)
        
        rightView = outerView
        rightViewMode = .always
    }
    
    func removeRightIcon(){
        let size = 15
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size) )
        outerView.backgroundColor = UIColor.white
        rightView = nil
        rightViewMode = .always
        
    }
    
}

class MyButton: UIButton {
    var addedTouchArea = CGFloat(0)
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        let newBound = CGRect(
            x: self.bounds.origin.x - addedTouchArea,
            y: self.bounds.origin.y - addedTouchArea,
            width: self.bounds.width + 2 * addedTouchArea,
            height: self.bounds.width + 2 * addedTouchArea
        )
        return newBound.contains(point)
    }
}

extension Date {
    var startOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 1, to: sunday)
    }
    
    var endOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 7, to: sunday)
    }
    
//    func  get_year() -> NSInteger {
//        let calendar: NSCalendar = NSCalendar.currentCalendar()
//        let component: NSDateComponents = calendar.components(NSCalendarUnit.Year, fromDate: self)
//        return component.year;
//    }
//    //Function will reutrn the current month Number
//    func  get_Month() -> NSInteger {
//        let calendar: NSCalendar = NSCalendar.currentCalendar()
//        let component: NSDateComponents = calendar.components(NSCalendarUnit.Month, fromDate: self)
//        return component.month;
//    }
//    //Function Will return the number of day of the month.
//    func  get_Day() -> NSInteger {
//        let calendar: NSCalendar = NSCalendar.currentCalendar
//        let component: NSDateComponents = calendar.components(NSCalendar.UnitNSCalendar.Unit.Day, fromDate: self)
//        return component.day;
//    }
//    //Will return the number day of week. like Sunday =1 , Monday = 2
//    func  get_WeekDay() -> NSInteger {
//        let calendar: Calendar = Calenderdar.current
//        let component: DateComponents = calendar.components(Calendar.UnitNSCalendar.Unit.Weekday, fromDate: self)
//        return component.weekday;
//    }

}

extension UIImage {
    class func convertImageToBase64(image: UIImage) -> String {
        let imageData = UIImagePNGRepresentation(image)!
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
}

//MARK:- Custom page controller
class CustomPageControl: UIPageControl {
    
    @IBInspectable var currentPageImage: UIImage?
    
    @IBInspectable var otherPagesImage: UIImage?
    
    override var numberOfPages: Int {
        didSet {
            updateDots()
        }
    }
    
    override var currentPage: Int {
        didSet {
            updateDots()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pageIndicatorTintColor = .clear
        currentPageIndicatorTintColor = .clear
        clipsToBounds = false
    }
    
    private func updateDots() {
        
        for (index, subview) in subviews.enumerated() {
            let imageView: UIImageView
            if let existingImageview = getImageView(forSubview: subview) {
                imageView = existingImageview
            } else {
                imageView = UIImageView(image: otherPagesImage)
                
                imageView.center = subview.center
                subview.addSubview(imageView)
                subview.clipsToBounds = false
            }
            imageView.image = currentPage == index ? currentPageImage : otherPagesImage
        }
    }
    
    private func getImageView(forSubview view: UIView) -> UIImageView? {
        if let imageView = view as? UIImageView {
            return imageView
        } else {
            let view = view.subviews.first { (view) -> Bool in
                return view is UIImageView
                } as? UIImageView
            
            return view
        }
    }
}


