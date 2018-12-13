//
//  SearchSortViewController.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 28/08/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
import HCSStarRatingView
import CoreLocation

class SearchSortViewController: BaseViewController {
    
    //Interface builder outkets
    @IBOutlet weak var searchResultLabel: UILabel!
    @IBOutlet weak var filterButtonOutlet: UIButton!
    @IBOutlet weak var sortButtonOutlet: UIButton!
    @IBOutlet weak var searchRestaurantTableView: UITableView!
    @IBOutlet weak var buttonSubscriptionMode: UIButton!
    @IBOutlet weak var buttonDemandMode: UIButton!
    @IBOutlet weak var slidingView: UIView!
    @IBOutlet weak var buttonModify: UIButton!
    @IBOutlet weak var noResultView: UIView!
    
    
    //Navigation Segues Identfiers
    fileprivate struct Segues {
        static let toRestaurantMenuScreen = "restauranDetailSegue"
        static let editAddressSegue = "editAddressSegue"
        static let searchSortTableCell = "SearchSortTableCell"
        static let subscriptionSegue = "subscriptionSegue"
        static let selectAddreesActionSheet = "SelectAddreesActionSheet"
    }
    var textField : TextField?
    var userAddresses = [AddressStruct]()
    var currentLocation = CLLocation()
    var subLocality = String()
    var locality = String()
    var selectedAddressId : String?
    var centerXForSLidingView  :NSLayoutConstraint!
    var cuisineData = [String]()
    var mealTypeData = [String]()
    var selectedElement = [String]()
    var dictData = [Int:[String]]()
    
