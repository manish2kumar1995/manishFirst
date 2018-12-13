//
//  ChangeCurrencyViewController.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 20/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class ChangeCurrencyViewController: BaseViewController {
    
    @IBOutlet weak var changeCurrencyTableView: UITableView!
    
    fileprivate struct ReusableIdentifier {
        static let changeCurrencyTableCell = "ChangeCurrencyTableCell"
    }
    
    //Creating data source for UI
    var dataSource  : [Currency] = [
        Currency(title:"Qatari Riyal", subTitle:"QAR", isCheck:((((UserDefaults.standard.value(forKey: "Currency") as? String)?.isEqualToString(find: "QAR")) ?? true) ? true : false), row:0),
        Currency(title:"United Arab Emirates Dirham", subTitle:"AED", isCheck:((((UserDefaults.standard.value(forKey: "Currency") as? String)?.isEqualToString(find: "EAD")) ?? false) ? true : false), row:1),
        Currency(title:"United States Dollar", subTitle:"USD", isCheck:((((UserDefaults.standard.value(forKey: "Currency") as? String)?.isEqualToString(find: "USD")) ?? false) ? true : false),row:2),
        Currency(title:"Great British Pound", subTitle:"GBP", isCheck:((((UserDefaults.standard.value(forKey: "Currency") as? String)?.isEqualToString(find: "GBP")) ?? false) ? true : false), row:3),
        Currency(title:"Australia Dollar", subTitle:"AUD", isCheck:((((UserDefaults.standard.value(forKey: "Currency") as? String)?.isEqualToString(find: "AUD")) ?? false) ? true : false), row:4),
        Currency(title:"Canada Dollar", subTitle:"CAD", isCheck:((((UserDefaults.standard.value(forKey: "Currency") as? String)?.isEqualToString(find: "CAD")) ?? false) ? true : false), row:5),
        Currency(title:"Switzerland Franc", subTitle:"CHF", isCheck:((((UserDefaults.standard.value(forKey: "Currency") as? String)?.isEqualToString(find: "CHF")) ?? false) ? true : false), row:6),
        Currency(title:"Denmark Krone", subTitle:"DKK", isCheck:((((UserDefaults.standard.value(forKey: "Currency") as? String)?.isEqualToString(find: "DKK")) ?? false) ? true : false), row:7),
        Currency(title:"Egypt Pound", subTitle:"EGP", isCheck:((((UserDefaults.standard.value(forKey: "Currency") as? String)?.isEqualToString(find: "EGP")) ?? false) ? true : false), row:8),
        Currency(title:"Hong Kong Dollar", subTitle:"HKD", isCheck:((((UserDefaults.standard.value(forKey: "Currency") as? String)?.isEqualToString(find: "HKD")) ?? false) ? true : false), row:9),
        Currency(title:"Israel Shekel", subTitle:"ILS", isCheck:((((UserDefaults.standard.value(forKey: "Currency") as? String)?.isEqualToString(find: "ILS")) ?? false) ? true : false), row:10),
        Currency(title:"Japan Yen", subTitle:"JPY", isCheck:((((UserDefaults.standard.value(forKey: "Currency") as? String)?.isEqualToString(find: "JPY")) ?? false) ? true : false), row:11),
        Currency(title:"Malaysia Ringgit", subTitle:"MYR", isCheck:((((UserDefaults.standard.value(forKey: "Currency") as? String)?.isEqualToString(find: "MYR")) ?? false) ? true : false), row:12),
        Currency(title:"New Zealand Dollar", subTitle:"NZD", isCheck:((((UserDefaults.standard.value(forKey: "Currency") as? String)?.isEqualToString(find: "NZD")) ?? false) ? true : false), row:13),
        Currency(title:"Poland Zloty", subTitle:"PLN", isCheck:((((UserDefaults.standard.value(forKey: "Currency") as? String)?.isEqualToString(find: "PLN")) ?? false) ? true : false), row:14),
        Currency(title:"Saudi Araia Riyal", subTitle:"SAR", isCheck:((((UserDefaults.standard.value(forKey: "Currency") as? String)?.isEqualToString(find: "SAR")) ?? false) ? true : false), row:15),
        Currency(title:"Sweden Krona", subTitle:"SEK", isCheck:((((UserDefaults.standard.value(forKey: "Currency") as? String)?.isEqualToString(find: "SEK")) ?? false) ? true : false), row:16),
        Currency(title:"Turkey Lira", subTitle:"TRY", isCheck:((((UserDefaults.standard.value(forKey: "Currency") as? String)?.isEqualToString(find: "TRY")) ?? false) ? true : false), row:17),
        Currency(title:"Russian Ruble", subTitle:"RUB", isCheck:((((UserDefaults.standard.value(forKey: "Currency") as? String)?.isEqualToString(find: "RUB")) ?? false) ? true : false), row:18)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configTableUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
}

//MARK:- custom methods
extension ChangeCurrencyViewController{
    func configTableUI(){
        self.setNavigation(title: "CHANGE CURRENCY")
        
        //Registering order cell
        let changeCell = UINib(nibName: ReusableIdentifier.changeCurrencyTableCell, bundle: nil)
        self.changeCurrencyTableView.register(changeCell, forCellReuseIdentifier: ReusableIdentifier.changeCurrencyTableCell)
    }
}

//MARK: Table view dlegate datasource
extension ChangeCurrencyViewController: UITableViewDelegate, UITableViewDataSource{
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
extension ChangeCurrencyViewController: ChangeCurrencyTableCellDelegate{
    func didTapOnCheckButton(row: Int) {
        for index in 0..<self.dataSource.count{
            if row == index{
                self.dataSource[index].isCheck = true
            }else{
                self.dataSource[index].isCheck = false
            }
        }
        
        if row == 0{
            UserDefaults.standard.set("QAR", forKey: "Currency")
        }else if row == 1{
            UserDefaults.standard.set("AED", forKey: "Currency")
        }else if row == 2{
            UserDefaults.standard.set("USD", forKey: "Currency")
        }else if row == 3{
            UserDefaults.standard.set("GBP", forKey: "Currency")
        }else if row == 4{
            UserDefaults.standard.set("AUD", forKey: "Currency")
        }else if row == 5{
            UserDefaults.standard.set("CAD", forKey: "Currency")
        }else if row == 6{
            UserDefaults.standard.set("CHF", forKey: "Currency")
        }else if row == 7{
            UserDefaults.standard.set("DKK", forKey: "Currency")
        }else if row == 8{
            UserDefaults.standard.set("EGP", forKey: "Currency")
        }else if row == 9{
            UserDefaults.standard.set("HKD", forKey: "Currency")
        }else if row == 10{
            UserDefaults.standard.set("ILS", forKey: "Currency")
        }else if row == 11{
            UserDefaults.standard.set("JPY", forKey: "Currency")
        }else if row == 12{
            UserDefaults.standard.set("MYR", forKey: "Currency")
        }else if row == 13{
            UserDefaults.standard.set("NZD", forKey: "Currency")
        }else if row == 14{
            UserDefaults.standard.set("PLN", forKey: "Currency")
        }else if row == 15{
            UserDefaults.standard.set("SAR", forKey: "Currency")
        }else if row == 16{
            UserDefaults.standard.set("SEK", forKey: "Currency")
        }else if row == 17{
            UserDefaults.standard.set("TRY", forKey: "Currency")
        }else if row == 18{
            UserDefaults.standard.set("RUB", forKey: "Currency")
        }
        
        self.changeCurrencyTableView.reloadData()
    }
}
