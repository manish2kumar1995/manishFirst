//
//  SignUpViewController.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 11/14/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class SignUpViewController: BaseViewController {
    
    //MARK:- IBOutlet
    @IBOutlet weak var buttonAlreadySignIn: UIButton!
    @IBOutlet weak var buttonCreateAccount: UIButton!
    @IBOutlet weak var emailTextField: LeftSpaceTextField!
    @IBOutlet weak var passWordTextField: LeftSpaceTextField!
    @IBOutlet weak var nameTextField: LeftSpaceTextField!
    
    @IBOutlet weak var labelError: UILabel!
    @IBOutlet weak var errorView: UIView!
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func buttonAlreadyAccountAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func createAccountAction(_ sender: Any) {
        
        if (self.nameTextField.text?.isEmpty)!{
            self.showAlertViewWithTitle(title: "", Message: "Please enter your name", CancelButtonTitle: "ok")
        }else if ((self.nameTextField.text?.count)! < 3){
            self.showAlertViewWithTitle(title: "", Message: "Please enter name with atleast 3 character", CancelButtonTitle: "ok")
        }else if !(self.emailTextField.text?.isValidEmail())!{
            self.showAlertViewWithTitle(title: "", Message: "Please enter valid email", CancelButtonTitle: "ok")
        }else if (self.emailTextField.text?.isEmpty)!{
            self.showAlertViewWithTitle(title: "", Message: "Please provide email address", CancelButtonTitle: "ok")
        }else if (self.passWordTextField.text?.isEmpty)!{
            self.showAlertViewWithTitle(title: "", Message: "Please enter your name", CancelButtonTitle: "ok")
        }else{
            if Connectivity.isConnectedToInternet{
                self.callAPIForCreateUser()
            }else{
                self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "ok")
            }
        }
    }
}

//MARK:- Custom methods
extension SignUpViewController {
    func configUI(){
        self.emailTextField.tag = 1
        self.passWordTextField.tag = 2
        self.nameTextField.tag = 3
        self.errorView.isHidden = true
        self.emailTextField.delegate = self
        self.passWordTextField.delegate = self
        self.nameTextField.delegate = self
        
        self.buttonCreateAccount.layer.borderWidth = 1.0
        self.buttonCreateAccount.layer.borderColor = UIColor.white.cgColor
        
        DispatchQueue.main.async {
            self.emailTextField.layer.cornerRadius = self.emailTextField.frame.size.height/2
            self.nameTextField.layer.cornerRadius = self.nameTextField.frame.size.height/2
            self.passWordTextField.layer.cornerRadius = self.passWordTextField.frame.size.height/2
            self.buttonCreateAccount.layer.cornerRadius = self.buttonCreateAccount.frame.size.height/2
        }
        
        self.emailTextField.setLeftIcon(#imageLiteral(resourceName: "fadeEmail"))
        self.passWordTextField.setLeftIcon(#imageLiteral(resourceName: "fadePassNew"))
        self.nameTextField.setLeftIcon(#imageLiteral(resourceName: "fadeProfileNew"))
        
        self.setShade(textField: self.emailTextField)
        self.setShade(textField: self.passWordTextField)
        self.setShade(textField: self.nameTextField)
        
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
        let attributeAlreadyString = NSMutableAttributedString(string: "Already signed up? Login here",
                                                               attributes: yourAttributes)
        self.buttonAlreadySignIn.setAttributedTitle(attributeAlreadyString, for: .normal)
    }
    
    func callAPIForCreateUser(){
        self.showHud(message: "creating account..")
        let param = ["name" : "\(self.nameTextField.text ?? "")", "email" : "\(self.emailTextField.text ?? "")", "password" : "\(self.passWordTextField.text ?? "")"]
        _ = WebAPIHandler.sharedHandler.createUser(parameters: param, success: { (response) in
            debugPrint(response)
            self.hideHud()
            let token = (response["token"] as? String) ?? ""
            if !token.isEmpty{
                self.errorView.isHidden = true
                self.view.endEditing(true)
                DataBaseHelper.shared.saveData(token: token)
                self.performLogin()
            }else{
                let meta = (response["meta"] as? [String:Any]) ?? [:]
                let message = (meta["message"] as? String) ?? ""
                self.labelError.text = message
                self.errorView.isHidden = false
            }
            
        }, failure: { (error) in
            debugPrint(error)
            self.hideHud()
            self.labelError.text = "Something went wrong"
            self.errorView.isHidden = false
        })
    }
    
    func performLogin(){
        self.emailTextField.text = ""
        self.passWordTextField.text = ""
        UserShared.shared.isKnownUser = true
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "RootViewController") as! RootViewController
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
    
}


//MARK:- TextField delegate
extension SignUpViewController : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1{
            if (textField.text?.isValidEmail())!{
                self.emailTextField.setRightIcon(#imageLiteral(resourceName: "loginCheck"))
            }else{
                self.emailTextField.setRightIcon(#imageLiteral(resourceName: "loginCross"))
            }
        }
        
        if textField.tag == 2{
            if (textField.text?.count)! < 5{
                textField.setRightIcon(#imageLiteral(resourceName: "loginCross"))
                self.passWordTextField.setLeftIcon(#imageLiteral(resourceName: "errorPassword"))
                textField.isSecureTextEntry = false
                textField.text = "Invalid password"
                textField.textColor = UIColor.shadeRed
            }else{
                self.passWordTextField.setRightIcon(#imageLiteral(resourceName: "loginCheck"))
            }
        }
        
        if textField.tag == 3{
            if (textField.text?.count)! < 3{
                textField.setRightIcon(#imageLiteral(resourceName: "loginCross"))
            }else{
                self.nameTextField.setRightIcon(#imageLiteral(resourceName: "loginCheck"))
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1{
            self.emailTextField.removeRightIcon()
        }
        
        if textField.tag == 2{
            self.passWordTextField.text = ""
            self.passWordTextField.textColor = UIColor.darkGray
            self.passWordTextField.isSecureTextEntry = true
            self.passWordTextField.setLeftIcon(#imageLiteral(resourceName: "fadePassNew"))
            self.passWordTextField.removeRightIcon()
        }
        
        self.errorView.isHidden = true
    }
}

