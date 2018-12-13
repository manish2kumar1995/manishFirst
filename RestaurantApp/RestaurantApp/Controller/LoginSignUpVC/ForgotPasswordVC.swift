//
//  ForgotPasswordVC.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 11/15/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class ForgotPasswordVC: BaseViewController {
    //MARK:- IBOutlet
    @IBOutlet weak var sendResetButton: UIButton!
    @IBOutlet weak var emailTextField: LeftSpaceTextField!
    
    @IBOutlet weak var buttonLoginHere: UIButton!
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

//MARK:- Custom methods
extension ForgotPasswordVC{
    
    @IBAction func resetButtonAction(_ sender: Any) {
        if (self.emailTextField.text?.isEmpty)!{
            self.showLoginAlertWithTitle(title: "", Message: "Please provide email address", CancelButtonTitle: "Ok")
        }else if !(self.emailTextField.text?.isValidEmail())!{
            self.showLoginAlertWithTitle(title: "", Message: "Please enter valid email", CancelButtonTitle: "Ok")
        }else {
            if Connectivity.isConnectedToInternet{
                self.callAPIForResetPassword()
            }else{
                self.showLoginAlertWithTitle(title: "", Message: Messages
                    .internetUnavailable, CancelButtonTitle: "Ok")
            }
        }
        
    }
    
    @IBAction func loginHereAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func configUI(){
        self.navigationController?.isNavigationBarHidden = true
        self.emailTextField.delegate = self
        self.sendResetButton.layer.borderWidth = 1.0
        self.sendResetButton.layer.borderColor = UIColor.white.cgColor
        
        DispatchQueue.main.async {
            self.emailTextField.layer.cornerRadius = self.emailTextField.frame.size.height/2
            self.sendResetButton.layer.cornerRadius = self.sendResetButton.frame.size.height/2
        }
        
        self.emailTextField.setLeftIcon(#imageLiteral(resourceName: "fadeEmail"))
        
        self.setShade(textField: self.emailTextField)
        
        self.addAttributedText()
    }
    
    func setShade(textField : UITextField){
        textField.layer.masksToBounds = false
        textField.layer.shadowRadius = 20.0
        textField.layer.shadowColor = UIColor.shadeColor.cgColor
        textField.layer.shadowOffset = CGSize(width: 1.0, height: 5.0)
        textField.layer.shadowOpacity = 1.0
    }
    
    func addAttributedText(){
        let yourAttributes : [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor : UIColor.white,
            NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue]
        let attributeForgotString = NSMutableAttributedString(string: "Login here",
                                                              attributes: yourAttributes)
        self.buttonLoginHere.setAttributedTitle(attributeForgotString, for: .normal)
        
    }
    
    func callAPIForResetPassword(){
        //   "email": "m.himi@akly.co"
        let param = [ "email": self.emailTextField.text ?? ""]
        self.showHud(message: "Authenticating..")
        _ = WebAPIHandler.sharedHandler.sendResetLink(parameters: param, success: { (response) in
            debugPrint(response)
            self.hideHud()
            let success = (response["success"] as? Bool) ?? false
            let meta = (response["meta"] as? [String:Any]) ?? [:]
            let message = (meta["message"] as? String) ?? ""
            if success{
                self.performSegue(withIdentifier: "resetPasswordSegue", sender: nil)
            }else{
                self.showLoginAlertWithTitle(title: "", Message: message, CancelButtonTitle: "Ok")
            }
        }, failure: { (error) in
            debugPrint(error)
            self.hideHud()
            
        })
    }
    
}

//MARK:- Text field delegate
extension ForgotPasswordVC : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text?.isValidEmail())!{
            self.emailTextField.setRightIcon(#imageLiteral(resourceName: "loginCheck"))
        }else{
            self.emailTextField.setRightIcon(#imageLiteral(resourceName: "loginCross"))
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.emailTextField.removeRightIcon()
    }
}
