//
//  CheckOutViewController.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 07/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
import MRCountryPicker
import PushNotifications
import JWTDecode
import CoreLocation

class CheckOutViewController: BaseViewController {
    
    //MARK:- IBOutlet
    @IBOutlet weak var labelRestaurantName: UILabel!
    @IBOutlet weak var checkOutTableView: UITableView!
    @IBOutlet weak var checkOutBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonCompleteHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonCompleteOrder: UIButton!
    
    //custom variables
    var currentLocation = CLLocation()
    var subLocality = String()
    var locality = String()
    var myBasketData = [[String:MyBasketData]]()
    var restaurantId = String()
    var restaurantDetail : RestaurantLists?
    var cardNumber = ""
    var expiryMonth = ""
    var expiryYear = ""
    var cvv = ""
    var deliverAddressCell : DeliveryAddressTableCell?
    var specialRequestCell : SpecialNotesTableCell?
    var contactCell : PhoneNumberAndCodeCell?
    var addCouponCell : AddCouponCell?
    var orderStatus : String?
    var orderId : Int?
    var isCouponCodeApplied = true
    var addressDetail : [String:Any]?
    var deliveryDetail : [String:Any]?
    var savedPhones = [PhoneStruct]()
    var userAddresses = [AddressStruct]()
    var selectedAddressId : String?
    var selectedPhoneId : String?
    
    fileprivate struct ReusableIdentifier {
        static let paymentSectionHeader = "PaymentsSectionHesder"
        static let orderSummaryCell = "OrderSummaryTableCell"
        static let deliveryAddressSectionHeader = "DeliveryAddressSectionHeader"
        static let orderSectionFooter = "OrderSectionFooter"
        static let addCouponCodeCell = "AddCouponCell"
        static let paymentMethodsCell = "PaymentMethodsCell"
        static let cashOnDeliveryCell = "CashOnDeliveryCell"
        static let editPaymentSegue = "editPaymentSegue"
        static let specialNotesTableCell = "SpecialNotesTableCell"
        static let phoneNumberAndCodeCell = "PhoneNumberAndCodeCell"
        static let deliveryAddressTableCell = "DeliveryAddressTableCell"
        static let addCardCell = "AddCardCell"
        static let editPaymentsAddCardCell = "EditPaymentsAddCardCell"
        static let completeOrderSegue = "completeOrderSegue"
        static let phonesActionSheetVC = "PhonesActionSheetVC"
        static let selectAddreesActionSheet = "SelectAddreesActionSheet"
    }
    
    //Check out dataSource
    var checkOutDataSource = [[String:Any]]()
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkOutTableView.backgroundColor = UIColor.clear
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.configUI()
        if UserShared.shared.userSavedAddress == nil{
            self.selectedAddressId = ""
        }else{
            self.selectedAddressId = UserShared.shared.userSavedAddress?.id ?? ""
        }
        self.addKeyBoardListener()
        self.configTableView()
        self.getUserPhonesInfo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? OrderConfirmationVC{
            vc.orderStatus = self.orderStatus ?? ""
            vc.orderId = self.orderId ?? 0
            vc.deliveryFee = self.restaurantDetail?.deliveryFee ?? 0.0
            vc.addressDetail = self.addressDetail
            vc.deliveryDetail = self.deliveryDetail
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    
}

//MARK:- Custom methods
extension CheckOutViewController {
    
    //Complete order action
    @IBAction func completeOrderAction(_ sender: UIButton) {
        
        if Connectivity.isConnectedToInternet{
            self.callAPIForCreateOrder()
        }else{
            self.showAlertViewWithTitle(title: "Alert", Message: Messages.internetUnavailable, CancelButtonTitle: "Ok")
        }
    }
    
    func getUserPhonesInfo(){
        let user = DataBaseHelper.shared.getData().first
        let token = user?.tokenId ?? ""
        var userid = String()
        do{
            let jwt = try decode(jwt: token)
            if jwt.expired{
            }else{
                let body = jwt.body
                userid = (body["uid"] as? String) ?? ""
            }
        }catch{
            print("Data not fetched")
        }
        if Connectivity.isConnectedToInternet{
            _ = WebAPIHandler.sharedHandler.getAddressPhones(id: userid, index: 2, success: { (response) in
                debugPrint(response)
                let phones = (response["phones"] as? [[String:Any]] ) ?? []
                self.savedPhones.removeAll()
                for phone in phones{
                    self.savedPhones.append(PhoneStruct.init(data: phone))
                }
                self.checkOutTableView.reloadData()
            }, failure: { (error) in
                debugPrint(error)
            })
        }else{
            self.showAlertViewWithTitle(title:"", Message: Messages.internetUnavailable, CancelButtonTitle: "Ok")
        }
    }
    
    
    func getDishes() -> [[String:Any]]{
        var dishes = [[String:Any]]()
        for basketData in UserShared.shared.myBasketModel.myBasketData{
            if (basketData.values.first?.count)! > 1{
                for _ in 0..<(basketData.values.first?.count)!{
                    dishes.append(getParsedBasketData(with: basketData))
                }
            }else{
                dishes.append(getParsedBasketData(with: basketData))
            }
        }
        return dishes
    }
    
