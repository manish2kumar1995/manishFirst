//
//  MyAccountInfoVC.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 25/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
import JWTDecode
import SwipeCellKit
import Alamofire

class MyAccountInfoVC: BaseViewController {
    @IBOutlet weak var profileTableView: UITableView!
    
    //Variables
    var modes : ProfileInfoMode?
    var sectionHeader : MyAccountModeSection?
    var imagePicker = UIImagePickerController()
    var tableHeader : MyAccountHeaderSection?
    var cuisineNameArray : [CuisineData]?
    var restaurantNamesArray : [CuisineData]?
    var allergensNamesArray : [CuisineData]?
    var userHeight : Int?
    var userWeight : Int?
    var userAge : Int?
    var isEditingUser = false
    var selectedUserId : String?
    
    fileprivate struct ReusableIdentifier {
        static let myAccountHeaderSection = "MyAccountHeaderSection"
        static let myAccountModeSection = "MyAccountModeSection"
        static let basicInfocell = "BasicInfocell"
        static let preferenceGoalTableCell = "PreferenceGoalTableCell"
        static let filterHeaderTableViewCell = "FilterHeaderTableViewCell"
        static let cuisineTableSectionHeader = "CuisineTableSectionHeader"
        static let preferenceTableCell = "PreferenceTableCell"
        static let addCuisineVC = "addCuisineVC"
    }
    
    var userPreferencesDataSource = [
        PreferenceDeliveryInfo(sectionName: "CUSINES", sectionImage:"filterCusines", sectionObjects : []),
        PreferenceDeliveryInfo(sectionName: "RESTAURANTS", sectionImage:"filterCarrot",sectionObjects: []),
        PreferenceDeliveryInfo(sectionName: "ALLERGEN EXCLUSIONS", sectionImage:"filterCusines", sectionObjects : []),
        ]
    
    var userGoalDataSource = [
        PreferenceDeliveryInfo(sectionName: "ADDRESSES", sectionImage:"", sectionObjects : []),
        PreferenceDeliveryInfo(sectionName: "PHONE NUMBERS", sectionImage:"",sectionObjects: []),
        ]
    
