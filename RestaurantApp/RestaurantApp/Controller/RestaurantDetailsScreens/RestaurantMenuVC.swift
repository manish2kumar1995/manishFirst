//
//  RestaurantMenuVC.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 29/08/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class RestaurantMenuVC: BaseViewController {
    
    //MARK:- IBoutlet
    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelQARCount: UILabel!
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var viewContainingCartICon: UIView!
    @IBOutlet weak var buttonCheckOut: UIButton!
    @IBOutlet weak var labelCartCount: UILabel!
    
    var modes : RestaurantMode = .menu
    var sectionHeader : RestaurantSectionHeaderCell?
    var restaurantDetail : RestaurantLists?
    var filteredMenuId = [String]()
    var cartCount = Int()
    var totalPrice = CGFloat()
    var myBasketData  = [[String:MyBasketData]]()
    var minimumOrderValue = Int()
    var currencyType = String()
    var cuisineData = [String]()
    var mealTypeData = [String]()
    var foodType = [String]()
    var selectedElement = [String]()
    var dictData = [Int:[String]]()
    var noReview = false
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(RestaurantMenuVC.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    var restaurantId : String?
    var userAddresses = [AddressStruct]()
    var sortedDataSource = [MenuItems]()
    var isSortingDone = false
    var mainSortingSource = [[String:MenuItems]]()
    
    fileprivate struct ReusableIdenfier {
        static let restaurantSectionHeader = "RestaurantSectionHeaderCell"
        static let restaurantMenuCell = "RestaurantMenuCell"
        static let restaurantDescriptionCell = "DescriptionReviewCell"
        static let restaurantShortReviewCell = "ShortReviewCell"
        static let restaurantInfoMapCell = "InfoMapViewCell"
        static let restaurantInfoAboutCell = "InfoAboutTableCell"
        static let restaurantTableHeader = "RestaurantTableHeader"
        static let restaurantOpeningTimeCell = "RestaurantOpeningTimingCell"
        static let myBasketSegue = "myBasketSegue"
        static let dishDetailSegue = "dishDetailSegue"
        static let filterSegue = "filterSegue"
        static let sortSegue = "sortSegue"
        static let addOptionSegue = "addOptionSegue"
        static let noReview = "noReview"
    }
    
    //Data source for menu screen
    var filteredDishData : [String:[MenuItems]] = [String:[MenuItems]]()
    var menuDataSource : [String:[MenuItems]] = [String:[MenuItems]]()
    var mapDataSource = [RestaurantInfo.RestaurantMapInfo]()
    var timingDataSource = [RestaurantInfo.RestaurantTimingStruct]()
    var infoDataSource : [RestaurantInfo.RestaurantAboutInfo] = [RestaurantInfo.RestaurantAboutInfo]()
    var shortDescpDataSource = [RestaurantReview.RestaurantShortReview]()
    
    // DataSource for Descriptive cell
    
    var descriptiveDataSource : [RestaurantReview.RestaurantDetailReview] = [RestaurantReview.RestaurantDetailReview(starRating: "1", outerReview:"Mauris id dignissim purus, a fringila ex. Sed rhoncus ex at commodo tempus. Morbi a maximus lorem. Pelintesque non dolor tincidunt. pulvinar dolor in, rutrum erat. Cras nec odio tempor, rutrum risus a sagittis turpis.", interiorReview:"Mauris id dignissim purus, a fringila ex. Sed rhoncus ex at commodo tempus. Morbi a maximus lorem. Pelintesque non dolor tincidunt. pulvinar dolor in, rutrum erat.", reviewDate:"18/08/2017", restaurantName:"Arby's Restaurant", name: "Alex")]
    
    //MARK:- Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currencyType = (UserDefaults.standard.value(forKey: "Currency") as? String) ?? "QAR"
        if #available(iOS 10.0, *) {
            self.menuTableView.refreshControl = refreshControl
        }else{
            self.menuTableView.addSubview(refreshControl)
        }
        
        if self.restaurantId != nil{
            if Connectivity.isConnectedToInternet{
                self.callingAPIForRestaurantDetail()
            }else{
                self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "ok")
            }
        }
        
        //Calling API For Retaurant menu
        if Connectivity.isConnectedToInternet{
            self.callAPIForRestaurantDishes()
        }else{
            self.menuTableView.delegate = self
            self.menuTableView.dataSource = self
            self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "ok")
        }
        
        //Calling Restaurant Review
        if Connectivity.isConnectedToInternet{
            self.callingAPIForRestaurantReview()
        }else{
            self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "ok")
        }
        
        //Calling Restaurant Info
        if Connectivity.isConnectedToInternet{
            self.callingAPIForRestaurantInfo()
        }else{
            self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "ok")
        }
        
        //Calling Restaurant Opening times
        if Connectivity.isConnectedToInternet{
            self.callingAPIForRestaurantOpeningTimes()
        }else{
            self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "ok")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.configUI()
        self.configTableView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RestaurantDishViewControler{
            let data = sender! as! MenuItems
            vc.navigationTitle = data.menuTitle
            vc.menuData = data
            vc.restaurantId = self.restaurantDetail?.id
        }
        
        if let vc = segue.destination as? AddOptionVC{
            vc.menuData = sender! as? MenuItems
            vc.minimumOrderValue = self.minimumOrderValue
            vc.restaurantId = self.restaurantDetail?.id
        }
        
        if let vc = segue.destination as? MyBasketViewController{
            vc.myBasketData = self.myBasketData
            vc.totalCart = self.cartCount
            vc.totalQAR = self.totalPrice
            vc.restautantDetails = self.restaurantDetail
            vc.minimumOrderValue = self.minimumOrderValue
            vc.userAddresses = self.userAddresses
        }
        
        if let vc = segue.destination as? SortByViewController{
            vc.titleArray = ["Price - Low to High","Price - High to Low","Calories - Low to High","Calories - High to Low"]
            vc.titleIconArray = ["coloredTag","coloredTag", "likesIcon","likesIcon"]
            vc.delegate = self
        }
        
        if let vc = segue.destination as? FilterByViewController{
            vc.objectsArray = [FilterObject(sectionName: "CUSINES", sectionImage:"filterCusines", sectionObjects : self.cuisineData),FilterObject(sectionName: "MEAL TYPES", sectionImage:"menuBordered", sectionObjects: self.mealTypeData),FilterObject(sectionName: "DISH TYPES", sectionImage:"filterCarrot", sectionObjects: self.foodType)]
            vc.delegate = self
            vc.menuDataSource = self.menuDataSource
            vc.selectedElement = self.selectedElement
            vc.dataDictionary = self.dictData
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        UserShared.shared.myBasketModel.myBasketData = self.myBasketData
        UserShared.shared.myBasketModel.totalCart = self.cartCount
        UserShared.shared.myBasketModel.totalQAR = self.totalPrice
    }
}

