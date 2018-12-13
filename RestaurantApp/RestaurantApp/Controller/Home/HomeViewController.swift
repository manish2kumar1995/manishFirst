//
//  HomeViewController.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 28/08/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
import CoreLocation
import JWTDecode

class HomeViewController: BaseViewController {
    
    //MARK:- IB outlets
    @IBOutlet weak var buttonSubscriptionMode: UIButton!
    @IBOutlet weak var buttonDemandMode: UIButton!
    @IBOutlet weak var slidingView: UIView!
    @IBOutlet weak var adressTextField: UITextField!
    @IBOutlet weak var viewInMenu: UIView!
    @IBOutlet weak var numberOneLabel: UILabel!
    @IBOutlet weak var viewInTasteBuds: UIView!
    @IBOutlet weak var numberTwoLabel: UILabel!
    @IBOutlet weak var viewInDoorstep: UIView!
    @IBOutlet weak var numberThreeLabel: UILabel!
    @IBOutlet weak var buttonFindRestaurants: UIButton!
    @IBOutlet weak var sideMenuButton: MyButton!
    
    //Custom variables
    var currentLocation = CLLocation()
    var locationManager = CLLocationManager()
    var subLocality = String()
    var locality = String()
    var centerXForSLidingView  :NSLayoutConstraint!
    var userAddresses = [AddressStruct]()
    var selectedAddressId : String?
    
    fileprivate struct ReusableIdentifier{
        static let selectAddreesActionSheet = "SelectAddreesActionSheet"
    }
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getUserDetail()
        if UserShared.shared.isKnownUser{
            UserShared.shared.paymentMethods.payments = []
            UserShared.shared.paymentMethods.payments.append(Payments(methodsName : "Visa", cardNumber : "****4242", monthYear : "05/2026", isCheck: false))
            UserShared.shared.paymentMethods.payments.append(Payments(methodsName : "Amex", cardNumber : "****4853", monthYear : "02/2022", isCheck: false))
            UserShared.shared.paymentMethods.payments.append(Payments(methodsName : "Cash on delivery", cardNumber : "", monthYear : "", isCheck: true))
            UserShared.shared.paymentMethods.payments.append(Payments(methodsName : "New Card", cardNumber : "", monthYear : "", isCheck: false))
        }else{
            UserShared.shared.paymentMethods.payments = []
            UserShared.shared.paymentMethods.payments.append(Payments(methodsName : "Cash on delivery", cardNumber : "", monthYear : "", isCheck: true))
            UserShared.shared.paymentMethods.payments.append(Payments(methodsName : "New Card", cardNumber : "", monthYear : "", isCheck: false))
        }
        self.configUI()
        self.sideMenuButton.addedTouchArea = 30
        sideMenuViewController()?.menuContainerView?.delegate = self
        sideMenuViewController()?.menuContainerView?.allowPanGesture = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.getUserAddressInfo()
        self.adressTextField.addTarget(self, action: #selector(self.editAdreesTapped), for: UIControlEvents.touchDown)
        if UserShared.shared.userSavedAddress != nil{
            self.adressTextField?.text = UserShared.shared.userSavedAddress?.address.components(separatedBy: ",").first ?? ""
            self.selectedAddressId = UserShared.shared.userSavedAddress?.id ?? ""
        }else{
            self.adressTextField?.text = UserShared.shared.currentAddress.components(separatedBy: ",").first
            self.selectedAddressId = ""
        }
        self.initialConfigurationForLocation()
        if UserShared.shared.isSubscriptionMode{
            self.onSubscriptionAction(UIButton())
        }else{
            self.onDemandAction(UIButton())
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SearchSortViewController{
            vc.userAddresses = self.userAddresses
            vc.currentLocation = self.currentLocation
            vc.locality = self.locality
            vc.subLocality = self.subLocality
            vc.selectedAddressId = self.selectedAddressId ?? ""
        }
    }
    
    @objc func editAdreesTapped(textField: UITextField) {
        if Connectivity.isConnectedToInternet{
            let actionSheet = self.storyboard?.instantiateViewController(withIdentifier: ReusableIdentifier.selectAddreesActionSheet) as! SelectAddreesActionSheet
            actionSheet.addresses = self.userAddresses
            actionSheet.delegate = self
            actionSheet.selectedAddressId = self.selectedAddressId ?? ""
            self.present(actionSheet, animated: true, completion: nil)
        }else{
            self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "ok")
        }
    }
}

