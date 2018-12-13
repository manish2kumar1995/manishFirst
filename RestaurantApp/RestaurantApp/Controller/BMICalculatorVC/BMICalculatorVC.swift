//
//  BMICalculatorVC.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 11/13/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
import JWTDecode

class BMICalculatorVC: BaseViewController {
    
    //MARK:- IBOutlets
    @IBOutlet weak var heightCollectionView: UICollectionView!
    @IBOutlet weak var kgCollectionView: UICollectionView!
    @IBOutlet weak var ageCollectionView: UICollectionView!
    @IBOutlet weak var viewModeOutlet: UIView!
    @IBOutlet weak var buttonCalculateBMI: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var labelActivity: UILabel!
    @IBOutlet weak var viewFemaleOutlet: UIView!
    @IBOutlet weak var viewMaleOutlet: UIView!
    @IBOutlet weak var viewAgeOutlet: UIView!
    @IBOutlet weak var viewKgOutlet: UIView!
    @IBOutlet weak var labelActivityDay: UILabel!
    @IBOutlet weak var maleImageView: UIImageView!
    @IBOutlet weak var femaleImageView: UIImageView!
    @IBOutlet weak var viewWeightGoals: UIView!
    @IBOutlet weak var labelWeightGoals: UILabel!
    
    @IBOutlet weak var nameTextFieldHeightConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    private var collectionViewLayout: LGHorizontalLinearFlowLayout!
    private var agecollectionViewLayout: LGHorizontalLinearFlowLayout!
    private var kgcollectionViewLayout: LGHorizontalLinearFlowLayout!
    
    var heightDataSource: [String] = []
    var ageDataSource : [String] = []
    var weightDataSource : [String] = []
    var selectedCell : Int?
    var selectedDataAgeCell : Int?
    var selectedDataWeightCell : Int?
    var selectedAgeCell : Int?
    var selectedKgCell : Int?
    var selectedHeightCell : Int?
    var selectedIndex : Int?
    var selectedHeight = String()
    var selectedAge = String()
    var selectedWight = String()
    var selectedActivityId = String()
    var selectedGender = String()
    var bmiResultData = [String:Any]()
    var ageSelectedIndex = 0
    var weightSelectedIndex = 0
    var heightSelectedIndex = 0
    var isEditingUser : Bool?
    var selectedWeightGoalIndex : Int?
    var selectedWeightGoals : String?
    var userName : String?
    var activityLevel : String?
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //Preparing Data source
        for index in 160..<200{
            self.heightDataSource.append("\(index)")
        }
        
        for index in 18..<90{
            self.ageDataSource.append("\(index)")
        }
        
        for index in 30..<190{
            self.weightDataSource.append("\(index)")
        }
        
        self.configCollectionView()
        self.nameTextField.delegate = self
        self.nameTextField.textColor = UIColor.borderedRed
        if (self.isEditingUser ?? false){
            self.setNavigation(title: "Edit Profile")
            self.nameTextField.text = self.userName
            self.buttonCalculateBMI.setTitle("Save Details", for: .normal)
        }else{
            self.nameTextFieldHeightConstraints.constant = 0.0
            self.setNavigation(title:"BMI Calculator")
            self.buttonCalculateBMI.setTitle("Calculate My BMI", for: .normal)
        }
        self.configActiveButonWith(index: self.selectedIndex ?? 0)
        self.configWeightGoalWith(index: self.selectedWeightGoalIndex ?? 1)
        
