//
//  MyBasketViewController.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 06/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//


import UIKit

class MyBasketViewController: BaseViewController {
    
    //MARK:- IB outlet
    @IBOutlet weak var labelQAR: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var labelCart: UILabel!
    @IBOutlet weak var buttonCheckOut: UIButton!
    @IBOutlet weak var myBasketTableView: UITableView!
    
    //Custom variables
    var restautantDetails : RestaurantLists?
    var myBasketData  = [[String:MyBasketData]]()
    var totalCart = Int()
    var totalQAR = CGFloat()
    var minimumOrderValue = Int()
    var currencyType = String()
    var userAddresses = [AddressStruct]()
    
    fileprivate struct ReusableIdentifier {
        static let myBasketSectionHeadaer = "MyBasketSectionHeader"
        static let myBasketTableCell = "MyBasketTableCell"
        static let myBasketTableFooter = "MyBasketTableFooter"
        static let navigationTitle = "MY BASKET"
    }
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configTableView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.configUI()
        self.currencyType = (UserDefaults.standard.value(forKey: "Currency") as? String) ?? "QAR"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        UserShared.shared.myBasketModel.myBasketData = self.myBasketData
        UserShared.shared.myBasketModel.totalCart = self.totalCart
        UserShared.shared.myBasketModel.totalQAR = self.totalQAR
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CheckOutViewController{
            vc.restaurantDetail = self.restautantDetails
            vc.userAddresses = self.userAddresses
        }
    }
    
    
    @IBAction func buttonCheckOutAction(_ sender: UIButton) {
        if self.totalQAR >= CGFloat(self.minimumOrderValue){
            self.performSegue(withIdentifier: "checkOutSegue", sender: nil)
        }else{
            self.showAlertViewWithTitle(title: "Message", Message: "Please exceed the minimum order value \(self.minimumOrderValue) \(self.currencyType)", CancelButtonTitle: "Ok")
        }
    }
}

//MARK:- Custom Methods
extension MyBasketViewController {
    
    func configTableView(){
        self.setNavigation(title: ReusableIdentifier.navigationTitle)
        
        //Register NIB For Tabel Footer
        let footerNib = UINib(nibName: ReusableIdentifier.myBasketTableFooter, bundle: nil)
        self.myBasketTableView.register(footerNib, forCellReuseIdentifier: ReusableIdentifier.myBasketTableFooter)
        
        //Register NIB For Basket Cell
        let basketCell = UINib(nibName: ReusableIdentifier.myBasketTableCell, bundle: nil)
        self.myBasketTableView.register(basketCell, forCellReuseIdentifier: ReusableIdentifier.myBasketTableCell)
    }
    
    func configUI(){
        DispatchQueue.main.async {
            //Adding shadow to bottom view
            self.bottomView.layer.masksToBounds = false
            self.bottomView.layer.shadowRadius = 20.0
            self.bottomView.layer.shadowColor = UIColor.lightGray.cgColor
            self.bottomView.layer.shadowOffset = CGSize(width: 1.0, height: 5.0)
            self.bottomView.layer.shadowOpacity = 1.0
            
            self.buttonCheckOut.layer.cornerRadius = self.buttonCheckOut.frame.size.height/2
            self.labelCart.text = "\(self.totalCart)"
            
            self.labelQAR.text =  "\(self.totalQAR + (self.restautantDetails?.deliveryFee ?? 0.0)) \(self.currencyType)"
        }
    }
}

//MARK:- TableView data source & delegate methods
extension MyBasketViewController : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myBasketData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.myBasketTableCell, for: indexPath) as! MyBasketTableCell
        cell.delegate = self
        cell.row = indexPath.row
        cell.dataSource = self.myBasketData[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.myBasketSectionHeadaer) as! MyBasketSectionHeader
        header.labelSectionTitle.text = self.restautantDetails?.restaurantTitle ?? ""
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    // set view for footer
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.myBasketTableFooter) as! MyBasketTableFooter
        footer.dataSource = self.myBasketData
        footer.labelDeliveryFee.text = "\(self.restautantDetails?.deliveryFee ?? 0.0) \(currencyType)"
        footer.labelTotal.text = "\(UserShared.shared.myBasketModel.totalQAR + (self.restautantDetails?.deliveryFee ?? 0.0)) \(currencyType)"
        return footer
    }
    
    // set height for footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 150
    }
}

//MARK:- My basket table cell delegate
extension MyBasketViewController : MyBasketTableCellDelegate {
    
