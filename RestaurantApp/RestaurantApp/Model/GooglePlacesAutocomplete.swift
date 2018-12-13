//
//  GooglePlacesAutocomplete.swift
//  GooglePlacesAutocomplete
//
//  Created by Howard Wilson on 10/02/2015.
//  Copyright (c) 2015 Howard Wilson. All rights reserved.
//
//
//  Created by Dmitry Shmidt on 6/28/15.
//  Copyright (c) 2015 Dmitry Shmidt. All rights reserved.

import UIKit
import CoreLocation

//MARK:- PlaceType
public enum PlaceType: String {
    case all = ""
    case geocode
    case address
    case establishment
    case regions = "(regions)"
    case cities = "(cities)"
}

//MARK:- Places
open class Places: NSObject {
    open let id: String
    open let mainAddress: String
    open let secondaryAddress: String
    
    override open var description: String {
        get { return "\(mainAddress), \(secondaryAddress)" }
    }
    
    init(id: String, mainAddress: String, secondaryAddress: String) {
        self.id = id
        self.mainAddress = mainAddress
        self.secondaryAddress = secondaryAddress
    }
    
    convenience init(prediction: [String: Any]) {
        let structuredFormatting = prediction["structured_formatting"] as? [String: Any]
        
        self.init(
            id: prediction["place_id"] as? String ?? "",
            mainAddress: structuredFormatting?["main_text"] as? String ?? "",
            secondaryAddress: structuredFormatting?["secondary_text"] as? String ?? ""
        )
    }
}

//MARK:- Places
open class GooglePlacesAutocompleteContainer{
    
    private var apiKey: String = "AIzaSyBjcfC0L5dUxF337sw3LVTzYUlZo8sakwU"
    private var placeType: PlaceType = .all
    private var coordinate: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
    private var radius: Double = 0.0
    private var strictBounds: Bool = false
    private let cellIdentifier = "Cell"
    static let shared = GooglePlacesAutocompleteContainer()
}


//MARK:- Google places autocomplete handler
extension GooglePlacesAutocompleteContainer {

     func getParameters(for text: String) -> [String: String] {
        var params = [
            "input": text,
            "types": "",
            "key": "AIzaSyBjcfC0L5dUxF337sw3LVTzYUlZo8sakwU"
        ]
        
        if CLLocationCoordinate2DIsValid(coordinate) {
            params["location"] = "\(coordinate.latitude),\(coordinate.longitude)"
            
            if radius > 0 {
                params["radius"] = "\(radius)"
            }
            
            if strictBounds {
                params["strictbounds"] = "true"
            }
        }
        
        return params
    }
}

//MARK:- Google places autocomplete Request handler
public class GooglePlacesRequestHelpers {
    
    static func doRequest(_ urlString: String, params: [String: String], completion: @escaping (NSDictionary) -> Void) {
        var components = URLComponents(string: urlString)
        components?.queryItems = params.map { URLQueryItem(name: $0, value: $1) }
        
        guard let url = components?.url else { return }
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                print("GooglePlaces Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse else {
                print("GooglePlaces Error: No response from API")
                return
            }
            
            guard response.statusCode == 200 else {
                print("GooglePlaces Error: Invalid status code \(response.statusCode) from API")
                return
            }
            
            let object: NSDictionary?
            do {
                object = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
            } catch {
                object = nil
                print("GooglePlaces Error")
                return
            }
            
            guard object?["status"] as? String == "OK" else {
                print("GooglePlaces API Error: \(object?["status"] ?? "")")
                return
            }
            
            guard let json = object else {
                print("GooglePlaces Parse Error")
                return
            }
            
            // Perform table updates on UI thread
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                completion(json)
            }
        })
        
        task.resume()
    }
    
    static func getPlaces(with parameters: [String: String], completion: @escaping ([Places]) -> Void) {
        var parameters = parameters
        
        if let deviceLanguage = deviceLanguage {
            parameters["language"] = deviceLanguage
        }
        doRequest(
            "https://maps.googleapis.com/maps/api/place/autocomplete/json",
            params: parameters,
            completion: {
                guard let predictions = $0["predictions"] as? [[String: Any]] else { return }
                completion(predictions.map { Places(prediction: $0) })
         }
        )
    }
    
    private static var deviceLanguage: String? {
        return (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode) as? String
    }
}
