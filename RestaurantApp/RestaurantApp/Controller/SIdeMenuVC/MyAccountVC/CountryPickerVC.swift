//
//  CountryPickerVC.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 11/27/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
import MRCountryPicker

class CountryPickerVC: BaseViewController {
    
    //MARK:- IB Outlet
    @IBOutlet weak var countryTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var dataSource = [CountryFormat]()
    var filteredDataSource = [CountryFormat]()
    var searchActive = false
    
    //MARK:- UIView cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self.countryNamesByCode()
        self.countryTableView.delegate = self
        self.countryTableView.dataSource = self
        self.searchBar.delegate = self
        self.setNavigation(title: "Select Country")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddContactsVC{
            vc.countryData = sender as? CountryFormat
        }
    }
}

//MARK:- Custom methods
extension CountryPickerVC{
    func countryNamesByCode() -> [CountryFormat] {
        var countries = [CountryFormat]()
        let frameworkBundle = Bundle(for: type(of: MRCountryPicker()))
        guard let jsonPath = frameworkBundle.path(forResource: "SwiftCountryPicker.bundle/Data/countryCodes", ofType: "json"), let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonPath)) else {
            return countries
        }
        do {
            if let jsonObjects = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? NSArray {
                
                for jsonObject in jsonObjects {
                    
                    guard let countryObj = jsonObject as? NSDictionary else {
                        return countries
                    }
                    
                    guard let code = countryObj["code"] as? String, let phoneCode = countryObj["dial_code"] as? String, let name = countryObj["name"] as? String else {
                        return countries
                    }
                    
                    let country = CountryFormat(code: code, name: name, phoneCode: phoneCode)
                    countries.append(country)
                }
                
            }
        } catch {
            return countries
        }
        return countries
    }
    
}


//MARK:- Table view delegate datasource
extension CountryPickerVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive){
            return self.filteredDataSource.count
        }else{
            return self.dataSource.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryPickerCell", for: indexPath) as! CountryPickerCell
        if(searchActive){
            cell.dataSource = self.filteredDataSource[indexPath.row]
        }else{
            cell.dataSource = self.dataSource[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.searchActive{
            self.performSegue(withIdentifier: "addContactsSegue", sender: self.filteredDataSource[indexPath.row])
        }else{
            self.performSegue(withIdentifier: "addContactsSegue", sender: self.dataSource[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

//MARK:- UI search bar delegate
extension CountryPickerVC  : UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
        self.countryTableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
        self.countryTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        
        searchBar.text = nil
        searchBar.resignFirstResponder()
        countryTableView.resignFirstResponder()
        self.searchBar.showsCancelButton = false
        countryTableView.reloadData()
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
        
        self.filteredDataSource = searchText.isEmpty ? self.dataSource : self.dataSource.filter({ (restaurant) -> Bool in
            return restaurant.name?.range(of: searchText, options: .caseInsensitive) != nil
        })
        countryTableView.reloadData()
    }
}


//MARK:- Structure for country picker
struct CountryFormat {
    var code: String?
    var name: String?
    var phoneCode: String?
    var flag: UIImage? {
        guard let code = self.code else { return nil }
        return UIImage(named: "SwiftCountryPicker.bundle/Images/\(code.uppercased())", in: Bundle(for: MRCountryPicker.self), compatibleWith: nil)
    }
    
    init(code: String?, name: String?, phoneCode: String?) {
        self.code = code
        self.name = name
        self.phoneCode = phoneCode
    }
}