//MARK:- Private methods
fileprivate extension HomeViewController {
    
    func getUserAddressInfo(){
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
            _ = WebAPIHandler.sharedHandler.getAddressPhones(id: userid, index: 1, success: { (response) in
                debugPrint(response)
                let addresses = (response["addresses"] as? [[String:Any]] ) ?? []
                self.userAddresses.removeAll()
                for address in addresses{
                    self.userAddresses.append(AddressStruct.init(data: address))
                }
            }, failure: { (error) in
                debugPrint(error)
            })
        }else{
            self.showAlertViewWithTitle(title:"", Message: Messages.internetUnavailable, CancelButtonTitle: "Ok")
        }
    }
    
    
    func configUI(){
        DispatchQueue.main.async {
            self.configLocationSearchField()
            self.buttonFindRestaurants.layer.cornerRadius = 5
            self.configHowItWorksViews(view: self.viewInMenu, label: self.numberOneLabel)
            self.configHowItWorksViews(view: self.viewInTasteBuds, label: self.numberTwoLabel)
            self.configHowItWorksViews(view: self.viewInDoorstep, label: self.numberThreeLabel)
        }
        
        //Making sliding view to center of demand button.
        centerXForSLidingView = slidingView.centerXAnchor.constraint(equalTo: buttonDemandMode.centerXAnchor, constant: 0)
        centerXForSLidingView.isActive = true
    }
    
    
    func getUserDetail(){
        let user = DataBaseHelper.shared.getData().first
        let token = user?.tokenId ?? ""
        var userid = String()
        var email = String()
        do{
            let jwt = try decode(jwt: token)
            if jwt.expired{
            }else{
                let body = jwt.body
                userid = (body["uid"] as? String) ?? ""
                email = (body["uemail"] as? String) ?? ""
            }
        }catch{
            print("Data not fetched")
        }
        if Connectivity.isConnectedToInternet{
            self.showHud(message: "please wait..")
            _ = WebAPIHandler.sharedHandler.getUserDetail(token: token,uid : userid, success: { (response) in
                debugPrint(response)
                self.hideHud()
                let data = (((response["users"] as? [[String:Any]])?.first)) ?? [:]
                let firstName = ((data["firstName"] as? String) ?? " ").uppercased()
                let lastName = ((data["lastName"] as? String) ?? " ").uppercased()
                let profilePic = (data["avatar"] as? String) ?? " "
                DispatchQueue.main.async {
                    let imageView = UIImageView()
                    imageView.sd_setImage(with: URL(string: (data["avatar"] as? String) ?? " " ), placeholderImage: nil)
                    UserShared.shared.user.userImage = imageView.image ?? nil
                }
                UserShared.shared.user.firstName = firstName
                UserShared.shared.user.lastName = lastName
                UserShared.shared.user.imageName =  profilePic
                
                UserShared.shared.user.email = email
                let weightProfile = (data["weightProfile"] as? [String:Any]) ?? [:]
                self.prepareDataSource(profile : weightProfile)
            }) { (error) in
                self.hideHud()
                debugPrint(error)
            }
        }else{
            self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "Ok")
        }
    }
    
    func prepareDataSource(profile : [String:Any]){
        let gender = (profile["gender"] as? String) ?? " "
        let height = ((profile["height"] as? NSNumber) ?? 0).intValue
        let weight = ((profile["weight"] as? NSNumber) ?? 0).intValue
        let bmi = ((((profile["bmi"] as? [String:Any]) ?? [:])["value"] as? NSNumber) ?? 0).stringValue
        let weightGoal = (profile["weightGoal"] as? String) ?? " "
        let weightRecommend = (profile["weightRecommendation"] as? String) ?? "lose"
        let calorieAllowance = ((profile["dailyCalorieAllowance"] as? NSNumber) ?? 0).stringValue
        let activityLevel = (profile["activityLevel"] as? [String:Any]) ?? [:]
        let activityId = (activityLevel["id"] as? String ) ?? " "
        let userAge = ((profile["age"] as? NSNumber) ?? 0).intValue
        UserShared.shared.user.weightGoals = weightGoal
        UserShared.shared.user.activityLevelID = activityId
        UserShared.shared.user.gender = gender
        UserShared.shared.user.weight = weight
        UserShared.shared.user.height = height
        UserShared.shared.user.age = userAge
        UserShared.shared.user.weightRecommendation = weightRecommend
        UserShared.shared.user.dailyCaloryAllowance = calorieAllowance
        UserShared.shared.user.bmiClassification = (((profile["bmi"] as? [String:Any]) ?? [:])["classification"] as? String) ?? ""
        UserShared.shared.user.bmiValue = bmi
        UserShared.shared.user.activityLevel = (activityLevel["name"] as? String) ?? ""
    }
    
    
    //Configure how it works ui
    func configHowItWorksViews(view :UIView,label:UILabel) {
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 12.5
        view.layer.cornerRadius = 5
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.borderedGray.cgColor
    }
    
    //Configure ui for textfield
    func configLocationSearchField(){
        //Adding rightside image on textField
        self.adressTextField.rightViewMode = .always
        self.adressTextField.rightView?.contentMode = .left
        let viewAccessory = UIView.init(frame: CGRect(x:0,y:0,width:30,height:30))
        viewAccessory.backgroundColor = UIColor.white
        let buttonLocation = UIButton.init()
        buttonLocation.setImage(UIImage.init(named: "currentLoc"), for: .normal)
        buttonLocation.backgroundColor = UIColor.white
        buttonLocation.frame = CGRect.init(x: 0, y: 5, width: 20, height: 20)
        buttonLocation.addTarget(self, action:#selector(self.tapOnCurrentLoc(_:)), for: .touchUpInside)
        viewAccessory.addSubview(buttonLocation)
        self.adressTextField.rightViewMode = .always
        self.adressTextField.rightView = viewAccessory
        self.adressTextField.rightView?.backgroundColor = UIColor.white
        self.adressTextField.text = ""
        self.adressTextField.layer.borderWidth = 1
        self.adressTextField.layer.borderColor = UIColor.white.cgColor
        self.adressTextField.layer.cornerRadius = 3
        self.adressTextField.layer.masksToBounds = false
        self.adressTextField.layer.shadowRadius = 40.0
        self.adressTextField.layer.shadowColor = UIColor.lightGray.cgColor
        self.adressTextField.layer.shadowOffset = CGSize(width: 1.0, height: 5.0)
        self.adressTextField.layer.shadowOpacity = 1.0
    }
    
    @objc func tapOnCurrentLoc(_ button: UIButton) {
        if Connectivity.isConnectedToInternet{
            self.showHud(message: nil)
            ServiceManager.shared.getAddressForLatLngByGoogle(latitude:"\(self.currentLocation.coordinate.latitude)" , longitude: "\(self.currentLocation.coordinate.longitude)") { (address) in
                self.subLocality =  (address?.subLocality) ?? ""
                self.locality = (address?.locality) ?? ""
                self.hideHud()
                if !self.subLocality.isEmpty && !self.locality.isEmpty{
                    UserShared.shared.googleCurrentAddress = address
                    UserShared.shared.currentAddress = "\(self.subLocality), \(self.locality)"
                    self.adressTextField.text = "\(self.subLocality)"
                }
                UserShared.shared.userSavedAddress = nil
                self.selectedAddressId = nil
                UserShared.shared.currentLocation = self.currentLocation
            }
        }else{
            self.showAlertViewWithTitle(title: "", Message:Messages.internetUnavailable, CancelButtonTitle: "ok")
        }
    }
    
    //Config permission related changes
    func initialConfigurationForLocation(){
        locationManager.delegate = self
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                locationManager.requestAlwaysAuthorization()
                debugPrint("No access")
            case .authorizedAlways, .authorizedWhenInUse:
                debugPrint("Access")
                currentLocation = locationManager.location ?? CLLocation()
                locationManager.desiredAccuracy = kCLLocationAccuracyBest;
                locationManager.distanceFilter = 25.0 ;
                locationManager.startUpdatingLocation()
                locationManager.startUpdatingHeading()
            }
        }else{
            self.showAlertViewWithTitle(title: "Enable Location", Message: "Please enable your location services", CancelButtonTitle: "Ok")
        }
    }
    
    //Updating the UI
    func updateLocationAddressUI(lat:CLLocationDegrees, lon : CLLocationDegrees){
        self.adressTextField.text = "\(self.subLocality), \(self.locality)"
        UserShared.shared.currentAddress = "\(self.subLocality), \(self.locality)"
        UserShared.shared.currentLocation = self.currentLocation
    }
}