    //Info DataSource
    var basicInfoDataSource = [BasicInfo]()
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(MyAccountInfoVC.updateUI(_:)), name: NotificationNames.userUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MyAccountInfoVC.updateContact(_:)), name: Notification.Name.init("updateContacts"), object: nil)
        self.profileTableView.delegate = self
        self.profileTableView.dataSource = self
        self.configTableView()
        DispatchQueue.main.async {
            self.getUserPreferences()
            self.getUserAddressInfo()
            self.getUserPhonesInfo()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        DispatchQueue.main.async {
            self.basicInfoDataSource = [
                BasicInfo(infoMenuIcon:"genderIcon", infoTitle:"Sex", infoSubTitle:UserShared.shared.user.gender.uppercased()),
                BasicInfo(infoMenuIcon:"ageIcon", infoTitle:"Age", infoSubTitle:"\(UserShared.shared.user.age)"),
                BasicInfo(infoMenuIcon:"heightIcon", infoTitle:"Height", infoSubTitle:"\(UserShared.shared.user.height)cm"),
                BasicInfo(infoMenuIcon:"weightIcon", infoTitle:"Weight", infoSubTitle:"\(UserShared.shared.user.weight)kg"),
                BasicInfo(infoMenuIcon:"bmiIcon", infoTitle:"Weight Goal", infoSubTitle:UserShared.shared.user.weightGoals.capitalizingFirstLetter()),
                BasicInfo(infoMenuIcon:"activityNewIcon", infoTitle:"Activity Level", infoSubTitle:(UserShared.shared.user.activityLevel).components(separatedBy: "(").first ?? ""),
                BasicInfo(infoMenuIcon:"bmiNewIcon", infoTitle:"BMI", infoSubTitle:UserShared.shared.user.bmiValue),
            ]
            self.profileTableView.reloadData()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func updateUI(_ notification: NSNotification){
        //   self.performValidationWork()
    }
    
    @objc func updateContact(_ notification: NSNotification){
        
        print(notification.userInfo ?? "")
        //  var numbers = ""
        
        if let dict = notification.object as? CuisineData? {
            self.didSelectContact(number: dict!, section: 1)
        }
        //self.performValidationWork()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination  as? AddCuisineVC{
            vc.section = (sender as? Int ) ?? 0
            if ((sender as? Int ) ?? 0) ==  0{
                //  vc.mainDataSource = self.cuisineNameArray ?? []
            }else{
            }
            vc.delegate = self
            vc.selectedCuisineData = self.userPreferencesDataSource[((sender as? Int ) ?? 0)].sectionObjects
            var cuisineArray = [String]()
            for cuisine in self.userPreferencesDataSource[((sender as? Int ) ?? 0)].sectionObjects{
                cuisineArray.append(cuisine.restaurantTitle)
            }
            vc.selectedData = cuisineArray
        }
        
        if let vc = segue.destination as? AddAddressVC{
            vc.delegate = self
            vc.section = (sender as? Int ) ?? 0
        }
        
        if let vc = segue.destination as? BMICalculatorVC{
            if UserShared.shared.user.activityLevelID.isEqualToString(find: "91c082199c334065751594ca961e6fd9"){
                vc.selectedIndex = 1
            }else if UserShared.shared.user.activityLevelID.isEqualToString(find: "598d4db9ff36443c3375e26b6553257e"){
                vc.selectedIndex = 2
            }else if UserShared.shared.user.activityLevelID.isEqualToString(find: "e59d724fac626cefce2a3bd164b5ce1c"){
                vc.selectedIndex = 3
            }else if UserShared.shared.user.activityLevelID.isEqualToString(find: "60310e0499004242abef30721bc7fde0"){
                vc.selectedIndex = 4
            }else if UserShared.shared.user.activityLevelID.isEqualToString(find: "2d4c3e4c8d32a1b6c0afc880f6316165"){
                vc.selectedIndex = 5
            }else{
                vc.selectedIndex = 1
            }
            
            if userHeight != 0{
                vc.selectedHeightCell = UserShared.shared.user.height
            }
            if userWeight != 0{
                vc.selectedKgCell = UserShared.shared.user.weight
            }
            if userAge != 0{
                vc.selectedAgeCell = UserShared.shared.user.age
            }
            vc.isEditingUser = self.isEditingUser
            vc.userName = "\(UserShared.shared.user.firstName) \(UserShared.shared.user.lastName)"
            if UserShared.shared.user.weightGoals.isEqualToString(find: "lose"){
                vc.selectedWeightGoalIndex = 1
            }else if UserShared.shared.user.weightGoals.isEqualToString(find: "maintain"){
                vc.selectedWeightGoalIndex = 2
            }else if UserShared.shared.user.weightGoals.isEqualToString(find: "gain"){
                vc.selectedWeightGoalIndex = 3
            }
            vc.selectedGender = UserShared.shared.user.gender
        }
    }
}

//MARK:- Custom methods
extension MyAccountInfoVC {
    