    //Preparing Static DataSource
    var dataSource = [RestaurantLists]()
    var filterData = [RestaurantLists]()
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(SearchSortViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        self.noResultView.isHidden = true
        self.sortButtonOutlet.isHidden = true
        self.filterButtonOutlet.isHidden = true
        if #available(iOS 10.0, *) {
            self.searchRestaurantTableView.refreshControl = refreshControl
        }else{
            self.searchRestaurantTableView.addSubview(refreshControl)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RestaurantMenuVC{
            let data = sender! as! RestaurantLists
            vc.minimumOrderValue = data.minimumOrderValue
            vc.restaurantDetail = data
            vc.userAddresses = self.userAddresses
        }
        
        if let vc = segue.destination as? SubscriptionPlanTypeVC{
            let data = sender! as! RestaurantLists
            vc.restaurantId = data.id
            vc.restaurantDetail = data
        }
        
        if let vc = segue.destination as? SortByViewController{
            vc.titleArray = ["Distance - Nearest to Furthest","Distance - Furthest to Nearest","Rating - High to Low","Rating - Low to High"]
            vc.titleIconArray = ["borderedMarker","borderedMarker", "borderedStar","borderedStar"]
            vc.delegate = self
        }
        
        if let vc = segue.destination as? FilterByViewController{
            vc.objectsArray = [FilterObject(sectionName: "CUSINES", sectionImage:"filterCusines", sectionObjects : self.cuisineData),FilterObject(sectionName: "MEAL TYPES", sectionImage:"menuBordered", sectionObjects: self.mealTypeData)]
            vc.delegate = self
            vc.restaurantsDataSource = self.dataSource
            vc.selectedElement = self.selectedElement
            vc.dataDictionary = self.dictData
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //To search restaurant and show hud only for one time
        if UserShared.shared.didChangeLocation{
            if Connectivity.isConnectedToInternet {
                self.callAPIForSearchRestaurants()
            }else{
                self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "ok")
            }
        }
        UserShared.shared.myBasketModel.myBasketData = []
        UserShared.shared.myBasketModel.totalQAR = 0.0
        UserShared.shared.myBasketModel.totalCart = 0
        if UserShared.shared.userSavedAddress != nil{
            self.textField?.text = UserShared.shared.userSavedAddress?.address.components(separatedBy: ",").first ?? ""
        }else{
            self.textField?.text = UserShared.shared.currentAddress.components(separatedBy: ",").first
            self.selectedAddressId = ""
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.textField?.resignFirstResponder()
        self.view.endEditing(true)
    }
    
}


//MARK:- IBAction
fileprivate extension SearchSortViewController{
    
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
        self.callAPIForSearchRestaurants()
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
        self.callAPIForSearchRestaurants()
    }
}
//MARK:- Private methods
fileprivate extension SearchSortViewController {
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        if Connectivity.isConnectedToInternet{
            self.callAPIForSearchRestaurants()
        }else{
            self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "ok")
        }
        refreshControl.endRefreshing()
    }
    
    func configUI(){
        DispatchQueue.main.async {
            self.sortButtonOutlet.layer.borderWidth = 1
            self.sortButtonOutlet.layer.borderColor = UIColor.init(red: 175/255, green: 8/255, blue: 54/255, alpha: 1.0).cgColor
            self.sortButtonOutlet.layer.cornerRadius = self.sortButtonOutlet.frame.size.height/2
            
            self.filterButtonOutlet.layer.borderWidth = 1
            self.filterButtonOutlet.layer.borderColor = UIColor.init(red: 175/255, green: 8/255, blue: 54/255, alpha: 1.0).cgColor
            self.filterButtonOutlet.layer.cornerRadius = self.sortButtonOutlet.frame.size.height/2
            
            self.buttonModify.layer.cornerRadius = self.buttonModify.frame.size.height/2
        }
        
        //Making sliding view to center of demand button.
        centerXForSLidingView = slidingView.centerXAnchor.constraint(equalTo: buttonDemandMode.centerXAnchor, constant: 0)
        centerXForSLidingView.isActive = true
        
        //Making attirbuted strings to show restaurants count
        self.configRestaurantResultCountLabel()
        
        //Add Search field.
        self.configureSearchField()
        
        if Connectivity.isConnectedToInternet {
            self.callAPIForSearchRestaurants()
        }else{
            self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "ok")
        }
        
        if UserShared.shared.isSubscriptionMode{
            self.onSubscriptionAction(UIButton())
        }else{
            self.onDemandAction(UIButton())
        }
        
    }
    
    func configRestaurantResultCountLabel(){
        let stringRestaurantResultCount = "\(self.filterData.count) restaurants found matching your search"
        let stringRestaurantCount = "\(self.filterData.count)"
        
        let attributedString = NSMutableAttributedString(string:stringRestaurantResultCount)
        attributedString.addAttribute(NSAttributedStringKey.font, value: UIFont.boldSystemFont(ofSize: 15) as Any, range: NSRange(location: 0, length: stringRestaurantCount.count))
        
        let range2 = (stringRestaurantResultCount as NSString).range(of: stringRestaurantCount)
        attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.init(red: 175/255, green: 8/255, blue: 54/255, alpha: 1.0) , range: range2)
        self.searchResultLabel.attributedText = attributedString
    }
    
    func configureSearchField(){
        textField = TextField.init(frame: CGRect(x:0,y:0,width: self.navigationController!.navigationBar.frame.size.width - 150, height:35.0))
        textField?.delegate = self
        textField?.text = "Doha, Qatar"
        textField?.backgroundColor = UIColor.white
        textField?.layer.cornerRadius = 3
        textField?.textColor = UIColor.textGray
        textField?.font = UIFont.gouthamRegular
        textField?.text = UserShared.shared.currentAddress.components(separatedBy: ",").first
        
        //Adding rightside image on textField
        textField?.rightViewMode = .always
        textField?.rightView?.contentMode = .left
        
        let viewAccessory = UIView.init(frame: CGRect(x:0,y:0,width:30,height:30))
        viewAccessory.backgroundColor = UIColor.white
        let buttonSearch = UIButton.init()
        buttonSearch.backgroundColor = UIColor.white
        buttonSearch.setImage(UIImage.init(named: "searchIcon"), for: .normal)
        buttonSearch.frame = CGRect.init(x: 0, y: 5, width: 20, height: 20)
        viewAccessory.addSubview(buttonSearch)
        
        textField?.rightView = viewAccessory
        self.navigationItem.titleView = textField
    }
    
    @IBAction func backToSearch(_ segue: UIStoryboardSegue) {
        //Coming back to home screen from unwind segue
    }
    
    @objc func myTargetFunction(textField: UITextField) {
        if Connectivity.isConnectedToInternet{
            self.performSegue(withIdentifier: Segues.editAddressSegue, sender: nil)
        }else{
            self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "ok")
        }
    }
    
    //Calling web service
    func callAPIForSearchRestaurants(){
        self.showHud(message: "searching restaurants...")
        UserShared.shared.didChangeLocation = false
        let latitudeString =  String(format: "%.6f",(UserShared.shared.currentLocation?.coordinate.latitude) ?? "")
        let longitudeString = String(format: "%.6f",(UserShared.shared.currentLocation?.coordinate.longitude) ?? "")
        
        _ = WebAPIHandler.sharedHandler.getRestaurantsBy(latitude: latitudeString, longitude: longitudeString, success: { (response) in
            debugPrint(response)
            self.hideHud()
            let restaurants = (response["restaurants"] as? [[String:Any]]) ?? []
            self.dataSource.removeAll()
            if restaurants.count != 0 {
                for restaurant  in restaurants {
                    self.dataSource.append(RestaurantLists(data: restaurant))
                    let cuisineData = (restaurant["cuisines"] as? [String])?.first ?? ""
                    if !self.cuisineData.contains(cuisineData){
                        self.cuisineData.append(cuisineData)
                    }
                    let mealData = (restaurant["mealTypes"] as? [String])?.first ?? ""
                    if !self.mealTypeData.contains(mealData){
                        self.mealTypeData.append(mealData)
                    }
                }
                self.sortButtonOutlet.isHidden = false
                self.filterButtonOutlet.isHidden = false
            }
            self.filterData = self.dataSource
            if self.filterData.count == 0{
                self.noResultView.isHidden = false
            }else{
                self.noResultView.isHidden = true
            }
            self.configRestaurantResultCountLabel()
            self.searchRestaurantTableView.reloadData()
        }){(error) in
            self.hideHud()
            debugPrint(error.localizedDescription)
            UserShared.shared.didChangeLocation = false
            self.showAlertViewWithTitle(title: "", Message: error.localizedDescription, CancelButtonTitle: "ok")
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
                    self.textField?.text = "\(self.subLocality), \(self.locality)"
                }
                UserShared.shared.userSavedAddress = nil
                self.selectedAddressId = nil
                UserShared.shared.currentLocation = self.currentLocation
                self.callAPIForSearchRestaurants()
            }
        }else{
            self.showAlertViewWithTitle(title: "", Message:Messages.internetUnavailable, CancelButtonTitle: "ok")
        }
    }
    
    //Perform sort related work
    func sortDistancecloseToFar(){
        let tempData = self.filterData
        self.filterData.removeAll()
        self.filterData = tempData.sorted(by: { (menu1, menu2) -> Bool in
            return menu1.restaurantDistance < menu2.restaurantDistance
        })
        self.searchRestaurantTableView.reloadData()
        self.configRestaurantResultCountLabel()
    }
    
    func sortDistanceFarToClose(){
        let tempData = self.filterData
        self.filterData.removeAll()
        self.filterData = tempData.sorted(by: { (menu1, menu2) -> Bool in
            return menu1.restaurantDistance > menu2.restaurantDistance
        })
        self.searchRestaurantTableView.reloadData()
        self.configRestaurantResultCountLabel()
    }
    
    func sortRatingLowToHigh(){
        let tempData = self.dataSource
        self.filterData.removeAll()
        self.filterData = tempData.sorted(by: { (menu1, menu2) -> Bool in
            return menu1.restaurantStar < menu2.restaurantStar
        })
        self.searchRestaurantTableView.reloadData()
        self.configRestaurantResultCountLabel()
    }
    
    func sortRatingHighToLow(){
        let tempData = self.dataSource
        self.filterData.removeAll()
        self.filterData = tempData.sorted(by: { (menu1, menu2) -> Bool in
            return menu1.restaurantStar > menu2.restaurantStar
        })
        self.searchRestaurantTableView.reloadData()
        self.configRestaurantResultCountLabel()
    }
}