//MARK:- UITextfield delegate methods
extension HomeViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK:-  UIButton action methods
extension HomeViewController {
    
    @IBAction func findRestaurantAction(_ sender: UIButton) {
        if (self.adressTextField.text?.isEmpty)!{
            self.showAlertViewWithTitle(title: "Message", Message: "Please fill the address field", CancelButtonTitle: "Ok")
        }else{
            self.performSegue(withIdentifier: "searchSortSegue", sender: nil)
        }
    }
    
    @IBAction func onDemandAction(_ sender: UIButton) {
        //Moving sliding view indicator to center of Demand mode button
        centerXForSLidingView.isActive = false
        centerXForSLidingView = slidingView.centerXAnchor.constraint(equalTo: buttonDemandMode.centerXAnchor, constant: 0)
        centerXForSLidingView.isActive = true
        UserShared.shared.isSubscriptionMode = false
        UserShared.shared.userMode = "on_demand"
        UIView.animate(withDuration: 0.2, animations: {
            self.slidingView.superview?.layoutIfNeeded()
        }, completion: nil)
        
        self.buttonDemandMode.setTitleColor(UIColor.darkRed, for: .normal)
        self.buttonSubscriptionMode.setTitleColor(UIColor.disabledGray, for: .normal)
    }
    
