//
//  SideMenuViewController.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 18/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class SideMenuViewController: BaseViewController {
    
    @IBOutlet weak var sideOptionTableView: UITableView!
    
    //data source
    var dataSource :  [[String:Any]] = []
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserShared.shared.isKnownUser{
            self.dataSource = [
                ["menuLogo":"homeIcon","menuName":"Home"],
                ["menuLogo":"whiteProfile","menuName":"My Account"],
                ["menuLogo":"whitePaperIcon","menuName":"My Orders"],
                ["menuLogo":"whiteRoundCheck","menuName":"My Subscriptions"],
                ["menuLogo":"whiteNotificationBell","menuName":"Notifications"],
                ["menuLogo":"whiteChatIcon","menuName":"Support"],
                ["menuLogo":"whiteSettingIcon","menuName":"Settings"]
            ]
        }else{
            self.dataSource = [
                ["menuLogo":"homeIcon","menuName":"Home"],
                ["menuLogo":"whiteProfile","menuName":"Log In"],
                ["menuLogo":"whitePaperIcon","menuName":"My Orders"],
                ["menuLogo":"whiteRoundCheck","menuName":"My Subscriptions"],
                ["menuLogo":"whiteNotificationBell","menuName":"Notifications"],
                ["menuLogo":"whiteChatIcon","menuName":"Support"],
                ["menuLogo":"whiteSettingIcon","menuName":"Settings"]
            ]
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.sideOptionTableView.isScrollEnabled = sideOptionTableView.contentSize.height > sideOptionTableView.frame.size.height;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
}

//MARK:- Custom methods
extension SideMenuViewController{
    
}

//MARK:- table view delegate data source
extension SideMenuViewController : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTableCell", for: indexPath) as! SideMenuTableCell
        cell.dataSource = self.dataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            if let homeVC = self.sideMenuViewController()?.menuContainerView?.delegate as? HomeViewController {
                homeVC.navigationController?.popToRootViewController(animated: true)
                self.sideMenuViewController()?.menuContainerView?.closeSideMenu()
            }
        }else if indexPath.row == 1{
            if UserShared.shared.isKnownUser{
                if let homeVC = self.sideMenuViewController()?.menuContainerView?.delegate as? HomeViewController {
                    homeVC.performSegue(withIdentifier: "myAccountInfoSegue", sender: nil)
                    self.sideMenuViewController()?.menuContainerView?.closeSideMenu()
                }
            }else{
                DataBaseHelper.shared.emptyCoreData()
                UserShared.shared.myBasketModel.myBasketData = []
                UserShared.shared.myBasketModel.totalQAR = 0.0
                UserShared.shared.myBasketModel.totalCart = 0
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginVC") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
        }else if indexPath.row == 2{
            if UserShared.shared.isKnownUser{
                if let homeVC = self.sideMenuViewController()?.menuContainerView?.delegate as? HomeViewController {
                    homeVC.performSegue(withIdentifier: "myOrderSegue", sender: nil)
                    self.sideMenuViewController()?.menuContainerView?.closeSideMenu()
                }
            }else{
                DataBaseHelper.shared.emptyCoreData()
                UserShared.shared.myBasketModel.myBasketData = []
                UserShared.shared.myBasketModel.totalQAR = 0.0
                UserShared.shared.myBasketModel.totalCart = 0
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginVC") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
        }else if indexPath.row == self.dataSource.count - 1{
            if let homeVC = self.sideMenuViewController()?.menuContainerView?.delegate as? HomeViewController {
                homeVC.performSegue(withIdentifier: "settingSegue", sender: nil)
                self.sideMenuViewController()?.menuContainerView?.closeSideMenu()
            }
        }
    }
}
