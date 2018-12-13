//
//  FilterByViewController.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 03/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
protocol FilterByViewControllerDelegate{
    func didTapOnApplyFilter(data : [String], dictData : [Int:[String]])
}

class FilterByViewController: BaseViewController {
    
    @IBOutlet var tableViewFilterOptions: UITableView!
    
    var objectsArray = [FilterObject(sectionName: "CUSINES", sectionImage:"filterCusines", sectionObjects : ["Indian","Lebanese","Persion"]),FilterObject(sectionName: "MEAL TYPES", sectionImage:"menuBordered", sectionObjects: ["Breakfast","smoothies","Soups"]), FilterObject(sectionName: "DIETARY PREFERENCES", sectionImage:"filterCarrot",sectionObjects: ["Vegitarian","Non-Vegitarioan","Smoothies"])]
    
    var menuDataSource : [String:[MenuItems]] = [String:[MenuItems]]()
    var restaurantsDataSource : [RestaurantLists] = [RestaurantLists]()
    var filterData : [RestaurantLists] = [RestaurantLists]()
    var selectedElement = [String]()
    var delegate : FilterByViewControllerDelegate?
    var dataDictionary = [Int:[String]]()
    var filteredDishData : [String:[MenuItems]] = [String:[MenuItems]]()
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.setNavigation(title: "FILTER BY")
    }
}

//MARK : UIButton Action
private extension FilterByViewController{
    
    @IBAction func applyFilterAction(_ sender: Any) {
        self.checkForFilter()
    }
    
    @IBAction func applyFilter(_ sender: Any) {
        self.checkForFilter()
    }
    
