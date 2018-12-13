//
//  BMIResultVC.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 11/20/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
import HGCircularSlider
import JWTDecode

class BMIResultVC: BaseViewController {
    
    //MARK:- IBOutlets
    @IBOutlet weak var viewWeightRecommendation: UIView!
    @IBOutlet weak var labelHeight: UILabel!
    @IBOutlet weak var labelWeight: UILabel!
    @IBOutlet weak var viewDailyRecommendation: UIView!
    @IBOutlet weak var labelBMI: UILabel!
    @IBOutlet weak var labelLose: UILabel!
    @IBOutlet weak var labelGain: UILabel!
    @IBOutlet weak var labelClassification: UILabel!
    @IBOutlet weak var buttonRecommendationPlan: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var labelMaintain: UILabel!
    @IBOutlet weak var gainImageView: UIImageView!
    @IBOutlet weak var maintainImageView: UIImageView!
    @IBOutlet weak var loseImageView: UIImageView!
    @IBOutlet weak var labelDailyRecommendation: UILabel!
    @IBOutlet weak var circularView: CircularSlider!
    
    var selectedHeight : String?
    var selectedWeight : String?
    var selectedAge : String?
    var selectedGender : String?
    var selectedActivityId : String?
    var selectedGoals : String?
    var activityLevel : String?
    
    var bmiData : [String:Any]?
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        self.setNavigation(title: "BMI Results")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func saveResultsAction(_ sender: Any) {
        if Connectivity.isConnectedToInternet{
            self.callAPIForSaveResults()
        }else{
            self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "Ok")
        }
    }
}

//MARK:- Custom methods
extension BMIResultVC {
    
    func configUI(){
        DispatchQueue.main.async {
            //Adding shadow to bottom view
            self.bottomView.layer.masksToBounds = false
            self.bottomView.layer.shadowRadius = 20.0
            self.bottomView.layer.shadowColor = UIColor.lightGray.cgColor
            self.bottomView.layer.shadowOffset = CGSize(width: 1.0, height: 5.0)
            self.bottomView.layer.shadowOpacity = 1.0
            
            self.buttonRecommendationPlan.layer.cornerRadius = self.buttonRecommendationPlan.frame.size.height/2
            
            self.viewDailyRecommendation.layer.cornerRadius = 5.0
            self.viewWeightRecommendation.layer.cornerRadius = 5.0
            
            self.circularView.maximumValue = 100
            self.circularView.minimumValue = 1
            self.circularView.trackColor = UIColor.borderedRed
            self.circularView.backtrackLineWidth = 2.0
            self.circularView.trackColor = UIColor.viewBackgroundGray
            self.circularView.thumbRadius = 0.0
            self.circularView.endThumbTintColor = UIColor.clear
            self.circularView.endThumbStrokeColor = UIColor.clear
            
            self.labelHeight.text = "\(self.selectedHeight ?? "0")cm"
            self.labelWeight.text = "\(self.selectedWeight ?? "0")kg"
            
            self.configureBMI()
        }
    }
    
    func configureBMI(){
        let classification = (self.bmiData!["classification"] as? String) ?? ""
        self.labelClassification.text = "\(classification)"
        let bmi = ((self.bmiData!["score"] as? NSNumber) ?? 0 ).stringValue
        self.circularView.endPointValue = CGFloat(((self.bmiData!["score"] as? NSNumber) ?? 0 ).floatValue)
        self.labelBMI.text = bmi
        let recommendedCalories = ((self.bmiData!["dailyCalorieIntakeRecommendation"] as? NSNumber) ?? 0).stringValue
        self.labelDailyRecommendation.text = recommendedCalories
        let weightRecommendation = (self.bmiData!["recommendation"] as? String) ?? ""
        
        if weightRecommendation.isEqualToString(find: "Lose"){
            self.labelLose.textColor = UIColor.borderedRed
            self.labelMaintain.textColor = UIColor.disableRed
            self.labelGain.textColor = UIColor.disableRed
            
            self.loseImageView.image = #imageLiteral(resourceName: "colorRightTick")
            self.maintainImageView.image = #imageLiteral(resourceName: "fadeRightTick")
            self.gainImageView.image = #imageLiteral(resourceName: "fadeRightTick")
        }else if weightRecommendation.isEqualToString(find: "Maintain"){
            self.labelLose.textColor = UIColor.disableRed
            self.labelMaintain.textColor = UIColor.borderedRed
            self.labelGain.textColor = UIColor.disableRed
            
            self.loseImageView.image = #imageLiteral(resourceName: "fadeRightTick")
            self.maintainImageView.image = #imageLiteral(resourceName: "colorRightTick")
            self.gainImageView.image = #imageLiteral(resourceName: "fadeRightTick")
        }else if weightRecommendation.isEqualToString(find: "Gain"){
            self.labelLose.textColor = UIColor.disableRed
            self.labelMaintain.textColor = UIColor.disableRed
            self.labelGain.textColor = UIColor.borderedRed
            
            self.loseImageView.image = #imageLiteral(resourceName: "fadeRightTick")
            self.maintainImageView.image = #imageLiteral(resourceName: "fadeRightTick")
            self.gainImageView.image = #imageLiteral(resourceName: "colorRightTick")
        }
    }
    
