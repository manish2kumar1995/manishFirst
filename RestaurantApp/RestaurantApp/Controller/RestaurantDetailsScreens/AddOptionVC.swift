//
//  AddOptionVC.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 04/10/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class AddOptionVC: BaseViewController {
    
    //MARK:- IBOutlets
    @IBOutlet weak var labelQARCount: UILabel!
    @IBOutlet weak var labelCartCount: UILabel!
    @IBOutlet weak var buttonAdd: UIButton!
    @IBOutlet weak var addOptionTableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    
    fileprivate struct ReusableIdentifier{
        static let addOptionTableCell = "AddOptionTableCell"
    }
    
    //Custom variables
    var restaurantId : String?
    var menuData : MenuItems?
    var selectedSteak : String?
    var selectedSauce : String?
    var selectedSteakPrice = Int()
    var selectedSaucePrice = Int()
    var selectedSteakId : String?
    var selectedSauceId : String?
    var currencyType = String()
    var minimumOrderValue = Int()
    var selectedSteakCount = Int()
    var selectedSauceCount = Int()
    var dishAdded = true
    
    var dataSource = [AddOptionData]()
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigation(title: "Select dish options")
        
        //Calling Restaurant Dish Options API
        if Connectivity.isConnectedToInternet{
            self.callingDishOptionsAPI()
        }else{
            self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "ok")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.currencyType = (UserDefaults.standard.value(forKey: "Currency") as? String) ?? "QAR"
        self.configUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK:- IB action
extension AddOptionVC{
    
