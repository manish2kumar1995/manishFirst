//
//  MyAccountHeaderSection.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 25/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

protocol MyAccountHeaderSectionDelegate {
    func didTapOnImage()
    func didTapOnLogout()
}

class MyAccountHeaderSection: UITableViewCell {

    @IBOutlet weak var headerImageView: UIImageView!{
        didSet{
            DispatchQueue.main.async {
                self.headerImageView.layer.cornerRadius = 57.5
            }
        }
    }
    var delegate : MyAccountHeaderSectionDelegate?
    
    @IBOutlet weak var buttonLogout: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
            self.headerImageView.layer.cornerRadius = 57.5
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyAccountHeaderSection.tapOnImage(_:)))
       self.headerImageView.isUserInteractionEnabled = true
        self.headerImageView.addGestureRecognizer(tapGestureRecognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func buttonLogoutAction(_ sender: Any) {
        self.delegate?.didTapOnLogout()
    }
    
    @objc func tapOnImage(_ sender:AnyObject){
        self.delegate?.didTapOnImage()
    }
}