//MARK:- UITableview data source & delegate
extension SearchSortViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filterData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Segues.searchSortTableCell , for: indexPath) as! SearchSortTableCell
        cell.dataSource = filterData[indexPath.row]
        cell.timeImageView.image = UIImage.init(named: "greenTimer")
        cell.timeLabel.textColor = UIColor.greenTimerColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if UserShared.shared.isSubscriptionMode{
            self.performSegue(withIdentifier: Segues.subscriptionSegue, sender: filterData[indexPath.row])
        }else{
            self.performSegue(withIdentifier: Segues.toRestaurantMenuScreen, sender: filterData[indexPath.row])
        }
    }
}

//MARK:- Textfield delgate
extension SearchSortViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        let actionSheet = self.storyboard?.instantiateViewController(withIdentifier: Segues.selectAddreesActionSheet) as! SelectAddreesActionSheet
        actionSheet.addresses = self.userAddresses
        actionSheet.delegate = self
        actionSheet.selectedAddressId = self.selectedAddressId ?? ""
        self.present(actionSheet, animated: true, completion: nil)
        textField.resignFirstResponder()
    }
}

//MARK:- Sorting delegate methods
extension SearchSortViewController : SortByViewControllerDelegate{
    
    func didSelectedSortedCatagory(basisOf: String) {
        if basisOf.isEqualToString(find: "Distance - Nearest to Furthest"){
            self.sortDistancecloseToFar()
        }else if basisOf.isEqualToString(find: "Distance - Furthest to Nearest"){
            self.sortDistanceFarToClose()
        }else if basisOf.isEqualToString(find: "Rating - Low to High"){
            self.sortRatingLowToHigh()
        }else if basisOf.isEqualToString(find: "Rating - High to Low"){
            self.sortRatingHighToLow()
        }
    }
}

