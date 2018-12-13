//
//  WeekViewVC.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 12/6/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class WeekViewVC: BaseViewController {
    
    @IBOutlet weak var weekTableView: UITableView!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelDay: UILabel!
    
    var mainDataSource = [[String:[WeekStruct]]]()
    var startDate = Date()
    var endDate = Date()
    
    let sundayDataSource = [
        ["Breakfast":[WeekStruct(name:"Lentil Soup", likes: "180k",imageName : "testStarLogo"), WeekStruct(name:"Lentil Soup", likes: "180k",imageName : "testPinterLogo")]],
        ["Lunch":[WeekStruct(name:"Lentil Soup", likes: "180k",imageName : "testApnaLogo")]],
        ["Dinner":[WeekStruct(name:"Lentil Soup", likes: "180k",imageName : "testMenuLOgo")]]
    ]
    
    let mondayDataSource = [
        ["Breakfast":[WeekStruct(name:"Lentil Soup", likes: "180k",imageName : "testStarLogo")]],
        ["Lunch":[WeekStruct(name:"Lentil Soup", likes: "180k",imageName : "testPinterLogo"),WeekStruct(name:"Lentil Soup", likes: "180k",imageName : "testApnaLogo")]],
        ["Dinner":[WeekStruct(name:"Lentil Soup", likes: "180k",imageName : "testMenuLOgo")]]
    ]
    
    let tuesdayDataSource = [
        ["Breakfast":[WeekStruct(name:"Lentil Soup", likes: "180k",imageName : "testStarLogo"),WeekStruct(name:"Lentil Soup", likes: "180k",imageName : "testApnaLogo")]],
        ["Lunch":[WeekStruct(name:"Lentil Soup", likes: "180k",imageName : "testPinterLogo")]],
        ["Dinner":[WeekStruct(name:"Lentil Soup", likes: "180k",imageName : "testMenuLOgo")]]
    ]
    
    let wedDataSource = [
        ["Breakfast":[WeekStruct(name:"Lentil Soup", likes: "180k",imageName : "testStarLogo")]],
        ["Lunch":[WeekStruct(name:"Lentil Soup", likes: "180k",imageName : "testApnaLogo")]],
        ["Dinner":[WeekStruct(name:"Lentil Soup", likes: "180k",imageName : "testMenuLOgo"), WeekStruct(name:"Lentil Soup", likes: "180k",imageName : "testPinterLogo")]]
    ]
    
    let thuDataSource = [
        ["Breakfast":[WeekStruct(name:"Lentil Soup", likes: "180k",imageName : "testStarLogo")]],
        ["Lunch":[WeekStruct(name:"Lentil Soup", likes: "180k",imageName : "testPinterLogo"),WeekStruct(name:"Lentil Soup", likes: "180k",imageName : "testApnaLogo")]],
        ["Dinner":[WeekStruct(name:"Lentil Soup", likes: "180k",imageName : "testMenuLOgo")]]
    ]
    
    let friDataSource = [
        ["Breakfast":[WeekStruct(name:"Lentil Soup", likes: "180k",imageName : "testStarLogo"),WeekStruct(name:"Lentil Soup", likes: "180k",imageName : "testApnaLogo")]],
        ["Lunch":[WeekStruct(name:"Lentil Soup", likes: "180k",imageName : "testPinterLogo")]],
        ["Dinner":[WeekStruct(name:"Lentil Soup", likes: "180k",imageName : "testMenuLOgo")]]
    ]
    
    let satDataSource = [
        ["Breakfast":[WeekStruct(name:"Lentil Soup", likes: "180k",imageName : "testStarLogo")]],
        ["Lunch":[WeekStruct(name:"Lentil Soup", likes: "180k",imageName : "testPinterLogo")]],
        ["Dinner":[WeekStruct(name:"Lentil Soup", likes: "180k",imageName : "testMenuLOgo"),WeekStruct(name:"Lentil Soup", likes: "180k",imageName : "testApnaLogo")]]
    ]
    
    fileprivate struct ReusableIdenfier {
        static let restaurantMenuCell = "RestaurantMenuCell"
    }
    var selectedDayIndex = 1
    
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configNavigationTitlte()
        self.mainDataSource = mondayDataSource
        self.endDate = Calendar.current.date(byAdding: .day, value: self.selectedDayIndex - 1, to: self.startDate)!
        self.configDayIndex()
        self.configDateUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func crossButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //Called by arrow to change UI base on selected day
    @IBAction func increaseDecraseAction(_ sender: UIButton) {
        if sender.tag == 1{
            self.selectedDayIndex = self.selectedDayIndex - 1
            if self.selectedDayIndex < 1{
                self.selectedDayIndex = 7
                self.endDate = Calendar.current.date(byAdding: .day, value: (self.selectedDayIndex - 1), to: self.startDate)!
            }else{
                self.endDate = Calendar.current.date(byAdding: .day, value: -1, to: self.endDate)!
            }
            self.configDayIndex()
            self.configDateUI()
        }else{
            self.selectedDayIndex = self.selectedDayIndex + 1
            if self.selectedDayIndex > 7{
                self.selectedDayIndex = 1
            }
            self.endDate = Calendar.current.date(byAdding: .day, value: self.selectedDayIndex - 1, to: self.startDate)!
            self.configDayIndex()
            self.configDateUI()
        }
    }
}

