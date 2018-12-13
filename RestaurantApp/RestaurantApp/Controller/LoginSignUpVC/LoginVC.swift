//
//  LoginVC.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 11/14/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
import JWTDecode

class LoginVC: BaseViewController {
    
    //MARK:- IBOutlets
    @IBOutlet weak var buttonSignUp: UIButton!
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var passwordTextField: TextField!
    @IBOutlet weak var emailTextField: TextField!
    @IBOutlet weak var buttonForgotPassword: UIButton!
    @IBOutlet weak var labelError: UILabel!
    @IBOutlet weak var errorImageView: UIImageView!
    
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.errorImageView.isHidden = true
        self.configUI()
      //  self.checkForAutoLogin()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func loginButtonAction(_ sender: Any) {
        if (self.emailTextField.text?.isEmpty)!{
            self.showLoginAlertWithTitle(title: "", Message:"Please enter an email", CancelButtonTitle: "ok")
        }else if (self.passwordTextField.text?.isEmpty)! {
            self.showLoginAlertWithTitle(title: "", Message:"Please enter the password", CancelButtonTitle: "ok")
        }else if !(self.emailTextField.text?.isValidEmail())!{
            self.showLoginAlertWithTitle(title: "", Message:"Please enter valid email", CancelButtonTitle: "ok")
        }else{
            if Connectivity.isConnectedToInternet{
                self.callAPIForLogin()
            }else{
                self.showLoginAlertWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "ok")
            }
        }
    }
    @IBAction func skipButtonAction(_ sender: Any) {
        UserShared.shared.isKnownUser = false
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "RootViewController") as! RootViewController
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
}

//MARK:- Custom Methods
extension LoginVC{
    
    func configUI(){
        self.navigationController?.isNavigationBarHidden = true
        self.emailTextField.delegate = self
        self.emailTextField.tag = 1
        self.passwordTextField.tag = 2
        self.passwordTextField.delegate = self
        self.labelError.isHidden = true
        
        self.buttonLogin.layer.borderWidth = 1.0
        self.buttonLogin.layer.borderColor = UIColor.white.cgColor
        
        DispatchQueue.main.async {
            self.emailTextField.layer.cornerRadius = self.emailTextField.frame.size.height/2
            self.passwordTextField.layer.cornerRadius = self.passwordTextField.frame.size.height/2
            self.buttonLogin.layer.cornerRadius = self.buttonLogin.frame.size.height/2
        }
        
        self.emailTextField.setLeftIcon(#imageLiteral(resourceName: "fadeEmail"))
        self.passwordTextField.setLeftIcon(#imageLiteral(resourceName: "fadePassNew"))
        
        self.setShade(textField: self.emailTextField)
        self.setShade(textField: self.passwordTextField)
        
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
        let attributeForgotString = NSMutableAttributedString(string: "Forgot password?",
                                                              attributes: yourAttributes)
        self.buttonForgotPassword.setAttributedTitle(attributeForgotString, for: .normal)
        
        let attributeSignUpString = NSMutableAttributedString(string: "No account? Sign up!",
                                                              attributes: yourAttributes)
        self.buttonSignUp.setAttributedTitle(attributeSignUpString, for: .normal)
    }
    
    //Calling Login API
    func callAPIForLogin(){
        self.showHud(message: "please wait..")
        let _ = WebAPIHandler.sharedHandler.callLoginAPI(email: self.emailTextField.text ?? "", pass: self.passwordTextField.text ?? "", success: { (response) in
            debugPrint(response)
            self.hideHud()
            let token = (response["token"] as? String) ?? ""
            if !token.isEmpty{
                self.errorImageView.isHidden = true
//                self.passwordTextField.setLeftIcon()
//                self.passwordTextField.setRightIcon()
                
                self.view.endEditing(true)
                DataBaseHelper.shared.saveData(token: token)
                self.performLogin()
            }else{
                let meta = (response["meta"] as? [String:Any]) ?? [:]
                let message = (meta["message"] as? String) ?? ""
      //          self.showLoginAlertWithTitle(title: "", Message: message, CancelButtonTitle: "ok")
        //        self.passwordTextField.setLeftIcon(#imageLiteral(resourceName: "errorPassword"))
                self.labelError.isHidden = false
                self.labelError.text = "\(message)"
//                self.passwordTextField.textColor = UIColor.shadeRed
//                self.passwordTextField.text = "Invalid password"
//                self.passwordTextField.isSecureTextEntry = false
//                self.passwordTextField.setRightIcon(#imageLiteral(resourceName: "loginCross"))
                self.errorImageView.isHidden = false
            }
        }){ (error) in
            debugPrint(error)
            self.hideHud()
         //   self.showLoginAlertWithTitle(title: "", Message: "Invalid email or password", CancelButtonTitle: "ok")
//            self.passwordTextField.isSecureTextEntry = false
//            self.passwordTextField.setLeftIcon(#imageLiteral(resourceName: "errorPassword"))
//            self.passwordTextField.textColor = UIColor.shadeOrange
//            self.passwordTextField.text = "Invalid password"
//            self.passwordTextField.setRightIcon(#imageLiteral(resourceName: "loginCross"))
            self.errorImageView.isHidden = false
        }
    }
    
    func checkForAutoLogin(){
        let user = DataBaseHelper.shared.getData().first
        let token = user?.tokenId ?? ""
        if !token.isEmpty{
            do{
                let jwt = try decode(jwt: token)
                if !jwt.expired{
                    self.performLogin()
                }
            }catch{
                print("Data not fetched")
            }
        }
    }
    
    func performLogin(){
        self.emailTextField.text = ""
        self.passwordTextField.text = ""
        UserShared.shared.isKnownUser = true
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "RootViewController") as! RootViewController
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
}

//MARK:- TextField delegate
extension LoginVC : UITextFieldDelegate{
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
                self.passwordTextField.setLeftIcon(#imageLiteral(resourceName: "errorPassword"))
                textField.isSecureTextEntry = false
                textField.text = "Invalid password"
                textField.textColor = UIColor.shadeRed
            }else{
                self.passwordTextField.setRightIcon(#imageLiteral(resourceName: "loginCheck"))
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1{
            self.emailTextField.removeRightIcon()
        }
        
        if textField.tag == 2{
            self.passwordTextField.text = ""
            self.passwordTextField.textColor = UIColor.darkGray
            self.passwordTextField.isSecureTextEntry = true
            self.passwordTextField.setLeftIcon(#imageLiteral(resourceName: "fadePassNew"))
            self.errorImageView.isHidden = true
            self.labelError.isHidden = true
            self.passwordTextField.removeRightIcon()
        }
    }
}