    func getCustomer() -> [String:Any] {
        // Congfig Contact Cell
        let contactCell = self.contactCell ?? PhoneNumberAndCodeCell()
        let firstName = contactCell.firstNameTextField.text ?? ""
        let lastName = contactCell.lastNameTextField.text ?? ""
        let email = contactCell.emailTextField.text ?? ""
        let number = contactCell.phoneNumberTextField.text ?? ""
        //Config Delivery Address Cell
        var address = ""
        var addressType = ""
        var city = ""
        var countryCode = ""
        var aptNumber = ""
        let deliveryCell = self.deliverAddressCell ?? DeliveryAddressTableCell()
        if self.deliverAddressCell != nil{
            address = (deliveryCell.adressTextField.text ?? "").components(separatedBy: ",").first ?? ""
            if UserShared.shared.userSavedAddress != nil{
                city = UserShared.shared.userSavedAddress?.city ?? ""
            }else{
                city = UserShared.shared.googleCurrentAddress?.address?.locality ?? ""
            }
            addressType = (deliveryCell.homeTextField.text ?? "").lowercasingFirstLetter()
            countryCode = deliveryCell.coountryCode ?? ""
            aptNumber = deliveryCell.aptNumberTextField.text ?? ""
        }
        
        let latitudeString =  String(format: "%.6f", (UserShared.shared.currentLocation?.coordinate.latitude) ?? "")
        let longitudeString = String(format: "%.6f",(UserShared.shared.currentLocation?.coordinate.longitude) ?? "")
        
        let coordinates = "\(latitudeString), \(longitudeString)"
        
        if firstName.isEmpty{
            self.showAlertViewWithTitle(title: "Alert", Message: "Please fill first name", CancelButtonTitle: "Ok")
        }else if lastName.isEmpty{
            self.showAlertViewWithTitle(title: "Alert", Message: "Please fill last name", CancelButtonTitle: "Ok")
        }else if email.isEmpty{
            self.showAlertViewWithTitle(title: "Alert", Message: "Please fill email id", CancelButtonTitle: "Ok")
        }else if !email.isValidEmail(){
            self.showAlertViewWithTitle(title: "Alert", Message: "Please enter valid email id", CancelButtonTitle: "Ok")
        }else if countryCode.isEmpty{
            self.showAlertViewWithTitle(title: "Alert", Message: "Please fill country code", CancelButtonTitle: "Ok")
        }else if address.isEmpty{
            self.showAlertViewWithTitle(title: "Alert", Message: "Please fill address field", CancelButtonTitle: "Ok")
        }else if addressType.isEmpty{
            self.showAlertViewWithTitle(title: "Alert", Message: "Please fill address type field", CancelButtonTitle: "Ok")
        }else if number.isEmpty{
            self.showAlertViewWithTitle(title: "Alert", Message: "Please provide contact number", CancelButtonTitle: "Ok")
        }else if city.isEmpty{
            self.showAlertViewWithTitle(title: "Alert", Message: "Please provide city name", CancelButtonTitle: "Ok")
        }else if aptNumber.isEmpty{
            self.showAlertViewWithTitle(title: "Alert", Message: "Please provide apartment number", CancelButtonTitle: "Ok")
        }else{
            let customer = ["firstName":firstName, "lastName":lastName, "address":address,"city":city, "addressType":addressType, "postcode":"", "coordinates": coordinates, "countryCode":countryCode, "phone":["dialCountry":"GB", "number":number], "email":email, "aptNo": aptNumber] as [String : Any]
            return customer
        }
        return [:]
    }
    
    func getParsedBasketData(with data:[String:MyBasketData]) -> [String:Any]{
        let basketValue = data.values.first!
        var arrayOfIds = basketValue.menuId.components(separatedBy: " ")
        let dishId = arrayOfIds.first
        arrayOfIds.remove(at: 0)
        
        let returnDict = ["id":dishId ?? "", "optionIds": arrayOfIds] as [String:Any]
        return returnDict
    }
    
    func configureAmoutAsPercent(amount:CGFloat){
        let percentOf = (amount/100) * UserShared.shared.myBasketModel.totalQAR
        UserShared.shared.myBasketModel.totalQAR = UserShared.shared.myBasketModel.totalQAR - percentOf
        self.checkOutDataSource = [["sectionTitle":"Delivery Address", "data":PaymentScetionInfoClass.init(section: 0, sectionTitle: "", isExpanded: ((UserShared.shared.isKnownUser == true) ? true : true))],["sectionTitle":"Contact Details", "data":PaymentScetionInfoClass.init(section: 1, sectionTitle: "", isExpanded: true)],["sectionTitle":"Order Summary", "data":UserShared.shared.myBasketModel.myBasketData, "footerData":["subTotal":UserShared.shared.myBasketModel.totalQAR , "deliveryFee": self.restaurantDetail?.deliveryFee ?? 0.0]],["sectionTitle":"Add Coupon Code", "data":PaymentScetionInfoClass.init(section: 3, sectionTitle: "", isExpanded: false)],["sectionTitle":"Special Request", "data":PaymentScetionInfoClass.init(section: 4, sectionTitle: "", isExpanded: false)],["sectionTitle":"Payment Methods", "data":""],["sectionTitle":"New Card" , "data" : PaymentScetionInfoClass.init(section: 1, sectionTitle: "", isExpanded: true)]]
        self.checkOutTableView.reloadData()
    }
    
    func configureAsFixed(amount : CGFloat){
        UserShared.shared.myBasketModel.totalQAR = UserShared.shared.myBasketModel.totalQAR - amount
        self.checkOutTableView.reloadData()
    }
    