extension SearchSortViewController : SelectAddreesActionSheetDelegate{
    func didSelectAddressType(cell: AdressActionSheetCell, index: Int) {
        if index == 0{
            if Connectivity.isConnectedToInternet{
                self.performSegue(withIdentifier: Segues.editAddressSegue, sender: nil)
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
            self.textField?.text = cell.dataSource.address.components(separatedBy: ",").first ?? ""
            if Connectivity.isConnectedToInternet {
                self.callAPIForSearchRestaurants()
            }else{
                self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "ok")
            }
        }
    }
}

//MARK:- Filter View controller delgate
extension SearchSortViewController : FilterByViewControllerDelegate{
    func didTapOnApplyFilter(data: [String], dictData: [Int : [String]]) {
        self.selectedElement = data
        self.dictData = dictData
        let cuisineData = (dictData[0]) ?? []
        let mealData = (dictData[1]) ?? []
        
        if cuisineData.count != 0 && mealData.count != 0{
            self.filterData.removeAll()
            //Filter food type
            var cuisineFilterData = [RestaurantLists]()
            var restaurantData = [RestaurantLists]()
            
            for selectedData in cuisineData{
                var resData : [RestaurantLists]?
                resData = self.dataSource.filter({ (restaurant) -> Bool in
                    return restaurant.cuisineTypes.isEqualToString(find: selectedData)
                })
                if resData != nil{
                    restaurantData.append(contentsOf: resData ?? [])
                }
            }
            let items = Set(restaurantData)
            if items.count != 0{
                cuisineFilterData = Array(items)
            }
            
            restaurantData.removeAll()
            //Filter meal type
            for selectedData in mealData{
                var resData : [RestaurantLists]?
                resData = cuisineFilterData.filter({ (restaurant) -> Bool in
                    return restaurant.mealTypes.isEqualToString(find: selectedData)
                })
                if resData != nil{
                    restaurantData.append(contentsOf: resData ?? [])
                }
            }
            let resItems = Set.init(restaurantData)
            if items.count != 0{
                self.filterData = Array(resItems)
            }
            self.configRestaurantResultCountLabel()
            self.searchRestaurantTableView.reloadData()
        }else if cuisineData.count != 0 && mealData.count == 0{
            self.filterData.removeAll()
            //Filter food type
            var restaurantData = [RestaurantLists]()
            
            for selectedData in cuisineData{
                var resData : [RestaurantLists]?
                resData = self.dataSource.filter({ (restaurant) -> Bool in
                    return restaurant.cuisineTypes.isEqualToString(find: selectedData)
                })
                if resData != nil{
                    restaurantData.append(contentsOf: resData ?? [])
                }
            }
            let items = Set(restaurantData)
            if items.count != 0{
                self.filterData = Array(items)
            }
            self.configRestaurantResultCountLabel()
            self.searchRestaurantTableView.reloadData()
        }else if cuisineData.count == 0 && mealData.count != 0{
            self.filterData.removeAll()
            //Filter food type
            var restaurantData = [RestaurantLists]()
            
            for selectedData in mealData{
                var resData : [RestaurantLists]?
                resData = self.dataSource.filter({ (restaurant) -> Bool in
                    return restaurant.mealTypes.isEqualToString(find: selectedData)
                })
                if resData != nil{
                    restaurantData.append(contentsOf: resData ?? [])
                }
            }
            let items = Set(restaurantData)
            if items.count != 0{
                self.filterData = Array(items)
            }
            self.configRestaurantResultCountLabel()
            self.searchRestaurantTableView.reloadData()
        }else{
            self.filterData = self.dataSource
            self.configRestaurantResultCountLabel()
            self.searchRestaurantTableView.reloadData()
        }
    }
}


