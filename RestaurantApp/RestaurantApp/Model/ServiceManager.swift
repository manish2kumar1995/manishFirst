//
//  ServiceManager.swift
//  GoogleMapDemo
//
//  Created by Rahul on 06/04/18.
//  Copyright © 2018 Rahul. All rights reserved.
//
/*
 * Class to handle networking apis
 * Handle Google Address Search apis
 */

import Foundation
import Alamofire
import GoogleMaps
import SwiftyJSON

class ServiceManager: NSObject {
    
    static let shared = ServiceManager()
    var placesResponse:PlacesResponse?
    var placesByPlaceIdResponse: PlacesByPlaceIdResponse?
    var address : Address?
    
    
    func getLocationFrom(placeId: String,completion: @escaping ( (PlacesByPlaceIdResponse?) -> Swift.Void)){
        let url = "https://maps.googleapis.com/maps/api/place/details/json?input=bar&placeid=\(placeId)&key=AIzaSyBjcfC0L5dUxF337sw3LVTzYUlZo8sakwU"
        request(for: url, method: .get, params: nil) { (response) in
            
            if response.response == nil {
                return
            }
            
            if response.response?.statusCode != 200 {
                return
            }
            
            if response.value != nil {
                self.placesByPlaceIdResponse = PlacesByPlaceIdResponse.init(objec: response.value!)
            }
            
            completion(self.placesByPlaceIdResponse)
            
        }
    }
    
    
    //Getting address from latitude and longitude
    func getAddressForLatLng(latitude: String, longitude: String, completion : @escaping((Address?) -> Swift.Void))  {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Double("\(latitude)")!
        let lon: Double = Double("\(longitude)")!
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        
        let loc: CLLocation = CLLocation(latitude:lat, longitude: lon)
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                    print(pm.country ?? "")
                    print(pm.locality ?? "")
                    print(pm.subLocality ?? "")
                    print(pm.thoroughfare ?? "")
                    print(pm.postalCode ?? "")
                    print(pm.subThoroughfare ?? "")
                    
                    //           self.address = Address.init(pm: pm)
                }else{
                    return
                }
                completion(self.address)
        })
    }
    
    
    //Getting address from latitude and longitude google API
    func getAddressForLatLngByGoogle(latitude: String, longitude: String, completion : @escaping((Address?) -> Swift.Void))  {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Double("\(latitude)")!
        let lon: Double = Double("\(longitude)")!
        center.latitude = lat
        center.longitude = lon
        
        let geocoder = GMSGeocoder()
        geocoder.accessibilityLanguage = "en-US"
        let coordinate = CLLocationCoordinate2DMake(lat,lon)
        geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
            if response != nil{
                if let address = response?.firstResult() {
                    print(address)
                    self.address = Address.init(address: address)
                }
                completion(self.address)
                
            }else{
                self.address = nil
                completion(self.address)
            }
            
        }
        //  let loc: CLLocation = CLLocation(latitude:lat, longitude: lon)
        
        
    }
    
    
    //MARK:- Private methods
    
    @discardableResult  private func requestWithHeaders(for endPoint: String, method: HTTPMethod,headers:HTTPHeaders, params : [String : Any]?, completionHandler: @escaping ( (DataResponse<Any>) -> Swift.Void)) -> DataRequest
    {
        
        if headers.count > 0 {
            
            return Alamofire.request(endPoint, method: method, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { (response) in
                completionHandler(response)
            })
        }
        
        return Alamofire.request(endPoint, method: method, encoding: JSONEncoding.default).responseJSON(completionHandler: { (response) in
            completionHandler(response)
        })
    }
    
    
    @discardableResult
    private func request(for endPoint: String, method: HTTPMethod, params : [String : Any]?, completionHandler: @escaping ( (DataResponse<Any>) -> Swift.Void)) -> DataRequest
    {
        
        return Alamofire.request(endPoint, method: method, encoding: JSONEncoding.default).responseJSON(completionHandler: { (response) in
            completionHandler(response)
        })
    }
    
}

