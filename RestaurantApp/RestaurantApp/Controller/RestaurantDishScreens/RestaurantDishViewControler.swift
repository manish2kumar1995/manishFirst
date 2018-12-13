//
//  RestaurantDishViewControler.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 03/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class RestaurantDishViewControler: BaseViewController {
    
    @IBOutlet weak var dishTableView: UITableView!
    
    var modes : DishDetailModes = .description
    var sectionHeader : RestaurantDishSectionHeader?
    var navigationTitle : String?
    var menuData : MenuItems?
    var restaurantId : String?
    var isWantToShowloading:Bool = true
    
    //Various Reusable identifiers
    fileprivate struct ReusableIdenfier {
        static let restaurantDishSectionHeader = "RestaurantDishSectionHeader"
        static let restaurantIngredientsCell = "RestaurantIngredientsCell"
        static let dishDescriptionCell = "RestaurantDishDescriptionCell"
        static let restaurantTableHeader = "RestaurantTableHeader"
        static let nutritionCollection = "NutritionCollectionCell"
        static let restaurantNutritionTableCell = "RestaurantNutrientsTableCell"
    }
    
    //Data Source for Nutrients
    var dishNutrientsDataSource = [RestaurantDishDetail.DishNutrients]()
    
    //Data Source for Ingredients
    var ingredientsDataSource = [RestaurantDishDetail.DishIngredients]()
    
    //Data Source for Description
    var dishDescriptionDataSource = [RestaurantDishDetail.DishDescription]()
    
    //MARK:- UIView life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configTableView()
        self.prepareDescriptionDataSource()
        
        //Calling Dish Ingredients
        if Connectivity.isConnectedToInternet{
            self.callingAPIForDishIngredients()
        }else{
            self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "ok")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

