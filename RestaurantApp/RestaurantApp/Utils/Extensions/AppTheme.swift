//
//  AppTheme.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 28/08/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import Foundation
import UIKit

//MARK:- Color
extension UIColor {
    
    static let darkRed = UIColor.init(red: 220/255, green: 122/255, blue: 146/255, alpha: 1.0)
    static let disabledGray = UIColor.lightGray
    static let disabledLightGray = UIColor.init(red: 222/255, green: 222/255, blue: 222/255, alpha: 1.0)
    static let borderedRed = UIColor.init(red: 175/255, green: 8/255, blue: 54/255, alpha: 1.0)
    static let greenTimerColor = UIColor.init(red: 77/255, green: 178/255, blue: 72/255, alpha: 1.0)
    static let redTimerColor = UIColor.init(red: 191/255, green: 0/255, blue: 63/255, alpha: 1.0)
    static let textGray = UIColor.init(red: 117/255, green: 117/255, blue: 117/255, alpha: 1.0)
    static let borderedGray = UIColor.init(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)
    static let modesButtonSelectedText = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
    static let modesButtonSelectedBackground = UIColor.init(red: 254/255, green: 254/255, blue: 254/255, alpha: 1.0)
    static let modeButtonUnselectedText = UIColor.init(red: 170/255, green: 170/255, blue: 170/255, alpha: 1.0)
    static let modeButtonUnselectedBackground = UIColor.init(red: 237/255, green: 237/255, blue: 237/255, alpha: 1.0)
    static let blackishGray  = UIColor.init(red: 141/255, green: 141/255, blue: 142/255, alpha: 1.0)
    static let viewBackgroundGray  = UIColor.init(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)
    static let buttonBackgroundGray  = UIColor.init(red: 237/255, green: 237/255, blue: 237/255, alpha: 1.0)
    static let naivgationTitleColor = UIColor.white
    static let pinkColor = UIColor.init(red: 255/255, green: 49/255, blue: 243/255, alpha: 1.0)
    static let darkGreen = UIColor.init(red: 35/255, green: 168/255, blue: 38/255, alpha: 1.0)
    static let darkYellow = UIColor.init(red: 255/255, green: 171/255, blue: 0/255, alpha: 1.0)
    static let shadeColor = UIColor.init(red: 186/255, green: 46/255, blue: 34/255, alpha: 1.0)
    static let shadeOrange = UIColor.init(red: 235/255, green: 98/255, blue: 0/255, alpha: 1.0)
    static let disableRed = UIColor.init(red: 223/255, green: 192/255, blue: 196/255, alpha: 1.0)
    static let shadeRed = UIColor.init(red: 204/255, green: 52/255, blue: 32/255, alpha: 1.0)
}

//Methods for UI color
extension UIColor {
    static func gradientColorFrom(color color1:UIColor, toColor color2:UIColor ,withSize size:CGSize) -> UIColor
    {
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        let context = UIGraphicsGetCurrentContext();
        let colorspace = CGColorSpaceCreateDeviceRGB();
        
        let colors = [color1.cgColor, color2.cgColor] as CFArray;
        
        let gradient = CGGradient(colorsSpace: colorspace, colors: colors, locations: nil);
        context!.drawLinearGradient(gradient!, start: CGPoint(x:0, y:0), end: CGPoint(x:size.width, y:0), options: CGGradientDrawingOptions(rawValue: UInt32(0)));
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        let finalCColor = UIColor(patternImage: image!);
        return finalCColor;
    }
}

//MARK:- Fonts
extension UIFont {
    static let gouthamRegular = UIFont.init(name: "Gotham Medium Regular", size: 10.0)
}

