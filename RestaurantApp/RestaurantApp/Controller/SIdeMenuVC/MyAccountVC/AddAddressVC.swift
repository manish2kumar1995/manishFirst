//
//  AddAddressVC.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 11/26/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
import GoogleMaps
import JWTDecode

protocol AddAddressVCDelegate {
    func didSelectAddress(address : CuisineData, section : Int)
}

class AddAddressVC: BaseViewController {
    
    //MARK:- IB Outlet
    @IBOutlet weak var addressTableView: UITableView!
    @IBOutlet weak var appartmentTextField: TextField!
    @IBOutlet weak var addressTextField: PaddingTextfield!
    @IBOutlet weak var labelLocationName: UILabel!
    @IBOutlet weak var pinIconImageVew: UIImageView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var labelCity: UILabel!
    @IBOutlet weak var labelStreet: UILabel!
    @IBOutlet weak var addressTypeTextField: TextField!
    
    //Custom variables
    var section : Int?
    var currentLocation = CLLocation()
    var locationManager = CLLocationManager()
    var subLocality = String()
    var locality = String()
    var selectedCoordinates = CLLocation()
    var places = [Places]() {
        didSet { self.addressTableView.reloadData();self.addressTableView.isHidden = false }
    }
    let marker = GMSMarker()
    var selectedPlace : CLPlacemark?
    var matchingItems = [CLPlacemark]()
    var place : Places?
    var googleAddress : Address?
    var homeOfficeOption = ["Home", "Office"]
    let pickerView = UIPickerView()
    var delegate : AddAddressVCDelegate?
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.addressTypeTextField.text = "Home"
        self.appartmentTextField.tag = 1
        self.addressTypeTextField.tag = 2
        self.addressTextField.tag = 3
        self.appartmentTextField.delegate = self
        self.addressTypeTextField.delegate = self
        self.addressTextField.delegate = self
        self.addressTypeTextField.inputView = self.pickerView
        initialConfigurationForLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        initialUIConfiguration()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.view.endEditing(true)
    }
    
    //MARK:- IBACtion
    @IBAction func addButtonAction(_ sender: Any) {
        if (self.addressTypeTextField.text?.isEmpty)!{
            self.showAlertViewWithTitle(title: "", Message: "Please enter address type", CancelButtonTitle: "Ok")
        }else if (self.appartmentTextField.text?.isEmpty)!{
            self.showAlertViewWithTitle(title: "", Message: "Please enter apartment number", CancelButtonTitle: "Ok")
        }else if (self.addressTextField.text?.isEmpty)!{
            self.showAlertViewWithTitle(title: "", Message: "Please enter address ", CancelButtonTitle: "Ok")
        }else{
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
            
            let coordinates = "\(self.googleAddress?.address?.coordinate.latitude ?? 0.0),\(self.googleAddress?.address?.coordinate.longitude ?? 0.0)"
            let address = "\(self.appartmentTextField.text ?? ""), \(self.subLocality), \(self.locality)"
            let param = ["aptNo": "\(self.appartmentTextField.text ?? "")","address": "\(self.subLocality)","city": "\(self.googleAddress?.address?.locality ?? self.locality)","postcode": "","countryCode": "QA","coordinates": coordinates,"type": "\(self.addressTypeTextField.text?.lowercasingFirstLetter() ?? "home")"]
            self.showHud(message: "Saving address..")
            _ = WebAPIHandler.sharedHandler.addAddressForDeliveryid(id: userid, index: 1, param: param, success: { (response) in
                debugPrint(response)
                self.hideHud()
                let meta = (response["meta"] as? [String:Any]) ?? [:]
                let message = (meta["message"] as? String) ?? ""
                if message.isEmpty{
                    let addresses = (response["addresses"] as? [[String:Any]])?.first ?? [:]
                    var cuisineAddress = CuisineData(data: [:], index: 0)
                    cuisineAddress.restaurantTitle = address
                    cuisineAddress.id = (addresses["id"] as? String) ?? ""
                    self.delegate?.didSelectAddress(address: cuisineAddress, section :self.section ?? 0)
                    self.navigationController?.popViewController(animated: true)
                }else{
                    self.showAlertViewWithTitle(title: "", Message: message, CancelButtonTitle: "Ok")
                }
            }, failure: { (error) in
                debugPrint(error)
                self.hideHud()
            })
            
        }
    }
    
    @IBAction func buttonCurrentLocAction(_ sender: Any) {
        
        if Connectivity.isConnectedToInternet{
            //self.showHud(message: nil)
            
            ServiceManager.shared.getAddressForLatLngByGoogle(latitude:"\(self.currentLocation.coordinate.latitude)" , longitude: "\(self.currentLocation.coordinate.longitude)") { (address) in
                if address != nil{
                    
                    self.subLocality =  (address?.subLocality) ?? ""
                    self.locality = (address?.locality) ?? ""
                    self.hideHud()
                    self.googleAddress = address
                    self.updateLocationAddressUI(lat: self.currentLocation.coordinate.latitude, lon: self.currentLocation.coordinate.longitude)
                }
            }
        }else{
            self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "oK")
        }
    }
    
    
    //Updating the UI
    func updateLocationAddressUI(lat:CLLocationDegrees, lon : CLLocationDegrees){
        let currentZoom = self.mapView.camera.zoom;
        self.addressTextField.text = self.subLocality
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: currentZoom)
        self.selectedCoordinates = CLLocation.init(latitude: lat, longitude: lon)
        
        if !self.subLocality.isEmpty && !self.locality.isEmpty{
            self.labelLocationName.text = "\(self.subLocality), \(self.locality)"
        }
        self.mapView.camera = camera
        self.labelStreet.text = self.subLocality
        self.labelCity.text = self.locality
    }
}

