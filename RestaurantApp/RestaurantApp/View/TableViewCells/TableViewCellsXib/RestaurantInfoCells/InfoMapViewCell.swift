//
//  InfoMapViewCell.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 29/08/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
import GoogleMaps

class InfoMapViewCell: UITableViewCell {
    
    //MARK:- IBOutlets
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var viewInCell: UIView!
    @IBOutlet weak var restaurantAddress: UILabel!
    @IBOutlet weak var restaurantTitle: UILabel!
    @IBOutlet weak var restaurantIcon: UIImageView!
 
    
    var dataSource : RestaurantInfo.RestaurantMapInfo = RestaurantInfo.RestaurantMapInfo(data: [:])  {
        didSet{
            self.restaurantTitle.text = dataSource.restaurantTitle
            self.restaurantIcon.image = UIImage.init(named: dataSource.restaurantImage)
            self.restaurantAddress.text = dataSource.restaurantAddress
            
            self.restaurantIcon.sd_setImage(with: URL(string: dataSource.restaurantImage), placeholderImage: UIImage(named: "logo"))
            let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(dataSource.latitude), longitude: CLLocationDegrees(dataSource.longitude), zoom: 10.0)
            self.mapView.camera = camera
            
            // Creates a marker in the center of the map.
            let marker = GMSMarker()
            marker.position = camera.target
            marker.title = "Mohammed Bin Thani Street"
            marker.snippet = "Doha, Qatar"
            marker.map = mapView
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.viewInCell.layer.cornerRadius = 5
            self.viewInCell.layer.borderWidth = 0.4
            self.viewInCell.layer.borderColor = UIColor.lightGray.cgColor
        }
        mapView.settings.scrollGestures = false
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
