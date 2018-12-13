//
//  AppAlertViewController.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 21/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
//MARK:- protocol for various events
protocol AppAlertViewControllerDelegate {
    func didTapOnRemove()
}

class AppAlertViewController: BaseViewController {
    
    //MARK:- IB outlets
    @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var buttonRemove: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var blurrView: UIView!
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    
    //Custom variables
    var message = String()
    var okTitle = String()
    var cancelTitle = String()
    var topHeight = CGFloat()
    var bottomSpace = CGFloat()
    var isComingFromAccount = false
    var delegate : AppAlertViewControllerDelegate?
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //Config UI based work
        configureUI()
    }
}

//MARK:- Other methods
extension AppAlertViewController {
    
    func configureUI(){
     
        DispatchQueue.main.async {
            self.blurrView.makeBlurr()
            self.viewTopConstraint.constant = self.topHeight
            self.viewBottomConstraint.constant = self.bottomSpace
            self.buttonRemove.layer.cornerRadius = self.buttonRemove.frame.size.height/2
            self.cancelButton.layer.cornerRadius = self.cancelButton.frame.size.height/2
        }
            self.labelMessage.text = self.message
            self.cancelButton.setTitle(self.cancelTitle, for: .normal)
            self.buttonRemove.setTitle(self.okTitle, for: .normal)
            self.cancelButton.isHidden = (self.cancelTitle.isEmpty) ? true : false
    }
}

//MARK:- IB button action methods
extension AppAlertViewController{
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func removeButtonAction(_ sender: UIButton) {
        if self.isComingFromAccount{
            self.delegate?.didTapOnRemove()
        }
        self.dismiss(animated: true, completion: nil)
    }
}