//MARK:- Custom Methods
extension AddAddressVC{
    
    //Config permission related changes
    func initialConfigurationForLocation(){
        
        DispatchQueue.main.async{
            self.addressTextField.layer.shadowColor = UIColor.darkGray.cgColor
            self.addressTextField.layer.shadowOffset = CGSize(width: 0.0, height: 1.0);
            self.addressTextField.layer.shadowOpacity = 1;
            self.addressTextField.layer.shadowRadius = 10.0;
            
            self.appartmentTextField.layer.shadowColor = UIColor.darkGray.cgColor
            self.appartmentTextField.layer.shadowOffset = CGSize(width: 0.0, height: 1.0);
            self.appartmentTextField.layer.shadowOpacity = 1;
            self.appartmentTextField.layer.shadowRadius = 10.0;
            
            self.addressTypeTextField.layer.shadowColor = UIColor.darkGray.cgColor
            self.addressTypeTextField.layer.shadowOffset = CGSize(width: 0.0, height: 1.0);
            self.addressTypeTextField.layer.shadowOpacity = 1;
            self.addressTypeTextField.layer.shadowRadius = 10.0;
        }
        
        locationManager.delegate = self
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                locationManager.requestAlwaysAuthorization()
                self.showAlertViewWithTitle(title: "Enable Location", Message: "Please enable your location services", CancelButtonTitle: "Ok")
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
    
    
    func initialUIConfiguration() {
        self.addressTableView.isHidden = true
        self.addressTableView.delegate = self
        self.mapView.delegate = self
        self.addressTableView.dataSource = self
        self.setNavigation(title: "Add Address")
        
        let lat = (UserShared.shared.currentLocation?.coordinate.latitude == nil) ? self.currentLocation.coordinate.latitude : UserShared.shared.currentLocation?.coordinate.latitude
        let long = (UserShared.shared.currentLocation?.coordinate.longitude == nil) ? self.currentLocation.coordinate.longitude : UserShared.shared.currentLocation?.coordinate.longitude
        let camera = GMSCameraPosition.camera(withLatitude: lat!, longitude: long!, zoom: 15.0)
        self.mapView.camera = camera
        if UserShared.shared.userSavedAddress != nil{
            self.addressTextField.text = "\(UserShared.shared.userSavedAddress?.address ?? "")"
            self.labelLocationName.text = "\(UserShared.shared.userSavedAddress?.address.components(separatedBy: ",").first ?? "")"
        }else if !UserShared.shared.currentAddress.isEmpty{
            let addressArray = UserShared.shared.currentAddress.components(separatedBy: ",")
            self.labelLocationName.text = addressArray[0]
            if !(addressArray[1].isEmpty) && !(addressArray[2].isEmpty){
                self.addressTextField.text = "\(addressArray[1]), \(addressArray[2])"
            }
        }else{
            ServiceManager.shared.getAddressForLatLngByGoogle(latitude:"\(self.currentLocation.coordinate.latitude)" , longitude: "\(self.currentLocation.coordinate.longitude)") { (address) in
                self.subLocality =  (address?.subLocality) ?? ""
                self.locality = (address?.locality) ?? ""
                self.googleAddress = address
                self.hideHud()
                self.updateLocationAddressUI(lat: self.currentLocation.coordinate.latitude, lon: self.currentLocation.coordinate.longitude)
            }
        }
    }
}

//MARK:- Core location manager delegate
extension AddAddressVC: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            debugPrint(currentLocation == locations.first)
            currentLocation = locations.first!
            debugPrint(currentLocation.coordinate)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            currentLocation = locationManager.location!
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            locationManager.distanceFilter = 25.0;
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
    }
}

