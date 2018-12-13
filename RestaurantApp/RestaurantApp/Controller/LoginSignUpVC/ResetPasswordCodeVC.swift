//
//  ResetPasswordCodeVC.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 11/22/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class ResetPasswordCodeVC: BaseViewController {
    
    //TODO:- IB Outlet
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var emailTextField: LeftSpaceTextField!
    @IBOutlet weak var buttonLogin: UIButton!
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.showLoginAlertWithTitle(title: "", Message: "Please enter the code sent to your email", CancelButtonTitle: "Ok")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ConfirmPasswordVC{
            vc.code = self.emailTextField.text ?? ""
        }
    }
    
    @IBAction func resentButtonAction(_ sender: Any) {
        if (self.emailTextField.text?.isEmpty)!{
            self.showLoginAlertWithTitle(title: "", Message: "Please enter the code", CancelButtonTitle: "Ok")
        }else{
            self.performSegue(withIdentifier: "confirmPassSegue", sender: nil)
        }
    }
    
    @IBAction func loginAction(_ sender: Any) {
        let arr_controller:[UIViewController] = (self.navigationController?.viewControllers)!
        _ = self.navigationController?.popToViewController(arr_controller[0], animated: true)
    }
}

//MARK:- Custom Methods
extension ResetPasswordCodeVC {
    
    func configUI(){
        self.emailTextField.delegate = self
        self.resetButton.layer.borderWidth = 1.0
        self.resetButton.layer.borderColor = UIColor.white.cgColor
        
        DispatchQueue.main.async {
            self.emailTextField.layer.cornerRadius = self.emailTextField.frame.size.height/2
            self.resetButton.layer.cornerRadius = self.resetButton.frame.size.height/2
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
        self.buttonLogin.setAttributedTitle(attributeForgotString, for: .normal)
        
    }
}

//MARK:- Text field delegate
extension ResetPasswordCodeVC : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