//MARK:- IB action
extension RestaurantMenuVC{
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        if Connectivity.isConnectedToInternet{
            self.callAPIForRestaurantDishes()
            self.callingAPIForRestaurantInfo()
            self.callingAPIForRestaurantReview()
            self.callingAPIForRestaurantOpeningTimes()
        }else{
            self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "ok")
        }
        refreshControl.endRefreshing()
    }
    
    
    @IBAction func buttonCheckOutAction(_ sender: UIButton) {
        if self.cartCount != 0{
            if self.totalPrice >= CGFloat(self.minimumOrderValue){
                self.performSegue(withIdentifier: ReusableIdenfier.myBasketSegue, sender: nil)
            }else{
                self.showAlertViewWithTitle(title: "Message", Message: "Please exceed the minimum order value \(self.minimumOrderValue) \(self.currencyType)", CancelButtonTitle: "Ok")
            }
        }else{
            self.showAlertViewWithTitle(title: "Message", Message: "Please exceed the minimum order value \(self.minimumOrderValue) \(self.currencyType)", CancelButtonTitle: "Ok")
        }
    }
}

//MARK:- Custom Methods
extension RestaurantMenuVC {
    
    func configTableView(){
        self.menuTableView.estimatedRowHeight = 80
        self.menuTableView.rowHeight = UITableViewAutomaticDimension
        
        //Configuring Table Header
        let tableHeader = UINib.init(nibName: ReusableIdenfier.restaurantTableHeader, bundle: Bundle.main)
        self.menuTableView.register(tableHeader, forHeaderFooterViewReuseIdentifier: ReusableIdenfier.restaurantTableHeader)
        
        //Registering section header
        let sectionHeader = UINib.init(nibName: ReusableIdenfier.restaurantSectionHeader, bundle: Bundle.main)
        self.menuTableView.register(sectionHeader, forCellReuseIdentifier:  ReusableIdenfier.restaurantSectionHeader)
        
        //Registering various cells of restaurant Review
        
        //Registering Decriptive cell NIB
        let desNib = UINib(nibName: ReusableIdenfier.restaurantDescriptionCell, bundle: nil)
        self.menuTableView.register(desNib, forCellReuseIdentifier: ReusableIdenfier.restaurantDescriptionCell)
        
        //Registering short cell NIB
        let shortNib = UINib(nibName: ReusableIdenfier.restaurantShortReviewCell, bundle: nil)
        self.menuTableView.register(shortNib, forCellReuseIdentifier: ReusableIdenfier.restaurantShortReviewCell)
        
        //Registering various cell for Restaurant Info
        
        //Registering Map NIB
        let mapNib = UINib(nibName: ReusableIdenfier.restaurantInfoMapCell, bundle: nil)
        self.menuTableView.register(mapNib, forCellReuseIdentifier: ReusableIdenfier.restaurantInfoMapCell)
        
        //Registering about NIB
        let aboutNib = UINib(nibName: ReusableIdenfier.restaurantInfoAboutCell, bundle: nil)
        self.menuTableView.register(aboutNib, forCellReuseIdentifier: ReusableIdenfier.restaurantInfoAboutCell)
        
        //Registering openingTime NIB
        let openingNib = UINib(nibName: ReusableIdenfier.restaurantOpeningTimeCell, bundle: nil)
        self.menuTableView.register(openingNib, forCellReuseIdentifier: ReusableIdenfier.restaurantOpeningTimeCell)
    }
    