//MARK:- Endpoints
struct Endpoints{
    
    static let base_url = ""
    struct methods {
    }
}

public class Response: NSObject, NSCoding {
    
    private struct SerializationKeys {
        static let success = "success"
        static let status  = "status"
        static let message = "message"
        static let error   = "errors"
    }
    
    // MARK: Properties
    
    var status: Int?
    var success: Bool?
    var message: String?
    var error: NSError?
    
    var isSuccess: Bool {
        return self.success!
    }
    
    required public init(json: JSON) {
        self.status = json[SerializationKeys.status].intValue
        self.message = json[SerializationKeys.message].stringValue
        self.success = json[SerializationKeys.success].boolValue
        super.init()
    }
    
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        dictionary[SerializationKeys.success] = success
        if let value = status { dictionary[SerializationKeys.status] = value }
        if let value = message { dictionary[SerializationKeys.message] = value }
        dictionary[SerializationKeys.error] = error
        return dictionary
    }
    
    // MARK: NSCoding Protocol
    required public init(coder aDecoder: NSCoder) {
        self.success = aDecoder.decodeBool(forKey: SerializationKeys.success)
        self.status  = aDecoder.decodeObject(forKey: SerializationKeys.status) as? Int
        self.message = aDecoder.decodeObject(forKey: SerializationKeys.message) as? String
        self.error = aDecoder.decodeObject(forKey: SerializationKeys.error) as? NSError
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(success, forKey: SerializationKeys.success)
        aCoder.encode(status, forKey: SerializationKeys.status)
        aCoder.encode(message, forKey: SerializationKeys.message)
        aCoder.encode(error, forKey: SerializationKeys.error)
    }
    
    
}


class PlacesResponse: Response {
    
    private struct SerializationKeys {
        static let predictions = "predictions"
        static let main_text = "main_text"
        static let description = "description"
        static let place_id = "place_id"
        static let structured_formatting = "structured_formatting"
    }
    
    var places = [Places]()
    
    // MARK: Initializers
    convenience init(objec: Any) {
        self.init(json: JSON.init(objec))
    }
    
    /// Initiates the instance based on the JSON that was passed.
    public required init(json: JSON) {
        super.init(json: json)
    }
    
    
    // MARK: NSCoding Protocol
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    public override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
    }
    
}


//MARK:- Address class
class Address {
    var locality = String()
    var subLocality = String()
    var address : GMSAddress?
    required public init(address : GMSAddress) {
        self.address = address
        if address.thoroughfare != nil && address.subLocality != nil{
            self.subLocality = "\(address.thoroughfare ?? ""), \(address.subLocality ?? "")"
        }else if address.thoroughfare == nil && address.subLocality != nil{
            self.subLocality = "\(address.subLocality ?? "")"
        }else if address.thoroughfare != nil && address.subLocality == nil {
            self.subLocality = "\(address.thoroughfare ?? "")"
        }else if address.thoroughfare == nil && address.subLocality == nil{
            self.subLocality = address.lines?.first ?? ""
        }
        if address.locality != nil{
            self.locality = "\(address.locality ?? ""), \(address.country ?? "")"
        }else{
            self.locality = "\(address.administrativeArea ?? ""), \(address.country ?? "")"
        }
    }
}


class PlacesByPlaceIdResponse: Response{
    private struct SerializationKeys {
        static let result = "result"
        static let location = "location"
        static let lat = "lat"
        static let lng = "lng"
        static let geometry = "geometry"
        
    }
    
    var lattitude : Double!
    var longitude: Double!
    
    // MARK: Initializers
    convenience init(objec: Any) {
        self.init(json: JSON.init(objec))
    }
    
    public required init(json: JSON) {
        super.init(json: json)
        let location = json[SerializationKeys.result][SerializationKeys.geometry][SerializationKeys.location]
        self.lattitude = location[SerializationKeys.lat].double ?? 0.0
        self.longitude = location[SerializationKeys.lng].double ?? 0.0
    }
    
    
    // MARK: NSCoding Protocol
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    public override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
    }
    
}