    //Decrease the cart count
    func didTapOnDecreaseCount(cell: MyBasketTableCell?) {
        var totalQAR = CGFloat()
        var totalCart = 0
        var qarDiff = CGFloat()
        for index in 0..<self.myBasketData.count {
            var myBasket = self.myBasketData[index]
            let data = myBasket.values.first!
            if myBasket.keys.first == cell?.dataSource.keys.first{
                let key = myBasket.keys.first!
                var data = myBasket.values.first!
                data.count = data.count - 1
                totalCart = totalCart + data.count
                qarDiff = data.menuPrice
                data.basketPrice = (CGFloat(data.count) * data.menuPrice)
                totalQAR = totalQAR + data.basketPrice
                myBasket.updateValue(data, forKey: key)
                self.myBasketData[index] = myBasket
            }else{
                totalQAR = totalQAR + ((myBasket.values.first?.menuPrice)! * CGFloat(data.count))
                totalCart = totalCart + Int(data.count)
            }
        }
        self.totalCart = UserShared.shared.myBasketModel.totalCart - 1
        self.totalQAR = UserShared.shared.myBasketModel.totalQAR - qarDiff
        UserShared.shared.myBasketModel.totalCart = self.totalCart
        UserShared.shared.myBasketModel.totalQAR = self.totalQAR
        self.labelQAR.text = "\(self.totalQAR + (self.restautantDetails?.deliveryFee ?? 0.0)) \(self.currencyType)"
        self.labelCart.text = "\(self.totalCart) "
        if self.totalQAR >= CGFloat(self.minimumOrderValue) {
            self.buttonCheckOut.backgroundColor = UIColor.borderedRed
            self.labelCart.textColor = UIColor.borderedRed
            self.labelQAR.textColor = UIColor.borderedRed
        }else{
            self.buttonCheckOut.backgroundColor = UIColor.disabledLightGray
            self.labelCart.textColor = UIColor.darkRed
            self.labelQAR.textColor = UIColor.darkRed
        }
        self.myBasketTableView.reloadData()
    }
    
    //Increase the cart count
    func didTapOnIncreaseCount(cell: MyBasketTableCell?) {
        
        var totalQAR = CGFloat()
        var totalCart = 0
        var qarIncrease = CGFloat()
        for index in 0..<self.myBasketData.count {
            var myBasket = self.myBasketData[index]
            let data = myBasket.values.first!
            if myBasket.keys.first == cell?.dataSource.keys.first{
                let key = myBasket.keys.first!
                var data = myBasket.values.first!
                data.count = data.count + 1
                qarIncrease = data.menuPrice
                totalCart = totalCart + Int(data.count)
                data.basketPrice = (CGFloat(data.count) * data.menuPrice)
                totalQAR = totalQAR + data.basketPrice
                myBasket.updateValue(data, forKey: key)
                self.myBasketData[index] = myBasket
            }else{
                totalQAR = totalQAR + ((myBasket.values.first?.menuPrice)! * CGFloat(data.count))
                totalCart = totalCart + Int(data.count)
            }
        }
        self.totalCart = UserShared.shared.myBasketModel.totalCart + 1
        self.totalQAR = UserShared.shared.myBasketModel.totalQAR + qarIncrease
        UserShared.shared.myBasketModel.totalCart = self.totalCart
        UserShared.shared.myBasketModel.totalQAR = self.totalQAR
        self.labelQAR.text = "\(self.totalQAR + (self.restautantDetails?.deliveryFee ?? 0.0)) \(self.currencyType)"
        self.labelCart.text = "\(self.totalCart) "
        if self.totalQAR >= CGFloat(self.minimumOrderValue) {
            self.buttonCheckOut.backgroundColor = UIColor.borderedRed
            self.labelCart.textColor = UIColor.borderedRed
            self.labelQAR.textColor = UIColor.borderedRed
        }else{
            self.buttonCheckOut.backgroundColor = UIColor.disabledLightGray
            self.labelCart.textColor = UIColor.darkRed
            self.labelQAR.textColor = UIColor.darkRed
        }
        self.myBasketTableView.reloadData()
        return
    }
    
    //Removing particular cell
    func didTapOnRemoveCell(cell: MyBasketTableCell?) {
        for index in 0..<self.myBasketData.count {
            let myBasket = self.myBasketData[index]
            if myBasket.keys.first == cell?.dataSource.keys.first{
                var data = myBasket.values.first!
                data.basketPrice = (CGFloat(data.count) * data.menuPrice)
                self.myBasketData.remove(at: index)
                self.totalCart = self.totalCart - data.count
                self.totalQAR = self.totalQAR - data.basketPrice
                UserShared.shared.myBasketModel.totalCart = self.totalCart
                UserShared.shared.myBasketModel.totalQAR = self.totalQAR
                self.labelQAR.text = "\(self.totalQAR + (self.restautantDetails?.deliveryFee ?? 0.0)) \(self.currencyType)"
                self.labelCart.text = "\(self.totalCart)"
                self.myBasketTableView.reloadData()
                if self.totalQAR >= CGFloat(self.minimumOrderValue) {
                    self.buttonCheckOut.backgroundColor = UIColor.borderedRed
                    self.labelCart.textColor = UIColor.borderedRed
                    self.labelQAR.textColor = UIColor.borderedRed
                }else{
                    self.buttonCheckOut.backgroundColor = UIColor.disabledLightGray
                    self.labelCart.textColor = UIColor.darkRed
                    self.labelQAR.textColor = UIColor.darkRed
                }
                return
            }
        }
    }
}
