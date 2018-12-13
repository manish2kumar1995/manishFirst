//
//  MyAccountChangePasswordVC.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 27/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
import JWTDecode

class MyAccountChangePasswordVC: BaseViewController {
    
    @IBOutlet weak var changePasswordTableView: UITableView!
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addKeyBoardListener()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //Stop scrolling of table view on the basis of content size
        self.checkTableScrolling()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    
}

//MARK:- Custom methods
extension MyAccountChangePasswordVC{
    //Checkinf the table scrolling
    func checkTableScrolling(){
        self.changePasswordTableView.isScrollEnabled = changePasswordTableView.contentSize.height > changePasswordTableView.frame.size.height;
    }
    
    func callAPIForChangePassword(with param: [String:Any]){
        let user = DataBaseHelper.shared.getData().first
        let token = user?.tokenId ?? ""
        var userid = String()
        do{
            let jwt = try decode(jwt: token)
            if jwt.expired{
            }else{
                let body = jwt.body
                userid = (body["uid"] as? String) ?? ""
            }
        }catch{
            print("Data not fetched")
        }
        
        self.showHud(message: "changing password..")
        _ = WebAPIHandler.sharedHandler.changeUserPassword(id: userid, param: param, success: { (response) in
            debugPrint(response)
            self.hideHud()
            let success = (response["success"] as? Bool) ?? false
            if success{
                self.showAlertViewWithTitle(title: "", Message: "Password changed successfully", CancelButtonTitle: "Ok")
            }else{
                let meta = (response["meta"] as? [String:Any]) ?? [:]
                let message = (meta["message"] as? String) ?? ""
                self.showAlertViewWithTitle(title: "", Message: message, CancelButtonTitle: "Ok")
            }
        }, failure: { (error) in
            debugPrint(error)
            self.hideHud()
        })
    }
    
    //Adding keyboard listener
    func addKeyBoardListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil);
    }
    
    //Appearence of keyboard will trigger this method
    @objc func keyboardWillShow(_ notification: Notification) {
    }
    
    //Appearence of keyboard will trigger this method
    @objc func keyboardWillHide(_ notification: Notification) {
        self.checkTableScrolling()
    }
    
    //After Appearence of keyboard will trigger this method
    @objc func keyboardDidShow(_ notification: Notification) {
        self.checkTableScrolling()
    }
}

//MARK:- Table view delegate data source
extension MyAccountChangePasswordVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChangePasswordCell", for: indexPath) as! ChangePasswordCell
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  360
    }
}

//MARK;- Change Password Cell Delegate
extension MyAccountChangePasswordVC: ChangePasswordCellDelegate{
    func didTapOnChangePassword(cell: ChangePasswordCell) {
        let oldPassword = cell.oldPasswordTextField.text ?? ""
        let newPasss = cell.newPasswordTextField.text ?? ""
        let confirmPass = cell.confirmPasswordTextField.text ?? ""
        if oldPassword.isEmpty{
            self.showAlertViewWithTitle(title: "", Message: "Please enter old password", CancelButtonTitle: "Ok")
        }else if newPasss.isEmpty{
            self.showAlertViewWithTitle(title: "", Message: "Please enter new password", CancelButtonTitle: "Ok")
        }else if confirmPass.isEmpty{
            self.showAlertViewWithTitle(title: "", Message: "Penter confirm password", CancelButtonTitle: "Ok")
        }else if !newPasss.isEqualToString(find: confirmPass){
            self.showAlertViewWithTitle(title: "", Message: "New password and confirm password do not match", CancelButtonTitle: "Ok")
        }else{
            let param = ["password": newPasss,"passwordConfirmation": confirmPass, "oldPassword":oldPassword]
            self.callAPIForChangePassword(with : param)
        }
    }
}
