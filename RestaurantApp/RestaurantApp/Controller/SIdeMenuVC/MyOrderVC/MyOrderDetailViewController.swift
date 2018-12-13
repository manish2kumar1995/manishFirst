//
//  MyOrderDetailViewController.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 06/10/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class MyOrderDetailViewController: BaseViewController {
    
    @IBOutlet weak var myOrderTableView: UITableView!
    
    var basketData = [DishData]()
    var hotelName = String()
    var orderId : Int?
    var address : [String:Any]?
    var createdDate : String?
    var imageLogo : String?
    var dishPrice : [String:Any]?
    let notificationName = Notification.Name("notificatioForStatus")
    var status = String()
    var selectedRestaurant : RestaurantLists?
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(MyOrderDetailViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    fileprivate struct ReusableIdentifier{
        static let myOrderHeaderTableCell = "MyOrderHeaderTableCell"
        static let yourOrderCell = "YourOrderCell"
        static let myBasketTableFooter = "MyBasketTableFooter"
    }
    
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 10.0, *) {
            self.myOrderTableView.refreshControl = refreshControl
        }else{
            self.myOrderTableView.addSubview(refreshControl)
        }
        self.setNavigation(title: "Manage Order")
        NotificationCenter.default.addObserver(self, selector: #selector(MyOrderVC.updateUI(_:)), name: notificationName, object: nil)
        
        self.configUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RestaurantMenuVC{
            vc.restaurantId = selectedRestaurant?.id ?? ""
            vc.restaurantDetail = selectedRestaurant
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UserShared.shared.myBasketModel.myBasketData = []
        UserShared.shared.myBasketModel.totalQAR = 0.0
        UserShared.shared.myBasketModel.totalCart = 0
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil)
        debugPrint("ViewController deinit")
    }
    
    @IBAction func buttonReorderAction(_ sender: Any) {
        //        let arr_controller:[UIViewController] = (self.navigationController?.viewControllers)!
        //        _ = self.navigationController?.popToViewController(arr_controller[0], animated: true)
        
        self.performSegue(withIdentifier: "reorderSegue", sender: nil)
    }
}

//MARK:- Custom methods
extension MyOrderDetailViewController{
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        if Connectivity.isConnectedToInternet{
            self.callApiForOrderDetail()
        }else{
            self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "ok")
        }
        refreshControl.endRefreshing()
    }
    
    @objc func updateUI(_ notification: NSNotification){
        if Connectivity.isConnectedToInternet{
            self.callApiForOrderDetail()
        }else{
            self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "ok")
        }
    }
    
    func configUI(){
        self.myOrderTableView.delegate = self
        self.myOrderTableView.dataSource = self
        //Registering order cell
        let orderCell = UINib(nibName: ReusableIdentifier.yourOrderCell, bundle: nil)
        self.myOrderTableView.register(orderCell, forCellReuseIdentifier: ReusableIdentifier.yourOrderCell)
        
        //Register NIB For Tabel Footer
        let footerNib = UINib(nibName: ReusableIdentifier.myBasketTableFooter, bundle: nil)
        self.myOrderTableView.register(footerNib, forCellReuseIdentifier: ReusableIdentifier.myBasketTableFooter)
        
        //Calling order detail api
        if Connectivity.isConnectedToInternet{
            self.callApiForOrderDetail()
        }else{
            self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "Ok")
        }
    }
    
    func callApiForOrderDetail(){
        self.showHud(message: "loading order detail")
        let _ = WebAPIHandler.sharedHandler.getMyORderDetail(orderId: self.orderId ?? 0, success: { (resposne) in
            self.hideHud()
            debugPrint(resposne)
            let orders = (resposne["orders"] as? [[String:Any]])?.first ?? [:]
            self.createdDate = ((orders["createdAt"] as? String) ?? "").components(separatedBy: " ").first ?? ""
            self.status = (orders["status"] as? String) ?? ""
            let dishes = (orders["dishes"] as? [[String:Any]]) ?? []
            self.basketData.removeAll()
            for dish in dishes{
                self.basketData.append(DishData.init(data: dish))
            }
            let restaurant = (orders["restaurant"] as? [String:Any]) ?? [:]
            self.selectedRestaurant = RestaurantLists.init(data: restaurant)
            self.dishPrice = (orders["price"] as? [String:Any]) ?? [:]
            let customer = (orders["customer"] as? [String:Any]) ?? [:]
            self.address = (customer["address"] as? [String:Any]) ?? [:]
            self.myOrderTableView.reloadData()
        }) { (error) in
            self.hideHud()
            debugPrint(error)
        }
    }
}

//MARK:- Table View delegate data source
extension MyOrderDetailViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 0
        }else{
            return basketData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.yourOrderCell, for: indexPath) as! YourOrderCell
        cell.initializeCellItems(data: self.basketData[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            let header = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.myOrderHeaderTableCell) as! MyOrderHeaderTableCell
            header.dataSource = self.address ?? [:]
            header.labelHotelName.text = self.hotelName
            header.labelOrderNumber.text = "#\(self.orderId ?? 0)"
            header.imageLogoView.sd_setImage(with: URL(string: self.imageLogo ?? ""), placeholderImage: UIImage(named: "logo"))
            if (self.status.isEqualToString(find: "completed")){
                header.buttonReview.isHidden = false
            }else{
                header.buttonReview.isHidden = true
            }
            let dataArray = self.createdDate?.components(separatedBy: "-") ?? []
            let dateFormatterFirst = DateFormatter()
            dateFormatterFirst.dateFormat = "yyyy'-'MM'-'dd'"
            let date = dateFormatterFirst.date(from: self.createdDate ?? "")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            
            dateFormatter.dateFormat = "EE dd MMM  yyyy"
            let currentDateString: String = dateFormatter.string(from: date ?? Date())
            print("Current date is \(currentDateString)")
            
            if dataArray.count != 0 {
                header.stringOrderOnSub = currentDateString
            }
            
            var country = (header.dataSource["country"] as? String) ?? ""
            if !country.isEmpty{
                country = ", \(country)"
            }
            header.stringDeliverySub = "\(((header.dataSource["address"] as? String) ?? "" )), \(((header.dataSource["city"] as? String) ?? "" ))\(country)"
            header.initializeContent()
            return header
        }else{
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            if (self.status.isEqualToString(find: "completed")){
                return 265
            }else{
                return 200
            }
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.basketData.count != 0{
            return 90
        }else{
            return 0
        }
    }
    
    // set view for footer
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1{
            let footerCell = self.myOrderTableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.myBasketTableFooter) as! MyBasketTableFooter
            if self.dishPrice != nil{
                footerCell.initializeFooter(data: self.dishPrice ?? [:])
            }
            //     footerCell.dataSource = self.myBasketData
            return footerCell
        }else{
            return nil
        }
    }
    
    // set height for footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 150
        }else{
            return 0
        }
    }
}
