//
//  EditAdressViewController.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 11/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import GooglePlaces
import MapKit

class EditAdressViewController: BaseViewController {
    
    //MARK:- IBOutlets
    @IBOutlet weak var labelCity: UILabel!
    @IBOutlet weak var containerVieHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelStreet: UILabel!
    @IBOutlet weak var buttonContinueHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var locationTextField: TextField!
    @IBOutlet weak var addressTableView: UITableView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var labelLocationName: UILabel!
    
    //Custom variables
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialConfigurationForLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        initialUIConfiguration()
        self.addKeyBoardListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.view.endEditing(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    
}

//MARK:- IB Action
extension EditAdressViewController{
    
    @IBAction func buttonCurrentLocAction(_ sender: Any) {
        if Connectivity.isConnectedToInternet{
            
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
    
    @IBAction func buttonContinueAction(_ sender: UIButton) {
        
        if !self.subLocality.isEmpty && !self.locality.isEmpty{
            UserShared.shared.currentAddress = "\(self.subLocality), \(self.locality)"
            UserShared.shared.googleCurrentAddress = self.googleAddress
        }
        UserShared.shared.userSavedAddress = nil
        UserShared.shared.currentLocation = self.selectedCoordinates
        UserShared.shared.didChangeLocation = true
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK:- Custom Methods
extension EditAdressViewController {
    // Configuring UI
    func initialUIConfiguration() {
        self.addressTableView.isHidden = true
        self.addressTableView.delegate = self
        self.mapView.delegate = self
        self.addressTableView.dataSource = self
        self.setNavigation(title: "Edit your address")
        
        let lat = (UserShared.shared.currentLocation?.coordinate.latitude == nil) ? self.currentLocation.coordinate.latitude : UserShared.shared.currentLocation?.coordinate.latitude
        let long = (UserShared.shared.currentLocation?.coordinate.longitude == nil) ? self.currentLocation.coordinate.longitude : UserShared.shared.currentLocation?.coordinate.longitude
        let camera = GMSCameraPosition.camera(withLatitude: lat!, longitude: long!, zoom: 15.0)
        self.mapView.camera = camera
        
        if !UserShared.shared.currentAddress.isEmpty{
            if UserShared.shared.userSavedAddress != nil{
                self.locationTextField.text = UserShared.shared.userSavedAddress?.address ?? ""
            }else{
                let addressArray = UserShared.shared.currentAddress.components(separatedBy: ",")
                for index in 0..<addressArray.count{
                    if index == 0{
                        self.labelLocationName.text = addressArray[0]
                    }
                    if index == 1{
                        self.locationTextField.text = "\(addressArray[1])"
                    }
                    if index == 2{
                        self.locationTextField.text = "\(addressArray[1]), \(addressArray[2])"
                    }
                }
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
    
    //Config permission related changes
    func initialConfigurationForLocation(){
        
        DispatchQueue.main.async{
            self.locationTextField.layer.shadowColor = UIColor.darkGray.cgColor
            self.locationTextField.layer.shadowOffset = CGSize(width: 0.0, height: 1.0);
            self.locationTextField.layer.shadowOpacity = 1;
            self.locationTextField.layer.shadowRadius = 30.0;
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
    
    //Updating the UI
    func updateLocationAddressUI(lat:CLLocationDegrees, lon : CLLocationDegrees){
        let currentZoom = self.mapView.camera.zoom;
        self.locationTextField.text = self.subLocality
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: currentZoom)
        self.selectedCoordinates = CLLocation.init(latitude: lat, longitude: lon)
        
        if !self.subLocality.isEmpty && !self.locality.isEmpty{
            self.labelLocationName.text = "\(self.subLocality), \(self.locality)"
        }
        self.mapView.camera = camera
        self.labelStreet.text = self.subLocality
        self.labelCity.text = self.locality
    }
    
    //Adding keyboard listener
    func addKeyBoardListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil);
    }
    
    //Appearence of keyboard will trigger this method
    @objc func keyboardWillShow(_ notification: Notification) {
        self.buttonContinueHeightConstraint.constant = 0.0
        self.containerView.isHidden = true
        self.containerVieHeightConstraint.constant = 0.0
    }
    
    //Disappearence of keyboard will trigger this method
    @objc func keyboardWillHide(_ notification: Notification) {
        self.buttonContinueHeightConstraint.constant = 65
        self.containerView.isHidden = false
        self.containerVieHeightConstraint.constant = 75.0
    }
}

//MARK:- Core location manager delegate
extension EditAdressViewController: CLLocationManagerDelegate{
    
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
extension EditAdressViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
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
}

//MARK:- Marker drag delegate
extension EditAdressViewController : GMSMapViewDelegate {
    
    func mapView (_ mapView: GMSMapView, didEndDragging didEndDraggingMarker: GMSMarker) {
        self.showHud(message: nil)
        ServiceManager.shared.getAddressForLatLngByGoogle(latitude:"\(didEndDraggingMarker.position.latitude)" , longitude: "\(didEndDraggingMarker.position.longitude)") { (address) in
            //        print(address)
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
extension EditAdressViewController : UITableViewDelegate, UITableViewDataSource{
    
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
        self.locationTextField.resignFirstResponder()
        self.showHud(message: nil)
        
        ServiceManager.shared.getLocationFrom(placeId: (place!.id)) { (response) in
            let currentZoom = self.mapView.camera.zoom;
            self.locationTextField.text = self.subLocality
            let camera = GMSCameraPosition.camera(withLatitude: (response?.lattitude)!, longitude: (response?.longitude)!, zoom: currentZoom)
            self.mapView.camera = camera
            self.place = nil
        }
        self.hideHud()
    }
}


