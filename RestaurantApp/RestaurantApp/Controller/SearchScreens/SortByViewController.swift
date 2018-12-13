//
//  SortByViewController.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 03/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

protocol SortByViewControllerDelegate {
    func didSelectedSortedCatagory(basisOf : String)
}

class SortByViewController: BaseViewController {
    
    @IBOutlet var tableViewOptions: UITableView!
    var titleArray = ["Price","Rating","Distance"]
    var titleIconArray = ["coloredTag", "borderedStar", "borderedMarker"]
    var delegate : SortByViewControllerDelegate?
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableViewOptions.tableFooterView = UIView()
        self.tableViewOptions.delegate = self
        self.tableViewOptions.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.setNavigation(title: "SORT BY")
    }
}

//MARK : UIButton Action
private extension SortByViewController{
    
}

//MARK : Private Methods
private extension SortByViewController{
    
}


//MARK : Table View Methods
extension SortByViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "SortByTableViewCell") as! SortByTableViewCell
        cell.labelTitle.text = titleArray[indexPath.row]
        cell.imageViewIcon.image = UIImage(named: "\(titleIconArray[indexPath.row])")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.didSelectedSortedCatagory(basisOf: self.titleArray[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
}
