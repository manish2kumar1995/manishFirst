//
//  NotificationVC.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 01/10/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class NotificationVC: BaseViewController {
    
    @IBOutlet weak var notificationTableView: UITableView!
    
    fileprivate struct ReusableIdentifier {
        static let notificationCell = "NotificationCell"
    }
    
    //Data source
    var notificationDataSource : [NotificationDetail] = [NotificationDetail(title : "App Notifications", imageNamed:"deviceIcon", state : ((((UserDefaults.standard.value(forKey: "notificationState") as? Bool)) ?? false) == true) ? true : false ), NotificationDetail(title : "Email Notifications", imageNamed:"messageIcon", state : ((((UserDefaults.standard.value(forKey: "emailState") as? Bool)) ?? false) == true) ? true : false )]
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigation(title:"NOTIFICATIONS")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK:- Table view delegate data source
extension NotificationVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notificationDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.notificationCell, for: indexPath) as! NotificationCell
        cell.row = indexPath.row
        cell.dataSource = self.notificationDataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