    func callAPIForCreateOrder(){
        let customer = getCustomer()
        if customer.isEmpty{
            return
        }
        self.showHud(message: "creating order")
        var specialRequest = ""
        if self.specialRequestCell != nil{
            specialRequest = self.specialRequestCell?.specialNotesTextVIew.text ?? ""
        }
        let parameters = ["dishes":getDishes(),"restaurantId":self.restaurantDetail?.id ?? "", "payment":["type":"cash"],"customer" : getCustomer(), "specialRequests": specialRequest] as [String : Any]
        
        let _ = WebAPIHandler.sharedHandler.createOrder(parameters: parameters, success: { (response) in
            debugPrint(response)
            self.hideHud()
            let errorData = (((response["meta"]  as? [String:Any]) ?? [:])["errorCategory"] as? String) ?? ""
            if !errorData.isEmpty{
                self.showAlertViewWithTitle(title: "Alert", Message: (((response["meta"]  as? [String:Any]) ?? [:])["message"] as? String) ?? "", CancelButtonTitle: "Ok")
            }else{
                let orders = (response["orders"] as? [[String:Any]]) ?? []
                let data = orders.first ?? [:]
                self.orderStatus = (data["status"] as? String) ?? ""
                let id = ((data["id"] as? NSNumber) ?? 0).intValue
                try? PushNotifications.shared.subscribe(interest: "\(id)")
                
                self.orderId = (data["id"] as? Int) ?? 0
                let customer = (data["customer"] as? [String:Any]) ?? [:]
                self.addressDetail = (customer["address"] as? [String:Any]) ?? [:]
                self.deliveryDetail = (data["delivery"] as? [String:Any]) ?? [:]
                self.performSegue(withIdentifier: ReusableIdentifier.completeOrderSegue, sender: nil)
            }
        }){ (error) in
            self.hideHud()
            debugPrint(error)
        }
    }
    
    func callingAPIForCoupon(parameters : [String : Any]){
        self.showHud(message: "validating coupon")
        let _ = WebAPIHandler.sharedHandler.validateCoupon(parameters: parameters, success: { (response) in
            debugPrint(response)
            self.hideHud()
            let errorData = (((response["meta"]  as? [String:Any]) ?? [:])["errorCategory"] as? String) ?? ""
            if !errorData.isEmpty{
                self.showAlertViewWithTitle(title: "Alert", Message: (((response["meta"]  as? [String:Any]) ?? [:])["message"] as? String) ?? "", CancelButtonTitle: "Ok")
            }else{
                self.showAlertViewWithTitle(title: "Alert", Message: "Coupon applied successfully", CancelButtonTitle: "Ok")
                self.isCouponCodeApplied = false
                let coupon = (response["coupon"] as? [String:Any]) ?? [:]
                let amount = (coupon["amount"] as? CGFloat) ?? 0
                let type = (coupon["type"] as? String) ?? ""
                self.addCouponCell?.couponCodeTextField.text = ""
                if type.isEqualToString(find: "percentage"){
                    self.configureAmoutAsPercent(amount:amount)
                }else{
                    self.configureAsFixed(amount: amount)
                }
            }
        }){ (error) in
            self.hideHud()
            debugPrint(error)
        }
    }
    
    //Getting current location
    @objc func tapOnCurrentLoc(_ button: UIButton) {
        if Connectivity.isConnectedToInternet{
            self.showHud(message: nil)
            ServiceManager.shared.getAddressForLatLngByGoogle(latitude:"\(self.currentLocation.coordinate.latitude)" , longitude: "\(self.currentLocation.coordinate.longitude)") { (address) in
                self.subLocality =  (address?.subLocality) ?? ""
                self.locality = (address?.locality) ?? ""
                self.hideHud()
                if !self.subLocality.isEmpty && !self.locality.isEmpty{
                    UserShared.shared.googleCurrentAddress = address
                    UserShared.shared.currentAddress = "\(self.subLocality)"
                    self.deliverAddressCell?.adressTextField.text = "\(self.subLocality), \(self.locality)"
                }
                UserShared.shared.userSavedAddress = nil
                self.selectedAddressId = nil
                UserShared.shared.currentLocation = self.currentLocation
            }
        }else{
            self.showAlertViewWithTitle(title: "", Message:Messages.internetUnavailable, CancelButtonTitle: "ok")
        }
    }
    
    
    func configTableView() {
        self.checkOutTableView.delegate = self
        self.checkOutTableView.dataSource = self
        //Registering various cells
        let orderSummaryCell = UINib(nibName: ReusableIdentifier.orderSummaryCell, bundle: nil)
        self.checkOutTableView.register(orderSummaryCell, forCellReuseIdentifier: ReusableIdentifier.orderSummaryCell)
        
        //Registering scetion header
        let sectionHeader = UINib(nibName: ReusableIdentifier.paymentSectionHeader, bundle: nil)
        self.checkOutTableView.register(sectionHeader, forCellReuseIdentifier: ReusableIdentifier.paymentSectionHeader)
        
        //Register Delivery Header
        let deliveryHeader = UINib(nibName: ReusableIdentifier.deliveryAddressSectionHeader, bundle: nil)
        self.checkOutTableView.register(deliveryHeader, forCellReuseIdentifier: ReusableIdentifier.deliveryAddressSectionHeader)
        
        //Register delivery address cell
        let deliveryCell = UINib(nibName: ReusableIdentifier.deliveryAddressTableCell, bundle: nil)
        self.checkOutTableView.register(deliveryCell, forCellReuseIdentifier: ReusableIdentifier.deliveryAddressTableCell)
        
        //Registering Table footer
        let footerNib = UINib(nibName: ReusableIdentifier.orderSectionFooter, bundle: nil)
        self.checkOutTableView.register(footerNib, forCellReuseIdentifier: ReusableIdentifier.orderSectionFooter)
        
        //Register coupon cell
        let couponCell = UINib(nibName: ReusableIdentifier.addCouponCodeCell, bundle: nil)
        self.checkOutTableView.register(couponCell, forCellReuseIdentifier: ReusableIdentifier.addCouponCodeCell)
        
        //Register payment methods cell
        let paymentCell = UINib(nibName: ReusableIdentifier.paymentMethodsCell, bundle: nil)
        self.checkOutTableView.register(paymentCell, forCellReuseIdentifier: ReusableIdentifier.paymentMethodsCell)
        
        //Register cash on delivery payment methods cell
        let cashOnDeliveryCell = UINib(nibName: ReusableIdentifier.cashOnDeliveryCell, bundle: nil)
        self.checkOutTableView.register(cashOnDeliveryCell, forCellReuseIdentifier: ReusableIdentifier.cashOnDeliveryCell)
        
        //Register Special notes cell
        let specialNotes = UINib(nibName: ReusableIdentifier.specialNotesTableCell, bundle: nil)
        self.checkOutTableView.register(specialNotes, forCellReuseIdentifier: ReusableIdentifier.specialNotesTableCell)
        
        
        //Register phone number cell
        let phoneCell = UINib(nibName: ReusableIdentifier.phoneNumberAndCodeCell, bundle: nil)
        self.checkOutTableView.register(phoneCell, forCellReuseIdentifier: ReusableIdentifier.phoneNumberAndCodeCell)
        
        //Register Add card header cell
        let addCard = UINib(nibName: ReusableIdentifier.addCardCell, bundle: nil)
        self.checkOutTableView.register(addCard, forCellReuseIdentifier: ReusableIdentifier.addCardCell)
        
        //Register Add card  cell
        let editPaymentsAddCardCell = UINib(nibName: ReusableIdentifier.editPaymentsAddCardCell, bundle: nil)
        self.checkOutTableView.register(editPaymentsAddCardCell, forCellReuseIdentifier: ReusableIdentifier.editPaymentsAddCardCell)
        self.checkOutTableView.reloadData()
    }
    
