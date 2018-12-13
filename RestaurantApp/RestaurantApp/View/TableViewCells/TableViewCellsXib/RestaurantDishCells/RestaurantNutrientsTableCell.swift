//
//  RestaurantNutrientsTableCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 05/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class RestaurantNutrientsTableCell: UITableViewCell {
    
    @IBOutlet weak var nutrientsCollectionView: UICollectionView!
    
    @IBOutlet weak var recommentNutrientsCollectionCell: UICollectionView!
    
    var spinnerView:UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setInticator(_ withShow:Bool) {
        if let spinnerView = spinnerView{
            if withShow{
                spinnerView.isHidden = false
                self.contentView.bringSubview(toFront: spinnerView)
            }else{
                spinnerView.isHidden = true
                self.contentView.sendSubview(toBack: spinnerView)
            }
        }else if(withShow){
            let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            spinner.startAnimating()
            spinner.center =  CGPoint(x: self.bounds.size.width/2, y: 0)
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: self.bounds.width, height: CGFloat(44))
            self.contentView.addSubview(spinner)
            self.spinnerView = spinner
            self.spinnerView?.isHidden = false
            self.contentView.bringSubview(toFront: spinner)
        }
    }
}
