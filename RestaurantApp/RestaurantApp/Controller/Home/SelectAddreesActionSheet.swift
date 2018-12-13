//
//  SelectAddreesActionSheet.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 12/1/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

protocol SelectAddreesActionSheetDelegate {
    func didSelectAddressType(cell : AdressActionSheetCell, index: Int)
}

class SelectAddreesActionSheet: BaseViewController {
    
    //MARK:- IB Outlet
    @IBOutlet weak var addressTableView: UITableView!
    @IBOutlet weak var blurrView: UIView!
    
    var addresses : [AddressStruct]?
    var delegate : SelectAddreesActionSheetDelegate?
    var selectedAddressId : String?
    
    fileprivate struct ReusableIdentifier{
        static let adressActionSheetCell = "AdressActionSheetCell"
    }
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addressTableView.tableFooterView = UIView()
        self.addressTableView.delegate = self
        self.addressTableView.dataSource = self
        self.blurrView.makeBlurr()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(self.dismisTapAction(_:)))
        self.blurrView.addGestureRecognizer(dismissTap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK:- Custom methods
extension SelectAddreesActionSheet{
    @objc func dismisTapAction(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK:- Table view delegate data source
extension SelectAddreesActionSheet : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.addresses!.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.adressActionSheetCell, for: indexPath) as! AdressActionSheetCell
        if indexPath.row == 0{
            cell.labelAddress.text = "Deliver to new address"
            cell.iconImageView.image = #imageLiteral(resourceName: "addressAddIcon")
            cell.buttonLoc.isHidden = true
        }else if indexPath.row == 1{
            cell.labelAddress.text = "Deliver to My Location"
            cell.iconImageView.image = #imageLiteral(resourceName: "addressCheckIcon")
            cell.buttonLoc.isHidden = true
        }else{
            cell.dataSource = self.addresses![indexPath.row - 2]
            cell.iconImageView.image = #imageLiteral(resourceName: "addressPinIcon")
            if ((self.selectedAddressId?.isEqualToString(find:self.addresses![indexPath.row - 2].id )) ?? false){
                cell.buttonLoc.setImage(#imageLiteral(resourceName: "addressFillIcon"), for: .normal)
            }else{
                cell.buttonLoc.setImage(#imageLiteral(resourceName: "addressEmptyLoc"), for: .normal)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! AdressActionSheetCell
        self.delegate?.didSelectAddressType(cell: cell, index: indexPath.row)
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let screenSize: CGRect = UIScreen.main.bounds
        let myView = UIView(frame: CGRect(x: 20, y: 0, width: screenSize.width, height: 20))
        let label = UILabel(frame: CGRect(x: 45, y: 20, width: screenSize.width - 70, height: 20))
        label.text = "Delivery Address"
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        let lineView = UIView(frame: CGRect(x: 0, y: 60, width: screenSize.width, height: 1))
        lineView.backgroundColor = UIColor.viewBackgroundGray
        myView.addSubview(label)
        myView.addSubview(lineView)
        myView.backgroundColor = UIColor.white
        return myView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
}