    //config UI with datasource
    func configUI(){
        self.labelRestaurantName.text = self.restaurantDetail?.restaurantTitle ?? ""
        self.myBasketData = (UserShared.shared.myBasketModel.myBasketData)
        //     self.totalPrice = UserShared.shared.myBasketModel.totalQAR
        self.setNavigation(title: "Checkout")
        self.checkOutDataSource = [["sectionTitle":"Delivery Address", "data":PaymentScetionInfoClass.init(section: 0, sectionTitle: "", isExpanded: ((UserShared.shared.isKnownUser == true) ? true : true))],["sectionTitle":"Contact Details", "data":PaymentScetionInfoClass.init(section: 1, sectionTitle: "", isExpanded: true)],["sectionTitle":"Order Summary", "data":UserShared.shared.myBasketModel.myBasketData, "footerData":["subTotal":UserShared.shared.myBasketModel.totalQAR, "deliveryFee": self.restaurantDetail?.deliveryFee ?? 0.0]],["sectionTitle":"Add Coupon Code", "data":PaymentScetionInfoClass.init(section: 3, sectionTitle: "", isExpanded: false)],["sectionTitle":"Special Request", "data":PaymentScetionInfoClass.init(section: 4, sectionTitle: "", isExpanded: false)],["sectionTitle":"Payment Methods", "data":""],["sectionTitle":"New Card" , "data" : PaymentScetionInfoClass.init(section: 1, sectionTitle: "", isExpanded: true)]]
    }
    
    //Getting when user tap on addcoupon
    func didTapOnAddCoupon(section: Int, cell: PaymentsSectionHesder?) {
        ((self.checkOutDataSource[section])["data"] as! PaymentScetionInfoClass).isExpanded = !((self.checkOutDataSource[section])["data"] as! PaymentScetionInfoClass).isExpanded
        self.checkOutTableView.reloadData()
    }
    
    //Getting when user tap on special request
    func didTapOnSpecialRequest(section: Int, cell: PaymentsSectionHesder?) {
        ((self.checkOutDataSource[section])["data"] as! PaymentScetionInfoClass).isExpanded = !((self.checkOutDataSource[section])["data"] as! PaymentScetionInfoClass).isExpanded
        self.checkOutTableView.reloadData()
    }
    
    //Opening the Map View for address selection
    func didTapOnEditPaymentMethods() {
        debugPrint("did paymentTapped")
        self.performSegue(withIdentifier: ReusableIdentifier.editPaymentSegue, sender: nil)
    }
    
    func didTapOnEditActionButton() {
        self.view.endEditing(true)
        self.performSegue(withIdentifier: "editAdressSegue", sender: nil)
    }
    