//MARK:- TableView delegate and dataSource methods
extension RestaurantDishViewControler: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 0
        }else if modes == .description{
            return dishDescriptionDataSource.count
        }else if modes == .nutrients{
            return 1
        }else{
            return ingredientsDataSource.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        switch (modes) {
        case .description:
            let descriptionCell = tableView.dequeueReusableCell(withIdentifier: ReusableIdenfier.dishDescriptionCell, for: indexPath) as! RestaurantDishDescriptionCell
            descriptionCell.dataSource = self.dishDescriptionDataSource[indexPath.row]
            cell = descriptionCell
            return cell
        case .nutrients:
            let nutrientsCell = tableView.dequeueReusableCell(withIdentifier: ReusableIdenfier.restaurantNutritionTableCell) as! RestaurantNutrientsTableCell
            nutrientsCell.nutrientsCollectionView.reloadData()
            nutrientsCell.setInticator(self.isWantToShowloading)
            cell = nutrientsCell
            
        case .ingredients:
            let ingredientsCell = tableView.dequeueReusableCell(withIdentifier: ReusableIdenfier.restaurantIngredientsCell, for: indexPath) as! RestaurantIngredientsCell
            ingredientsCell.dataSource = ingredientsDataSource[indexPath.row]
            ingredientsCell.delegate = self
            cell = ingredientsCell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            let headerView = self.dishTableView.dequeueReusableHeaderFooterView(withIdentifier: ReusableIdenfier.restaurantTableHeader) as! RestaurantTableHeader
            headerView.menuIconImage.sd_setImage(with: URL(string: (self.menuData?.menuLogoImage) ?? ""), placeholderImage: UIImage(named: "logo"))
            headerView.labelRating.text = "\(self.menuData?.menuStarRating ?? 0.0)"
            return headerView
        }else{
            if sectionHeader != nil {
                return sectionHeader
            }else{
                sectionHeader = (tableView.dequeueReusableCell(withIdentifier: ReusableIdenfier.restaurantDishSectionHeader) as! RestaurantDishSectionHeader)
                sectionHeader?.delegate = self
                sectionHeader?.selectionStyle = .none
                return sectionHeader
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 190
        }else{
            return 70
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if modes == .nutrients{
            return 350
        }else{
            return UITableViewAutomaticDimension
        }
    }
}


//MARK:- Collection View Delegate and Datasource
extension RestaurantDishViewControler: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dishNutrientsDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let ratingCell = collectionView.dequeueReusableCell(withReuseIdentifier: ReusableIdenfier.nutritionCollection, for: indexPath) as! NutritionCollectionCell
        ratingCell.dataSource = dishNutrientsDataSource[indexPath.row]
        return ratingCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let yourWidth = collectionView.bounds.width/3.35
        let yourHeight = yourWidth + 50.0
        
        return CGSize(width: yourWidth, height: yourHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}

//MARK:- Custom methods
extension RestaurantDishViewControler{
    
    func configTableView(){
        
        self.setNavigation(title: self.navigationTitle)
        
        self.dishTableView.rowHeight = UITableViewAutomaticDimension
        self.dishTableView.estimatedRowHeight = 80
        self.dishTableView.delegate = self
        self.dishTableView.dataSource = self
        //Configuring Table Header
        let tableHeader = UINib.init(nibName: ReusableIdenfier.restaurantTableHeader, bundle: Bundle.main)
        self.dishTableView.register(tableHeader, forHeaderFooterViewReuseIdentifier: ReusableIdenfier.restaurantTableHeader)
        
        //Registering section header
        let sectionHeader = UINib.init(nibName: ReusableIdenfier.restaurantDishSectionHeader, bundle: Bundle.main)
        self.dishTableView.register(sectionHeader, forCellReuseIdentifier:  ReusableIdenfier.restaurantDishSectionHeader)
        
        //Registering Ingredients Cell
        let ingredientsCell = UINib.init(nibName: ReusableIdenfier.restaurantIngredientsCell, bundle: Bundle.main)
        self.dishTableView.register(ingredientsCell, forCellReuseIdentifier:  ReusableIdenfier.restaurantIngredientsCell)
        
        //Registering Dish Description Cell
        let descriptionCell = UINib.init(nibName: ReusableIdenfier.dishDescriptionCell, bundle: Bundle.main)
        self.dishTableView.register(descriptionCell, forCellReuseIdentifier:  ReusableIdenfier.dishDescriptionCell)
        
        DispatchQueue.main.async{
            self.dishTableView.reloadData()
        }
    }
    
    func callingAPIForDishIngredients(){
        isWantToShowloading = true
        let _ = WebAPIHandler.sharedHandler.getDishIngredients(restaurantId:self.restaurantId ?? "", dishId:(self.menuData?.menuId) ?? "" , success: { (response) in
            debugPrint(response)
            self.isWantToShowloading = false
            let macros = (response["macros"] as? [String:Any]) ?? [:]
            for (key, value) in macros{
                let name = (key).capitalizingFirstLetter()
                let data = (value as? [String :Any]) ?? [:]
                let text = (data["text"] as? String) ?? ""
                self.dishNutrientsDataSource.append(RestaurantDishDetail.DishNutrients.init(nutrients: name, percentage:(data["percentage"] as? CGFloat) ?? 0.0, text : text))
                if(self.modes == .nutrients) {
                    self.changeModes(mode: self.modes)
                }
            }
            let ingredients = (response["ingredients"] as? [[String: Any]]) ?? [[:]]
            for ingredient in ingredients{
                self.ingredientsDataSource.append(RestaurantDishDetail.DishIngredients(data:ingredient))
            }
            self.dishTableView.reloadData()
        }){ (error) in
            self.hideHud()
            self.isWantToShowloading = false
            debugPrint(error)
        }
    }
    
    func prepareDescriptionDataSource(){
        self.dishDescriptionDataSource.append(RestaurantDishDetail.DishDescription.init(name:(self.menuData?.menuTitle) ?? "" , description:(self.menuData?.description) ?? ""))
    }
}

//MARK:- Section header delegate
extension RestaurantDishViewControler : RestaurantDishSectionHeaderDelegate{
    func changeModes(mode: DishDetailModes?) {
        modes = mode!
        self.dishTableView.reloadData()
    }
}

//MARK:- Restaurant Ingredients Cell Delegate
extension RestaurantDishViewControler : RestaurantIngredientsCellDelegate{
    func didTapOnToggleButton(cell: RestaurantIngredientsCell?) {
        self.dishTableView.reloadData()
    }
}