    @IBAction func buttonAddAction(_ sender: UIButton) {
        self.addSelectedDish()
        let priceString = self.menuData!.menuPrice
        let price = (priceString  + CGFloat(self.selectedSteakPrice) + CGFloat(self.selectedSaucePrice))
        UserShared.shared.myBasketModel.totalQAR = UserShared.shared.myBasketModel.totalQAR + price
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK:- Custom methods
extension AddOptionVC {
    
    //To add selected dish
    func addSelectedDish(){
        var found = false
        if UserShared.shared.myBasketModel.myBasketData.count != 0{
            for  i in 0..<UserShared.shared.myBasketModel.myBasketData.count {
                var myBasket = UserShared.shared.myBasketModel.myBasketData[i]
                let id = (self.menuData!.menuId) + (self.selectedSteakId ?? "")
                let fullID = id + (self.selectedSauceId ?? "")
                if (myBasket.keys.first?.isEqualToString(find: fullID))!{
                    let key = myBasket.keys.first!
                    var data = myBasket.values.first!
                    data.count = data.count + 1
                    data.basketPrice = CGFloat((data.count * Int(data.menuPrice)))
                    myBasket.updateValue(data, forKey: key)
                    found = true
                    UserShared.shared.myBasketModel.myBasketData[i] = myBasket
                }
            }
            if !found {
                let price = (self.menuData!.menuPrice + CGFloat(self.selectedSteakPrice) + CGFloat(self.selectedSaucePrice))
                let firstString = (self.menuData!.menuTitle + ","  + (self.selectedSteak ?? ""))
                let title = (firstString + "," + (self.selectedSauce ?? ""))
                
                UserShared.shared.myBasketModel.myBasketData.append([((self.menuData!.menuId) + (self.selectedSteakId ?? "") + (self.selectedSauceId ?? "")) : MyBasketData(menuId: ((self.menuData!.menuId) + (self.selectedSteakId ?? "") + (self.selectedSauceId ?? "")), menuTitle:title , count: (self.menuData!.count) + 1, menuLogoImage: (self.menuData!.menuLogoImage), menuPrice: price , basketPrice :price)])
            }
        }else {
            let price = (self.menuData!.menuPrice  + CGFloat(self.selectedSteakPrice) + CGFloat(self.selectedSaucePrice))
            let firstString = (self.menuData!.menuTitle + ","  + (self.selectedSteak ?? ""))
            let title = (firstString + "," + (self.selectedSauce ?? ""))
            
            UserShared.shared.myBasketModel.myBasketData.append([((self.menuData!.menuId) + (self.selectedSteakId ?? "") + (self.selectedSauceId ?? "")) : MyBasketData(menuId: ((self.menuData!.menuId) + (self.selectedSteakId ?? "") + (self.selectedSauceId ?? "")), menuTitle:title , count: (self.menuData!.count) + 1, menuLogoImage: (self.menuData!.menuLogoImage), menuPrice: CGFloat(price) , basketPrice :CGFloat(price))])
        }
        UserShared.shared.myBasketModel.totalCart = UserShared.shared.myBasketModel.totalCart + 1
    }
    
    func configUI(){
        
        self.buttonAdd.backgroundColor = UIColor.borderedRed
        
        //Adding shadow to bottom view
        self.bottomView.layer.masksToBounds = false
        self.bottomView.layer.shadowRadius = 20.0
        self.bottomView.layer.shadowColor = UIColor.lightGray.cgColor
        self.bottomView.layer.shadowOffset = CGSize(width: 1.0, height: 5.0)
        self.bottomView.layer.shadowOpacity = 1.0
        
        self.labelCartCount.textColor = UIColor.borderedRed
        self.labelQARCount.textColor = UIColor.borderedRed
        
        
        self.labelQARCount.text = "\(UserShared.shared.myBasketModel.totalQAR) \(self.currencyType)"
        self.labelCartCount.text = "\(UserShared.shared.myBasketModel.totalCart)"
        
        self.buttonAdd.layer.cornerRadius = self.buttonAdd.frame.size.height/2
    }
    
    func callingDishOptionsAPI(){
        self.showHud(message: "loading options")
        let  _ = WebAPIHandler.sharedHandler.getDishOptions(dishId: (self.menuData?.menuId) ?? "", restaurantId: self.restaurantId ?? "", success: { (response) in
            debugPrint(response)
            self.hideHud()
            let optionData = (response["options"] as? [String:[[String:Any]]]) ?? [:]
            
            for (key, value) in optionData{
                var sectionData = [SectionData]()
                for steak in value{
                    sectionData.append(SectionData.init(data: steak))
                }
                if sectionData.count != 0{
                    self.dataSource.append(AddOptionData(sectiontitle:key.uppercased(),sectionData:sectionData ))
                }
            }
            self.addOptionTableView.reloadData()
        }){(error) in
            self.hideHud()
            self.showAlertViewWithTitle(title: "", Message: error.localizedDescription, CancelButtonTitle: "ok")
        }
    }
}

//MARK:- Table view delegate and datasource
extension AddOptionVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource[section].sectionData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.addOptionTableCell, for: indexPath) as! AddOptionTableCell
        cell.delegate = self
        cell.section = indexPath.section
        cell.row = indexPath.row
        cell.dataSource = self.dataSource[indexPath.section].sectionData[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let screenSize: CGRect = UIScreen.main.bounds
        let myView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width - 20, height: 20))
        let label = UILabel(frame: CGRect(x: 26, y: 40, width: screenSize.width - 70, height: 20))
        label.text = self.dataSource[section].sectiontitle
        label.font = UIFont.boldSystemFont(ofSize: 20.0)
        label.textColor = UIColor.borderedRed
        myView.backgroundColor = UIColor.white
        myView.addSubview(label)
        return myView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
}

//MARK:- Add Option Table Cell delegate
extension AddOptionVC : AddOptionTableCellDelegate {
    
    func didTapOnCheck(section: Int?, row: Int?) {
        for index in 0..<self.dataSource[section!].sectionData.count{
            if index == row{
                self.dataSource[section!].sectionData[index].isCheck = true
            }else{
                self.dataSource[section!].sectionData[index].isCheck = false
            }
        }
        if section == 0{
            self.selectedSteak = self.dataSource[section!].sectionData[row!].title
            self.selectedSteakPrice = self.dataSource[section!].sectionData[row!].price
            self.selectedSteakCount = self.dataSource[section!].sectionData[row!].count
            self.selectedSteakId = " \(self.dataSource[section!].sectionData[row!].id)"
        }else{
            self.selectedSauce = self.dataSource[section!].sectionData[row!].title
            self.selectedSaucePrice = self.dataSource[section!].sectionData[row!].price
            self.selectedSauceCount = self.dataSource[section!].sectionData[row!].count
            self.selectedSauceId = " \(self.dataSource[section!].sectionData[row!].id)"
        }
        
        self.labelQARCount.text = "\(UserShared.shared.myBasketModel.totalQAR + CGFloat(self.selectedSteakPrice) + CGFloat(selectedSaucePrice)) \(self.currencyType)"
        self.addOptionTableView.reloadData()
    }
}
