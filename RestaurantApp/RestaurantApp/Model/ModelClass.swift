//
//  ModelClass.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 04/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import Foundation
import GoogleMaps
import Alamofire

//MARK:-Object for filter cell data source
struct FilterObject {
    var sectionName = String()
    var sectionImage = String()
    var sectionObjects = [String]()
}

//MARK:-Object for account Profile, preference and goals cell data source
public struct PrferencesGoal {
    var sectionName = String()
    var sectionImage = String()
    var sectionObjects = [sectionFilterData]()
}

public struct PreferenceAccount {
    var sectionName = String()
    var sectionImage = String()
    var sectionObjects = [String]()
}

public struct PreferenceDeliveryInfo {
    var sectionName = String()
    var sectionImage = String()
    var sectionObjects = [CuisineData]()
}

//MARK:- To maintain data for preference and goal
public struct sectionFilterData {
    var title = String()
    var isCheck = Bool()
}

//MARK:- struct for add options
public struct AddOptionData{
    var sectiontitle = String()
    var sectionData = [SectionData]()
    
}
//Section data for addoption
struct SectionData {
    var title = String()
    var isCheck = Bool()
    var price = Int()
    var id = String()
    var count = 0
    
    init(data:[String:Any]) {
        self.title = (data["name"] as? String) ?? ""
        self.id = (data["id"] as? String) ?? ""
        self.price = (data["extraFee"] as? Int) ?? 0
    }
}


//MARK:- Basic info struct
public struct BasicInfo{
    var infoMenuIcon = String()
    var infoTitle = String()
    var infoSubTitle = String()
}

//MARK:- Notfication struct
public struct NotificationDetail{
    var title = String()
    var imageNamed = String()
    var state = Bool()
}

//MARK:- Menu items struct
public struct MenuItems: Hashable, Equatable {
    var menuLogoImage = String()
    var menuTitle = String()
    var totalCalories = Int()
    var menuPrice = CGFloat()
    var menuId = String()
    var count = Int()
    var description = String()
    var hasOptions = false
    var cuisineType = String()
    var mealType = String()
    var foodType = String()
    var menuStarRating = CGFloat()
    
    init(data:[String:Any]){
        self.menuLogoImage = (data["image"] as? String) ?? ""
        self.menuTitle = (data["name"] as? String) ?? ""
        self.menuPrice = (data["amount"] as? CGFloat) ?? 0.0
        self.hasOptions =  (((data["hasOptions"] as? Int) ?? 0) == 0) ? false : true
        self.totalCalories = ((data["totalCalories"] as? NSNumber) ?? 0).intValue
        self.menuId = (data["id"] as? String) ?? ""
        self.description = (data["description"] as? String) ?? ""
        let cuisine = (data["cuisine"] as? [String:Any]) ?? [:]
        self.cuisineType.append((cuisine["name"] as? String) ?? "")
        let mealType = (data["mealType"] as? [String:Any]) ?? [:]
        self.mealType.append((mealType["name"] as? String) ?? "")
        let dishType = (data["type"] as? [String:Any]) ?? [:]
        self.foodType.append((dishType["name"] as? String) ?? "")
        self.menuStarRating = (((data["reviewRating"] as? [String:Any]) ?? [:])["average"] as? CGFloat) ?? 0.0
    }
}

//MARK:- Restaurant lists struct
public struct RestaurantLists: Hashable, Equatable  {
    var restaurantImage = String()
    var restaurantTitle = String()
    var restaurantStar = CGFloat()
    var restaurantRatingCount = String()
    var restaurantSpeciality = String()
    var restaurantDistance = Double()
    var minimumOrderValue = Int()
    var deliveryTime = String()
    var restaurantLogo = String()
    var id = String()
    var email = String()
    var deliveryFee = CGFloat()
    var outOfStar = Int()
    var restautrantClassification = String()
    var cuisineTypes = String()
    var mealTypes = String()
    