        if (self.selectedAgeCell ?? 0) != 0{
            self.ageSelectedIndex = (self.selectedAgeCell ?? 18) - 18
        }
        if (self.selectedHeightCell ?? 0) != 0{
            self.heightSelectedIndex = (self.selectedHeightCell ?? 160) - 160
        }
        if (self.selectedKgCell ?? 0) != 0{
            self.weightSelectedIndex = (self.selectedKgCell ?? 30) - 30
        }
        self.configUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? BMIResultVC{
            vc.selectedHeight = self.selectedHeight
            vc.selectedWeight = self.selectedWight
            vc.selectedActivityId = self.selectedActivityId
            vc.selectedAge = self.selectedAge
            vc.selectedGender = self.selectedGender
            vc.selectedGoals = self.selectedWeightGoals
            vc.bmiData = self.bmiResultData
            vc.activityLevel = self.activityLevel ?? ""
        }
    }
    
    
    @IBAction func calculateBMIAction(_ sender: Any) {
        if self.selectedCell == 0{
            self.selectedHeight = self.heightDataSource[0]
        }
        
        if self.selectedDataAgeCell == 0{
            self.selectedAge = self.ageDataSource[0]
        }
        
        if self.selectedDataWeightCell == 0{
            self.selectedWight = self.weightDataSource[0]
        }
        
        if (self.isEditingUser ?? false){
            let user = DataBaseHelper.shared.getData().first
            let token = user?.tokenId ?? ""
            var userid = String()
            var email = String()
            do{
                let jwt = try decode(jwt: token)
                if jwt.expired{
                    //   self.performLogout()
                }else{
                    let body = jwt.body
                    userid = (body["uid"] as? String) ?? ""
                    email = (body["uemail"] as? String) ?? ""
                }
            }catch{
                print("Data not fetched")
            }
            
            let trimmedName = self.nameTextField.text?.trim()
            let firstName = trimmedName?.components(separatedBy: " ").first ?? ""
            var lastName = ""
            if (trimmedName?.components(separatedBy: " ").count)! > 1{
                lastName = trimmedName?.components(separatedBy: " ").last ?? ""
            }
            let parameters = [
                "file": "",
                "first_name": "\(firstName)",
                "last_name": "\(lastName)",
                "email": "\(email)",
                "age": "\(self.selectedAge)",
                "gender": "\(self.selectedGender)",
                "height": "\(self.selectedHeight)",
                "weight": "\(self.selectedWight)",
                "daily_calorie_allowance": "\(UserShared.shared.user.dailyCaloryAllowance)",
                "activity_level_id": "\(self.selectedActivityId)",
                "weight_recommendation": "\(UserShared.shared.user.weightRecommendation.lowercasingFirstLetter())",
                "bmi_value": "\(UserShared.shared.user.bmiValue)",
                "bmi_classification": "\(UserShared.shared.user.bmiClassification)",
                "weight_goal" : "\(self.selectedWeightGoals ?? "")"
            ]
            
            if Connectivity.isConnectedToInternet{
                self.showHud(message: "Updating profile..")
                _ = WebAPIHandler.sharedHandler.updateUserDetail(parameter: parameters, uid: userid,token : token,  success: { (response) in
                    self.hideHud()
                    debugPrint(response)
                    let meta = (response["meta"] as? [String:Any]) ?? [:]
                    let message = (meta["message"] as? String) ?? ""
                    let success = (response["success"] as? Bool) ?? false
                    if success{
                        UserShared.shared.user.firstName = firstName.uppercased()
                        UserShared.shared.user.lastName = lastName.uppercased()
                        UserShared.shared.user.email = email
                        UserShared.shared.user.age = Int(self.selectedAge) ?? 0
                        UserShared.shared.user.gender = self.selectedGender
                        UserShared.shared.user.height = Int(self.selectedHeight) ?? 0
                        UserShared.shared.user.weight = Int(self.selectedWight) ?? 0
                        UserShared.shared.user.weightGoals = self.selectedWeightGoals ?? ""
                        UserShared.shared.user.activityLevel = "\(self.labelActivity.text ?? "")(\(self.labelActivityDay.text ?? ""))"
                        UserShared.shared.user.activityLevelID = self.selectedActivityId
                        self.navigationController?.popViewController(animated: true)
                    }else{
                        self.showAlertViewWithTitle(title: "", Message: message, CancelButtonTitle: "Ok")
                    }
                }, failure: { (error) in
                    debugPrint(error)
                    self.hideHud()
                })
            }else{
                self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "Ok")
            }
            
        }else{
            if Connectivity.isConnectedToInternet{
                self.callAPIForBMICalculate()
            }else{
                self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "ok")
            }
        }
    }
    
    @IBAction func weightGoalsAction(_ sender: UIButton) {
        if sender.tag == 1{
            //Decrease index
            self.selectedWeightGoalIndex = (self.selectedWeightGoalIndex ?? 2) - 1
            if (self.selectedWeightGoalIndex ?? 0 ) < 1{
                self.selectedWeightGoalIndex = 3
                self.configWeightGoalWith(index: self.selectedWeightGoalIndex ?? 0)
            }else{
                self.configWeightGoalWith(index: self.selectedWeightGoalIndex ?? 0)
            }
        }else{
            //Increase index
            self.selectedWeightGoalIndex = (self.selectedWeightGoalIndex ?? 2)! + 1
            if (self.selectedWeightGoalIndex ?? 0) > 3{
                self.selectedWeightGoalIndex = 1
                self.configWeightGoalWith(index: self.selectedWeightGoalIndex ?? 0)
            }else{
                self.configWeightGoalWith(index: self.selectedWeightGoalIndex ?? 0)
            }
        }
    }
    
    @objc func handleLeftGoalSwipe(){
        //Increase index
        self.selectedWeightGoalIndex = (self.selectedWeightGoalIndex ?? 3)! + 1
        if (self.selectedWeightGoalIndex ?? 0) > 3{
            self.selectedWeightGoalIndex = 1
            self.configWeightGoalWith(index: self.selectedWeightGoalIndex ?? 0)
        }else{
            self.configWeightGoalWith(index: self.selectedWeightGoalIndex ?? 0)
        }
    }
    
    @objc func handleRightGoalSwipe(){
        //Decrease index
        self.selectedWeightGoalIndex = (self.selectedWeightGoalIndex ?? 1) - 1
        if (self.selectedWeightGoalIndex ?? 0 ) < 1{
            self.selectedWeightGoalIndex = 3
            self.configWeightGoalWith(index: self.selectedWeightGoalIndex ?? 0)
        }else{
            self.configWeightGoalWith(index: self.selectedWeightGoalIndex ?? 0)
        }
    }
    
    
    @IBAction func activeButtonAction(_ sender: UIButton) {
        if sender.tag == 1{
            //Decrease index
            self.selectedIndex = (self.selectedIndex ?? 4) - 1
            if (self.selectedIndex ?? 0 ) < 1{
                self.selectedIndex = 5
                self.configActiveButonWith(index: self.selectedIndex ?? 0)
            }else{
                self.configActiveButonWith(index: self.selectedIndex ?? 0)
            }
        }else{
            //Increase index
            self.selectedIndex = (self.selectedIndex ?? 2)! + 1
            if (self.selectedIndex ?? 0) > 5{
                self.selectedIndex = 1
                self.configActiveButonWith(index: self.selectedIndex ?? 0)
            }else{
                self.configActiveButonWith(index: self.selectedIndex ?? 0)
            }
        }
    }
    
    @objc func handleLeftSwipe(){
        self.selectedIndex = (self.selectedIndex ?? 2)! + 1
        if (self.selectedIndex ?? 0) > 5{
            self.selectedIndex = 1
            self.configActiveButonWith(index: self.selectedIndex ?? 0)
        }else{
            self.configActiveButonWith(index: self.selectedIndex ?? 0)
        }
    }
    
    @objc func handleRightSwipe(){
        self.selectedIndex = (self.selectedIndex ?? 4) - 1
        if (self.selectedIndex ?? 0 ) < 1{
            self.selectedIndex = 5
            self.configActiveButonWith(index: self.selectedIndex ?? 0)
        }else{
            self.configActiveButonWith(index: self.selectedIndex ?? 0)
        }
    }
}

