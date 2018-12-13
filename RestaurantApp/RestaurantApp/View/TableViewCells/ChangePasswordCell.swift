//
//  ChangePasswordCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 27/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

protocol ChangePasswordCellDelegate {
    func didTapOnChangePassword(cell :ChangePasswordCell )
}

class ChangePasswordCell: UITableViewCell {
    
    //MARK:- IB outlets
    @IBOutlet weak var oldPasswordTextField: TextField!
    @IBOutlet weak var confirmPasswordTextField: TextField!
    @IBOutlet weak var newPasswordTextField: TextField!
    @IBOutlet weak var buttonChangePassword: UIButton!
    @IBOutlet weak var viewInCell: UIView!
    
    var delegate : ChangePasswordCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setDelegate()
        self.buttonChangePassword.layer.cornerRadius = 25
        DispatchQueue.main.async {
            self.viewInCell.layer.cornerRadius = 5
            self.viewInCell.layer.borderWidth = 0.4
            self.viewInCell.layer.borderColor = UIColor.lightGray.cgColor
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setDelegate(){
        self.oldPasswordTextField.delegate = self
        self.newPasswordTextField.delegate = self
        self.confirmPasswordTextField.delegate = self
    }
}

//MARK:- IB Action
extension ChangePasswordCell {
    
    @IBAction func changePasswordAction(_ sender: UIButton) {
        self.delegate?.didTapOnChangePassword(cell: self)
    }
}

//MARK:- TextField delegate
extension ChangePasswordCell : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
