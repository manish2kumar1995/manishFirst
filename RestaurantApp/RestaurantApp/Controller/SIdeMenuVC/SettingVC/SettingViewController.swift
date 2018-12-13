//
//  SettingViewController.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 19/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class SettingViewController: BaseViewController {
    
    @IBOutlet weak var settingTableView: UITableView!
    
    fileprivate struct ReusableIdentifier {
        static let settingTableCell = "SettingTableCell"
        static let changeLanguageSegue = "changeLanguageSegue"
        static let changeCurrencySegue = "changeCurrencySegue"
        static let changeUnitSegue = "changeUnitSegue"
        static let notificationSegue = "notificationSegue"
    }
    
    //Creating data source for UI
    var dataSource = [Settings]()
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigation(title: "SETTINGS")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Seting data in data source
        self.dataSource = [
            Settings(settingIcon:"languageIcon",settingTitle:"Language",settingSubTitle:((((UserDefaults.standard.value(forKey: "Language") as? String)?.isEqualToString(find: "en")) ?? true) ? "English" : "Arabic")),
            Settings(settingIcon:"currencyIcon",settingTitle:"Currency",settingSubTitle:"\((UserDefaults.standard.value(forKey: "Currency") as? String) ?? "QAR")"),
            Settings(settingIcon:"unitsIcon",settingTitle:"Units",settingSubTitle:"\((UserDefaults.standard.value(forKey: "Units") as? String) ?? "KM")"),
         Settings(settingIcon:"notificationIcon",settingTitle:"Notifications",settingSubTitle:"Email Notifications")
        ]
        
        self.settingTableView.reloadData()
        self.settingTableView.isScrollEnabled = settingTableView.contentSize.height > settingTableView.frame.size.height;
    }
}

//MARK:- Custom methods
extension SettingViewController{
    
}

//MARK:- Table view delegate data source
extension SettingViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.settingTableCell, for: indexPath) as! SettingTableCell
        cell.dataSource = self.dataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            self.performSegue(withIdentifier: ReusableIdentifier.changeLanguageSegue, sender: nil)
        }else if indexPath.row == 1{
            self.performSegue(withIdentifier: ReusableIdentifier.changeCurrencySegue, sender: nil)
        }else if indexPath.row == 2{
            self.performSegue(withIdentifier: ReusableIdentifier.changeUnitSegue, sender: nil)
        }
        else if indexPath.row == 3{
             self.performSegue(withIdentifier: ReusableIdentifier.notificationSegue, sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