//MARK:- Custom Methods
extension BMICalculatorVC{
    
    @objc func handleMaleTap(_ sender: UITapGestureRecognizer) {
        self.viewMaleOutlet.addGradienBorder(view: self.viewMaleOutlet)
        self.maleImageView.image = #imageLiteral(resourceName: "colourMaleGender")
        self.femaleImageView.image = #imageLiteral(resourceName: "fadeFemaleGender")
        self.selectedGender = "male"
        self.viewMaleOutlet.backgroundColor = UIColor.white
        self.viewFemaleOutlet.backgroundColor = UIColor.viewBackgroundGray
        self.viewFemaleOutlet.removeGradient(view: self.viewFemaleOutlet)
    }
    
    @objc func handleFemaleTap(_ sender: UITapGestureRecognizer) {
        self.viewFemaleOutlet.addGradienBorder(view: self.viewFemaleOutlet)
        self.maleImageView.image = #imageLiteral(resourceName: "fadeMaleGender")
        self.femaleImageView.image = #imageLiteral(resourceName: "colourFemaleGender")
        self.selectedGender = "female"
        self.viewFemaleOutlet.backgroundColor = UIColor.white
        self.viewMaleOutlet.backgroundColor = UIColor.viewBackgroundGray
        self.viewMaleOutlet.removeGradient(view: self.viewMaleOutlet)
    }
    
