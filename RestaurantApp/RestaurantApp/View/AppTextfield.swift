//
//  AppThemeClasses.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 30/08/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import Foundation
import UIKit

//MARK:- Custom textField with less padding
public class TextField: UITextField {
    
    private func setInsets(forBounds bounds: CGRect) -> CGRect {
        
        var totalInsets = padding //property in you subClass
        
        if leftView != nil  { totalInsets.left += padding.left }
        if let rightView = rightView { totalInsets.right += rightView.bounds.size.width - 10}
        
        return UIEdgeInsetsInsetRect(bounds, totalInsets)
    }
    
    let padding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 5)
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return  setInsets(forBounds: bounds)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return  setInsets(forBounds: bounds)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return  setInsets(forBounds: bounds)
    }
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: newValue!])
        }
    }
}

//MARK:- Textfield with with medium padding
public class PaddingTextfield : UITextField {
    
    private func setInsets(forBounds bounds: CGRect) -> CGRect {
        
        var totalInsets = padding //property in you subClass
        
        if leftView != nil  { totalInsets.left += padding.left }
        if let rightView = rightView { totalInsets.right += rightView.bounds.size.width - 100}
        
        return UIEdgeInsetsInsetRect(bounds, totalInsets)
    }
    
    let padding = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 5)
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return  setInsets(forBounds: bounds)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return  setInsets(forBounds: bounds)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return  setInsets(forBounds: bounds)
    }
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: newValue!])
        }
    }
}

//MARK:- Textfield with large padding
public class LeftSpaceTextField : UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 48, bottom: 0, right: 5)
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: newValue!])
        }
    }
}