    func configUI(){
        DispatchQueue.main.async {
            self.setNavigation(title: self.restaurantDetail?.restaurantTitle)
            self.myBasketData = (UserShared.shared.myBasketModel.myBasketData)
            self.cartCount = (UserShared.shared.myBasketModel.totalCart)
            self.totalPrice = CGFloat((UserShared.shared.myBasketModel.totalQAR))
            
            if self.totalPrice >= CGFloat(self.minimumOrderValue) {
                self.buttonCheckOut.backgroundColor = UIColor.borderedRed
                self.labelCartCount.textColor = UIColor.borderedRed
                self.labelQARCount.textColor = UIColor.borderedRed
            }else{
                self.buttonCheckOut.backgroundColor = UIColor.disabledLightGray
                self.labelCartCount.textColor = UIColor.darkRed
                self.labelQARCount.textColor = UIColor.darkRed
            }
            
            //Adding shadow to bottom view
            self.bottomView.layer.masksToBounds = false
            self.bottomView.layer.shadowRadius = 20.0
            self.bottomView.layer.shadowColor = UIColor.lightGray.cgColor
            self.bottomView.layer.shadowOffset = CGSize(width: 1.0, height: 5.0)
            self.bottomView.layer.shadowOpacity = 1.0
            
            
            self.labelQARCount.text = "\(self.totalPrice) \(self.currencyType)"
            self.labelCartCount.text = "\(UserShared.shared.myBasketModel.totalCart)"
            
            self.buttonCheckOut.layer.cornerRadius = self.buttonCheckOut.frame.size.height/2
        }
    }
    
    func getParsedData(data:[String:Any]){
        self.sortedDataSource.append(MenuItems.init(data: data))
        let type = (((data["type"] as? [String:Any]) ?? [:])["name"] as? String) ?? ""
        if self.menuDataSource.keys.contains(type) {
            var dataValue = self.menuDataSource[type]
            dataValue?.append(MenuItems.init(data: data))
            self.menuDataSource.updateValue(dataValue!, forKey: type)
        }else{
            self.menuDataSource[type] = [MenuItems.init(data: data)]
        }
    }
    
    //Calling API For Dishes
    func callAPIForRestaurantDishes(){
        self.showHud(message: "loading dishes")
        let _ =  WebAPIHandler.sharedHandler.getRestaurantDishes(restaurantId: (self.restaurantDetail?.id) ?? "", success: { (response) in
            self.hideHud()
            debugPrint(response)
            let dishes = (response["dishes"] as? [[String:Any]]) ?? []
            self.menuDataSource.removeAll()
            self.isSortingDone = false
            for dish in dishes{
                self.getParsedData(data:dish)
                let cuisine = (dish["cuisine"] as? [String:Any]) ?? [:]
                let cuisineData = (cuisine["name"] as? String) ?? ""
                if !self.cuisineData.contains(cuisineData){
                    self.cuisineData.append(cuisineData)
                }
                let mealType = (dish["mealType"] as? [String:Any]) ?? [:]
                let mealData = (mealType["name"] as? String) ?? ""
                if !self.mealTypeData.contains(mealData){
                    self.mealTypeData.append(mealData)
                }
                let dishType = (dish["type"] as? [String:Any]) ?? [:]
                let foodData = (dishType["name"] as? String) ?? ""
                if !self.foodType.contains(foodData){
                    self.foodType.append(foodData)
                }
            }
            self.filteredDishData = self.menuDataSource
            self.menuTableView.delegate = self
            self.menuTableView.dataSource = self
            self.menuTableView.reloadData()
        }){ (error) in
            self.menuTableView.delegate = self
            self.menuTableView.dataSource = self
            self.hideHud()
            debugPrint(error)
        }
    }
    
    //Calling API For restaurant review
    func callingAPIForRestaurantReview(){
        let _ = WebAPIHandler.sharedHandler.getRestaurantReview(restaurtantId: (self.restaurantDetail?.id) ?? "", success: { (response) in
            debugPrint(response)
            let reviews = (response["reviews"] as? [String:Any] ) ?? [:]
            let snippets = (reviews["snippets"] as? [[String:Any]]) ?? []
            for snippet in snippets{
                self.shortDescpDataSource.append(RestaurantReview.RestaurantShortReview.init(data: snippet))
            }
        }){ (error) in
            debugPrint(error)
        }
    }
    