//MARK:- UIView
extension UIView {
    /** Loads instance from nib with the same name. */
    func loadNib() -> UIView {
        return Bundle.main.loadNibNamed("RestaurantsSectionHeader", owner: self, options: nil)?.first as! UIView
    }
    
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        
        DispatchQueue.main.async {
            let path = UIBezierPath(roundedRect: self.bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius))
            let maskLayer = CAShapeLayer()
            maskLayer.frame = self.bounds
            maskLayer.path = path.cgPath
            maskLayer.lineWidth = 0.4
            maskLayer.strokeColor = UIColor.red.cgColor
            self.layer.mask = maskLayer
        }
    }
    
    enum ViewSide {
        case left, right, top, bottom
    }
    
    func addBorder(toSide side: ViewSide, withColor color: CGColor, andThickness thickness: CGFloat) {
        
        DispatchQueue.main.async {
            let border = CALayer()
            border.backgroundColor = color
            switch side {
            case .left: border.frame = CGRect(x: 0, y: 0, width: thickness, height: self.bounds.height)
            case .right: border.frame = CGRect(x: self.bounds.width - thickness, y: 0, width: thickness, height: self.frame.height)
            case .top: border.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: thickness)
            case .bottom: border.frame = CGRect(x: 0, y: self.bounds.width - thickness, width: self.bounds.width, height: thickness)
            }
            self.layer.addSublayer(border)
        }
    }
    
    func addGradienBorder(view : UIView) {
        let gradient = CAGradientLayer()
        gradient.frame =  CGRect(origin: .zero, size: view.frame.size)
        gradient.colors = [UIColor.shadeOrange.cgColor, UIColor.borderedRed.cgColor]
        //      (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5))
        gradient.startPoint = CGPoint(x: 0.0,y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0,y: 0.5)
        let shape = CAShapeLayer()
        shape.lineWidth = 2.5
        shape.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .bottomLeft, .topRight, .bottomRight], cornerRadii: CGSize(width: 7.0, height: 7.0)).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        view.layer.addSublayer(gradient)
    }
    
    
    
    func removeGradient(view : UIView) {
        if let sublayers = view.layer.sublayers {
            for layer in sublayers{
                if let lay = layer as? CAGradientLayer{
                    lay.removeFromSuperlayer()
                }
            }
        }
    }
}

//MARK:- UIlabel etension
extension UILabel {
    
    func applyGradientWith(startColor: UIColor, endColor: UIColor) {
        var startColorRed:CGFloat = 0
        var startColorGreen:CGFloat = 0
        var startColorBlue:CGFloat = 0
        var startAlpha:CGFloat = 0
        
        if !startColor.getRed(&startColorRed, green: &startColorGreen, blue: &startColorBlue, alpha: &startAlpha) {
        }
        
        var endColorRed:CGFloat = 0
        var endColorGreen:CGFloat = 0
        var endColorBlue:CGFloat = 0
        var endAlpha:CGFloat = 0
        
        if !endColor.getRed(&endColorRed, green: &endColorGreen, blue: &endColorBlue, alpha: &endAlpha) {
        }
        
        let gradientText = self.text ?? ""
        
        let name = NSAttributedStringKey.init("")
        let textSize: CGSize = gradientText.size(withAttributes: [name:self.font])
        let width:CGFloat = textSize.width
        let height:CGFloat = textSize.height
        
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return
        }
        
        UIGraphicsPushContext(context)
        
        let glossGradient:CGGradient?
        let rgbColorspace:CGColorSpace?
        let num_locations:size_t = 2
        let locations:[CGFloat] = [ 0.0, 1.0 ]
        let components:[CGFloat] = [startColorRed, startColorGreen, startColorBlue, startAlpha, endColorRed, endColorGreen, endColorBlue, endAlpha]
        rgbColorspace = CGColorSpaceCreateDeviceRGB()
        glossGradient = CGGradient(colorSpace: rgbColorspace!, colorComponents: components, locations: locations, count: num_locations)
        let topCenter = CGPoint.zero
        let bottomCenter = CGPoint(x: 0, y: textSize.height)
        context.drawLinearGradient(glossGradient!, start: topCenter, end: bottomCenter, options: CGGradientDrawingOptions.drawsBeforeStartLocation)
        
        UIGraphicsPopContext()
        
        guard let gradientImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return 
        }
        
        UIGraphicsEndImageContext()
        
        self.textColor = UIColor(patternImage: gradientImage)
        
    }
    
}


//MARK:- CALayer extension
extension CALayer {
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        DispatchQueue.main.async {
            let border = CALayer()
            
            switch edge {
            case .top:
                border.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: thickness)
            case .bottom:
                border.frame = CGRect(x: 0, y: self.bounds.width - thickness, width: self.bounds.width, height: thickness)
            case .left:
                border.frame = CGRect(x: 0, y: 0, width: thickness, height: self.bounds.width)
            case .right:
                border.frame = CGRect(x: self.bounds.width - thickness, y: 0, width: thickness, height: self.bounds.width)
            default:
                break
            }
            
            border.backgroundColor = color.cgColor;
            
            self.addSublayer(border)
        }
    }
    
}
