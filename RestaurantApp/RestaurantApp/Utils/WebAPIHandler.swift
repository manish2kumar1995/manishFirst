//
//  WebApiHandler.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 12/10/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import CoreLocation
import JWTDecode

// MARK: - Global request handlers.
public typealias RequestCompletionHandler = (Parameters) -> Void
public typealias RequestFailureHandler = (Error) -> Void

public typealias ResponseCompletionHandler = (_ response : Any ,_ error : Error) -> Void


public struct WebAPIs{
    //private static let baseUrl = "http://178.128.34.29/v1"
    public static let baseUrl = "http://35.200.203.199/v1"
}

public struct Methods{
    public static let createOrder = "/orders"
    public static let validateCoupon = "/coupons/validate_coupon"
    public static let login = "/auth/token"
    public static let signUp = "/users"
    public static let resetEmailLink = "/auth/password/email"
    public static let resetPassword = "/auth/password/reset"
}

// MARK: - Singlton Class to handle all API class.
public class WebAPIHandler: NSObject {
    
    
    
    // MARK: - Singleton Object
    public static let sharedHandler = WebAPIHandler()
    
    //MARK:- Prepare default header
    private static let defaultRequestHeaders : HTTPHeaders = {
        let user = DataBaseHelper.shared.getData().first
        let token = user?.tokenId ?? ""
        
        let header = ["Content-type": "application/json","Accept": "application/json", "Authorization": "Bearer \(token)"]
        //Add your own global headers
        return header
    }()
    
    func prepareTokenBasedHeader(token : String) -> HTTPHeaders{
        let header = ["Content-type": "application/json","Accept": "application/json", "Authorization": "Bearer \(token)"]
        //Add your own global headers
        return header
    }
    
    func prepareHeaderForUpdateUser(token : String) -> HTTPHeaders{
        //        let header = ["content-type": "multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW","authorization": "\(token)","cache-control": "no-cache","postman-token": "19281427-5403-9619-9e96-bb54fdd3559c"]
        
        let header = ["Authorization": "\(token)"]
        return header
    }
    
    //MARK:- Prepare GET URL
    func prepareURLRequestForRestaurants(latitude:String, longitude: String) -> String {
        //        let unit = (UserDefaults.standard.value(forKey: "Units") as? String) ?? "KM"
        //      let currency = (UserDefaults.standard.value(forKey: "Currency") as? String) ?? "QAR"
        let mode  = UserShared.shared.userMode
        //return WebAPIs.baseUrl + "/restaurants??from=1&to=10&latitude=\(latitude)&longitude=\(longitude)&unit=\(unit)&currency=\(currency)&mode=\(mode)"
        return WebAPIs.baseUrl + "/restaurants??from=1&to=10&latitude=\(latitude)&longitude=\(longitude)&mode=\(mode)"
    }
    
    //MARK:- Prepare GET URL for restaurant dishes
    func prepareURLForRestaurantDish(restaurantId:String) -> String {
        let currencyType = (UserDefaults.standard.value(forKey: "Currency") as? String) ?? "QAR"
        return WebAPIs.baseUrl + "/restaurants/\(restaurantId)/dishes?from=1&to=10&currency=\(currencyType)"
    }
    
    func prepareURLForParticularRestaurant(id : String) -> String{
        return WebAPIs.baseUrl + "/restaurants/\(id)"
    }
    
    //MARK:- Prepare GET URL for restaurant dishes
    func prepareURLForRestaurantInfo(restaurantId:String) -> String {
        return WebAPIs.baseUrl + "/restaurants/\(restaurantId)"
    }
    
    func prepareURLForDishOption(restaurantId: String, dishId: String) -> String {
        return WebAPIs.baseUrl + "/restaurants/\(restaurantId)/dishes/\(dishId)/options"
    }
    
    func prepareURLForRestautantReview(restaurantId: String) -> String {
        return WebAPIs.baseUrl + "/restaurants/\(restaurantId)/reviews"
    }
    