    //Adding keyboard listener
    func addKeyBoardListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil);
    }
    
    
    //Appearence of keyboard will trigger this method
    @objc func keyboardWillShow(_ notification: Notification) {
        self.checkOutBottomConstraint.constant = -65.0
    }
    
    //Disappearence of keyboard will trigger this method
    @objc func keyboardWillHide(_ notification: Notification) {
        self.checkOutBottomConstraint.constant = 0.0
        self.checkOutTableView.reloadData()
    }
    
    //Load card for add card section
    @objc func loadCardContents(cell : AddCardCell?){
        for index in 0..<UserShared.shared.paymentMethods.payments.count {
            if index == UserShared.shared.paymentMethods.payments.count - 1{
                UserShared.shared.paymentMethods.payments[index].isCheck = true
            }else{
                UserShared.shared.paymentMethods.payments[index].isCheck = false
            }
        }
        ((self.checkOutDataSource[6])["data"] as! PaymentScetionInfoClass).isExpanded = !((self.checkOutDataSource[6])["data"] as! PaymentScetionInfoClass).isExpanded
        self.checkOutTableView.reloadData()
        self.checkOutTableView.scrollToRow(at: IndexPath.init(row: 0, section: 6), at: .bottom, animated: true)
    }
    
    @objc func addCardButtonAction() {
        
        let date = NSDate()
        let components = Calendar.current.dateComponents([.day,.month,.year],from:date as Date)
        
        let month = components.month
        
        let indexPath = IndexPath.init(row: 0, section: 6)
        let cell = self.checkOutTableView.cellForRow(at: indexPath) as! EditPaymentsAddCardCell
        let cardHolderName = cell.cardHolderTextField.text ?? ""
        let cardNumber = cell.cardNumberTextField.text ?? ""
        let expMonth = cell.expMonthTextField.text ?? ""
        let expYear = cell.expYearTextField.text ?? ""
        
        if (cell.cardHolderTextField.text?.isEmpty)!{
            self.showAlertViewWithTitle(title: "Alert", Message: "Please fill card holder name", CancelButtonTitle: "Ok")
        }else if (cell.cardNumberTextField.text?.isEmpty)!{
            self.showAlertViewWithTitle(title: "Alert", Message: "Please fill card number", CancelButtonTitle: "Ok")
        }else if (cell.expMonthTextField.text?.isEmpty)!{
            self.showAlertViewWithTitle(title: "Alert", Message: "Please fill expiry month", CancelButtonTitle: "Ok")
        }else if (cell.expYearTextField.text?.isEmpty)!{
            self.showAlertViewWithTitle(title: "Alert", Message: "Please fill expiry year", CancelButtonTitle: "Ok")
        }else if (cell.cvvTextField.text?.isEmpty)!{
            self.showAlertViewWithTitle(title: "Alert", Message: "Please fill cvv number", CancelButtonTitle: "Ok")
        }else if cell.cardNumberTextField.text?.count != 16{
            self.showAlertViewWithTitle(title: "Alert", Message: "Please enter 16 digit card number", CancelButtonTitle: "Ok")
        }else if cell.cvvTextField.text?.count != 3{
            self.showAlertViewWithTitle(title: "Alert", Message: "Please enter 3 digit cvv number", CancelButtonTitle: "Ok")
        }else if (Int(cell.expMonthTextField.text!)! < month!) && (cell.expYearTextField.text?.isEqualToString(find: "2018"))! {
            self.showAlertViewWithTitle(title: "Alert", Message: "Please enter valid a date", CancelButtonTitle: "Ok")
        }else{
            UserShared.shared.paymentMethods.payments.insert(Payments(methodsName : cardHolderName, cardNumber : cardNumber, monthYear : "\(expMonth)/\(expYear)", isCheck: false), at: UserShared.shared.paymentMethods.payments.count - 2)
            
            cell.cardHolderTextField.text = ""
            cell.cardNumberTextField.text = ""
            cell.expMonthTextField.text = ""
            cell.expYearTextField.text = ""
            cell.cvvTextField.text = ""
            
            self.cardNumber = ""
            self.expiryMonth = ""
            self.expiryYear = ""
            self.cvv = ""
            self.checkOutTableView.reloadData()
        }
    }
}

