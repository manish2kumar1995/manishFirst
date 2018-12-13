//
//  BaseViewController.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 28/08/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire

class BaseViewController: UIViewController {
    
    let reachabilityManager = NetworkReachabilityManager()
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- UIConfiguration methods
    func setNavigation(title:String?){
        let titleLabel = UILabel.init()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = UIColor.naivgationTitleColor
        titleLabel.text = title
        titleLabel.frame = CGRect.init(x: 0, y: 5, width: 20, height: 20)
        self.navigationItem.titleView = titleLabel
        
        let backbutton = UIButton(type: .custom)
        backbutton.setImage(UIImage(named: "fadeBackArrow"), for: .normal)
        backbutton.addTarget(self, action:  #selector(backAction), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backbutton)
    }
    
    func setNavigationWithDotButton(title:String?) {
        let titleLabel = UILabel.init()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = UIColor.naivgationTitleColor
        titleLabel.text = title
        titleLabel.frame = CGRect.init(x: 0, y: 5, width: 20, height: 20)
        self.navigationItem.titleView = titleLabel
        
        let backbutton = UIButton(type: .custom)
        backbutton.setImage(UIImage(named: "dotMenu"), for: .normal)
        backbutton.addTarget(self, action:  #selector(backAction), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backbutton)
    }
    
    //To go back to previous screen
    @objc func backAction() -> Void {
        self.navigationController?.popViewController(animated: true)
    }
    
    //To show alert on various screens
    func showAlertViewWithTitle(title:String, Message msgText: String ,CancelButtonTitle  buttonTitle:String){
        
        let appAlert = self.storyboard?.instantiateViewController(withIdentifier: "AppAlertViewController") as! AppAlertViewController
        appAlert.message = msgText
        appAlert.okTitle = buttonTitle
        appAlert.bottomSpace = 0.0
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2436:
                appAlert.topHeight =  88
            default:
                appAlert.topHeight = self.getNavigationHeight()
            }
        }
        
        self.present(appAlert, animated: true, completion: nil)
    }
    
    
    func showLoginAlertWithTitle(title:String, Message msgText: String ,CancelButtonTitle  buttonTitle:String){
        
        let appAlert = self.storyboard?.instantiateViewController(withIdentifier: "AppAlertViewController") as! AppAlertViewController
        appAlert.message = msgText
        appAlert.okTitle = buttonTitle
        appAlert.bottomSpace = 0.0
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2436:
                appAlert.topHeight =  0
            default:
                appAlert.topHeight = 0
            }
        }
        self.present(appAlert, animated: true, completion: nil)
    }
    
    //Show alert as action sheet
    internal func showAlertWithAction(title:String){
        
        let alertContoller: UIAlertController = UIAlertController(title: title, message: nil, preferredStyle:.actionSheet)
        let yesAction : UIAlertAction = UIAlertAction(title: "Yes", style: .default) { _ in
            UserShared.shared.isKnownUser = true
            UserShared.shared.paymentMethods.payments.append(Payments(methodsName : "Visa", cardNumber : "****4242", monthYear : "05/2026", isCheck: false))
            UserShared.shared.paymentMethods.payments.append(Payments(methodsName : "Amex", cardNumber : "****4853", monthYear : "02/2022", isCheck: false))
            UserShared.shared.paymentMethods.payments.append(Payments(methodsName : "Cash on delivery", cardNumber : "", monthYear : "", isCheck: true))
            UserShared.shared.paymentMethods.payments.append(Payments(methodsName : "New Card", cardNumber : "", monthYear : "", isCheck: false))
        }
        
        let noAction : UIAlertAction = UIAlertAction(title: "No ", style: .default) { _ in
            UserShared.shared.isKnownUser = false
            UserShared.shared.paymentMethods.payments.append(Payments(methodsName : "Cash on delivery", cardNumber : "", monthYear : "", isCheck: true))
            UserShared.shared.paymentMethods.payments.append(Payments(methodsName : "New Card", cardNumber : "", monthYear : "", isCheck: false))
        }
        
        alertContoller.addAction(yesAction)
        alertContoller.addAction(noAction)
        self.present(alertContoller, animated: true, completion:nil)
    }
    
    //To show hud
    func showHud(message: String?){
        self.view.isUserInteractionEnabled = false
        SVProgressHUD.show(withStatus: message ?? "Please wait")
    }
    
    //To hide hud
    func hideHud(){
        self.view.isUserInteractionEnabled = true
        SVProgressHUD.dismiss()
    }
    
    //Get device navigation bar height
    func getNavigationHeight() -> CGFloat {
        let topBarHeight = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        return topBarHeight
    }
}

//MARK:- To check Internet connectivity
public class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
