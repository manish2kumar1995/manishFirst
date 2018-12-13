//
//  PhonesActionSheetVC.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 12/3/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
import MRCountryPicker

protocol PhonesActionSheetVCDelegate {
    func didTapOnSavedCell(data : PhoneStruct, index:Int)
}

class PhonesActionSheetVC: BaseViewController {
    
    //MARK:- IBOutlets
    @IBOutlet weak var phoneTableView: UITableView!
    @IBOutlet weak var blurrView: UIView!
    
    var savedPhoneNubers = [PhoneStruct]()
    var delegate : PhonesActionSheetVCDelegate?
    var selectedPhoneId : String?
    fileprivate struct ReusableIdentifier{
        static let adressActionSheetCell = "AdressActionSheetCell"
    }
    
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.phoneTableView.tableFooterView = UIView()
        self.phoneTableView.delegate = self
        self.phoneTableView.dataSource = self
        self.blurrView.makeBlurr()
        
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(self.dismisTapAction(_:)))
        self.blurrView.addGestureRecognizer(dismissTap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK:- Custom methods
extension PhonesActionSheetVC {
    @objc func dismisTapAction(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK:- Table view delegate data source
extension PhonesActionSheetVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.savedPhoneNubers.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.adressActionSheetCell, for: indexPath) as! AdressActionSheetCell
        if indexPath.row == 0{
            cell.labelAddress.text = "Choose new phone"
            cell.iconImageView.image = #imageLiteral(resourceName: "addressAddIcon")
            cell.buttonLoc.isHidden = true
        }else{
            cell.initUIForPhones(data: self.savedPhoneNubers[indexPath.row - 1])
            if ((self.selectedPhoneId?.isEqualToString(find:self.savedPhoneNubers[indexPath.row - 1].id )) ?? false){
                cell.buttonLoc.setImage(#imageLiteral(resourceName: "addressFillIcon"), for: .normal)
            }else{
                cell.buttonLoc.setImage(#imageLiteral(resourceName: "addressEmptyLoc"), for: .normal)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            self.delegate?.didTapOnSavedCell(data: PhoneStruct(data: [:]), index: indexPath.row)
        }else{
            self.delegate?.didTapOnSavedCell(data: self.savedPhoneNubers[indexPath.row - 1], index: indexPath.row)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let screenSize: CGRect = UIScreen.main.bounds
        let myView = UIView(frame: CGRect(x: 20, y: 0, width: screenSize.width, height: 20))
        let label = UILabel(frame: CGRect(x: 45, y: 20, width: screenSize.width - 70, height: 20))
        label.text = "Saved Phones"
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
