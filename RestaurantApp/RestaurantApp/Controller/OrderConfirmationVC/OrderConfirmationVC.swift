//
//  OrderConfirmationVC.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 14/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
import SwiftyGif

class OrderConfirmationVC: BaseViewController {
    
    @IBOutlet weak var orderTableView: UITableView!
    
    var currencyType = (UserDefaults.standard.value(forKey: "Currency") as? String) ?? "QAR"
    var orderStatus : String?
    var orderId : Int?
    var deliveryFee : CGFloat?
    let notificationName = Notification.Name("notificatioForStatus")
    var addressDetail : [String:Any]?
    var deliveryDetail : [String:Any]?
    
    //various string value perform action
    fileprivate struct ReusableIdentifier {
        static let yourOrderCell = "YourOrderCell"
        static let orderConfirmedTableHeader = "OrderConfirmedTableHeader"
        static let orderFooterCell = "OrderFooterCell"
        static let expectedDeliveryCell = "ExpectedDeliveryCell"
    }
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configTableView()
        NotificationCenter.default.addObserver(self, selector: #selector(OrderConfirmationVC.updateUI(_:)), name: notificationName, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.configUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil)
        debugPrint("ViewController deinit")
    }
    
    @IBAction func openSIdeMenu(_ sender: Any) {
        NotificationCenter.default.post(name:  KVSideMenu.Notifications.toggleLeft, object: self)
    }
}

//MARK:- Custom Methods
extension OrderConfirmationVC{
    @objc func updateUI(_ notification: NSNotification){
        debugPrint("Order called")
        let alert = notification.userInfo
        let body = (alert!["reservation_status"] as? String) ?? ""
        DispatchQueue.main.async {
            self.orderStatus = body
            self.orderTableView.reloadData()
        }
    }
    
    func configUI(){
        let titleLabel = UILabel.init()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = UIColor.naivgationTitleColor
        titleLabel.text = "Order Confirmation"
        titleLabel.frame = CGRect.init(x: 0, y: 5, width: 20, height: 20)
        self.navigationItem.titleView = titleLabel
    }
    
