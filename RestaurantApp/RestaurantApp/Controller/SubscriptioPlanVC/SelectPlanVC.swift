//
//  SelectPlanVC.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 11/27/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class SelectPlanVC: BaseViewController {
    
    //MARK:- IB outlet
    @IBOutlet weak var subscriptionCollectionView: UICollectionView!
    @IBOutlet weak var pageController: CustomPageControl!
    @IBOutlet weak var labelCurrentCards: UILabel!
    @IBOutlet weak var labelTotalCards: UILabel!
    
    @IBOutlet weak var labelRestaurantName: UILabel!
    @IBOutlet weak var restaurantImage: UIImageView!
    fileprivate struct ReusableIdentifier {
        static let subscrioptionCollectionCell = "SelectPlanTypeCell"
        static let recommendSegue = "recommendSegue"
    }
    
    var restaurantListDetail : RestaurantLists?
    var categoryDetail : SubscriptionCatagory?
    var planDataSource = [SelectPlan]()
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        self.setNavigation(title: "Select Plan")
        self.labelCurrentCards.text = "1"
        self.subscriptionCollectionView.showsHorizontalScrollIndicator = false
        let flowLayout = UPCarouselFlowLayout()
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.size.width - 110.0, height: subscriptionCollectionView.frame.size.height - 100)
        flowLayout.scrollDirection = .horizontal
        flowLayout.sideItemScale = 0.8
        flowLayout.sideItemAlpha = 0.6
        flowLayout.spacingMode = .fixed(spacing: 20.0)
        subscriptionCollectionView.collectionViewLayout = flowLayout
        
        if Connectivity.isConnectedToInternet{
            self.callAPIForSelectPlan()
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
}

//MARK:- Custom Methods
extension SelectPlanVC{
    
    func callAPIForSelectPlan(){
        self.showHud(message: "loading plans..")
        _ = WebAPIHandler.sharedHandler.getSubscriptionPlan(id: self.restaurantListDetail?.id ?? "", catagId: self.categoryDetail?.id ?? "", success: { (response) in
            debugPrint(response)
            self.hideHud()
            let subscriptions = (response["subscriptions"] as? [[String:Any]]) ?? []
            for subscription in subscriptions{
                self.planDataSource.append(SelectPlan.init(data: subscription))
            }
            self.pageController.numberOfPages = self.planDataSource.count
            
            if self.planDataSource.count == 0{
                self.labelCurrentCards.text = "0"
            }
            self.labelTotalCards.text = "\(self.planDataSource.count)"
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
        
        self.labelRestaurantName.text = self.restaurantListDetail?.restaurantTitle ?? ""
        self.restaurantImage.sd_setShowActivityIndicatorView(true)
        self.restaurantImage.sd_setIndicatorStyle(.gray)
        self.restaurantImage.sd_setImage(with: URL(string: restaurantListDetail?.restaurantLogo ?? ""), placeholderImage: UIImage(named: "logo"))
        
        self.subscriptionCollectionView.delegate = self
        self.subscriptionCollectionView.dataSource = self
    }
    
    fileprivate var pageSize: CGSize {
        let layout = self.subscriptionCollectionView.collectionViewLayout as! UPCarouselFlowLayout
        var pageSize = layout.itemSize
        if layout.scrollDirection == .horizontal {
            pageSize.width += layout.minimumLineSpacing
        } else {
            pageSize.height += layout.minimumLineSpacing
        }
        return pageSize
    }
}

//MARK:- Collection view delegate
extension SelectPlanVC: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.planDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReusableIdentifier.subscrioptionCollectionCell, for: indexPath) as! SelectPlanTypeCell
        cell.delegate = self
        cell.dataSource = self.planDataSource[indexPath.row]
        DispatchQueue.main.async {
            cell.contentView.clipsToBounds = true
            cell.contentView.addGradienBorder(view: cell.contentView)
        }
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
        
        if (currenIndex < self.planDataSource.count) || (currenIndex > 0){
            self.labelCurrentCards.text = "\(currenIndex + 1)"
        }
    }
}

//MARK:- Select Plan Type Cell Delegate
extension SelectPlanVC : SelectPlanTypeCellDelegate{
    func didTapOnSelect() {
        self.performSegue(withIdentifier: ReusableIdentifier.recommendSegue, sender: nil)
    }
}