    init(data : [String:Any]) {
        self.restaurantLogo = (data["logo"] as? String) ?? ""
        self.restaurantImage = (data["banner"] as? String) ?? ""
        self.restaurantTitle = (data["brand"] as? String) ?? ""
        self.restaurantStar = (((data["reviewRating"] as? [String:Any]) ?? [:])["average"] as? CGFloat) ?? 0.0
        self.deliveryFee = (data["deliveryFee"] as? CGFloat) ?? 0.0
        self.id = (data["id"] as? String) ?? ""
        self.restaurantSpeciality = (data["brand"] as? String) ?? ""
        self.restaurantDistance = (data["distance"] as? Double) ?? 0.000
        self.deliveryTime = (data["deliveryTime"] as? String) ?? ""
        self.restaurantRatingCount = "(\((((data["reviewRating"] as? [String:Any]) ?? [:])["outOf"] as? Int) ?? 0))"
        self.restautrantClassification = ((((data["reviewRating"] as? [String:Any]) ?? [:])["classification"] as? String) ?? "").uppercased()
        
        //MARK:- Criteria for delivery fee
        //    If free delivery type is always, we ignore delivery fee and always show delivery fee as 0.
        //    if free delivery type is never, we ignore minFreeDeliveryValue and always show delivery fee as deliveryFee key
        //    if free delivery type is 'on min delivery value', we need to check the minFreeDeliveryValue key and check whether basket is >= minFreeDeliveryValue. If below, we show delivery fee / apply delivery fee. If minFreeDeliveryValue reached, we show delivery fee as 0.
        
        let freeDeliveryType = (((data["freeDeliveryType"] as? [String:Any]) ?? [:])["name"] as? String) ?? ""
        if freeDeliveryType.isEqualToString(find: "on min delivery value"){
            self.minimumOrderValue = (data["minFreeDeliveryValue"] as? Int) ?? 0
            self.deliveryFee = 0.0
        }else if freeDeliveryType.isEqualToString(find: "always"){
            self.deliveryFee = 0.0
        }
        self.cuisineTypes = (data["cuisines"] as? [String])?.first ?? ""
        self.mealTypes = (data["mealTypes"] as? [String])?.first ?? ""
    }
}


//MARK:- Restaurant info struct
public struct RestaurantInfo{
    
    struct RestaurantMapInfo{
        var restaurantImage = String()
        var restaurantTitle = String()
        var restaurantAddress = String()
        var latitude = CGFloat()
        var longitude = CGFloat()
        
        init(data : [String:Any]){
            //self.restaurantImage = (data["logo"] as? String) ?? ""
            self.restaurantImage = (data["banner"] as? String) ?? ""
            self.restaurantTitle = (data["brand"] as? String) ?? ""
            self.restaurantAddress = (data["address"] as? String) ?? ""
            self.latitude = (data["latitude"] as? CGFloat) ?? 0.0
            self.longitude = (data["longitude"] as? CGFloat) ?? 0.0
        }
    }
    
    struct RestaurantAboutInfo{
        var restaurantTitle = String()
        var restaurantAbout = String()
    }
    
    struct RestaurantTimingStruct{
        var day = String()
        var id = String()
        var endHour = String()
        var startHour = String()
        
        init(data : [String:Any]){
            self.id = (data["id"] as? String) ?? ""
            self.day = (data["day"] as? String) ?? ""
            self.endHour = (data["endHour"] as? String) ?? ""
            self.startHour = (data["startHour"] as? String) ?? ""
        }
    }
}

//MARK:- Restaurant review struct
public struct RestaurantReview{
    
    struct RestaurantShortReview{
        var starRating = String()
        var reviewDetail = String()
        var reviewDate = String()
        var name = String()
        
        init(data : [String:Any]){
            self.starRating = "\((data["rating"] as? CGFloat) ?? 0.0)"
            self.reviewDate = ((data["createdAt"] as? String) ?? "").components(separatedBy: " ").first ?? ""
            self.name = (data["leftBy"]
                as? String) ?? ""
            self.reviewDetail = (data["comment"] as? String) ?? ""
        }
    }
    
    struct RestaurantDetailReview{
        var starRating = String()
        var outerReview = String()
        var interiorReview = String()
        var reviewDate = String()
        var restaurantName = String()
        var name = String()
    }
}

//MARK:- Restaurant dish detail structs
public struct RestaurantDishDetail{
    struct DishNutrients {
        var percentage = CGFloat()
        var nutrientsName = String()
        var textToShow = String()
        init(nutrients:String, percentage:CGFloat, text : String){
            self.percentage = percentage
            self.nutrientsName = nutrients
            self.textToShow = text
        }
    }
    
    struct DishIngredients {
        var description = String()
        var ingredientsName = String()
        
        init(data:[String:Any]){
            self.description = "\((data["quantity"] as? Int) ?? 0) \((data["unit"] as? String) ?? "")"
            self.ingredientsName = (data["name"] as? String) ?? ""
        }
    }
    