//MARK:- Table View delegates and datasource
extension CheckOutViewController : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return checkOutDataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if !UserShared.shared.isKnownUser{
                return 1
            }else{
                let sectionData = self.checkOutDataSource[section]
                let data = sectionData["data"] as! PaymentScetionInfoClass
                let expand = data.isExpanded
                if expand!{
                    return 1
                }else{
                    return 0
                }
            }
        }else if section == 2{
            return UserShared.shared.myBasketModel.myBasketData.count 
        }else if section == 1 {
            if !UserShared.shared.isKnownUser{
                return 1
            }else{
                let sectionData = self.checkOutDataSource[section]
                let data = sectionData["data"] as! PaymentScetionInfoClass
                let expand = data.isExpanded
                if expand!{
                    return 1
                }else{
                    return 0
                }
            }
        }else if section == 3 || section == 4{
            let sectionData = self.checkOutDataSource[section]
            let data = sectionData["data"] as! PaymentScetionInfoClass
            let expand = data.isExpanded
            if expand!{
                return 1
            }else{
                return 0
            }
        }else if section == 5{
            return UserShared.shared.paymentMethods.payments.count - 1
        }else{
            let expand = UserShared.shared.paymentMethods.payments[UserShared.shared.paymentMethods.payments.count - 1].isCheck
            if expand{
                return 1
            }else{
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if indexPath.section == 0{
            let deliveryCell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.deliveryAddressTableCell, for: indexPath) as! DeliveryAddressTableCell
            deliveryCell.adressTextField.text = UserShared.shared.currentAddress
            deliveryCell.delegate = self
            deliveryCell.configVariousCode()
            self.deliverAddressCell = deliveryCell
            cell = deliveryCell
        }else if indexPath.section == 1{
            let phoneCell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.phoneNumberAndCodeCell, for: indexPath) as! PhoneNumberAndCodeCell
            phoneCell.delegate = self
            self.contactCell = phoneCell
            if self.savedPhones.count > 0{
                self.selectedPhoneId = self.savedPhones.first?.id ?? ""
                phoneCell.initPhoneNumber(data: self.savedPhones.first!)
            }
            cell = phoneCell
        }else if indexPath.section == 2{
            let orderCell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.orderSummaryCell, for: indexPath) as! OrderSummaryTableCell
            let sectionData = self.checkOutDataSource[indexPath.section]
            let data = sectionData["data"] as! [[String:MyBasketData]]
            let dataSource = data[indexPath.row]
            orderCell.dataSource = dataSource
            cell = orderCell
        }else if indexPath.section == 3 {
            let couponCell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.addCouponCodeCell, for: indexPath) as! AddCouponCell
            self.addCouponCell = couponCell
            couponCell.couponCodeTextField.delegate = self
            couponCell.delegate = self
            cell = couponCell
        }else if indexPath.section == 4{
            let specialNotes = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.specialNotesTableCell, for: indexPath) as! SpecialNotesTableCell
            specialNotes.specialNotesTextVIew.delegate = self
            self.specialRequestCell = specialNotes
            cell = specialNotes
        }else if indexPath.section == 5 {
            if indexPath.row >= UserShared.shared.paymentMethods.payments.count - 2{
                let cashOnDeliveryCell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.cashOnDeliveryCell, for: indexPath) as! CashOnDeliveryCell
                let data = UserShared.shared.paymentMethods.payments
                let dataSource = data[indexPath.row]
                cashOnDeliveryCell.row = indexPath.row
                cashOnDeliveryCell.section = indexPath.section
                cashOnDeliveryCell.delegate = self
                cashOnDeliveryCell.dataSource = dataSource
                cell = cashOnDeliveryCell
            }else{
                let paymentCell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.paymentMethodsCell, for: indexPath) as! PaymentMethodsCell
                let data = UserShared.shared.paymentMethods.payments
                let dataSource = data[indexPath.row]
                paymentCell.dataSource = dataSource
                paymentCell.section = indexPath.section
                paymentCell.row = indexPath.row
                paymentCell.delegate = self
                cell = paymentCell
            }
        }else if indexPath.section == 6{
            let cell  = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.editPaymentsAddCardCell, for: indexPath) as! EditPaymentsAddCardCell
            cell.scanCardButton.addTarget(self, action: #selector(CheckOutViewController.scanCardClicked), for: .touchUpInside)
            cell.addButton.addTarget(self, action: #selector(CheckOutViewController.addCardButtonAction), for: .touchUpInside)
            return cell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            let deliveryHeader = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.deliveryAddressSectionHeader) as! DeliveryAddressSectionHeader
            deliveryHeader.labelDeliveryAddress.text = (self.checkOutDataSource[section]["sectionTitle"] as? String) ?? ""
            deliveryHeader.editButton.tag = section
            deliveryHeader.editButton.addTarget(self, action: #selector(self.buttonToggleAction(_:  cell : )), for: .touchUpInside)
            deliveryHeader.dataSource = (self.checkOutDataSource[section]["data"] as? PaymentScetionInfoClass) ?? PaymentScetionInfoClass()
            return deliveryHeader.contentView
        }else if section == 2{
            let paymentHeader = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.paymentSectionHeader) as! PaymentsSectionHesder
            paymentHeader.labelSectionTitle.text = (self.checkOutDataSource[section]["sectionTitle"] as? String) ?? ""
            paymentHeader.buttonToggle.isHidden = true
            paymentHeader.buttonToggle.tag = section
            return paymentHeader.contentView
        }else if section == 5{
            let paymentHeader = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.paymentSectionHeader) as! PaymentsSectionHesder
            paymentHeader.labelSectionTitle.text = (self.checkOutDataSource[section]["sectionTitle"] as? String) ?? ""
            paymentHeader.buttonToggle.isHidden = true
            paymentHeader.buttonToggle.addTarget(self, action: #selector(self.buttonToggleAction(_:  cell : )), for: .touchUpInside)
            paymentHeader.buttonToggle.tag = section
            return paymentHeader.contentView
        }else if section == 6{
            let addCard = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.addCardCell) as! AddCardCell
            addCard.delegate = self
            addCard.dataSource = UserShared.shared.paymentMethods.payments[UserShared.shared.paymentMethods.payments.count - 1]
            addCard.checkButton.addTarget(self, action: #selector(CheckOutViewController.loadCardContents), for: .touchUpInside)
            return addCard.contentView
        }else{
            let paymentHeader = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.paymentSectionHeader) as! PaymentsSectionHesder
            paymentHeader.labelSectionTitle.text = (self.checkOutDataSource[section]["sectionTitle"] as? String) ?? ""
            if section == 1 && !UserShared.shared.isKnownUser{
                paymentHeader.buttonToggle.isHidden = true
            }
            let sectionData = self.checkOutDataSource[section]
            let data = sectionData["data"] as! PaymentScetionInfoClass
            paymentHeader.dataSource = data
            paymentHeader.buttonToggle.tag = section
            paymentHeader.buttonToggle.addTarget(self, action: #selector(self.buttonToggleAction(_:  cell : )), for: .touchUpInside)
            return paymentHeader.contentView
        }
    }
    
    @objc func buttonToggleAction(_ sender: UIButton, cell : PaymentsSectionHesder?) {
        if sender.tag == 1{
            self.didTapOnAddCoupon(section:sender.tag, cell:cell)
        } else if sender.tag == 3{
            self.didTapOnAddCoupon(section:sender.tag, cell:cell)
        }else if sender.tag == 4 {
            self.didTapOnSpecialRequest(section: sender.tag, cell: cell)
        }else if sender.tag == 0{
            self.didTapOnSpecialRequest(section: sender.tag, cell: cell)
        }else{
            self.didTapOnEditPaymentMethods()
        }
    }
    
    
    @objc func buttonEditAction(_ sender: UIButton, cell : PaymentsSectionHesder?) {
        self.didTapOnEditActionButton()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 60
        }else{
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 110
        }else if indexPath.section == 3{
            return 65
        }else if indexPath.section == 5{
            return 30
        }else if indexPath.section == 4{
            return 90
        }else if indexPath.section == 1{
            return 150
        }else if indexPath.section == 6{
            return 260
        }else if indexPath.section == 2{
            if indexPath.row < UserShared.shared.myBasketModel.myBasketData.count {
                let basketData = UserShared.shared.myBasketModel.myBasketData[indexPath.row]
                let basketValue = basketData.values.first!
                let count = basketValue.count
                if count != 0{
                    return UITableViewAutomaticDimension
                }else{
                    return 0
                }
            }else{
                let optionData = UserShared.shared.myBasketModel.myOptionData[indexPath.row - UserShared.shared.myBasketModel.myBasketData.count]
                let valuedata = optionData.values.first
                let count = valuedata?.count
                if count != 0{
                    return 30
                }else{
                    return 0
                }
            }
        }
        return 30
    }
    
    // set view for footer
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 2{
            let footer = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.orderSectionFooter) as! OrderSectionFooter
            let sectionData = self.checkOutDataSource[section]
            let footerData = sectionData["footerData"] as! [String:Any]
            footer.dataSource = footerData
            return footer
        }else{
            return UIView()
        }
    }
    
    // set height for footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 2{
            return 113
        }else if section == 5{
            return 0
        }else {
            return 13
        }
    }
    
}

