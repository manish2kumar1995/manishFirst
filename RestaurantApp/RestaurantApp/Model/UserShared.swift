//
//  UserShared.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 06/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//
/*
 App singleton class to store user's menu items and user preferences.
 */

import Foundation
import CoreLocation
import UIKit
import GoogleMaps


class UserShared {
    static let shared = UserShared()
    
    var myBasketModel = MyBasket()
    var paymentMethods = PaymentMethods()
    var menuItems : [MenuItems]?
    var isKnownUser = false
    var currentAddress = ""
    var currentLocation : CLLocation?
    var googleCurrentAddress : Address?
    var didChangeLocation = true
    var isSubscriptionMode = false
    var user = UserInfo()
    var userSavedAddress : AddressStruct?
    var userMode  = "on_demand"
}