    struct DishDescription {
        var description = String()
        var name = String()
        
        init(name:String, description : String){
            self.description = description
            self.name = name
        }
    }
}

//MARK:- My Basket struct
public struct MyBasketData{
    var menuId = String()
    var menuTitle = String()
    var count = Int()
    var menuLogoImage = String()
    var menuPrice = CGFloat()
    var basketPrice = CGFloat()
}

//MAR:- My option struct
public struct MyOptionData{
    var id = Int()
    var name = String()
    var price = Int()
    var groupName = String()
    var count = Int()
    var basketPrice = Int()
}

//MARK:- Checkout Data
public struct CheckOutData{
    var sectionTitle = String()
    var data = [[String:Any]]()
}

//MARK:- Payment methods
public struct Payments {
    var methodsName = String()
    var cardNumber = String()
    var monthYear = String()
    var isCheck = Bool()
}

//MARK:- Setting data
public struct Settings{
    var settingIcon = String()
    var settingTitle = String()
    var settingSubTitle = String()
}

//MARK:- Change currency data
public struct Currency{
    var title = String()
    var subTitle = String()
    var isCheck = Bool()
    var row = Int()
}

//MARK:- My order struct
public struct MyOrderData{
    
    var imageIcon = String()
    var name = String()
    var cartCount = Int()
    var dateDelivery = String()
    var price = CGFloat()
    var orderId = Int()
    var currency = String()
    var status : FoodStatus?
    var date = Date()
    
    init(data : [String:Any]) {
        self.name = (((data["restaurant"] as? [String:Any]) ?? [:])["brand"] as? String) ?? ""
        self.cartCount = (data["quantity"] as? Int) ?? 0
        self.orderId = (data["id"] as? Int) ?? 0
        self.dateDelivery = (((data["createdAt"] as? String) ?? "").components(separatedBy: " ")).first ?? ""
        self.price = (((data["price"] as? [String:Any]) ?? [:])["total"] as? CGFloat) ?? 0.0
        self.currency = (((data["price"] as? [String:Any]) ?? [:])["currency"] as? String) ?? ""
        self.imageIcon = (((data["restaurant"] as? [String:Any]) ?? [:])["logo"] as? String) ?? ""
        if ((data["status"] as? String) ?? "").isEqualToString(find: "cooking"){
            self.status = .cooking
        }else if ((data["status"] as? String) ?? "").isEqualToString(find: "on the way"){
            self.status = .onWay
        }else if ((data["status"] as? String) ?? "").isEqualToString(find: "accepted"){
            self.status = .accepted
        }else if ((data["status"] as? String) ?? "").isEqualToString(find: "rejected"){
            self.status = .rejected
        }else if ((data["status"] as? String) ?? "").isEqualToString(find: "pending"){
            self.status = .pending
        }else if ((data["status"] as? String) ?? "").isEqualToString(find: "ready"){
            self.status = .ready
        }else if ((data["status"] as? String) ?? "").isEqualToString(find: "completed"){
            self.status = .completed
        }else if ((data["status"] as? String) ?? "").isEqualToString(find: "cancelled"){
            self.status = .cancel
        }else if ((data["status"] as? String) ?? "").isEqualToString(find: "archived"){
            self.status = .archived
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.date = formatter.date(from: ((data["createdAt"] as? String) ?? "")) ?? Date()
    }
}

public struct MyOrderDetail{
    var imageLogo = String()
    var restaurantName = String()
    var orderDate = String()
    var dishes = [DishData]()
    
    init(data:[String:Any]){
        
    }
}

struct DishData{
    var dishImage = String()
    var name = String()
    var quantity = Int()
    var optionsNames = [String]()
    var total = CGFloat()
    
    init(data:[String:Any]) {
        self.dishImage = (data["image"] as? String) ?? ""
        self.name = (data["name"] as? String) ?? ""
        self.quantity = (data["quantity"] as? Int) ?? 0
        self.total = (data["total"] as? CGFloat ) ?? 0.0
        self.optionsNames = (data["optionStrings"] as? [String]) ?? []
    }
}

public struct CuisineData{
    var restaurantImage = String()
    var restaurantTitle = String()
    var restaurantLogo = String()
    var id = String()
    var phoneCode = String()
    