    func callingAPIForRestaurantInfo(){
        let _ = WebAPIHandler.sharedHandler.getRestaurantInfo(restaurtantId: (self.restaurantDetail?.id) ?? "", success: { (response) in
            debugPrint(response)
            let restaurant = (response["restaurant"] as? [String:Any]) ?? [:]
            self.mapDataSource.append(RestaurantInfo.RestaurantMapInfo.init(data: restaurant))
            self.infoDataSource.append(RestaurantInfo.RestaurantAboutInfo(restaurantTitle:self.restaurantDetail?.restaurantTitle ?? "", restaurantAbout:(restaurant["description"] as? String) ?? ""))
        }){ (error) in
            debugPrint(error)
        }
    }
    
    
    func callingAPIForRestaurantDetail(){
        _ = WebAPIHandler.sharedHandler.getParticularRestuant(restaurantId: self.restaurantId ?? "", success: { (response) in
            debugPrint(response)
            let restaurant = (response["restaurant"] as? [String:Any]) ?? [:]
            self.restaurantDetail = RestaurantLists.init(data: restaurant)
            self.menuTableView.delegate = self
            self.menuTableView.dataSource = self
            self.menuTableView.reloadData()
        }, failure: { (error) in
            debugPrint(error)
            self.menuTableView.delegate = self
            self.menuTableView.dataSource = self
            self.menuTableView.reloadData()
        })
    }
    
    func callingAPIForRestaurantOpeningTimes(){
        let _ = WebAPIHandler.sharedHandler.getRstaurantOpeningTimes(restaurantId:  (self.restaurantDetail?.id) ?? "", success: { (response) in
            debugPrint(response)
            let timings = (response["openingTimes"] as? [[String:Any]]) ?? [[:]]
            for timing in timings{
                self.timingDataSource.append(RestaurantInfo.RestaurantTimingStruct(data:timing))
            }
        }) { (error) in
            debugPrint(error)
        }
    }
    
    
    //TODO:-- Sorting activities realated changes
    //Sort on basis of price
    func sortByPriceLowToHigh(){
        self.sortedDataSource.removeAll()
        for (_ , value) in self.filteredDishData{
            self.sortedDataSource.append(contentsOf: value)
        }
        
        
        self.isSortingDone = true
        let filteredData = self.sortedDataSource.sorted { (menu1, menu2) -> Bool in
            return menu1.menuPrice < menu2.menuPrice
        }
        self.mainSortingSource.removeAll()
        for data in  filteredData{
            self.mainSortingSource.append([data.foodType:data])
        }
        self.menuTableView.reloadData()
        
    }
    
    func sortByPriceHighToLow(){
        //   self.filteredDishData.removeAll()
        self.sortedDataSource.removeAll()
        for (_ , value) in self.filteredDishData{
            self.sortedDataSource.append(contentsOf: value)
        }
        
        self.isSortingDone = true
        
        let filteredData = self.sortedDataSource.sorted { (menu1, menu2) -> Bool in
            return menu1.menuPrice > menu2.menuPrice
        }
        self.mainSortingSource.removeAll()
        for data in  filteredData{
            self.mainSortingSource.append([data.foodType:data])
        }
        
        self.menuTableView.reloadData()
    }
    
    //Sort on basis of Calories
    func sortByCaloriesLowToHigh(){
        self.sortedDataSource.removeAll()
        for (_ , value) in self.filteredDishData{
            self.sortedDataSource.append(contentsOf: value)
        }
        
        
        self.isSortingDone = true
        let filteredData = self.sortedDataSource.sorted { (menu1, menu2) -> Bool in
            return menu1.totalCalories < menu2.totalCalories
        }
        self.mainSortingSource.removeAll()
        for data in  filteredData{
            self.mainSortingSource.append([data.foodType:data])
        }
        
        self.menuTableView.reloadData()
    }
    
    func sortByCaloriesHighToLow(){
        self.sortedDataSource.removeAll()
        for (_ , value) in self.filteredDishData{
            self.sortedDataSource.append(contentsOf: value)
        }
        
        self.isSortingDone = true
        let filteredData = self.sortedDataSource.sorted { (menu1, menu2) -> Bool in
            return menu1.totalCalories > menu2.totalCalories
        }
        self.mainSortingSource.removeAll()
        for data in  filteredData{
            self.mainSortingSource.append([data.foodType:data])
        }
        self.menuTableView.reloadData()
    }
}