//MARK:- Delivery AddressTableCell Delegate
extension CheckOutViewController : DeliveryAddressTableCellDelegate{
    func didTapOnTextField(currentLoc : CLLocation) {
        self.currentLocation = currentLoc
        let actionSheet = self.storyboard?.instantiateViewController(withIdentifier: ReusableIdentifier.selectAddreesActionSheet) as! SelectAddreesActionSheet
        actionSheet.addresses = self.userAddresses
        actionSheet.delegate = self
        actionSheet.selectedAddressId = self.selectedAddressId ?? ""
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func didShowInternetAlert(){
        self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "ok")
    }
}

//MARK:- Phone Number cell delegate
extension CheckOutViewController: PhoneNumberAndCodeCellDelegate{
    func showAlert(){
        self.showAlertViewWithTitle(title: "Message", Message: "Please enter valid email address", CancelButtonTitle: "Ok")
    }
    
    func showSavedPhones() {
        let actionSheet = self.storyboard?.instantiateViewController(withIdentifier: ReusableIdentifier.phonesActionSheetVC) as! PhonesActionSheetVC
        actionSheet.savedPhoneNubers = self.savedPhones
        actionSheet.delegate = self
        actionSheet.selectedPhoneId = self.selectedPhoneId
        self.present(actionSheet, animated: true, completion: nil)
    }
}

//MARK:- Payment method celll delegate
extension CheckOutViewController: PaymentMethodsCellDelegate{
    func didTapOnCheckButton(row: Int, section: Int) {
        for index in 0..<UserShared.shared.paymentMethods.payments.count{
            if index == row{
                UserShared.shared.paymentMethods.payments[index].isCheck = true
            }else{
                UserShared.shared.paymentMethods.payments[index].isCheck = false
            }
        }
        self.checkOutTableView.reloadData()
    }
}

//MARK:- Cash on delivery method celll delegate
extension CheckOutViewController: CashOnDeliveryCellDelegate {
    func didTapOnCheckFromCashOnDelivery(row: Int, section: Int) {
        for index in 0..<UserShared.shared.paymentMethods.payments.count{
            if index == row{
                UserShared.shared.paymentMethods.payments[index].isCheck = true
            }else{
                UserShared.shared.paymentMethods.payments[index].isCheck = false
            }
        }
        self.checkOutTableView.reloadData()
    }
}

//MARK:- Delivery address celll delegate
extension CheckOutViewController : DeliveryAddressSectionHeaderDelegate{
    func didTapOnEditAction(){
        self.performSegue(withIdentifier: "editAdressSegue", sender: nil)
    }
    
    func reloadTable(){
        self.checkOutTableView.reloadData()
    }
}

//MARK:- Textfield delegate
extension CheckOutViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK:- Text View delegate
extension CheckOutViewController : UITextViewDelegate{
}

//MARK:- Add card delegate
extension CheckOutViewController : AddCardCellDelegate{
    
    func didTapOnAddCardCheck(row: Int){
        for index in 0..<UserShared.shared.paymentMethods.payments.count {
            if index == row{
                UserShared.shared.paymentMethods.payments[index].isCheck = true
            }else{
                UserShared.shared.paymentMethods.payments[index].isCheck = false
            }
        }
        ((self.checkOutDataSource[6])["data"] as! PaymentScetionInfoClass).isExpanded = !((self.checkOutDataSource[6])["data"] as! PaymentScetionInfoClass).isExpanded
        self.checkOutTableView.reloadData()
    }
}


//MARK:- Scanner methods
extension CheckOutViewController : CardIOPaymentViewControllerDelegate{
    