    func configTableView(){
        NotificationCenter.default.addObserver(self, selector: #selector(OrderConfirmationVC.updateUI(_:)), name: notificationName, object: nil)
        
        orderTableView.rowHeight = UITableViewAutomaticDimension
        orderTableView.estimatedRowHeight = UITableViewAutomaticDimension
        //Registering order cell
        let orderCell = UINib(nibName: ReusableIdentifier.yourOrderCell, bundle: nil)
        self.orderTableView.register(orderCell, forCellReuseIdentifier: ReusableIdentifier.yourOrderCell)
        
        //Registering table header
        let tableHeader = UINib(nibName: ReusableIdentifier.orderConfirmedTableHeader, bundle: nil)
        self.orderTableView.register(tableHeader, forCellReuseIdentifier: ReusableIdentifier.orderConfirmedTableHeader)
        
        
        //Register footer cell
        let footerCell = UINib(nibName: ReusableIdentifier.orderFooterCell, bundle: nil)
        self.orderTableView.register(footerCell, forCellReuseIdentifier: ReusableIdentifier.orderFooterCell)
        
        //Registering Table footer
        let expectedDeliveryCell = UINib(nibName: ReusableIdentifier.expectedDeliveryCell, bundle: nil)
        self.orderTableView.register(expectedDeliveryCell, forCellReuseIdentifier: ReusableIdentifier.expectedDeliveryCell)
    }
}

//MARK:- IB Action
extension OrderConfirmationVC{
    
}

//MARK:- UITableview datasource and delegate methods
extension OrderConfirmationVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 0
        }else if section == 1{
            return 0
        }else{
            return UserShared.shared.myBasketModel.myBasketData.count 
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.yourOrderCell, for: indexPath) as! YourOrderCell
        cell.dataSource = (UserShared.shared.myBasketModel.myBasketData[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let header = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.orderConfirmedTableHeader) as! OrderConfirmedTableHeader
            header.labelOrderNumber.text = "#\(self.orderId ?? 0)"
            if (self.orderStatus?.isEqualToString(find: "cooking"))!{
                let image = UIImage.init(gifName: "cooking.gif")
                header.labelStatus.text = "Your order is cooking"
                header.labelStatus.textColor = UIColor.pinkColor
                header.labelOrderNumber.textColor = UIColor.pinkColor
                header.statusImageVIew.setGifImage(image)
            }else if (self.orderStatus?.isEqualToString(find: "on the way"))!{
                let image = UIImage.init(gifName: "onTheWay.gif")
                header.labelStatus.text = "Your order is on the way"
                header.labelStatus.textColor = UIColor.darkYellow
                header.labelOrderNumber.textColor = UIColor.darkYellow
                header.statusImageVIew.setGifImage(image)
            }else if (self.orderStatus?.isEqualToString(find: "accepted"))!{
                let image = UIImage.init(gifName: "accepted.gif")
                header.labelStatus.text = "Your order is accepted"
                header.labelStatus.textColor = UIColor.blue
                header.labelOrderNumber.textColor = UIColor.blue
                header.statusImageVIew.setGifImage(image)
            }else if (self.orderStatus?.isEqualToString(find: "rejected"))!{
                header.labelStatus.text = "Your order is rejected"
                header.labelStatus.textColor = UIColor.red
                header.labelOrderNumber.textColor = UIColor.red
                header.statusImageVIew.image = #imageLiteral(resourceName: "orderCancel")
            }else if (self.orderStatus?.isEqualToString(find: "pending"))!{
                let image = UIImage.init(gifName: "pending.gif")
                header.labelStatus.text = "Your order is pending"
                header.labelStatus.textColor = UIColor.orange
                header.labelOrderNumber.textColor = UIColor.orange
                header.statusImageVIew.setGifImage(image)
            }else if (self.orderStatus?.isEqualToString(find: "ready"))!{
                let image = UIImage.init(gifName: "ready.gif")
                header.labelStatus.text = "Your order is ready"
                header.labelOrderNumber.textColor = UIColor.darkGreen
                header.labelStatus.textColor = UIColor.darkGreen
                header.statusImageVIew.setGifImage(image)
            }else if (self.orderStatus?.isEqualToString(find: "completed"))!{
                header.labelStatus.text = "Your order is completed"
                header.labelStatus.textColor = UIColor.darkGreen
                header.labelOrderNumber.textColor = UIColor.darkGreen
                header.statusImageVIew.image = #imageLiteral(resourceName: "orderComplete")
            }else if (self.orderStatus?.isEqualToString(find: "cancelled"))!{
                header.labelStatus.text = "Your order is cancelled"
                header.labelStatus.textColor = UIColor.red
                header.labelOrderNumber.textColor = UIColor.red
                header.statusImageVIew.image = #imageLiteral(resourceName: "orderCancel")
            }else if (self.orderStatus?.isEqualToString(find: "archived"))!{
                let image = UIImage.init(gifName: "archieved.gif")
                header.labelStatus.text = "Your order is archived"
                header.labelStatus.textColor = UIColor.gray
                header.labelOrderNumber.textColor = UIColor.gray
                header.statusImageVIew.setGifImage(image)
            }
            return header
        }else if section == 1{
            let header = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.expectedDeliveryCell) as! ExpectedDeliveryCell
            header.data = self.addressDetail ?? [:]
            header.initDelivery(deliveryData: self.deliveryDetail ?? [:])
            return header
        }else{
            let screenSize: CGRect = UIScreen.main.bounds
            let myView = UIView(frame: CGRect(x: 20, y: 0, width: screenSize.width - 20, height: 20))
            let label = UILabel(frame: CGRect(x: 35, y: 15, width: screenSize.width - 70, height: 20))
            label.text = "Your order"
            label.font = UIFont.boldSystemFont(ofSize: 14.0)
            
            myView.addSubview(label)
            return myView
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.orderFooterCell) as! OrderFooterCell
            cell.labelTotal.text = "\(UserShared.shared.myBasketModel.totalQAR + (self.deliveryFee ?? 0.0)) \(self.currencyType)"
            cell.labelSubtotal.text = "\(UserShared.shared.myBasketModel.totalQAR) \(self.currencyType)"
            cell.labelDeliveryFee.text = "\(self.deliveryFee ?? 0.0) \(self.currencyType)"
            return cell
        }else{
            let view = UIView()
            view.backgroundColor = UIColor.white
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 190
        }else if section == 1{
            return 130
        }else{
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2{
            return 160
        }else if section == 0{
            return 30
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let basketData = UserShared.shared.myBasketModel.myBasketData[indexPath.row]
        let basketValue = basketData.values.first!
        let count = basketValue.count
        if count != 0{
            return 90
        }else{
            return 0
        }
    }
}
