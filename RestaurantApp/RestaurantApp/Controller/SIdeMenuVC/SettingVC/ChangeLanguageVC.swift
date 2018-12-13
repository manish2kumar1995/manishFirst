//
//  ChangeLanguageVC.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 21/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class ChangeLanguageVC: BaseViewController {
    
    @IBOutlet weak var changeLanguageTableView: UITableView!
    
    fileprivate struct ReusableIdentifier {
        static let changeCurrencyTableCell = "ChangeCurrencyTableCell"
    }
    
    //Creating data source for UI
    var dataSource  : [Currency] = [
        Currency(title:"Arabic", subTitle:"عربى", isCheck:((((UserDefaults.standard.value(forKey: "Language") as? String)?.isEqualToString(find: "ar")) ?? false) ? true : false), row:0),
        Currency(title:"English", subTitle:"English", isCheck:((((UserDefaults.standard.value(forKey: "Language") as? String)?.isEqualToString(find: "en")) ?? true) ? true : false), row:1)
    ]
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configTableUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.changeLanguageTableView.isScrollEnabled = changeLanguageTableView.contentSize.height > changeLanguageTableView.frame.size.height;
    }
}

//MARK:- Custom methods
extension ChangeLanguageVC{
    
    func configTableUI() {
        self.setNavigation(title: "SELECT LANGUAGE")
        
        //Registering order cell
        let changeCell = UINib(nibName: ReusableIdentifier.changeCurrencyTableCell, bundle: nil)
        self.changeLanguageTableView.register(changeCell, forCellReuseIdentifier: ReusableIdentifier.changeCurrencyTableCell)
    }
}

//MARK:- Table view delegate data source methods
extension ChangeLanguageVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:ReusableIdentifier.changeCurrencyTableCell , for: indexPath) as! ChangeCurrencyTableCell
        cell.dataSource = self.dataSource[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

//MARK:- Change currency delegate
extension ChangeLanguageVC: ChangeCurrencyTableCellDelegate {
    
    func didTapOnCheckButton(row: Int) {
        for index in 0..<self.dataSource.count{
            if row == index{
                self.dataSource[index].isCheck = true
            }else{
                self.dataSource[index].isCheck = false
            }
        }
        
        if row == 0{
            UserDefaults.standard.set("ar", forKey: "Language")
        }else{
            UserDefaults.standard.set("en", forKey: "Language")
        }
        self.changeLanguageTableView.reloadData()
    }
}
