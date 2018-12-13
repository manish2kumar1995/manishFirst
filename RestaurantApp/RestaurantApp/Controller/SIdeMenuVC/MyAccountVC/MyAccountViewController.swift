//
//  MyAccountViewController.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 25/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
import JWTDecode

class MyAccountViewController: BaseViewController {
    
    //MARK:- IB outlet
    @IBOutlet weak var slidingViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var buttonTabs: [UIButton]!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bottomContainerView: UIView!
    @IBOutlet weak var slidingView: UIView!
    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    
    fileprivate struct ReusableIdentifier {
        static let myAccountInfoVC = "MyAccountInfoVC"
        static let myAccountBillingVC = "MyAccountBillingVC"
        static let myAccountPasswordVC = "MyAccountChangePasswordVC"
    }
    weak var currentViewController: UIViewController?
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigation(title: "My Account")
        self.addKeyBoardListener()
        self.addInitialVC()
        //Adding shadow to bottom view
        self.bottomContainerView.layer.masksToBounds = false
        self.bottomContainerView.layer.shadowRadius = 20.0
        self.bottomContainerView.layer.shadowColor = UIColor.disabledLightGray.cgColor
        self.bottomContainerView.layer.shadowOffset = CGSize(width: 1.0, height: 5.0)
        self.bottomContainerView.layer.shadowOpacity = 1.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.view.endEditing(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NotificationNames.userUpdate, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    
}

//MARK:- IB button action
extension MyAccountViewController{
    
    @objc func updateUI(_ notification: NSNotification){
        //   self.configUI()
    }
    
    @IBAction func buttonTabAction(_ sender: UIButton) {
        for tabButton in self.buttonTabs{
            if tabButton.tag == sender.tag{
                let xAxis = tabButton.frame.origin.x
                self.slidingViewLeadingConstraint.constant = xAxis
                UIView.animate(withDuration: 0.2, animations: {
                    self.slidingView.superview?.layoutIfNeeded()
                }, completion: nil)
                if tabButton.tag == 1{
                    tabButton.setTitleColor(UIColor.borderedRed, for: .normal)
                    tabButton.setImage(#imageLiteral(resourceName: "coloredProfile"), for: .normal)
                    self.switchToView(tag: tabButton.tag)
                }else if tabButton.tag == 2 {
                    tabButton.setTitleColor(UIColor.borderedRed, for: .normal)
                    tabButton.setImage(#imageLiteral(resourceName: "coloredBilling"), for: .normal)
                    self.switchToView(tag: tabButton.tag)
                }else{
                    tabButton.setTitleColor(UIColor.borderedRed, for: .normal)
                    tabButton.setImage(#imageLiteral(resourceName: "coloredPassword"), for: .normal)
                    self.switchToView(tag: tabButton.tag)
                }
            }else{
                if tabButton.tag == 1{
                    tabButton.setTitleColor(UIColor.modeButtonUnselectedText, for: .normal)
                    tabButton.setImage(#imageLiteral(resourceName: "fadeProfile"), for: .normal)
                }else if tabButton.tag == 2 {
                    tabButton.setTitleColor(UIColor.modeButtonUnselectedText, for: .normal)
                    tabButton.setImage(#imageLiteral(resourceName: "fadeBilling"), for: .normal)
                }else{
                    tabButton.setTitleColor(UIColor.modeButtonUnselectedText, for: .normal)
                    tabButton.setImage(#imageLiteral(resourceName: "fadePassword"), for: .normal)
                }
            }
        }
    }
    
}

//MARK:- Custom methods
extension MyAccountViewController {
    
    // Adding Initial view controller
    func addInitialVC(){
        self.currentViewController = self.storyboard?.instantiateViewController(withIdentifier: ReusableIdentifier.myAccountInfoVC) as! MyAccountInfoVC
        self.currentViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChildViewController(self.currentViewController!)
        self.addSubview(subView: self.currentViewController!.view, toView: self.containerView)
    }
    
    // Adding view controller
    func addSubview(subView:UIView, toView parentView:UIView) {
        parentView.addSubview(subView)
        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["subView"] = subView
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[subView]|",options: [], metrics: nil, views: viewBindingsDict))
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[subView]|",options: [], metrics: nil, views: viewBindingsDict))
    }
    
    //Switching to another view
    func switchToView(tag:Int){
        if tag == 1{
            self.addInfoVCAsChild()
        }else if tag == 2{
            self.addBillingVCAsChild()
        }else{
            self.addPasswordVCAsChild()
        }
    }
    
    //Adding Info ViewController as child view controller
    func addInfoVCAsChild(){
        self.view.endEditing(true)
        let newViewController = self.storyboard?.instantiateViewController(withIdentifier: ReusableIdentifier.myAccountInfoVC) as! MyAccountInfoVC
        newViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.cycleFromViewController(oldViewController: self.currentViewController!, toViewController: newViewController)
        self.currentViewController = newViewController
    }
    
    //Adding Billing ViewController as child view controllers
    func addBillingVCAsChild(){
        self.view.endEditing(true)
        let newViewController = self.storyboard?.instantiateViewController(withIdentifier: ReusableIdentifier.myAccountBillingVC) as! MyAccountBillingVC
        newViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.cycleFromViewController(oldViewController: self.currentViewController!, toViewController: newViewController)
        self.currentViewController = newViewController
    }
    
    //Adding Password ViewController as child view controller
    func addPasswordVCAsChild(){
        self.view.endEditing(true)
        let newViewController = self.storyboard?.instantiateViewController(withIdentifier: ReusableIdentifier.myAccountPasswordVC)
        newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.cycleFromViewController(oldViewController: self.currentViewController!, toViewController: newViewController!)
        self.currentViewController = newViewController
    }
    
    //Cycling of another view controller
    func cycleFromViewController(oldViewController: UIViewController, toViewController newViewController: UIViewController) {
        oldViewController.willMove(toParentViewController: nil)
        self.addChildViewController(newViewController)
        self.addSubview(subView: newViewController.view, toView:self.containerView!)
        newViewController.view.layoutIfNeeded()
        // TODO: Set the ending state of your constraints here
        UIView.animate(withDuration: 0.5, animations: {
            newViewController.view.layoutIfNeeded()
        },completion: { finished in                                    oldViewController.view.removeFromSuperview()
            oldViewController.removeFromParentViewController()
            newViewController.didMove(toParentViewController: self)
        })
    }
    
    
    //Adding keyboard listener
    func addKeyBoardListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil);
    }
    
    
    //Appearence of keyboard will trigger this method
    @objc func keyboardWillShow(_ notification: Notification) {
        self.bottomViewBottomConstraint.constant = -66.0
    }
    
    //Disappearence of keyboard will trigger this method
    @objc func keyboardWillHide(_ notification: Notification) {
        self.bottomViewBottomConstraint.constant = 0.0
    }
}



