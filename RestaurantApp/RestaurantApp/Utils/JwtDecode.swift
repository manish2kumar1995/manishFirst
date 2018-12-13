//
//  JwtDecode.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 12/7/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import Foundation
import UIKit
import JWTDecode

class JwtDecode {
    static let shared = JwtDecode()
    
    func getUserId() -> String{
        let user = DataBaseHelper.shared.getData().first
        let token = user?.tokenId ?? ""
        var userid = String()
        do{
            let jwt = try decode(jwt: token)
            if jwt.expired{
            }else{
                let body = jwt.body
                userid = (body["uid"] as? String) ?? ""
            }
        }catch{
            print("Data not fetched")
        }
        return userid
    }
    
    func getToken() -> String{
        let user = DataBaseHelper.shared.getData().first
        let token = user?.tokenId ?? ""
        return token
    }
}
