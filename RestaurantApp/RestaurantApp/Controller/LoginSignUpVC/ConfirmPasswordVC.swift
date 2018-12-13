//
//  ConfirmPasswordVC.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 11/22/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class ConfirmPasswordVC: BaseViewController {
    
    //MARK:- IB outlet
    @IBOutlet weak var buttonReset: UIButton!
    @IBOutlet weak var confirmPasswordTextFiels: LeftSpaceTextField!
    @IBOutlet weak var newPasswordTextField: LeftSpaceTextField!
    @IBOutlet weak var buttonLogin: UIButton!
    var code : String?
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func resetButtonAction(_ sender: Any) {
        if (self.newPasswordTextField.text?.isEmpty)!{
            self.showLoginAlertWithTitle(title: "", Message: "Please provide new password", CancelButtonTitle: "Ok")
        }else if (self.confirmPasswordTextFiels.text?.isEmpty)!{
            
            
            self.showLoginAlertWithTitle(title: "", Message: "Please confirm password", CancelButtonTitle: "Ok")
        }else if (self.newPasswordTextField.text?.count)! < 5{
            self.showLoginAlertWithTitle(title: "", Message: "Please enter atleast 5 character password", CancelButtonTitle: "Ok")
        }else if !(self.newPasswordTextField.text?.isEqualToString(find: self.confirmPasswordTextFiels.text ?? ""))!{
            self.showLoginAlertWithTitle(title: "", Message: "Confirm password does not match", CancelButtonTitle: "Ok")
        }else{
            if Connectivity.isConnectedToInternet{
                self.callAPIForResetPassword()
            }else{
                self.showLoginAlertWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "Ok")
            }
        }
    }
    
    @IBAction func loginAction(_ sender: Any) {
        let arr_controller:[UIViewController] = (self.navigationController?.viewControllers)!
        _ = self.navigationController?.popToViewController(arr_controller[0], animated: true)
    }
}

//MARK:- Custom Methods
extension ConfirmPasswordVC {
    func configUI(){
        self.newPasswordTextField.delegate = self
        self.confirmPasswordTextFiels.delegate = self
        self.newPasswordTextField.tag = 1
        self.confirmPasswordTextFiels.tag = 2
        self.buttonReset.layer.borderWidth = 1.0
        self.buttonReset.layer.borderColor = UIColor.white.cgColor
        self.addAttributedText()
        DispatchQueue.main.async {
            self.newPasswordTextField.layer.cornerRadius = self.newPasswordTextField.frame.size.height/2
            self.confirmPasswordTextFiels.layer.cornerRadius = self.confirmPasswordTextFiels.frame.size.height/2
            self.buttonReset.layer.cornerRadius = self.buttonReset.frame.size.height/2
        }
        
        self.newPasswordTextField.setLeftIcon(#imageLiteral(resourceName: "fadePassNew"))
        self.confirmPasswordTextFiels.setLeftIcon(#imageLiteral(resourceName: "fadePassNew"))
        
        self.setShade(textField: self.newPasswordTextField)
        self.setShade(textField: self.confirmPasswordTextFiels)
    }
    
    func setShade(textField : UITextField){
        textField.layer.masksToBounds = false
        textField.layer.shadowRadius = 20.0
        textField.layer.shadowColor = UIColor.shadeColor.cgColor
        textField.layer.shadowOffset = CGSize(width: 1.0, height: 5.0)
        textField.layer.shadowOpacity = 1.0
    }
    
    func callAPIForResetPassword(){
        self.showHud(message: "resetting password..")
        let param = ["resetKey": self.code ?? "","password" : self.newPasswordTextField.text ?? "" ,"passwordConfirmation":self.confirmPasswordTextFiels.text ?? ""]
        _ = WebAPIHandler.sharedHandler.resetPassword(parameters: param, success: { (response) in
            debugPrint(response)
            self.hideHud()
            let token = (response["token"] as? String) ?? ""
            if !token.isEmpty{
                self.view.endEditing(true)
                DataBaseHelper.shared.saveData(token: token)
                self.performLogin()
            }else{
                let meta = (response["meta"] as? [String:Any]) ?? [:]
                let message = (meta["message"] as? String) ?? ""
                self.showLoginAlertWithTitle(title: "", Message: message, CancelButtonTitle: "Ok")
            }
        }, failure: { (error) in
            debugPrint(error)
            self.hideHud()
        })
    }
    
    func performLogin(){
        self.newPasswordTextField.text = ""
        self.confirmPasswordTextFiels.text = ""
        UserShared.shared.isKnownUser = true
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "RootViewController") as! RootViewController
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
    
    func addAttributedText(){
        let yourAttributes : [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor : UIColor.white,
            NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue]
        let attributeForgotString = NSMutableAttributedString(string: "Login here",
                                                              attributes: yourAttributes)
        self.buttonLogin.setAttributedTitle(attributeForgotString, for: .normal)
        
    }
    
}

//MARK:- Text field delegate
extension ConfirmPasswordVC : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1{
            if (textField.text?.count)! < 5{
                textField.setRightIcon(#imageLiteral(resourceName: "loginCross"))
                textField.setLeftIcon(#imageLiteral(resourceName: "errorPassword"))
                textField.isSecureTextEntry = false
                textField.text = "Invalid password"
                textField.textColor = UIColor.shadeRed
            }else{
                textField.setRightIcon(#imageLiteral(resourceName: "loginCheck"))
            }
        }
        
        if textField.tag == 2{
            if !(textField.text?.isEqualToString(find: self.newPasswordTextField.text ?? ""))!{
                textField.setRightIcon(#imageLiteral(resourceName: "loginCross"))
                textField.setLeftIcon(#imageLiteral(resourceName: "errorPassword"))
                textField.isSecureTextEntry = false
                textField.text = "Invalid password"
                textField.textColor = UIColor.shadeRed
            }else{
                textField.setRightIcon(#imageLiteral(resourceName: "loginCheck"))
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        textField.text = ""
        textField.textColor = UIColor.darkGray
        textField.isSecureTextEntry = true
        textField.setLeftIcon(#imageLiteral(resourceName: "fadePassNew"))
        textField.removeRightIcon()
    }
}


