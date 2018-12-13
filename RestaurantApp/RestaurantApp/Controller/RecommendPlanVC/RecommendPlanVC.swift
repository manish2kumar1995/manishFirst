//
//  RecommendPlanVC.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 12/5/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class RecommendPlanVC: BaseViewController {
    
    //MARK:- IB Outlet
    @IBOutlet weak var recommendTableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var buttonSubscribe: UIButton!
    
    //Various Reusable identifiers
    fileprivate struct ReusableIdentifier{
        static let recommendScheduleCell = "RecommendScheduleCell"
        static let recommendTableHeader = "RecommendTableHeader"
        static let recoomendModeHeader = "RecoomendModeHeader"
        static let restaurantNutritionTableCell = "RestaurantNutrientsTableCell"
        static let nutritionCollection = "NutritionCollectionCell"
        static let filterHeaderTableViewCell = "FilterHeaderTableViewCell"
    }
    
    
    var sectionHeader :  RecoomendModeHeader?
    var recommendMode : RecommendMode = .schedule
    var weekOfTheYear = Int()
    
    //Data Source for Nutrients
    var recommendNutrientsDataSource = [RestaurantDishDetail.DishNutrients]()
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configTableView()
        self.configUI()
        self.configDataSource()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? WeekViewVC{
            vc.startDate = (sender as? RecommendScheduleCell)?.startDate ?? Date()
            vc.endDate = (sender as? RecommendScheduleCell)?.endDate ?? Date()
        }
    }
    
    @IBAction func subscribeAction(_ sender: Any) {
        
    }
}

//MARK:- Custom Methods
extension RecommendPlanVC {
    
    func weeks() -> Int {
        let weekRange = NSCalendar.current.range(of: .weekOfYear, in: .yearForWeekOfYear, for: Date())
        return weekRange?.count ?? 0
    }
    
    //Prepare the data source
    func configDataSource(){
        self.recommendNutrientsDataSource.append(RestaurantDishDetail.DishNutrients.init(nutrients: "Calories", percentage: 30.0, text: "57"))
        self.recommendNutrientsDataSource.append(RestaurantDishDetail.DishNutrients.init(nutrients: "Sodium", percentage: 10.0, text: "119mg"))
        self.recommendNutrientsDataSource.append(RestaurantDishDetail.DishNutrients.init(nutrients: "Sugars", percentage: 30.0, text: "0.9g"))
        self.recommendNutrientsDataSource.append(RestaurantDishDetail.DishNutrients.init(nutrients: "TotalFat", percentage: 30.0, text: "0.19g"))
        self.recommendNutrientsDataSource.append(RestaurantDishDetail.DishNutrients.init(nutrients: "Protein", percentage: 30.0, text: "4.51g"))
        self.recommendNutrientsDataSource.append(RestaurantDishDetail.DishNutrients.init(nutrients: "Potassium", percentage: 30.0, text: "184.5mg"))
    }
    
    //Configure UI based work
    func configUI(){
        let calendar = Calendar.current
        let weekOfYear = calendar.component(.weekOfYear, from: Date.init(timeIntervalSinceNow: 0))
        self.weekOfTheYear = weekOfYear
        
        self.setNavigation(title: "Recommended Plan")
        self.recommendTableView.delegate = self
        self.recommendTableView.dataSource = self
        //Adding shadow to bottom view
        self.bottomView.layer.masksToBounds = false
        self.bottomView.layer.shadowRadius = 20.0
        self.bottomView.layer.shadowColor = UIColor.lightGray.cgColor
        self.bottomView.layer.shadowOffset = CGSize(width: 1.0, height: 5.0)
        self.bottomView.layer.shadowOpacity = 1.0
        
        self.buttonSubscribe.layer.cornerRadius = self.buttonSubscribe.frame.size.height/2
    }
    
    
    //Configure table View
    func configTableView(){
        self.recommendTableView.estimatedRowHeight = 80
        self.recommendTableView.rowHeight = UITableViewAutomaticDimension
        
        //Configuring Table Header
        let tableHeader = UINib.init(nibName: ReusableIdentifier.recommendTableHeader, bundle: Bundle.main)
        self.recommendTableView.register(tableHeader, forHeaderFooterViewReuseIdentifier: ReusableIdentifier.recommendTableHeader)
        
        //Registering section header
        let sectionHeader = UINib.init(nibName: ReusableIdentifier.recoomendModeHeader, bundle: Bundle.main)
        self.recommendTableView.register(sectionHeader, forCellReuseIdentifier:  ReusableIdentifier.recoomendModeHeader)
    }
}

