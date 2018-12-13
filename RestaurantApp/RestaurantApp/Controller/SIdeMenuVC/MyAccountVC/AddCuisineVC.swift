//
//  AddCuisineVC.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 11/17/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
import JWTDecode
protocol AddCuisineVCDelegate {
    func initializeDataSource(section : Int, data : [CuisineData])
    func sendTheSelectedData(data : [CuisineData], section : Int)
}


class AddCuisineVC: BaseViewController {
    
    //MARK:- IBOutlet
    @IBOutlet weak var addCuisineTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var buttonAdd: UIButton!
    @IBOutlet weak var bottomView: UIView!
    
    fileprivate struct ReusableIdentifier {
        static let addCuisineTableCell = "AddCuisineTableCell"
    }
    
    var searchActive = false
    var section : Int?
    var cuisineDataSource = ["Indian","Arabic","English"]
    var dietryDataSource = ["Vegetarian",  "Non-Vegetarian", "Smoothies"]
    var mealTypesDataSource = ["Breakfast", "Smoothies","Soups"]
    var filteredArray = [String]()
    var dataSource = [String]()
    var selectedData = [String]()
    var mainDataSource = [CuisineData]()
    var filteredDataSource = [CuisineData]()
    var selectedCuisineData = [CuisineData]()
    var delegate : AddCuisineVCDelegate?
    var newlySelectedData = [CuisineData]()
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        for _ in 0..<self.selectedData.count{
            self.configDataSource()
        }
        if !(self.mainDataSource.count == 0){
            self.selectedData.removeAll()
        }
        self.addCuisineTableView.reloadData()
        if Connectivity.isConnectedToInternet{
            if (self.section ?? 0) == 0{
                self.searchBar.placeholder = "Enter a cuisine to search"
                //     if self.mainDataSource.count == 0{
                self.showHud(message: "loading cuisines..")
                _ = WebAPIHandler.sharedHandler.getCuisine(index : 1, success: { (response) in
                    debugPrint(response)
                    self.hideHud()
                    self.mainDataSource.removeAll()
                    let cuisines = (response["cuisines"] as? [[String:Any]]) ?? []
                    
                    for cuisine in cuisines{
                        self.dataSource.append((cuisine["name"] as? String) ?? "" )
                        self.mainDataSource.append(CuisineData.init(data: cuisine, index : 1) )
                    }
                    
                    DispatchQueue.main.async {
                        for _ in 0..<self.selectedData.count{
                            //to remove the present names from data source
                            self.configDataSource()
                            print("I Occur many times")
                        }
                        self.filteredDataSource = self.mainDataSource
                        self.selectedData.removeAll()
                        defer{
                            self.addCuisineTableView.reloadData()
                            print("I Occur only once")
                        }
                    }
                }, failure: { (error) in
                    self.hideHud()
                    debugPrint(error)
                })
                //       }
            }else if (self.section ?? 0) == 1{
                self.searchBar.placeholder = "Enter restaurant name to search"
                //       if self.mainDataSource.count == 0{
                self.showHud(message: "loading restaurants..")
                _ = WebAPIHandler.sharedHandler.getCuisine(index : 2 ,success: { (response) in
                    debugPrint(response)
                    self.hideHud()
                    self.mainDataSource.removeAll()
                    let restaurants = (response["restaurants"] as? [[String:Any]]) ?? []
                    for restaurant in restaurants{
                        self.dataSource.append((restaurant["brand"] as? String) ?? "" )
                        self.mainDataSource.append(CuisineData.init(data: restaurant, index : 2) )
                    }
                    DispatchQueue.main.async {
                        for _ in 0..<self.selectedData.count{
                            self.configDataSource()
                        }
                        self.filteredDataSource = self.mainDataSource
                        self.selectedData.removeAll()
                        defer{
                            self.addCuisineTableView.reloadData()
                        }
                    }
                }, failure: { (error) in
                    debugPrint(error)
                    self.hideHud()
                })
                //       }
            }else{
                self.searchBar.placeholder = "Enter allergens name to search"
                if self.mainDataSource.count == 0{
                    self.showHud(message: "loading allergens..")
                    _ = WebAPIHandler.sharedHandler.getCuisine(index : 3 ,success: { (response) in
                        debugPrint(response)
                        self.hideHud()
                        let allergens = (response["allergens"] as? [[String:Any]]) ?? []
                        for allergen in allergens{
                            self.dataSource.append((allergen["name"] as? String) ?? "" )
                            self.mainDataSource.append(CuisineData.init(data: allergen, index : 1))
                        }
                        
                        DispatchQueue.main.async {
                            for _ in 0..<self.selectedData.count{
                                self.configDataSource()
                            }
                            self.filteredDataSource = self.mainDataSource
                            self.selectedData.removeAll()
                            defer{
                                self.addCuisineTableView.reloadData()
                            }
                        }
                    }, failure: { (error) in
                        debugPrint(error)
                        self.hideHud()
                    })
                }
            }
        }else{
            self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "Ok")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.view.endEditing(true)
        self.delegate?.initializeDataSource(section: self.section ?? 0, data: self.mainDataSource)
    }
    
    @IBAction func buttonAddAction(_ sender: Any) {
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
        if self.newlySelectedData.count != 0{
            if (self.section ?? 0) == 0{
                var parameter = [[String:Any]]()
                for data in self.newlySelectedData{
                    parameter.append(["id": "\(data.id)"])
                }
                self.showHud(message: "adding cuisines..")
                _ = WebAPIHandler.sharedHandler.addResturantPreferences(id: userid, param: parameter, index: 1, success: { (response) in
                    debugPrint(response)
                    self.hideHud()
                    let cuisines = (response["cuisines"] as? [[String:Any]]) ?? []
                    if (cuisines.count != 0){
                        self.newlySelectedData.removeAll()
                        for cuisine in cuisines{
                            self.newlySelectedData.append(CuisineData.init(data: cuisine, index: 1))
                        }
                        self.delegate?.sendTheSelectedData(data: self.newlySelectedData, section: self.section ?? 0)
                        self.view.endEditing(true)
                        self.navigationController?.popViewController(animated: true)
                    }else{
                        let meta = (response["meta"] as? [String:Any]) ?? [:]
                        let message = (meta["message"] as? String) ?? ""
                        self.showAlertViewWithTitle(title: "", Message: message, CancelButtonTitle: "Ok")
                    }
                }, failure: { (error) in
                    debugPrint(error)
                    self.hideHud()
                    
                })
            }else if (self.section ?? 0) == 1{
                
                var parameter = [[String:Any]]()
                for data in self.newlySelectedData{
                    parameter.append(["id": "\(data.id)"])
                }
                self.showHud(message: "adding restaurants..")
                _ = WebAPIHandler.sharedHandler.addResturantPreferences(id: userid, param: parameter, index: 2, success: { (response) in
                    debugPrint(response)
                    self.hideHud()
                    let restaurants = (response["restaurants"] as? [[String:Any]]) ?? []
                    if (restaurants.count != 0){
                        self.newlySelectedData.removeAll()
                        for restaurant in restaurants{
                            self.newlySelectedData.append(CuisineData.init(data: restaurant, index: 1))
                        }
                        self.delegate?.sendTheSelectedData(data: self.newlySelectedData, section: self.section ?? 0)
                        self.view.endEditing(true)
                        self.navigationController?.popViewController(animated: true)
                    }else{
                        let meta = (response["meta"] as? [String:Any]) ?? [:]
                        let message = (meta["message"] as? String) ?? ""
                        self.showAlertViewWithTitle(title: "", Message: message, CancelButtonTitle: "Ok")
                    }
                }, failure: { (error) in
                    debugPrint(error)
                    self.hideHud()
                    
                })
            }else if (self.section ?? 0) == 2{
                var parameter = [[String:Any]]()
                for data in self.newlySelectedData{
                    parameter.append(["id": "\(data.id)"])
                }
                self.showHud(message: "adding allergens..")
                _ = WebAPIHandler.sharedHandler.addResturantPreferences(id: userid, param: parameter, index: 3, success: { (response) in
                    debugPrint(response)
                    self.hideHud()
                    
                    let allergens = (response["allergens"] as? [[String:Any]]) ?? []
                    if (allergens.count != 0){
                        self.newlySelectedData.removeAll()
                        for allergen in allergens{
                            self.newlySelectedData.append(CuisineData.init(data: allergen, index: 1))
                        }
                        self.delegate?.sendTheSelectedData(data: self.newlySelectedData, section: self.section ?? 0)
                        self.view.endEditing(true)
                        self.navigationController?.popViewController(animated: true)
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
        }else{
            self.showAlertViewWithTitle(title: "", Message: "Please select any new entry", CancelButtonTitle: "Ok")
        }
    }
}

//MARK:- Custom methods
extension AddCuisineVC{
    func configDataSource(){
        for index in 0..<self.mainDataSource.count{
            if self.selectedData.contains(self.mainDataSource[index].restaurantTitle){
                self.mainDataSource.remove(at: index)
                break
            }
        }
    }
    
    func configUI(){
        if self.section == 0{
            self.setNavigation(title: "Select  Cuisine")
        }else if self.section == 1{
            self.setNavigation(title: "Select Restaurants")
        }else{
            self.setNavigation(title: "Select Meal Allergens")
        }
        
        DispatchQueue.main.async {
            //Adding shadow to bottom view
            self.bottomView.layer.masksToBounds = false
            self.bottomView.layer.shadowRadius = 20.0
            self.bottomView.layer.shadowColor = UIColor.lightGray.cgColor
            self.bottomView.layer.shadowOffset = CGSize(width: 1.0, height: 5.0)
            self.bottomView.layer.shadowOpacity = 1.0
            
            self.buttonAdd.layer.cornerRadius = self.buttonAdd.frame.size.height/2
        }
        
        self.addCuisineTableView.delegate = self
        self.addCuisineTableView.dataSource = self
        self.addCuisineTableView.tableFooterView = UIView()
    }
}

//MARK:- UI search bar delegate
extension AddCuisineVC  : UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
        self.addCuisineTableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
        self.addCuisineTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        
        searchBar.text = nil
        searchBar.resignFirstResponder()
        addCuisineTableView.resignFirstResponder()
        self.searchBar.showsCancelButton = false
        addCuisineTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        searchActive = false;
        self.searchBar.endEditing(true)
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchActive = true;
        self.searchBar.showsCancelButton = true
        filteredArray.removeAll()
        self.filteredArray = searchText.isEmpty ? self.dataSource : self.dataSource.filter({(dataString: String) -> Bool in
            return dataString.range(of: searchText, options: .caseInsensitive) != nil
        })
        
        self.filteredDataSource = searchText.isEmpty ? self.mainDataSource : self.mainDataSource.filter({ (restaurant) -> Bool in
            return restaurant.restaurantTitle.range(of: searchText, options: .caseInsensitive) != nil
        })
        addCuisineTableView.reloadData()
    }
    
}

//MARK:- Table view delegate data source
extension AddCuisineVC : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive){
            return self.filteredDataSource.count
        }else{
            return self.mainDataSource.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.addCuisineTableCell, for: indexPath) as! AddCuisineTableCell
        cell.delegate = self
        if(searchActive){
            
            if self.section == 0 || self.section == 2{
                cell.logoWidthConstraints.constant = 0.0
            }else{
                cell.logoImageView.sd_setImage(with: URL(string: self.filteredDataSource[indexPath.row].restaurantLogo), placeholderImage: UIImage(named: "logo"))
                cell.logoImageView.sd_setShowActivityIndicatorView(true)
                cell.logoImageView.sd_setIndicatorStyle(.gray)
            }
            cell.labelTitle.text = self.filteredDataSource[indexPath.row].restaurantTitle
            if selectedData.contains(self.filteredDataSource[indexPath.row].restaurantTitle){
                cell.buttonCheck.setImage(#imageLiteral(resourceName: "cubeCheck"), for: .normal)
            }else{
                cell.buttonCheck.setImage(#imageLiteral(resourceName: "cubeUncheck"), for: .normal)
            }
            cell.cuisineObject = self.filteredDataSource[indexPath.row]
        }else {
            
            if self.section == 0 || self.section == 2{
                cell.logoWidthConstraints.constant = 0.0
            }else{
                cell.logoImageView.sd_setShowActivityIndicatorView(true)
                cell.logoImageView.sd_setIndicatorStyle(.gray)
                cell.logoImageView.sd_setImage(with: URL(string: self.mainDataSource[indexPath.row].restaurantLogo), placeholderImage: UIImage(named: "logo"))
            }
            cell.labelTitle.text = self.mainDataSource[indexPath.row].restaurantTitle
            
            if selectedData.contains(self.mainDataSource[indexPath.row].restaurantTitle){
                cell.buttonCheck.setImage(#imageLiteral(resourceName: "cubeCheck"), for: .normal)
            }else{
                cell.buttonCheck.setImage(#imageLiteral(resourceName: "cubeUncheck"), for: .normal)
            }
            cell.cuisineObject = self.mainDataSource[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
}

//MARK:- Add Cuisine Table Cell Delegate
extension AddCuisineVC : AddCuisineTableCellDelegate{
    func didTapOnAddCell(cell: AddCuisineTableCell) {
        let text = cell.labelTitle.text ?? ""
        if !self.selectedData.contains(text){
            self.selectedData.append(text)
            self.selectedCuisineData.append(cell.cuisineObject ?? CuisineData(data: [:], index: 0))
            self.newlySelectedData.append(cell.cuisineObject ?? CuisineData(data: [:], index: 0))
            self.addCuisineTableView.reloadData()
        }else{
            for index in 0..<self.selectedCuisineData.count {
                if self.selectedCuisineData[index].restaurantTitle.isEqualToString(find: text){
                    self.selectedCuisineData.remove(at: index)
                    break
                }
            }
            for index in 0..<self.newlySelectedData.count {
                if self.newlySelectedData[index].restaurantTitle.isEqualToString(find: text){
                    self.newlySelectedData.remove(at: index)
                    break
                }
            }
            for index in 0..<self.selectedData.count {
                if selectedData[index].isEqualToString(find: text){
                    self.selectedData.remove(at: index)
                    self.addCuisineTableView.reloadData()
                    return
                }
            }
        }
        
    }
}