    @IBAction func onSubscriptionAction(_ sender: UIButton) {
        //Moving sliding view indicator to center of Subscription mode button
        centerXForSLidingView.isActive = false
        UserShared.shared.isSubscriptionMode = true
        UserShared.shared.userMode = "subscription"
        centerXForSLidingView = slidingView.centerXAnchor.constraint(equalTo: buttonSubscriptionMode.centerXAnchor, constant: 0)
        centerXForSLidingView.isActive = true
        
        UIView.animate(withDuration: 0.2, animations: {
            self.slidingView.superview?.layoutIfNeeded()
        }, completion: nil)
        
        self.buttonSubscriptionMode.setTitleColor(UIColor.darkRed, for: .normal)
        self.buttonDemandMode.setTitleColor(UIColor.disabledGray, for: .normal)
    }
    
    
    @IBAction func backToHome(_ segue: UIStoryboardSegue) {
        //Coming back to home screen from unwind segue
    }
    
    @IBAction func toogleSideMenu(_ sender: UIButton) {
        NotificationCenter.default.post(name:  KVSideMenu.Notifications.toggleLeft, object: self)
    }
}

//MARK:- Core location manager delegate
extension DeliveryAddressTableCell: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            currentLocation = locations.first!
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            currentLocation = locationManager.location ?? CLLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            locationManager.distanceFilter = 25.0;
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
    }
}


//MARK:- KVRootBaseSideMenu Delegate

extension HomeViewController : KVRootBaseSideMenuDelegate {
    
    func willOpenSideMenuView(_ sideMenuView: KVMenuContainerView, state: KVSideMenu.SideMenuState) {
        print(#function)
    }
    
    func didOpenSideMenuView(_ sideMenuView: KVMenuContainerView, state: KVSideMenu.SideMenuState){
        print(#function)
    }
    
    func willCloseSideMenuView(_ sideMenuView: KVMenuContainerView, state: KVSideMenu.SideMenuState){
        print(#function)
    }
    
    func didCloseSideMenuView(_ sideMenuView: KVMenuContainerView, state: KVSideMenu.SideMenuState){
        print(#function)
    }
}

//MARK:- Select Addrees Action Sheet Delegate
extension HomeViewController : SelectAddreesActionSheetDelegate{
    func didSelectAddressType(cell: AdressActionSheetCell, index: Int) {
        if index == 0{
            if Connectivity.isConnectedToInternet{
                self.performSegue(withIdentifier: "editAddressSegue", sender: nil)
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
            self.adressTextField.text = cell.dataSource.address.components(separatedBy: ",").first ?? ""
        }
    }
}

