//
//  SubscriptionPlanTypeVC.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 11/21/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class SubscriptionPlanTypeVC: BaseViewController {
    
    //MARK:- IB outlet
    @IBOutlet weak var subscriptionCollectionView: UICollectionView!
    @IBOutlet weak var pageController: CustomPageControl!
    @IBOutlet weak var labelCurrentCards: UILabel!
    @IBOutlet weak var labelTotalCards: UILabel!
    @IBOutlet weak var resrtaurantImage: UIImageView!
    @IBOutlet weak var labelRestaurantName: UILabel!
    
    //For segue purpose
    fileprivate struct ReusableIdentifier {
        static let subscrioptionCollectionCell = "SubscriptionCollectionCell"
    }
    var restaurantId : String?
    var restaurantDetail : RestaurantLists?
    var subscriptionDataSource = [SubscriptionCatagory]()
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        self.setNavigation(title: "Select Category")
        self.labelCurrentCards.text = "1"
        self.subscriptionCollectionView.showsHorizontalScrollIndicator = false
        let floawLayout = UPCarouselFlowLayout()
        floawLayout.itemSize = CGSize(width: UIScreen.main.bounds.size.width - 100, height: subscriptionCollectionView.frame.size.height - 100)
        floawLayout.scrollDirection = .horizontal
        floawLayout.sideItemScale = 0.8
        floawLayout.sideItemAlpha = 0.6
        floawLayout.spacingMode = .fixed(spacing: 3.0)
        subscriptionCollectionView.collectionViewLayout = floawLayout
        if Connectivity.isConnectedToInternet{
            self.callAPIForCategory()
        }else{
            self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "Ok")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SelectPlanVC{
            vc.restaurantListDetail = self.restaurantDetail
            vc.categoryDetail = sender as? SubscriptionCatagory
        }
    }
}

//MARK:- Custom Methods
extension SubscriptionPlanTypeVC{
    
    func callAPIForCategory(){
        self.showHud(message: "loading categories")
        _ = WebAPIHandler.sharedHandler.getSubscriptionCategory(id: self.restaurantId ?? "", success: { (response) in
            debugPrint(response)
            self.hideHud()
            let subscriptions = (response["subscriptions"] as? [[String:Any]]) ?? []
            for subscription in subscriptions{
                let values = (subscription.values.first as? [[String:Any]]) ?? []
                let value = (values.first) ?? [:]
                let category = (value["category"] as? [String:Any]) ?? [:]
                self.subscriptionDataSource.append(SubscriptionCatagory.init(data: category))
            }
            
            
            self.pageController.numberOfPages = self.subscriptionDataSource.count
            
            if self.subscriptionDataSource.count == 0{
                self.labelCurrentCards.text = "0"
            }
            self.labelTotalCards.text = "\(self.subscriptionDataSource.count)"
            self.subscriptionCollectionView.reloadData()
        }, failure: { (error) in
            debugPrint(error)
            self.hideHud()
        })
    }
    
    func configUI(){
        //Registering cell
        let flowCell = UINib(nibName: ReusableIdentifier.subscrioptionCollectionCell, bundle: nil)
        self.subscriptionCollectionView.register(flowCell, forCellWithReuseIdentifier: ReusableIdentifier.subscrioptionCollectionCell)
        
        self.subscriptionCollectionView.delegate = self
        self.subscriptionCollectionView.dataSource = self
        self.labelRestaurantName.text = self.restaurantDetail?.restaurantTitle ?? ""
        self.resrtaurantImage.sd_setShowActivityIndicatorView(true)
        self.resrtaurantImage.sd_setIndicatorStyle(.gray)
        self.resrtaurantImage.sd_setImage(with: URL(string: restaurantDetail?.restaurantLogo ?? ""), placeholderImage: UIImage(named: "logo"))
    }
    
    fileprivate var pageSize: CGSize {
        let layout = self.subscriptionCollectionView.collectionViewLayout as! UPCarouselFlowLayout
        var pageSize = layout.itemSize
        if layout.scrollDirection == .horizontal {
            pageSize.width += layout.minimumLineSpacing
        }else{
            pageSize.height += layout.minimumLineSpacing
        }
        return pageSize
    }
}

//MARK:- Collection view delegate
extension SubscriptionPlanTypeVC: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.subscriptionDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReusableIdentifier.subscrioptionCollectionCell, for: indexPath) as! SubscriptionCollectionCell
        cell.dataSource = self.subscriptionDataSource[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let layout = self.subscriptionCollectionView.collectionViewLayout as! UPCarouselFlowLayout
        let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
        let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
        let index = floor((offset - pageSide / 2) / pageSide) + 1
        let currenIndexString =  String(format: "%.0f",(index))
        let currenIndex = (currenIndexString as NSString).integerValue
        self.pageController.currentPage = currenIndex
        
        if (currenIndex < self.subscriptionDataSource.count) || (currenIndex > 0){
            self.labelCurrentCards.text = "\(currenIndex + 1)"
        }
    }
}

//MARK:- Subscription Collection Cell Delegate
extension SubscriptionPlanTypeVC : SubscriptionCollectionCellDelegate{
    func didTapOnSelectPlan(cell:SubscriptionCollectionCell) {
        let data = cell.dataSource
        self.performSegue(withIdentifier: "selectPlanSegue", sender: data)
    }
}

