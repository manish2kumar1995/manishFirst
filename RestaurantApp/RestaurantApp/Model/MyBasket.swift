//
//  MyBasket.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 06/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//
/*
 :- Model for basket
 */

import Foundation

class MyBasket : NSObject  {
    var totalCart = Int()
    var totalQAR = CGFloat()
    var myBasketData = [[String:MyBasketData]]()
    var myOptionData = [[Int:MyOptionData]]()
}