    func getUserAddressInfo(){
        let user = DataBaseHelper.shared.getData().first
        let token = user?.tokenId ?? ""
        var userid = String()
        do{
            let jwt = try decode(jwt: token)
            if jwt.expired{
                self.performLogout()
            }else{
                let body = jwt.body
                userid = (body["uid"] as? String) ?? ""
                self.selectedUserId = userid
            }
        }catch{
            print("Data not fetched")
        }
        if Connectivity.isConnectedToInternet{
            _ = WebAPIHandler.sharedHandler.getAddressPhones(id: userid, index: 1, success: { (response) in
                debugPrint(response)
                DispatchQueue.main.async {
                    let addresses = (response["addresses"] as? [[String:Any]] ) ?? []
                    for address in addresses{
                        var cuisineAddress = CuisineData(data: [:], index: 0)
                        let aptNo = (address["aptNo"] as? NSNumber)?.stringValue ?? ""
                        let addressDetail = (address["address"] as? String) ?? ""
                        cuisineAddress.restaurantTitle = "\(aptNo),\(addressDetail)"
                        cuisineAddress.id = (address["id"] as? String) ?? ""
                        self.userGoalDataSource[0].sectionObjects.append(cuisineAddress)
                    }
                    self.profileTableView.reloadData()
                }
            }, failure: { (error) in
                debugPrint(error)
            })
        }else{
            self.showAlertViewWithTitle(title:"", Message: Messages.internetUnavailable, CancelButtonTitle: "Ok")
        }
        //    self.profileTableView.reloadData()
    }
    
    func getUserPhonesInfo(){
        let user = DataBaseHelper.shared.getData().first
        let token = user?.tokenId ?? ""
        var userid = String()
        do{
            let jwt = try decode(jwt: token)
            if jwt.expired{
                self.performLogout()
            }else{
                let body = jwt.body
                userid = (body["uid"] as? String) ?? ""
                self.selectedUserId = userid
            }
        }catch{
            print("Data not fetched")
        }
        if Connectivity.isConnectedToInternet{
            _ = WebAPIHandler.sharedHandler.getAddressPhones(id: userid, index: 2, success: { (response) in
                debugPrint(response)
                DispatchQueue.main.async {
                    let phones = (response["phones"] as? [[String:Any]] ) ?? []
                    for phone in phones{
                        var cuisineAddress = CuisineData(data: [:], index: 0)
                        cuisineAddress.restaurantTitle = (phone["phone"] as? String) ?? ""
                        cuisineAddress.id = (phone["id"] as? String) ?? ""
                        cuisineAddress.phoneCode = (phone["dialCountry"] as? String) ?? ""
                        self.userGoalDataSource[1].sectionObjects.append(cuisineAddress)
                    }
                    self.profileTableView.reloadData()
                }
            }, failure: { (error) in
                debugPrint(error)
            })
        }else{
            self.showAlertViewWithTitle(title:"", Message: Messages.internetUnavailable, CancelButtonTitle: "Ok")
        }
        //  self.profileTableView.reloadData()
    }
    
    
    func getUserPreferences(){
        let user = DataBaseHelper.shared.getData().first
        let token = user?.tokenId ?? ""
        var userid = String()
        do{
            let jwt = try decode(jwt: token)
            if jwt.expired{
                self.performLogout()
            }else{
                let body = jwt.body
                userid = (body["uid"] as? String) ?? ""
                self.selectedUserId = userid
            }
        }catch{
            print("Data not fetched")
        }
        
        if Connectivity.isConnectedToInternet{
            _ = WebAPIHandler.sharedHandler.getUserPreferences(id: userid, success: { (response) in
                debugPrint(response)
                //    DispatchQueue.main.async {
                var cuisineArray = [CuisineData]()
                var resturantArray = [CuisineData]()
                var allergensArray = [CuisineData]()
                let preferences = (response["preferences"] as? [[String:Any]])?.first ?? [:]
                let cuisineData = (preferences["cuisines"] as? [[String:Any]]) ?? []
                for cuisine in cuisineData{
                    cuisineArray.append(CuisineData.init(data: cuisine, index : 1) )
                }
                let restaurants = (preferences["restaurants"] as? [[String:Any]]) ?? []
                for restaurant in restaurants{
                    resturantArray.append(CuisineData.init(data: restaurant, index : 1) )
                }
                let allergenExclusions = (preferences["allergens"] as? [[String:Any]]) ?? []
                for allergen in allergenExclusions{
                    allergensArray.append(CuisineData.init(data: allergen, index : 1))
                }
                
                self.userPreferencesDataSource = [
                    PreferenceDeliveryInfo(sectionName: "CUSINES", sectionImage:"filterCusines", sectionObjects : cuisineArray),
                    PreferenceDeliveryInfo(sectionName: "RESTAURANTS", sectionImage:"filterCarrot",sectionObjects: resturantArray),
                    PreferenceDeliveryInfo(sectionName: "ALLERGEN EXCLUSIONS", sectionImage:"filterCusines", sectionObjects : allergensArray),
                ]
                self.profileTableView.reloadData()
                //  }
            }, failure: { (error) in
                debugPrint(error)
            })
        }else{
            self.showAlertViewWithTitle(title:"", Message: Messages.internetUnavailable, CancelButtonTitle: "Ok")
            self.profileTableView.reloadData()
            
        }
    }
    