    func prepareURLForOpeningTimes(restaurantId: String) -> String{
        return WebAPIs.baseUrl + "/restaurants/\(restaurantId)/opening_times"
    }
    
    func prepareURLForDishIngredients(restaurantId: String, dishId: String) -> String {
        return WebAPIs.baseUrl + "/restaurants/\(restaurantId)/dishes/\(dishId)/ingredients"
    }
    
    func prepareRequestForOrderDetail(orderID: Int) -> String{
        return WebAPIs.baseUrl + "/orders/\(orderID)"
    }
    
    func prepareRequestForUserDetail(uid:String) -> String{
        return WebAPIs.baseUrl + "/users/\(uid)"
    }
    
    func prepareURLForUpdateOrder(orderID: Int) -> String{
        return WebAPIs.baseUrl + "/orders/\(orderID)"
    }
    
    func prepareURLForAddAddress(id : String, index : Int) -> String{
        if index == 1{
            return WebAPIs.baseUrl + "/users/\(id)/addresses"
        }else{
            return WebAPIs.baseUrl + "/users/\(id)/phones"
        }
    }
    
    func prepareURLForAddRestaurant(id : String, index : Int) -> String{
        //   http://35.200.203.199/v1/users/10fe04e1554b93b1bece76350db2d4c7/preferences/restaurants
        http://35.200.203.199/v1/users/10fe04e1554b93b1bece76350db2d4c7/preferences/allergens
            if index == 1{
            return WebAPIs.baseUrl + "/users/\(id)/preferences/cuisines"
        }else if index == 2{
            return WebAPIs.baseUrl + "/users/\(id)/preferences/restaurants"
        }else{
            return WebAPIs.baseUrl + "/users/\(id)/preferences/allergens"
        }
    }
    
    func prepareURLForDeleteCuisines(id : String,index:Int,itemId : String) -> String{
        if index == 1{
            return WebAPIs.baseUrl + "/users/\(id)/preferences/cuisines/\(itemId)"
        }else if index == 2{
            return WebAPIs.baseUrl + "/users/\(id)/preferences/restaurants/\(itemId)"
        }else{
            return WebAPIs.baseUrl + "/users/\(id)/preferences/allergens/\(itemId)"
        }
    }
    
    func prepareURLForDeleteAddress(id : String,index:Int,itemId : String) -> String{
        if index == 1{
            return WebAPIs.baseUrl + "/users/\(id)/addresses/\(itemId)"
        }else{
            return WebAPIs.baseUrl + "/users/\(id)/phones/\(itemId)"
        }
    }
    
    func prepareURLForGetCuisine(index : Int) -> String {
        // /dishes/allergens
        if index == 1{
            return WebAPIs.baseUrl + "/dishes/cuisines"
        }else if index == 2{
            return WebAPIs.baseUrl + "/restaurants"
        }else{
            return WebAPIs.baseUrl + "/dishes/allergens"
        }
    }
    
    func prepareURLForGetPreferences(id : String) -> String{
        return WebAPIs.baseUrl + "/users/\(id)/preferences"
    }
    
    func prepareURLForBMICalculate(param:[String:String]) -> String{
        return WebAPIs.baseUrl + "/weight_profile?weight=\(param["weight"] ?? "")&height=\(param["height"] ?? "")&age=\(param["age"] ?? "")&gender=\(param["gender"] ?? "")&activity_level=\(param["activity_level"] ?? "")"
    }
    
    func prepareURLforChangePassword(id : String) -> String{
        //   http://35.200.203.199/v1/users/10fe04e1554b93b1bece76350db2d4c7/password
        return WebAPIs.baseUrl + "/users/\(id)/password"
    }
    
    //   restaurants/{id}/subscription_categories
    func prepareURLForSelectCat(id : String) -> String{
        return WebAPIs.baseUrl + "/restaurants/\(id)/subscription_categories"
    }
    