//MARK:- UITextfield delegate
extension AddAddressVC: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 3{
            if (self.place == nil){
                let searchBarText = (textField.text) ?? ""
                if Connectivity.isConnectedToInternet{
                    let parameters = GooglePlacesAutocompleteContainer.shared.getParameters(for: searchBarText)
                    if !((parameters["input"]) ?? "").isEmpty{
                        self.showHud(message: "Please wait...")
                        GooglePlacesRequestHelpers.getPlaces(with: parameters) {
                            self.hideHud()
                            self.places = $0
                        }
                    }
                }else{
                    self.view.endEditing(true)
                    self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "ok")
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 3{
            if self.place == nil{
                let searchBarText = (textField.text) ?? ""
                
                if Connectivity.isConnectedToInternet{
                    let parameters = GooglePlacesAutocompleteContainer.shared.getParameters(for: searchBarText)
                    GooglePlacesRequestHelpers.getPlaces(with: parameters) {
                        self.places = $0
                    }
                }else{
                    self.view.endEditing(true)
                    self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "ok")
                }
            }
            return true
        }
        if textField.tag == 1{
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

//MARK:- Marker drag delegate
extension AddAddressVC : GMSMapViewDelegate {
    
    func mapView (_ mapView: GMSMapView, didEndDragging didEndDraggingMarker: GMSMarker) {
        self.showHud(message: nil)
        ServiceManager.shared.getAddressForLatLngByGoogle(latitude:"\(didEndDraggingMarker.position.latitude)" , longitude: "\(didEndDraggingMarker.position.longitude)") { (address) in
            self.subLocality =  (address?.subLocality) ?? ""
            self.locality = (address?.locality) ?? ""
            self.hideHud()
            self.googleAddress = address
            self.updateLocationAddressUI(lat: didEndDraggingMarker.position.latitude, lon: didEndDraggingMarker.position.longitude)
        }
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        let coordinate = mapView.projection.coordinate(for: mapView.center)
        
        if Connectivity.isConnectedToInternet{
            
            ServiceManager.shared.getAddressForLatLngByGoogle(latitude:"\(coordinate.latitude)" , longitude: "\(coordinate.longitude)") { (address) in
                if address != nil{
                    self.subLocality =  (address?.subLocality) ?? ""
                    self.locality = (address?.locality) ?? ""
                    self.googleAddress = address
                    self.updateLocationAddressUI(lat: coordinate.latitude, lon: coordinate.longitude)
                }else{
                    self.subLocality =  (address?.subLocality) ?? ""
                    self.locality = (address?.locality) ?? ""
                    self.updateLocationAddressUI(lat: self.selectedCoordinates.coordinate.latitude, lon: self.selectedCoordinates.coordinate.longitude)
                    self.showAlertViewWithTitle(title: "Message", Message: "Error while fetching address", CancelButtonTitle: "oK")
                }
            }
        }else{
            self.hideHud()
            self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "oK")
        }
    }
}

//MARK:- UITableview datasource & delegate
extension AddAddressVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        let place = places[indexPath.row]
        
        cell?.textLabel?.text = place.mainAddress
        cell?.detailTextLabel?.text = place.secondaryAddress
        cell?.accessoryType = .disclosureIndicator
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.place = self.places[indexPath.row]
        self.addressTableView.isHidden = true
        self.addressTextField.resignFirstResponder()
        self.showHud(message: nil)
        
        ServiceManager.shared.getLocationFrom(placeId: (place!.id)) { (response) in
            let currentZoom = self.mapView.camera.zoom;
            self.addressTextField.text = self.subLocality
            let camera = GMSCameraPosition.camera(withLatitude: (response?.lattitude)!, longitude: (response?.longitude)!, zoom: currentZoom)
            self.mapView.camera = camera
            self.place = nil
        }
        self.hideHud()
    }
}


//MARK:- Picker view delegate
extension AddAddressVC : UIPickerViewDelegate, UIPickerViewDataSource{
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
        self.addressTypeTextField.text = self.homeOfficeOption[row]
    }
}