    func checkForFilter(){
        if self.restaurantsDataSource.count != 0{
            self.checkForRestaurant(data: self.selectedElement, dictData: self.dataDictionary)
            if self.filterData.count != 0{
                self.delegate?.didTapOnApplyFilter(data: self.selectedElement, dictData : self.dataDictionary)
                self.navigationController?.popViewController(animated: true)
            }
        }else{
            self.didTapOnApplyFilter(data: self.selectedElement, dictData: self.dataDictionary)
            
            if self.filteredDishData.count != 0 {
                self.delegate?.didTapOnApplyFilter(data: self.selectedElement, dictData : self.dataDictionary)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

//MARK : Private Methods
extension FilterByViewController {
    
}

//MARK:- Table View Methods
extension FilterByViewController: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return objectsArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (objectsArray[section].sectionObjects.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterTableViewCell") as! FilterTableViewCell
        
        let item = objectsArray[indexPath.section].sectionObjects[indexPath.row]
        cell.labelTitle.text = item
        cell.labelTitle.textColor = UIColor.gray
        
        for data in self.selectedElement{
            if item == data{
                cell.buttonRadio.isSelected = true
                cell.labelTitle.textColor = UIColor.black
            }
        }
        cell.initCellItem()
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterHeaderTableViewCell") as! FilterHeaderTableViewCell
        cell.imageViewIcon.image = UIImage(named: objectsArray[section].sectionImage)
        cell.labelTitle.text = objectsArray[section].sectionName
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
}

//UITableview cell delegate
extension FilterByViewController : FilterTableViewCellDelegate{
    
    func didToggleRadioButton(_ indexPath: IndexPath) {
        let section = indexPath.section
        let data = objectsArray[indexPath.section].sectionObjects[indexPath.row]
        if self.selectedElement.contains(data){
            self.selectedElement = selectedElement.filter { $0 != data }
        }else{
            self.selectedElement.append(data)
        }
        var dictArray = [String]()
        if var previousItem = dataDictionary[section] {
            
            if previousItem.contains(data){
                dictArray = previousItem.filter { $0 != data }
                self.dataDictionary.updateValue(dictArray, forKey: section)
            }else{
                previousItem.append(data)
                self.dataDictionary.updateValue(previousItem, forKey: section)
            }
        }else{
            dictArray.append(data)
            self.dataDictionary.updateValue(dictArray, forKey: section)
        }
        
        tableViewFilterOptions.reloadData()
    }
    
    func didTapOnApplyFilter(data: [String], dictData : [Int:[String]]) {
        self.selectedElement = data
        let cuisineData = (dictData[0]) ?? []
        let mealData = (dictData[1]) ?? []
        let foodData = (dictData[2]) ?? []
        
        if cuisineData.count != 0 && mealData.count != 0 && foodData.count  != 0 {
            self.filteredDishData.removeAll()
            //Filter meal first
            var mealFilterData = [String:[MenuItems]]()
            for (key, value) in self.menuDataSource{
                var menuItems = [MenuItems]()
                for selectedData in mealData{
                    var dishData : [MenuItems]?
                    dishData = value.filter({ (menuItem) -> Bool in
                        return  menuItem.mealType.isEqualToString(find: selectedData)
                    })
                    if dishData != nil{
                        menuItems.append(contentsOf: dishData!)
                    }
                }
                let items = Set(menuItems)
                if items.count != 0{
                    mealFilterData.updateValue(Array(items), forKey: key)
                }else{
                    mealFilterData.removeValue(forKey: key)
                }
            }
            
            //Filter Cuisine
            var cuisineDataWithFilter = [String:[MenuItems]]()
            for (key, value) in mealFilterData{
                var menuItems = [MenuItems]()
                for selectedData in cuisineData{
                    var dishData : [MenuItems]?
                    dishData = value.filter({ (menuItem) -> Bool in
                        return  menuItem.cuisineType.isEqualToString(find:selectedData )
                    })
                    if dishData != nil{
                        menuItems.append(contentsOf: dishData!)
                    }
                }
                let items = Set(menuItems)
                if items.count != 0{
                    cuisineDataWithFilter.updateValue(Array(items), forKey: key)
                }else{
                    cuisineDataWithFilter.removeValue(forKey: key)
                }
            }
            
            //Filter drinks
            for (key, value) in cuisineDataWithFilter{
                var menuItems = [MenuItems]()
                for selectedData in foodData{
                    var dishData : [MenuItems]?
                    dishData = value.filter({ (menuItem) -> Bool in
                        return  menuItem.foodType.isEqualToString(find:selectedData )
                    })
                    if dishData != nil{
                        menuItems.append(contentsOf: dishData!)
                    }
                }
                let items = Set(menuItems)
                if items.count != 0{
                    self.filteredDishData.updateValue(Array(items), forKey: key)
                }else{
                    self.filteredDishData.removeValue(forKey: key)
                }
            }
            
            //      self.menuTableView.reloadData()
        }else if cuisineData.count != 0 && mealData.count != 0 && foodData.count == 0{
            //  var menuItems = [MenuItems]()
            self.filteredDishData.removeAll()
            var mealFilterData = [String:[MenuItems]]()
            
            //Filter meal first
            for (key, value) in self.menuDataSource{
                var menuItems = [MenuItems]()
                for selectedData in mealData{
                    var dishData : [MenuItems]?
                    dishData = value.filter({ (menuItem) -> Bool in
                        return  menuItem.mealType.isEqualToString(find: selectedData)
                    })
                    if dishData != nil{
                        menuItems.append(contentsOf: dishData!)
                    }
                }
                let items = Set(menuItems)
                if items.count != 0{
                    mealFilterData.updateValue(Array(items), forKey: key)
                }else{
                    mealFilterData.removeValue(forKey: key)
                }
            }
            //Filter Cuisine
            for (key, value) in mealFilterData{
                var menuItems = [MenuItems]()
                for selectedData in cuisineData{
                    var dishData : [MenuItems]?
                    dishData = value.filter({ (menuItem) -> Bool in
                        return  menuItem.cuisineType.isEqualToString(find:selectedData )
                    })
                    if dishData != nil{
                        menuItems.append(contentsOf: dishData!)
                    }
                }
                let items = Set(menuItems)
                if items.count != 0{
                    self.filteredDishData.updateValue(Array(items), forKey: key)
                }else{
                    self.filteredDishData.removeValue(forKey: key)
                }
            }
            
            //       self.menuTableView.reloadData()
        }else if cuisineData.count != 0 && mealData.count == 0 && foodData.count == 0{
            //  var menuItems = [MenuItems]()
            self.filteredDishData.removeAll()
            
            //Filter cuisine first
            for (key, value) in self.menuDataSource{
                var menuItems = [MenuItems]()
                for selectedData in cuisineData{
                    var dishData : [MenuItems]?
                    dishData = value.filter({ (menuItem) -> Bool in
                        return  menuItem.cuisineType.isEqualToString(find: selectedData)
                    })
                    if dishData != nil{
                        menuItems.append(contentsOf: dishData!)
                    }
                }
                let items = Set(menuItems)
                if items.count != 0{
                    self.filteredDishData.updateValue(Array(items), forKey: key)
                }else{
                    self.filteredDishData.removeValue(forKey: key)
                }
            }
            //         self.menuTableView.reloadData()
        }else if cuisineData.count == 0 && mealData.count != 0 && foodData.count == 0{
            //  var menuItems = [MenuItems]()
            self.filteredDishData.removeAll()
            
            //Filter meal first
            for (key, value) in self.menuDataSource{
                var menuItems = [MenuItems]()
                for selectedData in mealData{
                    var dishData : [MenuItems]?
                    dishData = value.filter({ (menuItem) -> Bool in
                        return  menuItem.mealType.isEqualToString(find: selectedData)
                    })
                    if dishData != nil{
                        menuItems.append(contentsOf: dishData!)
                    }
                }
                let items = Set(menuItems)
                if items.count != 0{
                    self.filteredDishData.updateValue(Array(items), forKey: key)
                }else{
                    self.filteredDishData.removeValue(forKey: key)
                }
            }
            //         self.menuTableView.reloadData()
            
        }else if cuisineData.count != 0 && mealData.count == 0 && foodData.count != 0{
            //  var menuItems = [MenuItems]()
            self.filteredDishData.removeAll()
            //Filter Cuisine
            
            var cuisineDataWithFilter = [String:[MenuItems]]()
            for (key, value) in self.menuDataSource{
                var menuItems = [MenuItems]()
                for selectedData in cuisineData{
                    var dishData : [MenuItems]?
                    dishData = value.filter({ (menuItem) -> Bool in
                        return  menuItem.cuisineType.isEqualToString(find:selectedData )
                    })
                    if dishData != nil{
                        menuItems.append(contentsOf: dishData!)
                    }
                }
                let items = Set(menuItems)
                if items.count != 0{
                    cuisineDataWithFilter.updateValue(Array(items), forKey: key)
                }else{
                    cuisineDataWithFilter.removeValue(forKey: key)
                }
            }
            
            //Filter Food type
            for (key, value) in cuisineDataWithFilter{
                var menuItems = [MenuItems]()
                for selectedData in foodData{
                    var dishData : [MenuItems]?
                    dishData = value.filter({ (menuItem) -> Bool in
                        return  menuItem.foodType.isEqualToString(find:selectedData )
                    })
                    if dishData != nil{
                        menuItems.append(contentsOf: dishData!)
                    }
                }
                let items = Set(menuItems)
                if items.count != 0{
                    self.filteredDishData.updateValue(Array(items), forKey: key)
                }else{
                    self.filteredDishData.removeValue(forKey: key)
                }
            }
            
            //         self.menuTableView.reloadData()
            
        }else if cuisineData.count == 0 && mealData.count != 0 && foodData.count != 0{
            //  var menuItems = [MenuItems]()
            self.filteredDishData.removeAll()
            
            //Filter meal first
            var mealFilterData = [String:[MenuItems]]()
            for (key, value) in self.menuDataSource{
                var menuItems = [MenuItems]()
                for selectedData in mealData{
                    var dishData : [MenuItems]?
                    dishData = value.filter({ (menuItem) -> Bool in
                        return  menuItem.mealType.isEqualToString(find: selectedData)
                    })
                    if dishData != nil{
                        menuItems.append(contentsOf: dishData!)
                    }
                }
                let items = Set(menuItems)
                if items.count != 0{
                    mealFilterData.updateValue(Array(items), forKey: key)
                }else{
                    mealFilterData.removeValue(forKey: key)
                }
            }
            
            //Filter Food type
            for (key, value) in mealFilterData{
                var menuItems = [MenuItems]()
                for selectedData in foodData{
                    var dishData : [MenuItems]?
                    dishData = value.filter({ (menuItem) -> Bool in
                        return  menuItem.foodType.isEqualToString(find:selectedData )
                    })
                    if dishData != nil{
                        menuItems.append(contentsOf: dishData!)
                    }
                }
                let items = Set(menuItems)
                if items.count != 0{
                    self.filteredDishData.updateValue(Array(items), forKey: key)
                }else{
                    self.filteredDishData.removeValue(forKey: key)
                }
            }
            
            //        self.menuTableView.reloadData()
            
        }else if cuisineData.count == 0 && mealData.count == 0 && foodData.count != 0{
            //  var menuItems = [MenuItems]()
            self.filteredDishData.removeAll()
            //Filter food type
            for (key, value) in self.menuDataSource{
                var menuItems = [MenuItems]()
                for selectedData in foodData{
                    var dishData : [MenuItems]?
                    dishData = value.filter({ (menuItem) -> Bool in
                        return  menuItem.foodType.isEqualToString(find:selectedData )
                    })
                    if dishData != nil{
                        menuItems.append(contentsOf: dishData!)
                    }
                }
                let items = Set(menuItems)
                if items.count != 0{
                    self.filteredDishData.updateValue(Array(items), forKey: key)
                }else{
                    self.filteredDishData.removeValue(forKey: key)
                }
            }
        }else{
            self.filteredDishData = self.menuDataSource
        }
        if self.filteredDishData.count == 0{
            self.showAlertViewWithTitle(title: "", Message: "We couldn't find any dish for your selection. Try some other filters.", CancelButtonTitle: "Ok")
        }
    }
    
    func checkForRestaurant(data: [String], dictData : [Int:[String]]) {
        self.selectedElement = data
        let cuisineData = (dictData[0]) ?? []
        let mealData = (dictData[1]) ?? []
        
        if cuisineData.count != 0 && mealData.count != 0{
            self.filterData.removeAll()
            //Filter food type
            var cuisineFilterData = [RestaurantLists]()
            var restaurantData = [RestaurantLists]()
            
            for selectedData in cuisineData{
                var resData : [RestaurantLists]?
                resData = self.restaurantsDataSource.filter({ (restaurant) -> Bool in
                    return restaurant.cuisineTypes.isEqualToString(find: selectedData)
                })
                if resData != nil{
                    restaurantData.append(contentsOf: resData ?? [])
                }
            }
            let items = Set(restaurantData)
            if items.count != 0{
                cuisineFilterData = Array(items)
            }
            
            restaurantData.removeAll()
            //Filter meal type
            for selectedData in mealData{
                var resData : [RestaurantLists]?
                resData = cuisineFilterData.filter({ (restaurant) -> Bool in
                    return restaurant.mealTypes.isEqualToString(find: selectedData)
                })
                if resData != nil{
                    restaurantData.append(contentsOf: resData ?? [])
                }
            }
            let resItems = Set.init(restaurantData)
            if items.count != 0{
                self.filterData = Array(resItems)
            }
        }else if cuisineData.count != 0 && mealData.count == 0{
            self.filterData.removeAll()
            //Filter food type
            var restaurantData = [RestaurantLists]()
            
            for selectedData in cuisineData{
                var resData : [RestaurantLists]?
                resData = self.restaurantsDataSource.filter({ (restaurant) -> Bool in
                    return restaurant.cuisineTypes.isEqualToString(find: selectedData)
                })
                if resData != nil{
                    restaurantData.append(contentsOf: resData ?? [])
                }
            }
            let items = Set(restaurantData)
            if items.count != 0{
                self.filterData = Array(items)
            }
        }else if cuisineData.count == 0 && mealData.count != 0{
            self.filterData.removeAll()
            //Filter food type
            var restaurantData = [RestaurantLists]()
            
            for selectedData in mealData{
                var resData : [RestaurantLists]?
                resData = self.restaurantsDataSource.filter({ (restaurant) -> Bool in
                    return restaurant.mealTypes.isEqualToString(find: selectedData)
                })
                if resData != nil{
                    restaurantData.append(contentsOf: resData ?? [])
                }
            }
            let items = Set(restaurantData)
            if items.count != 0{
                self.filterData = Array(items)
            }
        }else{
            self.filterData = self.restaurantsDataSource
        }
        
        if self.filterData.count == 0{
            self.showAlertViewWithTitle(title: "", Message: "We couldn't find any restaurant for your selection. Try some other filters.", CancelButtonTitle: "Ok")
        }
        
    }
}