    func callAPIForSaveResults(){
        let classification = (self.bmiData!["classification"] as? String) ?? ""
        self.labelClassification.text = "\(classification)"
        let bmi = ((self.bmiData!["score"] as? NSNumber) ?? 0 ).stringValue
        self.circularView.endPointValue = CGFloat(((self.bmiData!["score"] as? NSNumber) ?? 0 ).floatValue)
        self.labelBMI.text = bmi
        let recommendedCalories = ((self.bmiData!["dailyCalorieIntakeRecommendation"] as? NSNumber) ?? 0).stringValue
        self.labelDailyRecommendation.text = recommendedCalories
        let weightRecommendation = (self.bmiData!["recommendation"] as? String) ?? ""
        
        
        let user = DataBaseHelper.shared.getData().first
        let token = user?.tokenId ?? ""
        var userid = String()
        do{
            let jwt = try decode(jwt: token)
            if jwt.expired{
                //   self.performLogout()
            }else{
                let body = jwt.body
                userid = (body["uid"] as? String) ?? ""
            }
        }catch{
            print("Data not fetched")
        }
        
        
        let parameters = [
            "file": "",
            "first_name": "\(UserShared.shared.user.firstName)",
            "last_name": "\(UserShared.shared.user.lastName)",
            "email": "\(UserShared.shared.user.email)",
            "age": "\(self.selectedAge ?? "")",
            "gender": "\(self.selectedGender ?? "")",
            "height": "\(self.selectedHeight ?? "")",
            "weight": "\(self.selectedWeight ?? "")",
            "daily_calorie_allowance": "\(UserShared.shared.user.dailyCaloryAllowance)",
            "activity_level_id": "\(self.selectedActivityId ?? "")",
            "weight_recommendation": "\(weightRecommendation.lowercasingFirstLetter())",
            "bmi_value": "\(bmi)",
            "bmi_classification": "\(classification)",
            "weight_goal" : "\(self.selectedGoals ?? "")"
        ]
        self.showHud(message: "Updating..")
        
        _ = WebAPIHandler.sharedHandler.updateUserDetail(parameter: parameters, uid: userid,token : token,  success: { (response) in
            self.hideHud()
            debugPrint(response)
            let meta = (response["meta"] as? [String:Any]) ?? [:]
            let message = (meta["message"] as? String) ?? ""
            let success = (response["success"] as? Bool) ?? false
            if success{
                UserShared.shared.user.age = Int(self.selectedAge ?? "") ?? 0
                UserShared.shared.user.gender = self.selectedGender ?? ""
                UserShared.shared.user.height = Int(self.selectedHeight ?? "") ?? 0
                UserShared.shared.user.weight = Int(self.selectedWeight ?? "") ?? 0
                UserShared.shared.user.weightGoals = self.selectedGoals ?? ""
                UserShared.shared.user.activityLevelID = self.selectedActivityId ?? ""
                UserShared.shared.user.weightRecommendation = weightRecommendation
                UserShared.shared.user.bmiValue = bmi
                UserShared.shared.user.bmiClassification = classification
                UserShared.shared.user.activityLevel = self.activityLevel ?? ""
                let arr_controller:[UIViewController] = (self.navigationController?.viewControllers)!
                _ = self.navigationController?.popToViewController(arr_controller[1], animated: true)
            }else{
                self.showAlertViewWithTitle(title: "", Message: message, CancelButtonTitle: "Ok")
            }
        }, failure: { (error) in
            debugPrint(error)
            self.hideHud()
        })
    }
}