//MARK:- Custom methods
extension WeekViewVC {
    
    //Configure the navigation bar
    func configNavigationTitlte(){
        let titleLabel = UILabel.init()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = UIColor.naivgationTitleColor
        titleLabel.text = "Week View"
        titleLabel.frame = CGRect.init(x: 0, y: 5, width: 20, height: 20)
        self.navigationItem.titleView = titleLabel
    }
    
    func configDateUI(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let currentDateString: String = dateFormatter.string(from: self.endDate)
        print("Current date is \(currentDateString)")
        self.labelDate.text = "\(currentDateString)"
    }
    
    //configure the UI based on selected index
    func configDayIndex(){
        switch (self.selectedDayIndex) {
        case 1:
            self.labelDay.text = "Monday"
            self.mainDataSource = mondayDataSource
            self.weekTableView.reloadData()
        case 2:
            self.labelDay.text = "Tuesday"
            self.mainDataSource = tuesdayDataSource
            self.weekTableView.reloadData()
        case 3:
            self.labelDay.text = "Wednesday"
            self.mainDataSource = wedDataSource
            self.weekTableView.reloadData()
        case 4:
            self.labelDay.text = "Thursday"
            self.mainDataSource = thuDataSource
            self.weekTableView.reloadData()
        case 5:
            self.labelDay.text = "Friday"
            self.mainDataSource = friDataSource
            self.weekTableView.reloadData()
        case 6:
            self.labelDay.text = "Saturday"
            self.mainDataSource = satDataSource
            self.weekTableView.reloadData()
        case 7:
            self.labelDay.text = "Sunday"
            self.mainDataSource = sundayDataSource
            self.weekTableView.reloadData()
        default:
            return
        }
    }
}

//MARK:- Table view delegate data source
extension WeekViewVC : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let values = self.mainDataSource[section].values.first?.count
        return values ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menuCell = tableView.dequeueReusableCell(withIdentifier: ReusableIdenfier.restaurantMenuCell, for: indexPath) as! RestaurantMenuCell
        menuCell.viewRightButton.isHidden = true
        let data = self.mainDataSource[indexPath.section].values.first?[indexPath.row]
        menuCell.initForWeek(data: data ?? WeekStruct())
        return menuCell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let screenSize: CGRect = UIScreen.main.bounds
        let myView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width , height: 60))
        let label = UILabel(frame: CGRect(x: 20, y: 25, width: screenSize.width - 70, height: 20))
        let text = self.mainDataSource[section].keys.first ?? ""
        label.text = text
        label.textColor = UIColor.borderedRed
        let view = UIView(frame: CGRect(x: 0, y: myView.frame.size.height - 1, width: screenSize.width , height: 1))
        view.backgroundColor = UIColor.viewBackgroundGray
        myView.backgroundColor = UIColor.white
        myView.addSubview(view)
        label.font = UIFont.boldSystemFont(ofSize: 19.0)
        myView.addSubview(label)
        return myView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
}