    func prepareURLForSelectPlan(id : String, categoryId : String) -> String{
        return WebAPIs.baseUrl + "/restaurants/\(id)/subscription_categories/\(categoryId)"
    }
    
    
    private final func prepareRequest(url:URL! , param:[String : Any] ) ->URLRequest{
        debugPrint(#function)
        debugPrint(url)
        let user = DataBaseHelper.shared.getData().first
        let token = user?.tokenId ?? ""
        
        var request    = URLRequest(url: url as URL)
        request.timeoutInterval = 220
        request.httpShouldHandleCookies = false
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try! JSONSerialization.data(withJSONObject: param, options: [])
        return request;
    }
    
    private final func prepareRequestFortPatch(url:URL! , param:[[String : Any]] ,token: String) ->URLRequest {
        debugPrint(#function)
        debugPrint(url)
        var request = URLRequest(url: url as URL)
        request.timeoutInterval = 220
        request.httpShouldHandleCookies = false
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try! JSONSerialization.data(withJSONObject: param, options: [])
        _ = try! JSONSerialization.jsonObject(with: try! JSONSerialization.data(withJSONObject: param, options: []), options: .mutableContainers)
        return request;
    }
    
    func prepareRequestForLogin(url:URL! , email:String, pass:String ) ->URLRequest {
        debugPrint(#function)
        debugPrint(url)
        var request = URLRequest(url: url as URL)
        request.timeoutInterval = 220
        request.httpShouldHandleCookies = false
        request.httpMethod = "POST"
        let loginString = String(format: "%@:%@", email, pass)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        return request;
    }
    
    func prepareURLRequestForUpdateUser(url:URL! ,param : [[String:Any]] ,token :String) ->URLRequest {
        debugPrint(#function)
        debugPrint(url)
        var request = URLRequest(url: url as URL)
        request.timeoutInterval = 220
        request.httpShouldHandleCookies = false
        request.httpMethod = "POST"
        request.addValue("multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW", forHTTPHeaderField: "Content-Type")
        request.addValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.addValue("\(token)", forHTTPHeaderField: "Authorization")
        request.addValue("19281427-5403-9619-9e96-bb54fdd3559c", forHTTPHeaderField: "Postman-Token")
        request.httpBody = try! JSONSerialization.data(withJSONObject: param, options: [])
        return request;
    }
    
    
    //MARK:- Methods For API
    public func getRestaurantsBy(latitude: String, longitude: String, success:@escaping RequestCompletionHandler,  failure: @escaping RequestFailureHandler) -> DataRequest {
        //let url = prepareURLRequestForRestaurants(latitude:"25.292935" , longitude: "51.521062")
        let url = prepareURLRequestForRestaurants(latitude:latitude , longitude: longitude)
        return request(with: url, method: .get, parameters: [:], success: success, failure: failure)
    }
    
    public func getRestaurantDishes(restaurantId: String, success:@escaping RequestCompletionHandler,  failure: @escaping RequestFailureHandler) -> DataRequest {
        let url = prepareURLForRestaurantDish(restaurantId: restaurantId)
        return request(with: url, method: .get, parameters: [:], success: success, failure: failure)
    }
    
    public func getDishOptions(dishId: String, restaurantId: String, success:@escaping RequestCompletionHandler,  failure: @escaping RequestFailureHandler) -> DataRequest {
        let url = prepareURLForDishOption(restaurantId: restaurantId, dishId: dishId)
        return request(with: url, method: .get, parameters: [:], success: success, failure: failure)
    }
    
    func getRestaurantReview(restaurtantId:String, success:@escaping RequestCompletionHandler,  failure: @escaping RequestFailureHandler) -> DataRequest{
        let url = prepareURLForRestautantReview(restaurantId: restaurtantId)
        return request(with: url, method: .get, parameters: [:], success: success, failure: failure)
    }
    
    func getRestaurantInfo(restaurtantId:String, success:@escaping RequestCompletionHandler,  failure: @escaping RequestFailureHandler) -> DataRequest{
        let url = prepareURLForRestaurantInfo(restaurantId: restaurtantId)
        return request(with: url, method: .get, parameters: [:], success: success, failure: failure)
    }
    
    func getDishIngredients(restaurantId:String, dishId: String, success:@escaping RequestCompletionHandler,  failure: @escaping RequestFailureHandler) -> DataRequest{
        let url = prepareURLForDishIngredients(restaurantId: restaurantId, dishId: dishId)
        return request(with: url, method: .get, parameters: [:], success: success, failure: failure)
    }
    
    func getRstaurantOpeningTimes(restaurantId:String, success:@escaping RequestCompletionHandler,  failure: @escaping RequestFailureHandler) -> DataRequest{
        let url = prepareURLForOpeningTimes(restaurantId: restaurantId)
        return request(with: url, method: .get, parameters: [:], success: success, failure: failure)
    }
    
    func createOrder(parameters: [String:Any], success:@escaping RequestCompletionHandler, failure:@escaping RequestFailureHandler) -> DataRequest{
        let url = WebAPIs.baseUrl + Methods.createOrder
        let request = prepareRequest(url: URL(string:url), param: parameters)
        return requestForPost(request: request, success: success, failure: failure)
    }
    
    func validateCoupon(parameters: [String:Any], success:@escaping RequestCompletionHandler, failure:@escaping RequestFailureHandler) -> DataRequest{
        let url = WebAPIs.baseUrl + Methods.validateCoupon
        let request = prepareRequest(url: URL(string:url), param: parameters)
        return requestForPost(request: request, success: success, failure: failure)
    }
    
    func getMyOrders(parameters: [String:Any], success:@escaping RequestCompletionHandler, failure:@escaping RequestFailureHandler) -> DataRequest{
        let url = WebAPIs.baseUrl + Methods.createOrder
        let user = DataBaseHelper.shared.getData().first
        let token = user?.tokenId ?? ""
        
        let header = prepareTokenBasedHeader(token: token)
        return requestWithHeaders(with: url, method: .get, header: header, parameters: [:], success: success, failure: failure)
    }
    
    func getMyORderDetail(orderId : Int, success:@escaping RequestCompletionHandler, failure:@escaping RequestFailureHandler) -> DataRequest{
        let url = prepareRequestForOrderDetail(orderID: orderId)
        return request(with: url, method: .get, parameters: [:], success: success, failure: failure)
    }
    
    func callLoginAPI(email:String, pass:String, success:@escaping RequestCompletionHandler, failure:@escaping RequestFailureHandler) -> DataRequest {
        let url = WebAPIs.baseUrl + Methods.login
        let request = prepareRequestForLogin(url: URL(string:url), email: email, pass: pass)
        return requestForPost(request: request, success: success, failure: failure)
    }
    
    func getUserDetail(token : String,uid :String, success:@escaping RequestCompletionHandler, failure:@escaping RequestFailureHandler) -> DataRequest {
        let url = prepareRequestForUserDetail(uid: uid)
        let header = prepareTokenBasedHeader(token : token)
        return requestWithHeaders(with: url, method: .get, header: header, parameters: [:], success: success, failure: failure)
    }
    
    func createUser(parameters : [String:Any], success:@escaping RequestCompletionHandler, failure:@escaping RequestFailureHandler) -> DataRequest{
        let url = WebAPIs.baseUrl + Methods.signUp
        let request = prepareRequest(url: URL(string: url), param: parameters)
        return requestForPost(request: request, success: success, failure: failure)
    }
    
    func calculateBMI(parameters : [String:String], success:@escaping RequestCompletionHandler, failure:@escaping RequestFailureHandler) -> DataRequest{
        let url = prepareURLForBMICalculate(param: parameters)
        return request(with: url, method: .get, parameters: [:], success: success, failure: failure)
    }
    
    func getCuisine(index : Int ,success:@escaping RequestCompletionHandler, failure:@escaping RequestFailureHandler) -> DataRequest{
        let url = prepareURLForGetCuisine(index : index)
        return request(with: url, method: .get, parameters: [:], success: success, failure: failure)
    }
    
    func sendResetLink(parameters : [String:Any], success:@escaping RequestCompletionHandler, failure:@escaping RequestFailureHandler) -> DataRequest{
        let url = WebAPIs.baseUrl + Methods.resetEmailLink
        let request = prepareRequest(url: URL(string: url), param: parameters)
        return requestForPost(request: request, success: success, failure: failure)
    }
    
    func resetPassword(parameters : [String:Any], success:@escaping RequestCompletionHandler, failure:@escaping RequestFailureHandler) -> DataRequest{
        let url = WebAPIs.baseUrl + Methods.resetPassword
        let request = prepareRequest(url: URL(string: url), param: parameters)
        return requestForPost(request: request, success: success, failure: failure)
    }
    
    func updateUserDetail(parameter : [String:Any],uid :String,token : String,  success:@escaping RequestCompletionHandler, failure:@escaping RequestFailureHandler) -> DataRequest? {
        let url = prepareRequestForUserDetail(uid: uid)
        let header = prepareHeaderForUpdateUser(token: token)
        return requestWithHeaders(with: url, method: .post, header: header, parameters: parameter, success: success, failure: failure)
    }
    
    func updateUserMultiparts(parameter : [String:Any],uid :String,token : String,imageData : Data,  success:@escaping RequestCompletionHandler, failure:@escaping RequestFailureHandler) -> DataRequest? {
        let url = prepareRequestForUserDetail(uid: uid)
        let header = prepareHeaderForUpdateUser(token: token)
        return MultiPart(url, params: parameter, imageData: imageData, header: header, success: success, failure: failure)
    }
    
    func getParticularRestuant(restaurantId:String, success:@escaping RequestCompletionHandler,  failure: @escaping RequestFailureHandler) -> DataRequest{
        let url = prepareURLForParticularRestaurant(id:restaurantId )
        return request(with: url, method: .get, parameters: [:], success: success, failure: failure)
    }
    
    func getUserPreferences(id : String,success:@escaping RequestCompletionHandler,  failure: @escaping RequestFailureHandler) -> DataRequest{
        let url = prepareURLForGetPreferences(id: id)
        return requestWithHeaders(with: url, method: .get, header: WebAPIHandler.defaultRequestHeaders, parameters: [:], success: success, failure: failure)
    }
    
    func addResturantPreferences(id : String,param : [[String:Any]],index: Int, success:@escaping RequestCompletionHandler,  failure: @escaping RequestFailureHandler) -> DataRequest{
        let url = prepareURLForAddRestaurant(id: id, index: index)
        let user = DataBaseHelper.shared.getData().first
        let token = user?.tokenId ?? ""
        let request = prepareRequestFortPatch(url: URL(string: url), param: param, token: token)
        return requestForPost(request: request, success: success, failure: failure)
    }
    
    func deletePreferenceCuisines(id : String,index : Int, itemId : String,success:@escaping RequestCompletionHandler,  failure: @escaping RequestFailureHandler) -> DataRequest{
        let url = prepareURLForDeleteCuisines(id: id, index: index, itemId: itemId)
        return requestWithHeaders(with: url, method: .delete, header: WebAPIHandler.defaultRequestHeaders, parameters: [:], success: success, failure: failure)
    }
    
    func addAddressForDeliveryid (id : String,index: Int, param: [String:Any], success:@escaping RequestCompletionHandler,  failure: @escaping RequestFailureHandler) -> DataRequest{
        let url = prepareURLForAddAddress(id: id, index : index)
        let request = prepareRequest(url: URL.init(string: url), param: param)
        return requestForPost(request: request, success: success, failure: failure)
    }
    
    func getAddressPhones (id : String,index: Int, success:@escaping RequestCompletionHandler,  failure: @escaping RequestFailureHandler) -> DataRequest{
        let url = prepareURLForAddAddress(id: id, index : index)
        if index == 1{
            return request(with: url, method: .get, parameters: [:], success: success, failure: failure)
        }else{
            return requestWithHeaders(with: url, method: .get, header: WebAPIHandler.defaultRequestHeaders, parameters: [:], success: success, failure: failure)
        }
    }
    
    func deleteUserDeliveryInfo(id : String,index : Int, itemId : String,success:@escaping RequestCompletionHandler,  failure: @escaping RequestFailureHandler) -> DataRequest{
        let url = prepareURLForDeleteAddress(id: id, index: index, itemId: itemId)
        return requestWithHeaders(with: url, method: .delete, header: WebAPIHandler.defaultRequestHeaders, parameters: [:], success: success, failure: failure)
    }
    
    func changeUserPassword(id : String,param : [String:Any] , success:@escaping RequestCompletionHandler,  failure: @escaping RequestFailureHandler) -> DataRequest{
        let url = prepareURLforChangePassword(id: id)
        let request = prepareRequest(url:URL.init(string: url), param: param)
        return requestForPost(request: request, success: success, failure: failure)
    }
    
    func getSubscriptionCategory(id : String, success:@escaping RequestCompletionHandler,  failure: @escaping RequestFailureHandler) -> DataRequest{
        let url = prepareURLForSelectCat(id: id)
        return request(with: url, method: .get, parameters: [:], success: success, failure: failure)
    }
    
    func getSubscriptionPlan(id : String, catagId : String, success:@escaping RequestCompletionHandler,  failure: @escaping RequestFailureHandler) -> DataRequest{
        let url = prepareURLForSelectPlan(id: id, categoryId: catagId)
        return request(with: url, method: .get, parameters: [:], success: success, failure: failure)
    }
    
    //TODO:- Calling Web Service
    private func request(with requestURL : String, method : HTTPMethod, parameters : Parameters, success : @escaping RequestCompletionHandler, failure : @escaping RequestFailureHandler) -> DataRequest {
        return Alamofire.request(requestURL, method: method, parameters: parameters, headers: WebAPIHandler.defaultRequestHeaders).responseJSON { (response) in
            debugPrint(response)
            if response.result.isSuccess{
                let responseObject = response.result.value!
                success((responseObject as? Parameters) ?? [:])
                debugPrint(responseObject)
            }else{
                debugPrint(response.request!)
                failure(response.result.error!)
            }
        }
    }
    
    private func requestWithHeaders(with requestURL : String, method : HTTPMethod,header : HTTPHeaders, parameters : Parameters, success : @escaping RequestCompletionHandler, failure : @escaping RequestFailureHandler) -> DataRequest {
        return Alamofire.request(requestURL, method: method, parameters: parameters, headers: header).responseJSON { (response) in
            debugPrint(response)
            if response.result.isSuccess{
                let responseObject = response.result.value!
                success((responseObject as? Parameters) ?? [:])
                debugPrint(responseObject)
            }else{
                debugPrint(response.request!)
                failure(response.result.error!)
            }
        }
    }
    
    //TODO:- API for post
    private func requestForPost(request:URLRequest, success : @escaping RequestCompletionHandler, failure : @escaping RequestFailureHandler) -> DataRequest{
        return Alamofire.request(request).responseJSON(completionHandler: { (response) in
            debugPrint(response)
            if response.result.isSuccess{
                let responseObject = response.result.value!
                success((responseObject as? Parameters) ?? [:] )
            }else{
                failure(response.result.error!)
            }
        })
    }
    
    //
    func MultiPart(_ endpoint:String, params: [String : Any]?, imageData : Data,header : HTTPHeaders, success : @escaping RequestCompletionHandler, failure : @escaping RequestFailureHandler) -> DataRequest?{
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            for (key, value) in params! {
                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
            multipartFormData.append(imageData, withName: "file", fileName: "file.png", mimeType: "image/png")
            
        }, to: endpoint,method: .post, headers: header)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                upload.responseJSON(completionHandler: { (response) in
                    if response.result.isSuccess{
                        let responseObject = response.result.value!
                        success((responseObject as? Parameters) ?? [:] )
                    }else{
                        failure(response.result.error!)
                    }
                })
            case .failure(let encodingError):
                print(encodingError)
                failure(encodingError)
            }
        }
        return nil
    }
}


