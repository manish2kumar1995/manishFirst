//
//  DeliveryAddressTableCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 20/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
import CoreLocation
import MRCountryPicker

//MARK:- Protocols for various cell events
protocol DeliveryAddressTableCellDelegate {
    func didTapOnTextField(currentLoc : CLLocation)
    func didShowInternetAlert()
}

class DeliveryAddressTableCell: UITableViewCell {
    
    //MARK:- IB outlets
    @IBOutlet weak var adressTextField: TextField!
    @IBOutlet weak var homeTextField: TextField!
    @IBOutlet weak var aptNumberTextField: TextField!
    @IBOutlet weak var viewInCell: UIView!
    
    //Custom variables
    var homeOfficeOption = ["Home", "Office"]
    let pickerView = UIPickerView()
    var currentLocation = CLLocation()
    var locationManager = CLLocationManager()
    var delegate : DeliveryAddressTableCellDelegate?
    var subLocality = String()
    var locality = String()
    var countryPicker = MRCountryPicker()
    var coountryCode : String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialConfigurationForLocation()
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.homeTextField.text = "Home"
        setDelegate()
        if UserShared.shared.userSavedAddress != nil{
            self.aptNumberTextField.text = UserShared.shared.userSavedAddress?.aptNo ?? ""
            self.homeTextField.text = UserShared.shared.userSavedAddress?.type.capitalizingFirstLetter()
        }
        self.adressTextField.tag = 1
        self.homeTextField.tag = 2
        self.aptNumberTextField.delegate = self
        
        self.homeTextField.inputView = self.pickerView
        countryPicker.countryPickerDelegate = self
        //Adding rightside image on textField
        self.adressTextField.rightViewMode = .always
        self.adressTextField.rightView?.contentMode = .left
        let viewAccessory = UIView.init(frame: CGRect(x:0,y:0,width:35,height:35))
        viewAccessory.clipsToBounds = true
        
        let buttonLocation = UIButton.init()
        buttonLocation.setImage(UIImage.init(named: "colorCurrentLoc"), for: .normal)
        buttonLocation.addTarget(self, action:#selector(self.tapOnCurrentLoc(_:)), for: .touchUpInside)
        buttonLocation.frame = CGRect.init(x: 0, y: 5, width: 25, height: 25)
        viewAccessory.addSubview(buttonLocation)
        self.adressTextField.rightView = viewAccessory
        
        DispatchQueue.main.async {
            self.adressTextField.addTarget(self, action: #selector(self.myTargetFunction), for: UIControlEvents.touchDown)
            self.contentView.layoutIfNeeded()
            self.viewInCell.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 5.0)
            self.viewInCell.addBorder(toSide: .left, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
            self.viewInCell.addBorder(toSide: .right, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
            self.viewInCell.addBorder(toSide: .bottom, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
            self.contentView.layoutSubviews()
        }
    }
    
    func configVariousCode(){
        if UserShared.shared.userSavedAddress != nil{
            self.coountryCode = UserShared.shared.userSavedAddress?.countryCode
        }else{
        countryPicker.setCountryByName((UserShared.shared.currentAddress.components(separatedBy: ",").last ?? "").trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }
    
    func setDelegate(){
        self.adressTextField.delegate = self
        self.aptNumberTextField.delegate = self
        self.homeTextField.delegate = self
    }
    
    
    //To pritn Current location
    @objc func tapOnCurrentLoc(_ button: UIButton) {
        if Connectivity.isConnectedToInternet{
            ServiceManager.shared.getAddressForLatLngByGoogle(latitude:"\(self.currentLocation.coordinate.latitude)" , longitude: "\(self.currentLocation.coordinate.longitude)") { (address) in
                self.subLocality =  (address?.subLocality) ?? ""
                self.locality = (address?.locality) ?? ""
                UserShared.shared.googleCurrentAddress = address
                self.adressTextField.text = "\(self.subLocality), \(self.locality)"
                UserShared.shared.currentAddress = "\(self.subLocality), \(self.locality)"
                UserShared.shared.currentLocation = self.currentLocation
            }
        }else{
            self.delegate?.didShowInternetAlert()
        }
    }
    
    //To nevigate after tapping textField
    @objc func myTargetFunction(textField: UITextField) {
        self.aptNumberTextField.resignFirstResponder()
        self.adressTextField.resignFirstResponder()
        self.homeTextField.resignFirstResponder()
        self.delegate?.didTapOnTextField(currentLoc : self.currentLocation)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

//MARK:- Custom methods
extension DeliveryAddressTableCell {
    
    //Asking for permission
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
        }
    }
    
    func updateLocationAddressUI(lat:CLLocationDegrees, lon : CLLocationDegrees){
        self.adressTextField.text = "\(self.subLocality), \(self.locality)"
        UserShared.shared.currentAddress = "\(self.subLocality), \(self.locality)"
    }
}

//MARK:- UI textfield delegate
extension DeliveryAddressTableCell : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 1{
            return false
        }else{
            return true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.tag == 2{
            //CardNumberTextField
            let maxLength = 16
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }else{
            return true
        }
    }
}

//MARK:- Picker view delegate
extension DeliveryAddressTableCell : UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return homeOfficeOption.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return homeOfficeOption[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.homeTextField.text = self.homeOfficeOption[row]
    }
}

//MARK:- Core location manager delegate
extension HomeViewController: CLLocationManagerDelegate {
    
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

//MARK:- Country picker delegate
extension DeliveryAddressTableCell : MRCountryPickerDelegate{
    func countryPhoneCodePicker(_ picker: MRCountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        self.coountryCode = countryCode
    }
}