    init(data : [String:Any], index : Int) {
        if index == 1{
            self.restaurantLogo = (data["logo"] as? String) ?? ""
            self.restaurantImage = (data["banner"] as? String) ?? ""
            self.restaurantTitle = (data["name"] as? String) ?? ""
            self.id = (data["id"] as? String) ?? ""
        }else if index == 2{
            self.restaurantLogo = (data["logo"] as? String) ?? ""
            self.restaurantImage = (data["banner"] as? String) ?? ""
            self.restaurantTitle = (data["brand"] as? String) ?? ""
            self.id = (data["id"] as? String) ?? ""
        }else{
            self.restaurantTitle = (data["type"] as? String) ?? ""
            self.id = (data["id"] as? String) ?? ""
        }
    }
}

struct JSONArrayEncoding: ParameterEncoding {
    private let array: [Parameters]
    
    init(array: [Parameters]) {
        self.array = array
    }
    
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
        
        let data = try JSONSerialization.data(withJSONObject: array, options: [])
        
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        urlRequest.httpBody = data
        
        return urlRequest
    }
}

public struct NotificationNames{
    static let userUpdate = Notification.Name("notificationForUserUpdate")
}

public struct UserInfo{
    var imageName = String()
    var firstName = String()
    var lastName = String()
    var age = Int()
    var gender = String()
    var height = Int()
    var userImage : UIImage?
    var weight = Int()
    var dailyCaloryAllowance = String()
    var activityLevelID = String()
    var weightRecommendation = String()
    var weightGoals = String()
    var bmiClassification = String()
    var bmiValue = String()
    var email = String()
    var activityLevel = String()
    
    init(){
        
    }
}

public struct AddressStruct{
    var address = String()
    var aptNo = String()
    var city = String()
    var country = String()
    var id = String()
    var type = String()
    var coordinates = CLLocation()
    var countryCode = String()
    
    init(data : [String:Any]){
        self.address = (data["address"] as? String) ?? ""
        self.aptNo = (data["aptNo"] as? NSNumber)?.stringValue ?? ""
        self.city = (data["city"] as? String) ?? ""
        self.country = (((data["country"] as? [String:Any]) ?? [:])["name"] as? String) ?? ""
        self.countryCode = (((data["country"] as? [String:Any]) ?? [:])["alpha2Code"] as? String) ?? ""
        self.id = (data["id"] as? String) ?? ""
        self.type = (data["type"] as? String) ?? ""
        let latitude = (data["latitude"] as? NSNumber)?.doubleValue ?? 0.0
        let longitude = (data["longitude"] as? NSNumber)?.doubleValue ?? 0.0
        self.coordinates = CLLocation.init(latitude: latitude, longitude: longitude)
    }
}

public struct PhoneStruct{
    var countryCode = String()
    var phoneNumber = String()
    var id = String()
    
    init(data :  [String:Any]){
        self.countryCode = (data["dialCountry"] as? String) ?? ""
        self.id = (data["id"] as? String) ?? ""
        self.phoneNumber = (data["phone"] as? String) ?? ""
    }
}

//MARK:- Demo Struct
public struct WeekStruct{
    var name = String()
    var likes = String()
    var imageName = String()
}

public struct SubscriptionCatagory{
    var name = String()
    var description = String()
    var id = String()
    
    init(data : [String:Any]){
        self.name = (data["name"] as? String) ?? ""
        self.description = (data["description"] as? String) ?? ""
        self.id = (data["id"] as? String) ?? ""
    }
}

public struct SelectPlan{
    var id = String()
    var name = String()
    var description = String()
    var totalCalories = Int()
    var totalPrice = Float()
    var currency = String()
    var totalDishes = Int()
    var totalDays = Int()
    var daysPerWeek = Int()
    var duration = Int()
    var interval = String()
    
    init(data: [String:Any]){
        self.id = (data["id"] as? String) ?? ""
        self.name = (data["name"] as? String) ?? ""
        self.totalPrice = ((((data["price"] as? [String:Any]) ?? [:])["total"] as? NSNumber )?.floatValue) ?? 0.0
        self.currency = (((data["price"] as? [String:Any]) ?? [:])["currency"] as? String ) ?? ""
        self.totalDishes = (data["totalDishes"] as? NSNumber)?.intValue ?? 0
        self.totalCalories = (data["totalCalories"] as? NSNumber)?.intValue ?? 0
        self.description = (data["description"] as? String) ?? ""
        self.daysPerWeek = (data["daysPerWeek"] as? NSNumber)?.intValue ?? 0
        self.duration = (data["duration"] as? NSNumber)?.intValue ?? 0
        self.interval = (data["interval"] as? String) ?? ""
    }
}