    func configUI(){
        
        let maleTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleMaleTap(_:)))
        self.viewMaleOutlet.addGestureRecognizer(maleTapGesture)
        
        let femaleTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleFemaleTap(_:)))
        self.viewFemaleOutlet.addGestureRecognizer(femaleTapGesture)
        
        let left = UISwipeGestureRecognizer(target : self, action : #selector(BMICalculatorVC.handleLeftSwipe))
        left.direction = .left
        self.viewModeOutlet.addGestureRecognizer(left)
        
        let right = UISwipeGestureRecognizer(target : self, action : #selector(BMICalculatorVC.handleRightSwipe))
        right.direction = .right
        self.viewModeOutlet.addGestureRecognizer(right)
        
        let leftGoal = UISwipeGestureRecognizer(target : self, action : #selector(BMICalculatorVC.handleLeftGoalSwipe))
        leftGoal.direction = .left
        self.viewWeightGoals.addGestureRecognizer(leftGoal)
        
        let rightGoal = UISwipeGestureRecognizer(target : self, action : #selector(BMICalculatorVC.handleRightGoalSwipe))
        rightGoal.direction = .right
        self.viewWeightGoals.addGestureRecognizer(rightGoal)
        
        
        DispatchQueue.main.async {
            //Adding shadow to bottom view
            self.bottomView.layer.masksToBounds = false
            self.bottomView.layer.shadowRadius = 20.0
            self.bottomView.layer.shadowColor = UIColor.lightGray.cgColor
            self.bottomView.layer.shadowOffset = CGSize(width: 1.0, height: 5.0)
            self.bottomView.layer.shadowOpacity = 1.0
            
            self.buttonCalculateBMI.layer.cornerRadius = self.buttonCalculateBMI.frame.size.height/2
            DispatchQueue.main.async {
                self.viewModeOutlet.layer.cornerRadius = 5.0
                self.viewMaleOutlet.layer.cornerRadius = 5.0
                self.viewFemaleOutlet.layer.cornerRadius = 5.0
                self.viewMaleOutlet.layer.borderWidth = 0.0
                
                if self.selectedGender.isEqualToString(find: "male"){
                    self.handleMaleTap(UITapGestureRecognizer())
                }else{
                    self.handleFemaleTap(UITapGestureRecognizer())
                }
                self.viewModeOutlet.addGradienBorder(view: self.viewModeOutlet)
                self.viewWeightGoals.addGradienBorder(view: self.viewWeightGoals)
                self.addGradienBorderToTextField(view: self.nameTextField)
                let heightIndex = IndexPath(item: self.heightSelectedIndex, section: 0)
                self.heightCollectionView.scrollToItem(at: heightIndex, at: [.centeredVertically,   .centeredHorizontally], animated: true)
                
                let ageIndex = IndexPath(item: self.ageSelectedIndex, section: 0)
                self.ageCollectionView.scrollToItem(at: ageIndex, at: [.centeredVertically,   .centeredHorizontally], animated: true)
                
                let weightIndex = IndexPath(item: self.weightSelectedIndex, section: 0)
                self.kgCollectionView.scrollToItem(at: weightIndex, at: [.centeredVertically,   .centeredHorizontally], animated: true)
                
            }
            
            self.viewAgeOutlet.layer.cornerRadius = 5.0
            self.viewKgOutlet.layer.cornerRadius = 5.0
        }
    }
    
    func addGradienBorderToTextField(view : UITextField) {
        let gradient = CAGradientLayer()
        gradient.frame =  CGRect(origin: .zero, size: view.frame.size)
        gradient.colors = [UIColor.shadeOrange.cgColor, UIColor.borderedRed.cgColor]
        gradient.startPoint = CGPoint(x: 0.0,y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0,y: 0.5)
        let shape = CAShapeLayer()
        shape.lineWidth = 2.5
        shape.path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [.topLeft, .bottomLeft, .topRight, .bottomRight], cornerRadii: CGSize(width: 7.0, height: 7.0)).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        view.layer.addSublayer(gradient)
    }
    
    
    func configCollectionView(){
        heightCollectionView.showsHorizontalScrollIndicator = false
        ageCollectionView.showsHorizontalScrollIndicator = false
        kgCollectionView.showsHorizontalScrollIndicator = false
        selectedCell = 0
        selectedDataAgeCell = 0
        selectedDataWeightCell = 0
        
        heightCollectionView.isPagingEnabled = false
        heightCollectionView.delegate = self
        heightCollectionView.dataSource = self
        ageCollectionView.delegate = self
        ageCollectionView.dataSource = self
        kgCollectionView.delegate = self
        kgCollectionView.dataSource = self
        let size = CGSize.init(width: 70, height: 70)
        let sizeForAge = CGSize.init(width: 40, height: 40)
        
        self.collectionViewLayout = LGHorizontalLinearFlowLayout
            .configureLayout(collectionView: heightCollectionView, itemSize:size, minimumLineSpacing: 2)
        self.agecollectionViewLayout = LGHorizontalLinearFlowLayout
            .configureLayout(collectionView: ageCollectionView, itemSize:sizeForAge, minimumLineSpacing: 2)
        self.kgcollectionViewLayout = LGHorizontalLinearFlowLayout
            .configureLayout(collectionView: kgCollectionView, itemSize:sizeForAge, minimumLineSpacing: 2)
    }
    
    func findCenterIndex(scrollView: UIScrollView, slideCollectionView: UICollectionView) {
        let collectionOrigin = slideCollectionView.bounds.origin
        let collectionWidth = slideCollectionView.bounds.width
        var centerPoint: CGPoint!
        var newX: CGFloat!
        if collectionOrigin.x > 0 {
            newX = collectionOrigin.x + collectionWidth / 2
            centerPoint = CGPoint(x: newX, y: collectionOrigin.y)
        }else{
            newX = collectionWidth / 2
            centerPoint = CGPoint(x: newX, y: collectionOrigin.y)
        }
        
        let index = slideCollectionView.indexPathForItem(at: centerPoint)
        let indexPath = IndexPath.init(row: 0, section: 0)
        let cell = slideCollectionView.cellForItem(at: indexPath) as? SlidingCollectionCell
        
        if(index != nil){
            for cell in slideCollectionView.visibleCells  {
                let currentCell = cell as! SlidingCollectionCell
                currentCell.labelValue.textColor = UIColor.black
            }
            
            let cell = slideCollectionView.cellForItem(at: index!) as? SlidingCollectionCell
            if(cell != nil){
                selectedCell = slideCollectionView.indexPath(for: cell!)?.item
            }
            slideCollectionView.reloadData()
        }else if(cell != nil){
            selectedCell = slideCollectionView.indexPath(for: cell!)?.item
            
            let actualPosition = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
            for cellView in slideCollectionView.visibleCells{
                let currentCell = cellView as? SlidingCollectionCell
                currentCell!.labelValue.textColor = UIColor.borderedRed
                if selectedCell == 1{
                    print("this is one")
                }
                
                if(currentCell == cell! && (selectedCell == 0 || selectedCell == 1 || selectedCell == 2) && actualPosition.x > 0){
                    selectedCell = slideCollectionView.indexPath(for: cell!)?.item
                }
            }
        }
    }
    
    func findCenterIndexForAge(scrollView: UIScrollView, slideCollectionView: UICollectionView) {
        let collectionOrigin = slideCollectionView.bounds.origin
        let collectionWidth = slideCollectionView.bounds.width
        var centerPoint: CGPoint!
        var newX: CGFloat!
        if collectionOrigin.x > 0 {
            newX = collectionOrigin.x + collectionWidth / 2
            centerPoint = CGPoint(x: newX, y: collectionOrigin.y)
        }else{
            newX = collectionWidth / 2
            centerPoint = CGPoint(x: newX, y: collectionOrigin.y)
        }
        
        let index = slideCollectionView.indexPathForItem(at: centerPoint)
        let indexPath = IndexPath.init(row: 0, section: 0)
        let cell = slideCollectionView.cellForItem(at: indexPath) as? SlidingCollectionCell
        
        if(index != nil){
            for cell in slideCollectionView.visibleCells  {
                let currentCell = cell as! SlidingCollectionCell
                currentCell.labelValue.textColor = UIColor.black
            }
            
            let cell = slideCollectionView.cellForItem(at: index!) as? SlidingCollectionCell
            if(cell != nil){
                selectedDataAgeCell = slideCollectionView.indexPath(for: cell!)?.item
            }
            slideCollectionView.reloadData()
        }else if(cell != nil){
            selectedDataAgeCell = slideCollectionView.indexPath(for: cell!)?.item
            
            let actualPosition = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
            for cellView in slideCollectionView.visibleCells{
                let currentCell = cellView as? SlidingCollectionCell
                currentCell!.labelValue.textColor = UIColor.borderedRed
                if selectedDataAgeCell == 1{
                    print("this is one")
                }
                
                if(currentCell == cell! && (selectedDataAgeCell == 0 || selectedDataAgeCell == 1 || selectedDataAgeCell == 2) && actualPosition.x > 0){
                    selectedDataAgeCell = slideCollectionView.indexPath(for: cell!)?.item
                }
            }
        }
    }
    
    func findCenterIndexForWeight(scrollView: UIScrollView, slideCollectionView: UICollectionView) {
        let collectionOrigin = slideCollectionView.bounds.origin
        let collectionWidth = slideCollectionView.bounds.width
        var centerPoint: CGPoint!
        var newX: CGFloat!
        if collectionOrigin.x > 0 {
            newX = collectionOrigin.x + collectionWidth / 2
            centerPoint = CGPoint(x: newX, y: collectionOrigin.y)
        }else{
            newX = collectionWidth / 2
            centerPoint = CGPoint(x: newX, y: collectionOrigin.y)
        }
        
        let index = slideCollectionView.indexPathForItem(at: centerPoint)
        let indexPath = IndexPath.init(row: 0, section: 0)
        let cell = slideCollectionView.cellForItem(at: indexPath) as? SlidingCollectionCell
        
        if(index != nil){
            for cell in slideCollectionView.visibleCells  {
                let currentCell = cell as! SlidingCollectionCell
                currentCell.labelValue.textColor = UIColor.black
            }
            
            let cell = slideCollectionView.cellForItem(at: index!) as? SlidingCollectionCell
            if(cell != nil){
                selectedDataWeightCell = slideCollectionView.indexPath(for: cell!)?.item
            }
            slideCollectionView.reloadData()
        }else if(cell != nil){
            selectedDataWeightCell = slideCollectionView.indexPath(for: cell!)?.item
            
            let actualPosition = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
            for cellView in slideCollectionView.visibleCells{
                let currentCell = cellView as? SlidingCollectionCell
                currentCell!.labelValue.textColor = UIColor.borderedRed
                if selectedDataWeightCell == 1{
                    print("this is one")
                }
                
                if(currentCell == cell! && (selectedDataWeightCell == 0 || selectedDataWeightCell == 1 || selectedDataWeightCell == 2) && actualPosition.x > 0){
                    selectedDataWeightCell = slideCollectionView.indexPath(for: cell!)?.item
                }
            }
            
        }
    }
    
    func configActiveButonWith(index : Int){
        
        if index == 1{
            self.labelActivity.text = "Sedentary"
            self.labelActivityDay.text = ""
            self.selectedActivityId = "91c082199c334065751594ca961e6fd9"
        }else if index == 2{
            self.labelActivity.text = "Little Exercise"
            self.labelActivityDay.text = "1-3 days p/week"
            self.selectedActivityId = "598d4db9ff36443c3375e26b6553257e"
        }else if index == 3{
            self.labelActivity.text = "Moderate Exercise"
            self.labelActivityDay.text = "3-5 days p/week"
            self.selectedActivityId = "e59d724fac626cefce2a3bd164b5ce1c"
        }else if index == 4{
            self.labelActivity.text = "Heavy Exercise"
            self.labelActivityDay.text = "6-7 days p/week"
            self.selectedActivityId = "60310e0499004242abef30721bc7fde0"
        }else if index == 5{
            self.labelActivity.text = "Very Heavy Exercise"
            self.labelActivityDay.text = "2x per day"
            self.selectedActivityId = "2d4c3e4c8d32a1b6c0afc880f6316165"
        }
    }
    
    func configWeightGoalWith(index : Int){
        if index == 1{
            self.labelWeightGoals.text = "Lose Weight"
            self.selectedWeightGoals = "lose"
        }else if index == 2{
            self.labelWeightGoals.text = "Maintain Weight"
            self.selectedWeightGoals = "maintain"
        }else if index == 3{
            self.labelWeightGoals.text = "Gain Weight"
            self.selectedWeightGoals = "gain"
        }
    }
    
    
    func callAPIForBMICalculate(){
        self.showHud(message: "calculating BMI..")
        let param = ["gender" : "\(self.selectedGender)","age":"\(self.selectedAge)","weight":"\(self.selectedWight)","height":"\(self.selectedHeight)", "activity_level":"\(self.selectedActivityId)"]
        
        _ = WebAPIHandler.sharedHandler.calculateBMI(parameters: param, success: { (response) in
            debugPrint(response)
            self.hideHud()
            let profile = (response["profile"] as? [String:Any]) ?? [:]
            self.bmiResultData = profile
            self.activityLevel = (((response["meta"] as? [String:Any]) ?? [:])["activityLevel"] as? String) ?? ""
            if !profile.isEmpty{
                self.performSegue(withIdentifier: "bmiResultSegue", sender: nil)
            }else{
                let meta = (response["meta"] as? [String:Any]) ?? [:]
                let meaasage = (meta["message"] as? String) ?? ""
                self.showAlertViewWithTitle(title: "", Message: meaasage, CancelButtonTitle: "Ok")
            }
        }, failure: { (error) in
            debugPrint(error)
            self.hideHud()
        })
    }
}

//MARK:- Collection View Delegate Methods
extension BMICalculatorVC : UICollectionViewDelegate, UICollectionViewDataSource{
    //
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1{
            return ageDataSource.count
        }else if collectionView.tag == 2{
            return weightDataSource.count
        }else{
            return heightDataSource.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = SlidingCollectionCell()
        if collectionView.tag == 1{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "slidingCollectionAgeCell", for: indexPath as IndexPath)
                as! SlidingCollectionCell
            cell.labelValue.text = ageDataSource[indexPath.item]
            cell.layer.shouldRasterize = true;
            cell.layer.rasterizationScale = UIScreen.main.scale
            
            if(selectedDataAgeCell != nil){
                if(indexPath.item == selectedDataAgeCell){
                    self.selectedAge = self.ageDataSource[indexPath.item]
                    cell.labelValue.textColor = UIColor.borderedRed
                }else{
                    cell.labelValue.textColor = UIColor.darkRed
                }
            }else{
                if indexPath.item == 0{
                    self.selectedAge = self.ageDataSource[indexPath.item]
                    cell.labelValue.textColor = UIColor.borderedRed
                }else{
                    cell.labelValue.textColor = UIColor.darkRed
                }
            }
            
        }else if collectionView.tag == 2{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "slidingCollectionKgCell", for: indexPath as IndexPath)
                as! SlidingCollectionCell
            cell.labelValue.text = weightDataSource[indexPath.item]
            cell.layer.shouldRasterize = true;
            cell.layer.rasterizationScale = UIScreen.main.scale
            
            if(selectedDataWeightCell != nil){
                if(indexPath.item == selectedDataWeightCell){
                    self.selectedWight = self.weightDataSource[indexPath.item]
                    cell.labelValue.textColor = UIColor.borderedRed
                }else{
                    cell.labelValue.textColor = UIColor.darkRed
                }
            }else{
                if indexPath.item == 0{
                    self.selectedWight = self.weightDataSource[indexPath.item]
                    cell.labelValue.textColor = UIColor.borderedRed
                }else{
                    cell.labelValue.textColor = UIColor.darkRed
                }
            }
            
        }else{
            cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "slidingCollectionCell", for: indexPath as IndexPath)
                as! SlidingCollectionCell
            cell.labelValue.text = heightDataSource[indexPath.item]
            cell.layer.shouldRasterize = true;
            cell.layer.rasterizationScale = UIScreen.main.scale
            
            if(selectedCell != nil){
                if(indexPath.item == selectedCell){
                    self.selectedHeight = self.heightDataSource[indexPath.item]
                    cell.labelValue.textColor = UIColor.borderedRed
                }else{
                    cell.labelValue.textColor = UIColor.darkRed
                }
            }else{
                if indexPath.item == 0{
                    self.selectedHeight = self.heightDataSource[indexPath.item]
                    cell.labelValue.textColor = UIColor.borderedRed
                }else{
                    cell.labelValue.textColor = UIColor.darkRed
                }
            }
        }
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView == heightCollectionView){
            DispatchQueue.main.async {
                self.findCenterIndex(scrollView: scrollView, slideCollectionView: self.heightCollectionView)
            }
        }else if (scrollView == ageCollectionView){
            DispatchQueue.main.async {
                self.findCenterIndexForAge(scrollView: scrollView, slideCollectionView: self.ageCollectionView)
            }
        }else if (scrollView == kgCollectionView){
            DispatchQueue.main.async {
                self.findCenterIndexForWeight(scrollView: scrollView, slideCollectionView: self.kgCollectionView)
            }
        }
    }
    
}

//MARK:- UItext field delegate
extension BMICalculatorVC : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

