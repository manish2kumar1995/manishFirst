//
//  PhoneNumberAndCodeCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 17/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
import MRCountryPicker

//Protocol for various cell events
protocol  PhoneNumberAndCodeCellDelegate{
    func showAlert()
    func showSavedPhones()
}

class PhoneNumberAndCodeCell: UITableViewCell {
    
    //MARK:- IB outlet
    @IBOutlet weak var viewInCell: UIView!
    @IBOutlet weak var labelCourtryCode: UILabel!
    @IBOutlet weak var phoneNumberTextField: TextField!
    @IBOutlet weak var countryFlagImageView: UIImageView!
    @IBOutlet weak var lastNameTextField: TextField!
    @IBOutlet weak var firstNameTextField: TextField!
    @IBOutlet weak var emailTextField: TextField!
    
    
    
    var countryPicker = MRCountryPicker()
    var delegate : PhoneNumberAndCodeCellDelegate?
    var countryCode = String()
    var shouldPick = false
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //UIConfiguration
        viewInCell.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 5.0)
        viewInCell.addBorder(toSide: .left, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
        viewInCell.addBorder(toSide: .right, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
        viewInCell.addBorder(toSide: .bottom, withColor : UIColor.disabledLightGray.cgColor, andThickness : 0.4)
        setTagAndDelegate()
   
        countryPicker.countryPickerDelegate = self
        countryPicker.showPhoneNumbers = true
        phoneNumberTextField.delegate = self
        if let address = UserShared.shared.userSavedAddress{
            self.countryFlagImageView.image = UIImage(named: "SwiftCountryPicker.bundle/Images/\(address.countryCode.uppercased())", in: Bundle(for: MRCountryPicker.self), compatibleWith: nil)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initPhoneNumber(data: PhoneStruct){
        self.phoneNumberTextField.text = data.phoneNumber
        self.countryFlagImageView.image = UIImage(named: "SwiftCountryPicker.bundle/Images/\(data.countryCode.uppercased())", in: Bundle(for: MRCountryPicker.self), compatibleWith: nil)
        self.labelCourtryCode.text = ""
    }
    
    func setTagAndDelegate(){
        self.phoneNumberTextField.tag = 1
        self.emailTextField.tag = 2
        self.firstNameTextField.tag = 3
        self.lastNameTextField.tag = 4
        self.emailTextField.text = UserShared.shared.user.email
        self.firstNameTextField.text = UserShared.shared.user.firstName
        self.lastNameTextField.text = UserShared.shared.user.lastName
        self.emailTextField.delegate = self
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
    }
    
    //Button action
    @IBAction func pickButtonAction(_ sender: UIButton) {
        self.phoneNumberTextField.inputView = countryPicker
        self.phoneNumberTextField.becomeFirstResponder()
    }
}

//MARK:- Text field delegate
extension PhoneNumberAndCodeCell : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 2{
            if !(textField.text?.isValidEmail())!{
                self.delegate?.showAlert()
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1{
            if UserShared.shared.isKnownUser{
                if !self.shouldPick{
                    DispatchQueue.main.async {
                        textField.resignFirstResponder()
                        self.delegate?.showSavedPhones()

                    }
                }
            }
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.tag == 3 || textField.tag == 4 {
            //first name and last name textfield
            let regex = try! NSRegularExpression(pattern: "[a-zA-Z\\s]+", options: [])
            let range = regex.rangeOfFirstMatch(in: string, options: [], range: NSRange(location: 0, length: string.count))
            return range.length == string.count
        }
        return true
    }
}

//MARK:- Country picker delegate
extension PhoneNumberAndCodeCell : MRCountryPickerDelegate{
    func countryPhoneCodePicker(_ picker: MRCountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        self.countryFlagImageView.image = flag
    //    self.labelCourtryCode.text = "\(phoneCode)"
        self.phoneNumberTextField.text = ""
        self.phoneNumberTextField.text = phoneCode
        self.countryCode = countryCode
        self.phoneNumberTextField.inputView = nil
        self.phoneNumberTextField.resignFirstResponder()
    }
}