//MARK:- UItable View delegate data source
extension RecommendPlanVC : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch self.recommendMode {
        case .schedule:
            return 2
        case .nutrients:
            return 2
        case .dishTypes:
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 0
        }else{
            if self.recommendMode == .nutrients{
                return 1
            }else if self.recommendMode == .dishTypes{
                if section > 1{
                    return 1
                }else{
                    return 0
                }
            }else{
                return (self.weeks() - self.weekOfTheYear) + 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        switch self.recommendMode {
        case .schedule:
            let scheduleCell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.recommendScheduleCell, for: indexPath) as! RecommendScheduleCell
            scheduleCell.labelWeekCount.text = "\(indexPath.row + 1)"
            scheduleCell.labelWeek.text = "Week \(self.weekOfTheYear + indexPath.row)"
            scheduleCell.labelWeekCount.applyGradientWith(startColor: UIColor.shadeOrange, endColor: UIColor.borderedRed)
            scheduleCell.configWeeks(index: indexPath.row)
            cell = scheduleCell
            return cell
        case .nutrients:
            let nutrientsCell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.restaurantNutritionTableCell) as! RestaurantNutrientsTableCell
            nutrientsCell.recommentNutrientsCollectionCell.reloadData()
            nutrientsCell.recommentNutrientsCollectionCell.showsVerticalScrollIndicator = false
            cell = nutrientsCell
            return cell
        case .dishTypes:
            let nutrientsCell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.restaurantNutritionTableCell) as! RestaurantNutrientsTableCell
            nutrientsCell.recommentNutrientsCollectionCell.reloadData()
            nutrientsCell.recommentNutrientsCollectionCell.showsVerticalScrollIndicator = false
            cell = nutrientsCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.recommendMode == .schedule{
            let cell = tableView.cellForRow(at: indexPath) as! RecommendScheduleCell
            self.performSegue(withIdentifier: "weekSegue", sender: cell)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if recommendMode == .schedule{
            return 90
        }else if recommendMode == .nutrients{
            return 350
        }else{
            return 170
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            let headerView = self.recommendTableView.dequeueReusableHeaderFooterView(withIdentifier: ReusableIdentifier.recommendTableHeader) as! RecommendTableHeader
            return headerView
        }else if section > 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.filterHeaderTableViewCell) as! FilterHeaderTableViewCell
            if section == 2{
                cell.imageViewIcon.image = #imageLiteral(resourceName: "filterCusines")
                cell.labelTitle.text = "CUSINES"
            }else{
                cell.imageViewIcon.image = #imageLiteral(resourceName: "filterCarrot")
                cell.labelTitle.text = "FOOD TYPES"
            }
            return cell.contentView
        }else{
            if sectionHeader != nil {
                return sectionHeader
            }else{
                sectionHeader = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.recoomendModeHeader) as? RecoomendModeHeader
                sectionHeader?.delegate = self
                sectionHeader?.selectionStyle = .none
                return sectionHeader
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 140
        }else if self.recommendMode == .nutrients || self.recommendMode == .dishTypes{
            return 65
        }else{
            return 115
        }
    }
}

//MARK:- Collection View Delegate and Datasource
extension RecommendPlanVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommendNutrientsDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let ratingCell = collectionView.dequeueReusableCell(withReuseIdentifier: ReusableIdentifier.nutritionCollection, for: indexPath) as! NutritionCollectionCell
        ratingCell.dataSource = recommendNutrientsDataSource[indexPath.row]
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


//MARK:- Recoomend Mode Header Delegate
extension RecommendPlanVC : RecoomendModeHeaderDelegate{
    func changeModes(mode: RecommendMode?) {
        self.recommendMode = mode!
        self.recommendTableView.reloadData()
    }
}
