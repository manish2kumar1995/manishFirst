//
//  ChangeUnitVC.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 10/10/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class ChangeUnitVC: BaseViewController {

    @IBOutlet weak var unitsTableView: UITableView!
    
    fileprivate struct ReusableIdentifier {
        static let changeCurrencyTableCell = "ChangeCurrencyTableCell"
    }
    
    //Creating data source for UI
    var dataSource  : [Currency] = [
        Currency(title:"KM", subTitle:"km", isCheck:((((UserDefaults.standard.value(forKey: "Units") as? String)?.isEqualToString(find: "KM")) ?? true) ? true : false), row:0),
        Currency(title:"MI", subTitle:"mi", isCheck:((((UserDefaults.standard.value(forKey: "Units") as? String)?.isEqualToString(find: "MI")) ?? false) ? true : false), row:1)
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
        self.unitsTableView.isScrollEnabled = unitsTableView.contentSize.height > unitsTableView.frame.size.height;
    }
}

//MARK:- Custom Methods
extension ChangeUnitVC {
    func configTableUI() {
        self.setNavigation(title: "SELECT UNIT")
        
        //Registering order cell
        let changeCell = UINib(nibName: ReusableIdentifier.changeCurrencyTableCell, bundle: nil)
        self.unitsTableView.register(changeCell, forCellReuseIdentifier: ReusableIdentifier.changeCurrencyTableCell)
    }
}

//MARK:- Table view delegate dataSource
extension ChangeUnitVC : UITableViewDelegate, UITableViewDataSource{
    
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
extension ChangeUnitVC: ChangeCurrencyTableCellDelegate {
    
    func didTapOnCheckButton(row: Int) {
        for index in 0..<self.dataSource.count{
            if row == index{
                self.dataSource[index].isCheck = true
            }else{
                self.dataSource[index].isCheck = false
            }
        }
        
        if row == 0{
            UserDefaults.standard.set("KM", forKey: "Units")
        }else{
            UserDefaults.standard.set("MI", forKey: "Units")
        }
        self.unitsTableView.reloadData()
    }
}