//MARK:- TableView Delegate and Datasource Methods
extension RestaurantMenuVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch(modes){
        case .menu:
            if !isSortingDone{
                if self.filteredDishData.isEmpty{
                    return 2
                }else{
                    return self.filteredDishData.count + 1
                }
            }else{
                return self.mainSortingSource.count + 1
            }
        case .review:
            return 2
        case .info:
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 0
        }else if modes == .review{
            if self.shortDescpDataSource.count == 0{
                self.noReview = true
                return 1
            }else{
                return shortDescpDataSource.count
            }
        }else if modes == .menu{
            if !isSortingDone{
                if self.filteredDishData.isEmpty{
                    return 0
                }else{
                    let values = Array(self.filteredDishData)[section - 1].value.count
                    return values
                }
            }else{
                return 1
            }
        }else{
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        switch(modes){
        case .menu:
            let menuCell = tableView.dequeueReusableCell(withIdentifier: ReusableIdenfier.restaurantMenuCell, for: indexPath) as! RestaurantMenuCell
            if !isSortingDone{
                menuCell.dataSource = Array(self.filteredDishData)[indexPath.section - 1].value[indexPath.row]
                menuCell.delegate = self
                cell = menuCell
            }else{
                menuCell.dataSource = self.mainSortingSource[indexPath.section - 1].values.first ?? MenuItems(data: [:])
                menuCell.delegate = self
                cell = menuCell
            }
        case .review:
            
            if self.noReview{
                let noReviewCell = tableView.dequeueReusableCell(withIdentifier: ReusableIdenfier.noReview, for: indexPath)
                cell = noReviewCell
            }else{
                let shortCell = self.menuTableView.dequeueReusableCell(withIdentifier: ReusableIdenfier.restaurantShortReviewCell) as! ShortReviewCell
                if shortDescpDataSource.count != 0{
                    shortCell.dataSource = self.shortDescpDataSource[indexPath.row]
                }
                cell = shortCell
            }
        case .info:
            
            if indexPath.row == 0{
                let mapCell = self.menuTableView.dequeueReusableCell(withIdentifier: ReusableIdenfier.restaurantInfoMapCell) as! InfoMapViewCell
                if self.mapDataSource.count != 0{
                    mapCell.dataSource = self.mapDataSource[indexPath.row]
                }
                cell = mapCell
            }else if indexPath.row == 1{
                let aboutCell = self.menuTableView.dequeueReusableCell(withIdentifier: ReusableIdenfier.restaurantInfoAboutCell) as! InfoAboutTableCell
                if self.infoDataSource.count != 0{
                    aboutCell.dataSource = self.infoDataSource[0]
                }
                cell = aboutCell
            }else{
                let timingCell = self.menuTableView.dequeueReusableCell(withIdentifier: ReusableIdenfier.restaurantOpeningTimeCell) as! RestaurantOpeningTimingCell
                if self.timingDataSource.count != 0{
                    timingCell.dataSource = self.timingDataSource
                }
                cell = timingCell
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            let headerView = self.menuTableView.dequeueReusableHeaderFooterView(withIdentifier: ReusableIdenfier.restaurantTableHeader) as! RestaurantTableHeader
            headerView.menuIconImage.sd_setShowActivityIndicatorView(true)
            headerView.menuIconImage.sd_setIndicatorStyle(.gray)
            headerView.menuIconImage.sd_setImage(with: URL(string: (self.restaurantDetail?.restaurantImage) ?? ""), placeholderImage: UIImage(named: ""))
            let rating = self.restaurantDetail?.restaurantStar ?? 0.0
            if (rating == 0.0){
                headerView.outerRatingView.isHidden = true
            }else{
                headerView.outerRatingView.isHidden = false
                headerView.labelRating.text = "\(self.restaurantDetail?.restaurantStar ?? 0.0)"
                headerView.labelClassification.text = self.restaurantDetail?.restautrantClassification ?? ""
            }
            return headerView
        }else if section > 1{
            let screenSize: CGRect = UIScreen.main.bounds
            let myView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width , height: 50))
            let label = UILabel(frame: CGRect(x: 20, y: 15, width: screenSize.width - 70, height: 20))
            var text = ""
            if !isSortingDone{
                text = Array(self.filteredDishData)[section - 1].key
            }else{
                text = self.mainSortingSource[section - 1].keys.first ?? ""
            }
            label.text = text
            label.textColor = UIColor.borderedRed
            let view = UIView(frame: CGRect(x: 0, y: myView.frame.size.height - 1, width: screenSize.width , height: 1))
            view.backgroundColor = UIColor.viewBackgroundGray
            myView.backgroundColor = UIColor.white
            myView.addSubview(view)
            label.font = UIFont.boldSystemFont(ofSize: 19.0)
            myView.addSubview(label)
            return myView
        }else{
            if sectionHeader != nil {
                if !isSortingDone{
                    if !self.filteredDishData.isEmpty{
                        sectionHeader?.labelFoodType.text = Array(self.filteredDishData)[section - 1].key
                    }
                }else{
                    sectionHeader?.labelFoodType.text = self.mainSortingSource[section - 1].keys.first ?? ""
                }
                return sectionHeader
            }else{
                sectionHeader = (tableView.dequeueReusableCell(withIdentifier: ReusableIdenfier.restaurantSectionHeader) as! RestaurantSectionHeaderCell)
                sectionHeader?.delegate = self
                sectionHeader?.selectionStyle = .none
                
                if !isSortingDone{
                    if !self.filteredDishData.isEmpty{
                        sectionHeader?.labelFoodType.text = Array(self.filteredDishData)[section - 1].key
                    }
                }else{
                    sectionHeader?.labelFoodType.text = self.mainSortingSource[section - 1].keys.first ?? ""
                }
                return sectionHeader
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if modes == .menu{
            self.performSegue(withIdentifier: ReusableIdenfier.dishDetailSegue, sender: Array(self.filteredDishData)[indexPath.section - 1].value[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 190
        }else{
            if modes == .menu{
                if filteredDishData.count == 0{
                    return 60
                }
                if section > 1{
                    return 50
                }else{
                    return 135
                }
            }else if modes == .review{
                return 75
            }else{
                return 60
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if modes == .menu{
            return 90
        }else if modes == .info{
            return UITableViewAutomaticDimension
        }else{
            if self.noReview{
                return 250
            }else{
                return UITableViewAutomaticDimension
            }
        }
    }
}

//MARK:- Restaurants section header delegate
extension RestaurantMenuVC : RestaurantsSectionHeaderDelegate {
    
    func didTapOnFilter() {
        self.performSegue(withIdentifier: ReusableIdenfier.filterSegue, sender: nil)
    }
    
    func didTapOnSort() {
        self.performSegue(withIdentifier: ReusableIdenfier.sortSegue, sender: nil)
    }
    
    func changeModes(mode: RestaurantMode?) {
        modes = mode!
        if mode != .menu{
            self.menuTableView.separatorStyle = .none
            self.bottomViewBottomConstraint.constant = -70
        }else{
            // self.menuTableView.separatorStyle = .singleLine
            self.bottomViewBottomConstraint.constant = 0
        }
        self.menuTableView.reloadData()
    }
}

//MARK:- Restaurants menu cell delegate
extension RestaurantMenuVC : RestaurantMenuCellDelegate{
    
    //Adding to cart from menu screen
    func didTapOnAddButton(cell: RestaurantMenuCell? ,  data: MenuItems?) {
        if (cell?.dataSource.hasOptions)!{
            self.performSegue(withIdentifier: ReusableIdenfier.addOptionSegue, sender: data)
        }else{
            var found = false
            if myBasketData.count != 0{
                for  i in 0..<self.myBasketData.count {
                    var myBasket = self.myBasketData[i]
                    if myBasket.keys.first == cell?.dataSource.menuId{
                        let key = myBasket.keys.first!
                        var data = myBasket.values.first!
                        data.count = data.count + 1
                        data.basketPrice = CGFloat((data.count * Int(data.menuPrice)))
                        myBasket.updateValue(data, forKey: key)
                        found = true
                        self.myBasketData[i] = myBasket
                    }
                }
                if !found {
                    self.myBasketData.append([(cell?.dataSource.menuId)! : MyBasketData(menuId: (cell?.dataSource.menuId)!, menuTitle: ((cell?.dataSource.menuTitle)! + ",,"), count: (cell?.dataSource.count)! + 1, menuLogoImage: (cell?.dataSource.menuLogoImage)!, menuPrice: (cell?.dataSource.menuPrice)!, basketPrice :(cell?.dataSource.menuPrice)!)])
                }
            }else{
                self.myBasketData.append([(cell?.dataSource.menuId)! : MyBasketData(menuId: (cell?.dataSource.menuId)!, menuTitle: ((cell?.dataSource.menuTitle)! + ",,"), count: (cell?.dataSource.count)! + 1, menuLogoImage: (cell?.dataSource.menuLogoImage)!, menuPrice: (cell?.dataSource.menuPrice)!, basketPrice :(cell?.dataSource.menuPrice)!)])
            }
            self.cartCount = self.cartCount + 1
            self.filteredMenuId.append((cell?.labelMenuTitle.text) ?? "")
            self.labelCartCount.text = "\(self.cartCount)"
            let priceString = cell?.dataSource.menuPrice
            let price = priceString
            self.totalPrice = self.totalPrice + price!
            self.labelQARCount.text = "\(self.totalPrice) \(self.currencyType)"
            
            if self.totalPrice >= CGFloat(self.minimumOrderValue) {
                self.buttonCheckOut.backgroundColor = UIColor.borderedRed
                self.labelCartCount.textColor = UIColor.borderedRed
                self.labelQARCount.textColor = UIColor.borderedRed
            }else{
                self.buttonCheckOut.backgroundColor = UIColor.disabledLightGray
                self.labelCartCount.textColor = UIColor.darkRed
                self.labelQARCount.textColor = UIColor.darkRed
            }
        }
    }
}

//MARK:- Sorting delegate methods
extension RestaurantMenuVC : SortByViewControllerDelegate{
    func didSelectedSortedCatagory(basisOf: String) {
        if basisOf.isEqualToString(find: "Price - Low to High"){
            self.sortByPriceLowToHigh()
        }else if basisOf.isEqualToString(find: "Price - High to Low"){
            self.sortByPriceHighToLow()
        }else if basisOf.isEqualToString(find: "Calories - Low to High"){
            self.sortByCaloriesLowToHigh()
        }else if basisOf.isEqualToString(find: "Calories - High to Low"){
            self.sortByCaloriesHighToLow()
        }
    }
}

//MARK:- Filter View controller delgate
extension RestaurantMenuVC : FilterByViewControllerDelegate{
    func didTapOnApplyFilter(data: [String], dictData : [Int:[String]]) {
        self.selectedElement = data
        self.dictData = dictData
        let cuisineData = (dictData[0]) ?? []
        let mealData = (dictData[1]) ?? []
        let foodData = (dictData[2]) ?? []
        self.isSortingDone = false
        
        if cuisineData.count != 0 && mealData.count != 0 && foodData.count  != 0 {
            self.filteredDishData.removeAll()
            
            //Filter meal first
            var mealFilterData = [String:[MenuItems]]()
            for (key, value) in self.menuDataSource{
                var menuItems = [MenuItems]()
                for selectedData in mealData{
                    var dishData : [MenuItems]?
                    dishData = value.filter({ (menuItem) -> Bool in
                        return  menuItem.mealType.isEqualToString(find: selectedData)
                    })
                    if dishData != nil{
                        menuItems.append(contentsOf: dishData!)
                    }
                }
                let items = Set(menuItems)
                if items.count != 0{
                    mealFilterData.updateValue(Array(items), forKey: key)
                }else{
                    mealFilterData.removeValue(forKey: key)
                }
            }
            
            //Filter Cuisine
            var cuisineDataWithFilter = [String:[MenuItems]]()
            for (key, value) in mealFilterData{
                var menuItems = [MenuItems]()
                for selectedData in cuisineData{
                    var dishData : [MenuItems]?
                    dishData = value.filter({ (menuItem) -> Bool in
                        return  menuItem.cuisineType.isEqualToString(find:selectedData )
                    })
                    if dishData != nil{
                        menuItems.append(contentsOf: dishData!)
                    }
                }
                let items = Set(menuItems)
                if items.count != 0{
                    cuisineDataWithFilter.updateValue(Array(items), forKey: key)
                }else{
                    cuisineDataWithFilter.removeValue(forKey: key)
                }
            }
            
            //Filter drinks
            for (key, value) in cuisineDataWithFilter{
                var menuItems = [MenuItems]()
                for selectedData in foodData{
                    var dishData : [MenuItems]?
                    dishData = value.filter({ (menuItem) -> Bool in
                        return  menuItem.foodType.isEqualToString(find:selectedData )
                    })
                    if dishData != nil{
                        menuItems.append(contentsOf: dishData!)
                    }
                }
                let items = Set(menuItems)
                if items.count != 0{
                    self.sortedDataSource.removeAll()
                    self.sortedDataSource = Array(items)
                    self.filteredDishData.updateValue(Array(items), forKey: key)
                }else{
                    self.filteredDishData.removeValue(forKey: key)
                }
            }
            
            self.menuTableView.reloadData()
        }else if cuisineData.count != 0 && mealData.count != 0 && foodData.count == 0{
            //  var menuItems = [MenuItems]()
            self.filteredDishData.removeAll()
            var mealFilterData = [String:[MenuItems]]()
            
            //Filter meal first
            for (key, value) in self.menuDataSource{
                var menuItems = [MenuItems]()
                for selectedData in mealData{
                    var dishData : [MenuItems]?
                    dishData = value.filter({ (menuItem) -> Bool in
                        return  menuItem.mealType.isEqualToString(find: selectedData)
                    })
                    if dishData != nil{
                        menuItems.append(contentsOf: dishData!)
                    }
                }
                let items = Set(menuItems)
                if items.count != 0{
                    mealFilterData.updateValue(Array(items), forKey: key)
                }else{
                    mealFilterData.removeValue(forKey: key)
                }
            }
            //Filter Cuisine
            for (key, value) in mealFilterData{
                var menuItems = [MenuItems]()
                for selectedData in cuisineData{
                    var dishData : [MenuItems]?
                    dishData = value.filter({ (menuItem) -> Bool in
                        return  menuItem.cuisineType.isEqualToString(find:selectedData )
                    })
                    if dishData != nil{
                        menuItems.append(contentsOf: dishData!)
                    }
                }
                let items = Set(menuItems)
                if items.count != 0{
                    self.sortedDataSource.removeAll()
                    self.sortedDataSource = Array(items)
                    self.filteredDishData.updateValue(Array(items), forKey: key)
                }else{
                    self.filteredDishData.removeValue(forKey: key)
                }
            }
            
            self.menuTableView.reloadData()
        }else if cuisineData.count != 0 && mealData.count == 0 && foodData.count == 0{
            //  var menuItems = [MenuItems]()
            self.filteredDishData.removeAll()
            
            //Filter cuisine first
            for (key, value) in self.menuDataSource{
                var menuItems = [MenuItems]()
                for selectedData in cuisineData{
                    var dishData : [MenuItems]?
                    dishData = value.filter({ (menuItem) -> Bool in
                        return  menuItem.cuisineType.isEqualToString(find: selectedData)
                    })
                    if dishData != nil{
                        menuItems.append(contentsOf: dishData!)
                    }
                }
                let items = Set(menuItems)
                if items.count != 0{
                    self.sortedDataSource.removeAll()
                    self.sortedDataSource = Array(items)
                    self.filteredDishData.updateValue(Array(items), forKey: key)
                }else{
                    self.filteredDishData.removeValue(forKey: key)
                }
            }
            self.menuTableView.reloadData()
        }else if cuisineData.count == 0 && mealData.count != 0 && foodData.count == 0{
            //  var menuItems = [MenuItems]()
            self.filteredDishData.removeAll()
            
            //Filter meal first
            for (key, value) in self.menuDataSource{
                var menuItems = [MenuItems]()
                for selectedData in mealData{
                    var dishData : [MenuItems]?
                    dishData = value.filter({ (menuItem) -> Bool in
                        return  menuItem.mealType.isEqualToString(find: selectedData)
                    })
                    if dishData != nil{
                        menuItems.append(contentsOf: dishData!)
                    }
                }
                let items = Set(menuItems)
                if items.count != 0{
                    self.sortedDataSource.removeAll()
                    self.sortedDataSource = Array(items)
                    self.filteredDishData.updateValue(Array(items), forKey: key)
                }else{
                    self.filteredDishData.removeValue(forKey: key)
                }
            }
            self.menuTableView.reloadData()
            
        }else if cuisineData.count != 0 && mealData.count == 0 && foodData.count != 0{
            //  var menuItems = [MenuItems]()
            self.filteredDishData.removeAll()
            //Filter Cuisine
            
            var cuisineDataWithFilter = [String:[MenuItems]]()
            for (key, value) in self.menuDataSource{
                var menuItems = [MenuItems]()
                for selectedData in cuisineData{
                    var dishData : [MenuItems]?
                    dishData = value.filter({ (menuItem) -> Bool in
                        return  menuItem.cuisineType.isEqualToString(find:selectedData )
                    })
                    if dishData != nil{
                        menuItems.append(contentsOf: dishData!)
                    }
                }
                let items = Set(menuItems)
                if items.count != 0{
                    cuisineDataWithFilter.updateValue(Array(items), forKey: key)
                }else{
                    cuisineDataWithFilter.removeValue(forKey: key)
                }
            }
            
            //Filter Food type
            for (key, value) in cuisineDataWithFilter{
                var menuItems = [MenuItems]()
                for selectedData in foodData{
                    var dishData : [MenuItems]?
                    dishData = value.filter({ (menuItem) -> Bool in
                        return  menuItem.foodType.isEqualToString(find:selectedData )
                    })
                    if dishData != nil{
                        menuItems.append(contentsOf: dishData!)
                    }
                }
                let items = Set(menuItems)
                if items.count != 0{
                    self.sortedDataSource.removeAll()
                    self.sortedDataSource = Array(items)
                    self.filteredDishData.updateValue(Array(items), forKey: key)
                }else{
                    self.filteredDishData.removeValue(forKey: key)
                }
            }
            
            self.menuTableView.reloadData()
            
        }else if cuisineData.count == 0 && mealData.count != 0 && foodData.count != 0{
            //  var menuItems = [MenuItems]()
            self.filteredDishData.removeAll()
            
            //Filter meal first
            var mealFilterData = [String:[MenuItems]]()
            for (key, value) in self.menuDataSource{
                var menuItems = [MenuItems]()
                for selectedData in mealData{
                    var dishData : [MenuItems]?
                    dishData = value.filter({ (menuItem) -> Bool in
                        return  menuItem.mealType.isEqualToString(find: selectedData)
                    })
                    if dishData != nil{
                        menuItems.append(contentsOf: dishData!)
                    }
                }
                let items = Set(menuItems)
                if items.count != 0{
                    mealFilterData.updateValue(Array(items), forKey: key)
                }else{
                    mealFilterData.removeValue(forKey: key)
                }
            }
            
            //Filter Food type
            for (key, value) in mealFilterData{
                var menuItems = [MenuItems]()
                for selectedData in foodData{
                    var dishData : [MenuItems]?
                    dishData = value.filter({ (menuItem) -> Bool in
                        return  menuItem.foodType.isEqualToString(find:selectedData )
                    })
                    if dishData != nil{
                        menuItems.append(contentsOf: dishData!)
                    }
                }
                let items = Set(menuItems)
                if items.count != 0{
                    self.sortedDataSource.removeAll()
                    self.sortedDataSource = Array(items)
                    self.filteredDishData.updateValue(Array(items), forKey: key)
                }else{
                    self.filteredDishData.removeValue(forKey: key)
                }
            }
            
            self.menuTableView.reloadData()
            
        }else if cuisineData.count == 0 && mealData.count == 0 && foodData.count != 0{
            //  var menuItems = [MenuItems]()
            self.filteredDishData.removeAll()
            //Filter food type
            for (key, value) in self.menuDataSource{
                var menuItems = [MenuItems]()
                for selectedData in foodData{
                    var dishData : [MenuItems]?
                    dishData = value.filter({ (menuItem) -> Bool in
                        return  menuItem.foodType.isEqualToString(find:selectedData )
                    })
                    if dishData != nil{
                        menuItems.append(contentsOf: dishData!)
                    }
                }
                let items = Set(menuItems)
                if items.count != 0{
                    self.sortedDataSource.removeAll()
                    self.sortedDataSource = Array(items)
                    self.filteredDishData.updateValue(Array(items), forKey: key)
                }else{
                    self.filteredDishData.removeValue(forKey: key)
                }
            }
            self.menuTableView.reloadData()
        }else{
            self.filteredDishData = self.menuDataSource
            self.menuTableView.reloadData()
        }
        if self.filteredDishData.count == 0{
            self.showAlertViewWithTitle(title: "", Message: "We couldn't find any dish for your selection. Try some other filters.", CancelButtonTitle: "Ok")
            self.menuTableView.reloadData()
        }
    }
}
