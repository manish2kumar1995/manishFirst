//
//  AddContactsVC.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 11/26/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
import MRCountryPicker
import JWTDecode

protocol AddContactsVCDelegate {
    func didSelectContact(number : String, section : Int)
}
class AddContactsVC: BaseViewController {
    
    //MARK:- IB Outlets
    @IBOutlet weak var labelCourtryCode: UILabel!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var countryFlagImageView: UIImageView!
    
    var countryPicker = MRCountryPicker()
    var countryCode = String()
    var delegate : AddContactsVCDelegate?
    var section : Int?
    
    var countryData : CountryFormat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigation(title: "Add Phone Numbers")
        self.countryFlagImageView.image = self.countryData?.flag
        self.labelCourtryCode.text = self.countryData?.phoneCode
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func pickButtonAction(_ sender: Any) {
    }
    
    @IBAction func addButtonAction(_ sender: Any) {
        if (self.phoneNumberTextField.text?.isEmpty)!{
            self.showAlertViewWithTitle(title: "", Message: "Please provide phone number", CancelButtonTitle: "Ok")
        }else{
            let user = DataBaseHelper.shared.getData().first
            let token = user?.tokenId ?? ""
            var userid = String()
            do{
                let jwt = try decode(jwt: token)
                if jwt.expired{
                    //    self.performLogout()
                }else{
                    let body = jwt.body
                    userid = (body["uid"] as? String) ?? ""
                }
            }catch{
                print("Data not fetched")
            }
            let param = ["dialCountry": "\(self.countryData?.code ?? "")","phone": "\(self.countryData?.phoneCode ?? "" )\(self.phoneNumberTextField.text ?? "")","type": "mobile"]
            self.showHud(message: "Adding phone numbers..")
            _ = WebAPIHandler.sharedHandler.addAddressForDeliveryid(id: userid, index: 2, param: param, success: { (response) in
                debugPrint(response)
                self.hideHud()
                let meta = (response["meta"] as? [String:Any]) ?? [:]
                let message = (meta["message"] as? String) ?? ""
                if message.isEmpty{
                    let addresses = (response["phones"] as? [[String:Any]])?.first ?? [:]
                    var cuisineAddress = CuisineData(data: [:], index: 0)
                    cuisineAddress.restaurantTitle = "\(self.countryData?.phoneCode ?? "" )\(self.phoneNumberTextField.text ?? "")"
                    cuisineAddress.id = (addresses["id"] as? String) ?? ""
                    cuisineAddress.phoneCode = self.countryData?.code ?? ""
                    NotificationCenter.default.post(name: Notification.Name.init("updateContacts"), object: cuisineAddress, userInfo: [:])
                    let arr_controller:[UIViewController] = (self.navigationController?.viewControllers)!
                    for controller in arr_controller{
                        if let controll = controller as? MyAccountViewController{
                            _ = self.navigationController?.popToViewController(controll, animated: true)
                        }
                    }
                }else{
                    self.showAlertViewWithTitle(title: "", Message: message, CancelButtonTitle: "Ok")
                }
            }, failure: { (error) in
                debugPrint(error)
                self.hideHud()
            })
        }
    }
}

//MARK:- Custom Methods
extension AddContactsVC{
    
}

//MARK:- Textfield delegate
extension AddContactsVC : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 16
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
}


