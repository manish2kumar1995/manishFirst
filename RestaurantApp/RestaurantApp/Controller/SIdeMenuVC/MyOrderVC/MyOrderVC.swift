//
//  MyOrderVC.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 06/10/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class MyOrderVC: BaseViewController {
    
    //MARK:- IB outlet
    @IBOutlet weak var myOrderTableView: UITableView!
    @IBOutlet weak var buttonSort: UIButton!
    @IBOutlet weak var labelOrderResult: UILabel!
    
    let notificationName = Notification.Name("notificatioForStatus")
    
    fileprivate struct ReusableIdentifier{
        static let myOrderTableCell = "MyOrderTableCell"
    }
    
    var myOrderDataSource = [MyOrderData]()
    var filterData = [MyOrderData]()
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(MyOrderVC.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        self.buttonSort.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(MyOrderVC.updateUI(_:)), name: notificationName, object: nil)
        
        
        if #available(iOS 10.0, *) {
            self.myOrderTableView.refreshControl = refreshControl
        }else{
            self.myOrderTableView.addSubview(refreshControl)
        }
        
        if Connectivity.isConnectedToInternet{
            self.callingAPIForMyOrders()
        }else{
            self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "Ok")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil)
        debugPrint("ViewController deinit")
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MyOrderDetailViewController{
            let data = sender as! MyOrderData
            vc.hotelName = data.name
            vc.orderId = data.orderId
            vc.imageLogo = data.imageIcon
        }
        
        if let vc = segue.destination as? SortByViewController{
            vc.titleArray = ["Order date - Closest to Furthest","Order date - Furthest to Closest","Name - A to Z","Name - Z to A"]
            vc.titleIconArray = ["colourCalenderIcon","colourCalenderIcon", "borderedStar","borderedStar"]
            vc.delegate = self
        }
    }
    
    @IBAction func buttonSortAction(_ sender: Any) {
        self.performSegue(withIdentifier: "sortSegue", sender: nil)
    }
}

//MARK:- Custom methods
extension MyOrderVC {
    
    @objc func updateUI(_ notification: NSNotification){
        self.callingAPIForMyOrders()
    }
    
    
    func configUI(){
        self.setNavigation(title: "My Orders")
        DispatchQueue.main.async {
            self.buttonSort.layer.borderWidth = 1
            self.buttonSort.layer.borderColor = UIColor.init(red: 175/255, green: 8/255, blue: 54/255, alpha: 1.0).cgColor
            self.buttonSort.layer.cornerRadius = self.buttonSort.frame.size.height/2
        }
        self.configRestaurantResultCountLabel()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        if Connectivity.isConnectedToInternet{
            self.callingAPIForMyOrders()
        }else{
            self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "ok")
        }
        refreshControl.endRefreshing()
    }
    
    
    func configRestaurantResultCountLabel(){
        let stringRestaurantResultCount = "You have \(self.filterData.count) Orders in your account"
        let stringRestaurantCount = "\(self.filterData.count)"
        
        let attributedString = NSMutableAttributedString(string:stringRestaurantResultCount)
        attributedString.addAttribute(NSAttributedStringKey.font, value: UIFont.boldSystemFont(ofSize: 15) as Any, range: NSRange(location: 8, length: stringRestaurantCount.count + 1))
        
        let range2 = (stringRestaurantResultCount as NSString).range(of: stringRestaurantCount)
        attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.init(red: 175/255, green: 8/255, blue: 54/255, alpha: 1.0) , range: range2)
        self.labelOrderResult.attributedText = attributedString
    }
    
    func callingAPIForMyOrders(){
        
        self.showHud(message: "loading orders")
        let _ = WebAPIHandler.sharedHandler.getMyOrders(parameters: [:], success: { (response) in
            debugPrint(response)
            self.hideHud()
            let orders = (response["orders"] as? [[String:Any]]) ?? []
            self.myOrderDataSource.removeAll()
            for order in orders{
                self.myOrderDataSource.append(MyOrderData(data: order))
            }
            self.filterData = self.myOrderDataSource
            if self.filterData.count != 0{
                self.buttonSort.isHidden = false
            }
            self.sortDataOnDate()
            self.configRestaurantResultCountLabel()
            self.myOrderTableView.reloadData()
        }) { (error) in
            self.hideHud()
            debugPrint(error)
        }
    }
    
    func sortDateClosestToFar(){
        let tempData = self.filterData
        self.filterData.removeAll()
        self.filterData = tempData.sorted(by: { (data1, data2) -> Bool in
            let timeIntervalDate1 = data1.date.timeIntervalSinceNow
            let timeIntervalDate2 = data2.date.timeIntervalSinceNow
            return timeIntervalDate1 > timeIntervalDate2
        })
        self.myOrderTableView.reloadData()
        self.configRestaurantResultCountLabel()
    }
    
    func sortDateFarToClose(){
        let tempData = self.filterData
        self.filterData.removeAll()
        self.filterData = tempData.sorted(by: { (data1, data2) -> Bool in
            let timeIntervalDate1 = data1.date.timeIntervalSinceNow
            let timeIntervalDate2 = data2.date.timeIntervalSinceNow
            return timeIntervalDate1 < timeIntervalDate2
        })
        self.myOrderTableView.reloadData()
        self.configRestaurantResultCountLabel()
    }
    
    func sortNameFromAToZ(){
        let tempData = self.filterData
        self.filterData.removeAll()
        self.filterData = tempData.sorted(by: { (menu1, menu2) -> Bool in
            return menu1.name < menu2.name
        })
        self.myOrderTableView.reloadData()
        self.configRestaurantResultCountLabel()
    }
    
    func sortNameZToA(){
        let tempData = self.filterData
        self.filterData.removeAll()
        self.filterData = tempData.sorted(by: { (menu1, menu2) -> Bool in
            return menu1.name > menu2.name
        })
        self.myOrderTableView.reloadData()
        self.configRestaurantResultCountLabel()
    }
}

//MARK:- IB Action
extension MyOrderVC {
    func sortDataOnDate(){
        self.filterData.removeAll()
        self.myOrderDataSource.sort(by: { $0.date.compare($1.date) == .orderedAscending })
        self.filterData = self.myOrderDataSource.sorted(by: { (data1, data2) -> Bool in
            let timeIntervalDate1 = data1.date.timeIntervalSinceNow
            let timeIntervalDate2 = data2.date.timeIntervalSinceNow
            return timeIntervalDate1 > timeIntervalDate2
        })
    }
}

//MARK:- table view delegate data source
extension MyOrderVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filterData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyOrderTableCell", for: indexPath) as! MyOrderTableCell
        cell.dataSource = self.filterData[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 195
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "orderDetailSegue", sender: self.filterData[indexPath.row])
    }
}

//MARK:- Sort view controller delegate
extension MyOrderVC : SortByViewControllerDelegate{
    func didSelectedSortedCatagory(basisOf: String) {
        
        if basisOf.isEqualToString(find: "Order date - Closest to Furthest"){
            self.sortDateClosestToFar()
        }else if basisOf.isEqualToString(find: "Order date - Furthest to Closest"){
            self.sortDateFarToClose()
        }else if basisOf.isEqualToString(find: "Name - A to Z"){
            self.sortNameFromAToZ()
        }else if basisOf.isEqualToString(find: "Name - Z to A"){
            self.sortNameZToA()
        }
    }
}
