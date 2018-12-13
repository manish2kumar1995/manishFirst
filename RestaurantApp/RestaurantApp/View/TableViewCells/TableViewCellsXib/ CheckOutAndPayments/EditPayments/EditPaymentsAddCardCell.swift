//
//  EditPaymentsAddCardCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 11/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class EditPaymentsAddCardCell: UITableViewCell {
    
    //MARK:- IB Outlets
    @IBOutlet weak var buttonCheckMark: UIButton!
    @IBOutlet weak var viewInCell: UIView!
    @IBOutlet weak var cardHolderTextField: TextField!
    @IBOutlet weak var cvvTextField: TextField!
    @IBOutlet weak var expYearTextField: TextField!
    @IBOutlet weak var expMonthTextField: TextField!
    @IBOutlet weak var cardNumberTextField: TextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var scanCardButton: UIButton!
    
    //MARK:- Custom variables
    var monthPickOption = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
    var yearPickOption = ["2018", "2019", "2020", "2021", "2022", "2023", "2024", "2025"]
    let pickerView = UIPickerView()
    var selectedIndex = Int()
    var isfirstTime = true
    var cellDataSource = ["nameData":"","numberData":"","expMonth":"", "expYear":"","cvv":""]
    
    //Custom attribute
    let yourAttributes : [NSAttributedStringKey: Any] = [
        NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14.0),
        NSAttributedStringKey.foregroundColor : UIColor.white,
        NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue]
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //Config UI based work
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.setData()
        
        self.setDelegate()
        
        self.expMonthTextField.inputView = self.pickerView
        self.expYearTextField.inputView = self.pickerView
        
        self.setTags()
        
        let attributeString = NSMutableAttributedString(string: "Scan",
                                                        attributes: self.yourAttributes)
        self.scanCardButton.setAttributedTitle(attributeString, for: .normal)
        
        let attributeStringAdd = NSMutableAttributedString(string: "Add",
                                                           attributes: self.yourAttributes)
        self.addButton.setAttributedTitle(attributeStringAdd, for: .normal)
        
        
        DispatchQueue.main.async {
            self.contentView.layoutIfNeeded()
            self.viewInCell.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 5.0)
            self.viewInCell.addBorder(toSide: .left, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
            self.viewInCell.addBorder(toSide: .right, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
            self.viewInCell.addBorder(toSide: .bottom, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
            self.contentView.layoutSubviews()
            self.addButton.layer.cornerRadius = 5
            self.addButton.clipsToBounds = true
            self.scanCardButton.layer.cornerRadius = 5
            self.scanCardButton.clipsToBounds = true
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

//MARK:- Custom Methods
extension EditPaymentsAddCardCell{
    func setDelegate(){
        self.cardHolderTextField.delegate = self
        self.cardNumberTextField.delegate = self
        self.expMonthTextField.delegate = self
        self.expYearTextField.delegate = self
        self.cvvTextField.delegate = self
    }
    
    //
    func setData(){
        self.cardHolderTextField.text = self.cellDataSource["nameData"]
        self.cardNumberTextField.text = self.cellDataSource["numberData"]
        self.expMonthTextField.text = self.cellDataSource["expMonth"]
        self.expYearTextField.text = self.cellDataSource["expYear"]
        self.cvvTextField.text = self.cellDataSource["cvv"]
    }
    
    //settins tags to handle flow
    func setTags(){
        self.expMonthTextField.tag = 1
        self.expYearTextField.tag = 2
        self.cardHolderTextField.tag = 3
        self.cvvTextField.tag = 4
        self.cardNumberTextField.tag = 5
    }
}

//MARK:- Picker view delegate
extension EditPaymentsAddCardCell : UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if self.selectedIndex == 1{
            return monthPickOption.count
        }else{
          
            if (self.expMonthTextField.text?.isEmpty)!{
                return yearPickOption.count
            }else if Int(self.expMonthTextField.text!)! < 9{
                  return yearPickOption.count
            }else{
                return yearPickOption.count
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if self.selectedIndex == 1{
            return monthPickOption[row]
        }else{
           return yearPickOption[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if self.selectedIndex == 1{
            self.expMonthTextField.text = monthPickOption[row]
        }else{
            self.expYearTextField.text = yearPickOption[row]
        }
    }
}

//MARK:- UI Textfield delegate
extension EditPaymentsAddCardCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1{
            self.selectedIndex = textField.tag
            pickerView.reloadAllComponents()
        }else{
            self.selectedIndex = textField.tag
            pickerView.reloadAllComponents()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.tag == 3{
            //CardHolderTextField
            self.cellDataSource.updateValue(textField.text ?? "", forKey: "nameData")
            let regex = try! NSRegularExpression(pattern: "[a-zA-Z\\s]+", options: [])
            let range = regex.rangeOfFirstMatch(in: string, options: [], range: NSRange(location: 0, length: string.count))
            return range.length == string.count
        }
        if textField.tag == 4{
            //CVVTextField
            self.cellDataSource.updateValue(textField.text ?? "", forKey: "cvv")
            let maxLength = 3
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        
        if textField.tag == 5{
            //CardNumberTextField
            self.cellDataSource.updateValue(textField.text ?? "", forKey: "numberData")
            let maxLength = 16
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        
        if textField.tag == 1{
            //Expiry month textfield
            self.cellDataSource.updateValue(textField.text ?? "", forKey: "expMonth")
        }
        
        if textField.tag == 2{
            //Expiry year textfield
            self.cellDataSource.updateValue(textField.text ?? "", forKey: "expYear")
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
}