    @objc func scanCardClicked() {
        let scanViewController = CardIOPaymentViewController(paymentDelegate: self)
        scanViewController?.modalPresentationStyle = .formSheet
        present(scanViewController!, animated: true)
    }
    
    func userDidProvide(_ info: CardIOCreditCardInfo?, in paymentViewController: CardIOPaymentViewController?) {
        if let anInfo = info {
            print("Scan succeeded with info: \(anInfo)")
        }
        // Do whatever needs to be done to deliver the purchased items.
        dismiss(animated: true)
        
        let indexPath = IndexPath.init(row: 0, section: 6)
        let cell = self.checkOutTableView.cellForRow(at: indexPath) as! EditPaymentsAddCardCell
        if let aNumber = info?.redactedCardNumber, let aCvv = info?.cvv {
            _ = String(format: "Received card info. Number: %@, expiry: %02lu/%lu, cvv: %@.", aNumber, UInt(info?.expiryMonth ?? 0), UInt(info?.expiryYear ?? 0), aCvv)
            self.cardNumber = String(aNumber)
            self.expiryYear = String(UInt(info?.expiryYear ?? 0))
            self.expiryMonth = String(UInt(info?.expiryMonth ?? 0))
            
            
            if UInt(info?.expiryMonth ?? 0) < 10{
                self.expiryMonth = "0" + self.expiryMonth
            }
            self.cvv = aCvv
            cell.cardHolderTextField.text = ""
            cell.cardNumberTextField.text = self.cardNumber
            cell.expMonthTextField.text = self.expiryMonth
            cell.expYearTextField.text = self.expiryYear
            cell.cvvTextField.text = self.cvv
            self.checkOutTableView.reloadData()
        }
    }
    
    func userDidCancel(_ paymentViewController: CardIOPaymentViewController?) {
        print("User cancelled scan")
        dismiss(animated: true)
    }
}

//MARK:- AddCouponCell delegate
extension CheckOutViewController : AddCouponCellDelegate{
    func didTapOnApplyButton(couponCode: String) {
        self.view.endEditing(true)
        // Congfig Contact Cell
        let contactCell = self.contactCell ?? PhoneNumberAndCodeCell()
        let email = contactCell.emailTextField.text ?? ""
        if couponCode.isEmpty{
            self.showAlertViewWithTitle(title: "Alert", Message: "Please enter coupon code", CancelButtonTitle: "Ok")
        }else if email.isEmpty{
            self.showAlertViewWithTitle(title: "Alert", Message: "Please fill email id field", CancelButtonTitle: "Ok")
        }else if !email.isValidEmail(){
            self.showAlertViewWithTitle(title: "Alert", Message: "Please enter valid email id", CancelButtonTitle: "Ok")
        }else{
            let parameters = ["couponId": couponCode, "email": email]
            if Connectivity.isConnectedToInternet{
                if isCouponCodeApplied{
                    self.callingAPIForCoupon(parameters: parameters)
                }else{
                    self.showAlertViewWithTitle(title: "Alert", Message: "Coupon is alredy applied", CancelButtonTitle: "Ok")
                }
            }else{
                self.showAlertViewWithTitle(title: "Alert", Message: Messages.internetUnavailable, CancelButtonTitle: "Ok")
            }
        }
    }
}

//MARK:- Custom data source class
class PaymentScetionInfoClass {
    var isExpanded : Bool!
    var sectionTitle : String!
    var section : Int!
    
    init(section : Int, sectionTitle: String, isExpanded : Bool) {
        self.section = section
        self.sectionTitle = sectionTitle
        self.isExpanded = isExpanded
    }
    init() {
        
    }
}

//MARK:- Phones Action Sheet VC Delegate
extension CheckOutViewController : PhonesActionSheetVCDelegate{
    func didTapOnSavedCell(data: PhoneStruct, index: Int) {
        if index == 0{
            self.contactCell?.shouldPick = true
            self.contactCell?.phoneNumberTextField.becomeFirstResponder()
        }else{
            self.contactCell?.countryFlagImageView.image = UIImage(named: "SwiftCountryPicker.bundle/Images/\(data.countryCode.uppercased())", in: Bundle(for: MRCountryPicker.self), compatibleWith: nil)
            self.selectedPhoneId = data.id
            self.contactCell?.phoneNumberTextField.text = data.phoneNumber
            self.contactCell?.labelCourtryCode.text = ""
        }
    }
}

//MARK:- Select Addrees Action Sheet Delegate
extension CheckOutViewController : SelectAddreesActionSheetDelegate{
    func didSelectAddressType(cell: AdressActionSheetCell, index: Int) {
        if index == 0{
            if Connectivity.isConnectedToInternet{
                self.performSegue(withIdentifier: "editAdressSegue", sender: nil)
            }else{
                self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "ok")
            }
        }else if index == 1{
            self.tapOnCurrentLoc(UIButton())
        }else{
            self.selectedAddressId = cell.dataSource.id
            UserShared.shared.userSavedAddress = cell.dataSource
            UserShared.shared.currentLocation = cell.dataSource.coordinates
            UserShared.shared.currentAddress = cell.dataSource.address.components(separatedBy: ",").first ?? ""
            self.deliverAddressCell?.adressTextField.text = cell.dataSource.address.components(separatedBy: ",").first ?? ""
            self.deliverAddressCell?.aptNumberTextField.text = cell.dataSource.aptNo
            self.deliverAddressCell?.homeTextField.text = cell.dataSource.type
        }
    }
}