    func openGallary(){
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func openCamera(){
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func cancel(){
        print("Cancel tapped")
    }
    
    func configTableView(){
        self.modes = .info
        imagePicker.delegate = self
        self.profileTableView.estimatedRowHeight = 80
        self.profileTableView.rowHeight = UITableViewAutomaticDimension
        
        //Configuring Table Header
        let tableHeader = UINib.init(nibName: ReusableIdentifier.myAccountHeaderSection, bundle: Bundle.main)
        self.profileTableView.register(tableHeader, forCellReuseIdentifier: ReusableIdentifier.myAccountHeaderSection)
        
        //Registering section header
        let sectionHeader = UINib.init(nibName: ReusableIdentifier.myAccountModeSection, bundle: Bundle.main)
        self.profileTableView.register(sectionHeader, forCellReuseIdentifier:  ReusableIdentifier.myAccountModeSection)
        
        //Registering cell for Info
        let infoCell = UINib.init(nibName: ReusableIdentifier.basicInfocell, bundle: Bundle.main)
        self.profileTableView.register(infoCell, forCellReuseIdentifier:  ReusableIdentifier.basicInfocell)
        
        self.profileTableView.reloadData()
    }
    
    func performLogout(){
        self.showAlertViewWithTitle(title: "", Message: "Token expired please login first", CancelButtonTitle: "Ok")
        self.dismiss(animated: true, completion: nil)
    }
    
    func didSelectContact(number: CuisineData, section : Int){
        self.userGoalDataSource[section].sectionObjects.append(number)
        self.profileTableView.reloadData()
    }
}

//MARK:- Table View delegtae data source
extension MyAccountInfoVC : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.basicInfoDataSource.count != 0{
            if self.modes == .info{
                return 2
            }else if self.modes == .preferences{
                return self.userPreferencesDataSource.count + 2
            }else{
                return self.userGoalDataSource.count + 2
            }
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (self.modes) {
        case .info?:
            if section == 1{
                return self.basicInfoDataSource.count
            }else{
                return 0
            }
        case .preferences?:
            if section > 1{
                return (self.userPreferencesDataSource[section - 2].sectionObjects.count)
            }else{
                return 0
            }
        case .goals?:
            if section > 1{
                return (self.userGoalDataSource[section - 2].sectionObjects.count)
            }else{
                return 0
            }
        case .none:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        switch (self.modes) {
        case .info?:
            let infoCell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.basicInfocell, for: indexPath) as!  BasicInfocell
            infoCell.dataSource = self.basicInfoDataSource[indexPath.row]
            cell = infoCell
        case .preferences?:
            let preferenceCell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.preferenceTableCell) as! PreferenceSwipeTableCell
            let item = self.userPreferencesDataSource[indexPath.section - 2].sectionObjects[indexPath.row]
            preferenceCell.section = indexPath.section - 2
            preferenceCell.row = indexPath.row
            preferenceCell.delegate = self
            preferenceCell.dataSource = item
            cell = preferenceCell
        case .goals?:
            let goalCell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.preferenceTableCell) as! PreferenceSwipeTableCell
            let item = userGoalDataSource[indexPath.section - 2].sectionObjects[indexPath.row]
            goalCell.section = indexPath.section - 2
            goalCell.row = indexPath.row
            goalCell.delegate = self
            if (indexPath.section - 2) == 0{
                goalCell.initAttributes(address: item)
            }else{
                goalCell.initForContact(data: item, code : item.phoneCode)
            }
            cell = goalCell
        case .none:
            return UITableViewCell()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.modes == .info{
            if indexPath.row == 6{
                self.isEditingUser = false
                self.performSegue(withIdentifier: "bmiIdentifier", sender: nil)
            }else {
                self.isEditingUser = true
                self.performSegue(withIdentifier: "bmiIdentifier", sender: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            let headerView = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.myAccountHeaderSection) as? MyAccountHeaderSection
            
            if UserShared.shared.user.userImage != nil{
                headerView?.headerImageView.image = UserShared.shared.user.userImage
            }else{
                headerView?.headerImageView.sd_setShowActivityIndicatorView(true)
                headerView?.headerImageView.sd_setIndicatorStyle(.gray)
                headerView?.headerImageView.sd_setImage(with: URL(string:  UserShared.shared.user.imageName), placeholderImage: nil)
            }
            DispatchQueue.main.async {
                headerView?.headerImageView.layer.cornerRadius = 57.5
            }
            headerView?.delegate = self
            self.tableHeader = headerView
            return headerView?.contentView
        }else if section == 1 {
            if sectionHeader != nil {
                sectionHeader?.labelUserName.text = "\(UserShared.shared.user.firstName) \(UserShared.shared.user.lastName)"
                return sectionHeader
            }else{
                sectionHeader = (tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.myAccountModeSection) as? MyAccountModeSection)
                sectionHeader?.delegate = self
                sectionHeader?.labelUserName.text = "\(UserShared.shared.user.firstName) \(UserShared.shared.user.lastName)"
                sectionHeader?.selectionStyle = .none
                return sectionHeader
            }
        }
        switch (self.modes) {
        case .info?:
            return nil
        case .preferences?:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.cuisineTableSectionHeader) as! CuisineTableSectionHeader
            cell.section = section - 2
            cell.labelTitle.text = self.userPreferencesDataSource[section - 2].sectionName
            cell.delegate = self
            return cell
        case .goals?:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.cuisineTableSectionHeader) as! CuisineTableSectionHeader
            cell.section = section - 2
            cell.labelTitle.text = userGoalDataSource[section - 2].sectionName
            cell.delegate = self
            return cell
        case .none:
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 130
        }else if section == 1{
            return 125
        }else{
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (self.modes) {
        case .info?:
            return 90
        case .preferences?:
            return 45
        case .goals?:
            return 45
        case .none:
            return 0
        }
    }
}

//MARK:- Profile modes delegate
extension MyAccountInfoVC : MyAccountModeSectionDelegate {
    func changeProfileMode(mode: ProfileInfoMode?) {
        self.modes = mode!
        self.profileTableView.reloadData()
    }
}

//MARK:- Cuisine Table Section Header Delegate
extension MyAccountInfoVC : CuisineTableSectionHeaderDelegate{
    func didTapOnAdd(section : Int) {
        if self.modes == .preferences{
            self.performSegue(withIdentifier: ReusableIdentifier.addCuisineVC, sender: section)
        }else{
            if section == 0{
                self.performSegue(withIdentifier: "addAddressSegue", sender: section)
            }else{
                self.performSegue(withIdentifier: "addCountrySegue", sender: section)
            }
        }
    }
}

//MARK:- MY account header delgate
extension MyAccountInfoVC : MyAccountHeaderSectionDelegate {
    func didTapOnImage() {
        imagePicker.delegate = self
        imagePicker.sourceType = .savedPhotosAlbum;
        imagePicker.allowsEditing = false
        
        let alert = UIAlertController(title: "Profile Picture Options", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let gallaryAction = UIAlertAction(title: "Open Gallery", style: UIAlertActionStyle.default)
        {
            UIAlertAction in self.openGallary()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
        {
            UIAlertAction in self.cancel()
        }
        
        let cameraAction = UIAlertAction(title: "Open Camera", style: UIAlertActionStyle.default)
        {
            UIAlertAction in self.openCamera()
        }
        alert.addAction(gallaryAction)
        alert.addAction(cameraAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func didTapOnLogout(){
        DataBaseHelper.shared.emptyCoreData()
        UserShared.shared.myBasketModel.myBasketData = []
        UserShared.shared.myBasketModel.totalQAR = 0.0
        UserShared.shared.myBasketModel.totalCart = 0
        UserShared.shared.isSubscriptionMode = false
        UserShared.shared.userSavedAddress = nil
        UserShared.shared.user = UserInfo()
        UserShared.shared.currentAddress = ""
        UserShared.shared.userMode = "subscription"
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginVC") as! UINavigationController
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
}

//MARK:- Image picker Delegate
extension MyAccountInfoVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        
        DispatchQueue.main.async {
            self.tableHeader?.headerImageView.layer.cornerRadius = 57.5
            self.tableHeader?.headerImageView.contentMode = .scaleAspectFill //3
            self.tableHeader?.headerImageView.layer.cornerRadius = 57.5
        }
        
        let user = DataBaseHelper.shared.getData().first
        let token = user?.tokenId ?? ""
        var userid = String()
        var email = String()
        do{
            let jwt = try decode(jwt: token)
            if jwt.expired{
                self.performLogout()
            }else{
                let body = jwt.body
                userid = (body["uid"] as? String) ?? ""
                email = (body["uemail"] as? String) ?? ""
            }
        }catch{
            print("Data not fetched")
        }
        let data = UIImageJPEGRepresentation(chosenImage, 0)!
        if Connectivity.isConnectedToInternet{
            //                            "file": data,
            
            let parameters = [
                "first_name": "\(UserShared.shared.user.firstName)",
                "last_name": "\(UserShared.shared.user.lastName)",
                "email": "\(email)",
                "age": "\(UserShared.shared.user.age)",
                "gender": "\(UserShared.shared.user.gender)",
                "height": "\(UserShared.shared.user.height)",
                "weight": "\(UserShared.shared.user.weight)",
                "daily_calorie_allowance": "\(UserShared.shared.user.dailyCaloryAllowance)",
                "activity_level_id": "\(UserShared.shared.user.activityLevelID)",
                "weight_recommendation": "\(UserShared.shared.user.weightRecommendation.lowercasingFirstLetter())",
                "bmi_value": "\(UserShared.shared.user.bmiValue)",
                "bmi_classification": "\(UserShared.shared.user.bmiClassification)",
                "weight_goal" : "\(UserShared.shared.user.weightGoals)"
                ] as [String : Any]
            
            self.showHud(message: "Uploading ...")
            _ = WebAPIHandler.sharedHandler.updateUserMultiparts(parameter: parameters, uid: userid, token: token, imageData: data, success: { (response) in
                debugPrint(response)
                self.hideHud()
                let success = (response["success"] as? Bool) ?? false
                if success{
                    UserShared.shared.user.userImage = chosenImage
                    //   NotificationCenter.default.post(name: NotificationNames.userUpdate, object: nil, userInfo: nil)
                    self.profileTableView.reloadData()
                }else{
                    let meta = (response["meta"] as? [String:Any]) ?? [:]
                    let message = (meta["message"] as? String) ?? ""
                    self.showAlertViewWithTitle(title: "", Message: message, CancelButtonTitle: "Ok")
                }
            }, failure: { (error) in
                self.hideHud()
                debugPrint(error)
                self.showAlertViewWithTitle(title: "", Message: "Some error occured", CancelButtonTitle: "Ok")
            })
            
        }else{
            self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "Ok")
        }
        
        dismiss(animated:true, completion: nil)
    }
}

//MARK:- Preference cell delegate
extension MyAccountInfoVC : PreferenceGoalTableCellDelegate{
    func didTapOnCheckButton(section: Int?, row: Int?) {
        if self.modes == .preferences{
        }else{
            for index in 0..<self.userGoalDataSource[section! - 2].sectionObjects.count{
                if index == row{
                    //     self.goalDataSource[section! - 2].sectionObjects[index].isCheck = true
                }else{
                    //    self.goalDataSource[section! - 2].sectionObjects[index].isCheck = false
                }
            }
        }
        self.profileTableView.reloadData()
    }
}

//MARK:- Add cuisine  delegate
extension MyAccountInfoVC : AddCuisineVCDelegate{
    func initializeDataSource(section: Int, data: [CuisineData]) {
        if section == 0{
            if self.cuisineNameArray?.count == nil{
                self.cuisineNameArray = data
            }
        }else if section == 1{
            if self.restaurantNamesArray?.count == nil{
                self.restaurantNamesArray = data
            }
        }else{
            if self.allergensNamesArray?.count == nil{
                self.allergensNamesArray = data
            }
        }
    }
    
    func sendTheSelectedData(data: [CuisineData], section: Int) {
        self.userPreferencesDataSource[section].sectionObjects.append(contentsOf: data)
        self.profileTableView.reloadData()
    }
}


//MARK:- Swipe Table View Cell Delegate
extension MyAccountInfoVC : SwipeTableViewCellDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            let user = DataBaseHelper.shared.getData().first
            let token = user?.tokenId ?? ""
            var userid = String()
            do{
                let jwt = try decode(jwt: token)
                if jwt.expired{
                    self.performLogout()
                }else{
                    let body = jwt.body
                    userid = (body["uid"] as? String) ?? ""
                }
            }catch{
                print("Data not fetched")
            }
            
            if self.modes == .preferences{
                //MARK:- Deleting preferences
                let itemId = self.userPreferencesDataSource[indexPath.section - 2].sectionObjects[indexPath.row].id
                let item = self.userPreferencesDataSource[indexPath.section - 2].sectionObjects[indexPath.row]
                self.userPreferencesDataSource[indexPath.section - 2].sectionObjects.remove(at: indexPath.row)
                if Connectivity.isConnectedToInternet{
                    self.showHud(message: "deleting...")
                    if (indexPath.section - 2) == 0{
                        _ = WebAPIHandler.sharedHandler.deletePreferenceCuisines(id: userid, index: 1, itemId: itemId, success: { (response) in
                            debugPrint(response)
                            self.hideHud()
                            let success = (response["success"] as? Bool) ?? false
                            if success{
                            }else{
                                let meta = (response["meta"] as? [String:Any]) ?? [:]
                                let message = (meta["message"] as? String) ?? ""
                                self.userPreferencesDataSource[indexPath.section - 2].sectionObjects.insert(item, at: indexPath.row)
                                self.showAlertViewWithTitle(title: "", Message: message, CancelButtonTitle: "Ok")
                                self.profileTableView.reloadData()
                            }
                            
                        }, failure: { (error) in
                            debugPrint(error)
                            self.hideHud()
                        })
                    }else if (indexPath.section - 2) == 1{
                        _ = WebAPIHandler.sharedHandler.deletePreferenceCuisines(id: userid, index: 2, itemId: itemId, success: { (response) in
                            debugPrint(response)
                            self.hideHud()
                            let success = (response["success"] as? Bool) ?? false
                            if success{
                            }else{
                                let meta = (response["meta"] as? [String:Any]) ?? [:]
                                let message = (meta["message"] as? String) ?? ""
                                self.userPreferencesDataSource[indexPath.section - 2].sectionObjects.insert(item, at: indexPath.row)
                                self.showAlertViewWithTitle(title: "", Message: message, CancelButtonTitle: "Ok")
                                self.profileTableView.reloadData()
                            }
                        }, failure: { (error) in
                            debugPrint(error)
                            self.hideHud()
                        })
                    }else{
                        _ = WebAPIHandler.sharedHandler.deletePreferenceCuisines(id: userid, index: 3, itemId: itemId, success: { (response) in
                            debugPrint(response)
                            self.hideHud()
                            let success = (response["success"] as? Bool) ?? false
                            if success{
                            }else{
                                let meta = (response["meta"] as? [String:Any]) ?? [:]
                                let message = (meta["message"] as? String) ?? ""
                                self.userPreferencesDataSource[indexPath.section - 2].sectionObjects.insert(item, at: indexPath.row)
                                self.showAlertViewWithTitle(title: "", Message: message, CancelButtonTitle: "Ok")
                                self.profileTableView.reloadData()
                            }
                        }, failure: { (error) in
                            debugPrint(error)
                            self.hideHud()
                        })
                    }
                }else{
                    self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "Ok")
                }
                action.fulfill(with: .delete)
                self.profileTableView.reloadData()
                
            }else{
                //MARK:- Deleting goals
                let itemId = self.userGoalDataSource[indexPath.section - 2].sectionObjects[indexPath.row].id
                let item = self.userGoalDataSource[indexPath.section - 2].sectionObjects[indexPath.row]
                self.userGoalDataSource[indexPath.section - 2].sectionObjects.remove(at: indexPath.row)
                if Connectivity.isConnectedToInternet{
                    self.showHud(message: "deleting...")
                    if (indexPath.section - 2) == 0{
                        _ = WebAPIHandler.sharedHandler.deleteUserDeliveryInfo(id: userid, index: 1, itemId: itemId, success: { (response) in
                            debugPrint(response)
                            self.hideHud()
                            let success = (response["success"] as? Bool) ?? false
                            if success{
                            }else{
                                let meta = (response["meta"] as? [String:Any]) ?? [:]
                                let message = (meta["message"] as? String) ?? ""
                                self.userGoalDataSource[indexPath.section - 2].sectionObjects.insert(item, at: indexPath.row)
                                self.showAlertViewWithTitle(title: "", Message: message, CancelButtonTitle: "Ok")
                                self.profileTableView.reloadData()
                            }
                            
                        }, failure: { (error) in
                            debugPrint(error)
                            self.hideHud()
                        })
                    }else if (indexPath.section - 2) == 1{
                        _ = WebAPIHandler.sharedHandler.deleteUserDeliveryInfo(id: userid, index: 2, itemId: itemId, success: { (response) in
                            debugPrint(response)
                            self.hideHud()
                            let success = (response["success"] as? Bool) ?? false
                            if success{
                            }else{
                                let meta = (response["meta"] as? [String:Any]) ?? [:]
                                let message = (meta["message"] as? String) ?? ""
                                self.userGoalDataSource[indexPath.section - 2].sectionObjects.insert(item, at: indexPath.row)
                                self.showAlertViewWithTitle(title: "", Message: message, CancelButtonTitle: "Ok")
                                self.profileTableView.reloadData()
                            }
                        }, failure: { (error) in
                            debugPrint(error)
                            self.hideHud()
                        })
                    }
                    
                }else{
                    self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "Ok")
                }
                action.fulfill(with: .delete)
                self.profileTableView.reloadData()
            }
        }
        deleteAction.hidesWhenSelected = true
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive(automaticallyDelete: false)
        options.transitionStyle = .border
        options.expansionStyle = orientation == .left ? .destructive : .destructive
        options.transitionStyle = SwipeOptions().transitionStyle
        options.buttonSpacing = 11
        return options
    }
}

//MARK:- Add address Delegate
extension MyAccountInfoVC : AddAddressVCDelegate{
    func didSelectAddress(address: CuisineData, section :Int) {
        userGoalDataSource[section].sectionObjects.append(address)
        self.profileTableView.reloadData()
    }
}


