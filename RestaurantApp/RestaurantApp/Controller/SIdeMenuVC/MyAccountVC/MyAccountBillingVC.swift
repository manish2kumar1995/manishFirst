//
//  MyAccountBillingVC.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 27/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
import JWTDecode

class MyAccountBillingVC: BaseViewController {
    
    @IBOutlet weak var bilingTableView: UITableView!
    
    fileprivate struct ReusableIdentifier {
        static let myAccountHeaderSection = "MyAccountHeaderSection"
        static let myAccountModeSection = "MyAccountModeSection"
        static let paymentSectionHeader = "PaymentsSectionHesder"
        static let editPaymentsAddCardCell = "EditPaymentsAddCardCell"
        static let editPaymentsCell = "EditPaymentsCell"
    }
    
    
    var profilePic = String()
    var userName = String()
    var activityId = String()
    var userWeight = Int()
    var userHeight = Int()
    var userAge = Int()
    var userGender = String()
    var weightGoal = String()
    var profileImage : UIImage?
    var editPaymentDataSource = [[:],["sectionTitle":"New Card" , "data" : PaymentScetionInfoClass.init(section: 1, sectionTitle: "", isExpanded: true)]]
    var row = Int()
    var cardNumber = ""
    var expiryMonth = ""
    var expiryYear = ""
    var cvv = ""
    var imagePicker = UIImagePickerController()
    var tableHeader : MyAccountHeaderSection?
    var hasChanged = false
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.bilingTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK:- Custom methods
extension MyAccountBillingVC{
    func configTableView(){
        //Configuring Table Header
        let tableHeader = UINib.init(nibName: ReusableIdentifier.myAccountHeaderSection, bundle: Bundle.main)
        self.bilingTableView.register(tableHeader, forCellReuseIdentifier: ReusableIdentifier.myAccountHeaderSection)
        
        //Registering section header
        let sectionHeader = UINib.init(nibName: ReusableIdentifier.myAccountModeSection, bundle: Bundle.main)
        self.bilingTableView.register(sectionHeader, forCellReuseIdentifier:  ReusableIdentifier.myAccountModeSection)
        
        //Registering scetion header
        let addCardSectionHeader = UINib(nibName: ReusableIdentifier.paymentSectionHeader, bundle: nil)
        self.bilingTableView.register(addCardSectionHeader, forCellReuseIdentifier: ReusableIdentifier.paymentSectionHeader)
        
        //Registering card cell
        let cardCell = UINib(nibName: ReusableIdentifier.editPaymentsAddCardCell, bundle: nil)
        self.bilingTableView.register(cardCell, forCellReuseIdentifier: ReusableIdentifier.editPaymentsAddCardCell)
        
        //Registering edit payment cell
        let editPayment = UINib(nibName: ReusableIdentifier.editPaymentsCell, bundle: nil)
        self.bilingTableView.register(editPayment, forCellReuseIdentifier: ReusableIdentifier.editPaymentsCell)
    }
    
    //Load add card content
    @objc func loadCardContents(cell : PaymentsSectionHesder?){
        ((self.editPaymentDataSource[1])["data"] as! PaymentScetionInfoClass).isExpanded = !((self.editPaymentDataSource[1])["data"] as! PaymentScetionInfoClass).isExpanded
        self.bilingTableView.reloadData()
        if ((self.editPaymentDataSource[1])["data"] as! PaymentScetionInfoClass).isExpanded{
            self.bilingTableView.scrollToRow(at: IndexPath.init(row: 0, section: 3), at: .bottom, animated: true)
        }
    }
    
    
    //To show App Alert with delegate
    func showAppALert( Message msgText: String ){
        let appAlert = self.storyboard?.instantiateViewController(withIdentifier: "AppAlertViewController") as! AppAlertViewController
        appAlert.message = msgText
        appAlert.okTitle = "Remove"
        appAlert.cancelTitle = "Cancel"
        appAlert.bottomSpace = 66.0
        appAlert.isComingFromAccount = true
        appAlert.delegate = self
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2436:
                appAlert.topHeight =  88
            default:
                appAlert.topHeight = self.getNavigationHeight()
            }
        }
        
        self.present(appAlert, animated: true, completion: nil)
    }
    
    //Add card on button click
    @objc func addCardButtonAction() {
        
        let date = NSDate()
        let components = Calendar.current.dateComponents([.day,.month,.year],from:date as Date)
        
        let month = components.month
        
        let indexPath = IndexPath.init(row: 0, section: 3)
        let cell = self.bilingTableView.cellForRow(at: indexPath) as! EditPaymentsAddCardCell
        let cardHolderName = cell.cardHolderTextField.text ?? ""
        let cardNumber = cell.cardNumberTextField.text ?? ""
        let expMonth = cell.expMonthTextField.text ?? ""
        let expYear = cell.expYearTextField.text ?? ""
        
        if (cell.cardHolderTextField.text?.isEmpty)!{
            self.showAlertViewWithTitle(title: "Alert", Message: "Please fill card holder name", CancelButtonTitle: "Ok")
        }else if (cell.cardNumberTextField.text?.isEmpty)!{
            self.showAlertViewWithTitle(title: "Alert", Message: "Please fill card number", CancelButtonTitle: "Ok")
        }else if (cell.expMonthTextField.text?.isEmpty)!{
            self.showAlertViewWithTitle(title: "Alert", Message: "Please fill expiry month", CancelButtonTitle: "Ok")
        }else if (cell.expYearTextField.text?.isEmpty)!{
            self.showAlertViewWithTitle(title: "Alert", Message: "Please fill expiry year", CancelButtonTitle: "Ok")
        }else if (cell.cvvTextField.text?.isEmpty)!{
            self.showAlertViewWithTitle(title: "Alert", Message: "Please fill cvv number", CancelButtonTitle: "Ok")
        }else if cell.cardNumberTextField.text?.count != 16{
            self.showAlertViewWithTitle(title: "Alert", Message: "Please enter 16 digit card number", CancelButtonTitle: "Ok")
        }else if cell.cvvTextField.text?.count != 3{
            self.showAlertViewWithTitle(title: "Alert", Message: "Please enter 3 digit cvv number", CancelButtonTitle: "Ok")
        }else if (Int(cell.expMonthTextField.text!)! < month!) && (cell.expYearTextField.text?.isEqualToString(find: "2018"))! {
            self.showAlertViewWithTitle(title: "Alert", Message: "Please enter valid a date", CancelButtonTitle: "Ok")
        }else{
            UserShared.shared.paymentMethods.payments.insert(Payments(methodsName : cardHolderName, cardNumber : cardNumber, monthYear : "\(expMonth)/\(expYear)", isCheck: false), at: UserShared.shared.paymentMethods.payments.count - 2)
            
            cell.cardHolderTextField.text = ""
            cell.cardNumberTextField.text = ""
            cell.expMonthTextField.text = ""
            cell.expYearTextField.text = ""
            cell.cvvTextField.text = ""
            
            self.cardNumber = ""
            self.expiryMonth = ""
            self.expiryYear = ""
            self.cvv = ""
            self.bilingTableView.reloadData()
        }
    }
}

//MARK:- Table view delegate data source
extension MyAccountBillingVC : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2{
            return UserShared.shared.paymentMethods.payments.count-2
        }else if section == 3{
            let expand = ((self.editPaymentDataSource[1])["data"] as! PaymentScetionInfoClass).isExpanded!
            if expand{
                return 1
            }else{
                return 0
            }
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 2{
            let cell  = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.editPaymentsCell, for: indexPath) as! EditPaymentsCell
            cell.dataSource = UserShared.shared.paymentMethods.payments[indexPath.row]
            cell.delegate = self
            cell.row = indexPath.row
            return cell
        }else{
            let cell  = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.editPaymentsAddCardCell, for: indexPath) as! EditPaymentsAddCardCell
            cell.scanCardButton.addTarget(self, action: #selector(MyAccountBillingVC.scanCardClicked), for: .touchUpInside)
            cell.addButton.addTarget(self, action: #selector(MyAccountBillingVC.addCardButtonAction), for: .touchUpInside)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            let headerView = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.myAccountHeaderSection) as? MyAccountHeaderSection
            if UserShared.shared.user.userImage != nil{
                headerView?.headerImageView.image = UserShared.shared.user.userImage
            }else{
                headerView?.headerImageView.sd_setShowActivityIndicatorView(true)
                headerView?.headerImageView.sd_setIndicatorStyle(.gray)
                headerView?.headerImageView.sd_setImage(with: URL(string: UserShared.shared.user.imageName), placeholderImage: UIImage(named: ""))
            }
            self.tableHeader = headerView
            headerView?.delegate = self
            return headerView
        }else if section == 1 {
            let sectionHeader = (tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.myAccountModeSection) as? MyAccountModeSection)
            sectionHeader?.labelUserName.text = "\(UserShared.shared.user.firstName) \(UserShared.shared.user.lastName)"
            sectionHeader?.selectionStyle = .none
            return sectionHeader
        }else if section == 2{
            let screenSize: CGRect = UIScreen.main.bounds
            let myView = UIView(frame: CGRect(x: 20, y: 0, width: screenSize.width - 20, height: 20))
            let label = UILabel(frame: CGRect(x: 35, y: 20, width: screenSize.width - 70, height: 20))
            label.text = "Saved Cards"
            label.font = UIFont.boldSystemFont(ofSize: 14.0)
            label.textColor = UIColor.disabledGray
            myView.backgroundColor = UIColor.viewBackgroundGray
            myView.addSubview(label)
            return myView
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.paymentSectionHeader) as! PaymentsSectionHesder
            cell.dataSource = self.editPaymentDataSource[1]["data"] as! PaymentScetionInfoClass
            cell.labelSectionTitle.text = "Add Card"
            cell.buttonToggle.addTarget(self, action: #selector(MyAccountBillingVC.loadCardContents), for: .touchUpInside)
            
            return cell.contentView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 130
        }else if section == 1{
            return 60
        }else {
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2{
            return 75
        }else{
            return 240
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2{
            return 30
        }else{
            return 0
        }
    }
}

//MARK:- Edit payment cell delgate
extension MyAccountBillingVC : EditPaymentsCellDelegate{
    
    func didTapCheckButton(row: Int) {
        for index in 0..<UserShared.shared.paymentMethods.payments.count {
            if index == row{
                UserShared.shared.paymentMethods.payments[index].isCheck = true
            }else{
                UserShared.shared.paymentMethods.payments[index].isCheck = false
            }
        }
        self.bilingTableView.reloadData()
    }
    
    func didTapOnCrossButton(row: Int) {
        self.row = row
        self.showAppALert(Message: "Do you really want to remove that credit card from your account?")
    }
}

//MARK:- App Alert delegate
extension MyAccountBillingVC : AppAlertViewControllerDelegate{
    func didTapOnRemove(){
        UserShared.shared.paymentMethods.payments.remove(at: self.row)
        self.bilingTableView.reloadData()
    }
}

//MARK:- Scanner methods
extension MyAccountBillingVC : CardIOPaymentViewControllerDelegate{
    
    func openGallary(){
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func openCamera(){
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func cancel(){
        print("Cancel tapped")
    }
    
    
    @objc func scanCardClicked() {
        let scanViewController = CardIOPaymentViewController(paymentDelegate: self)
        scanViewController?.modalPresentationStyle = .formSheet
        present(scanViewController!, animated: true)
    }
    
    func userDidProvide(_ info: CardIOCreditCardInfo?, in paymentViewController: CardIOPaymentViewController?){
        if let anInfo = info {
            print("Scan succeeded with info: \(anInfo)")
        }
        // Do whatever needs to be done to deliver the purchased items.
        dismiss(animated: true)
        
        let indexPath = IndexPath.init(row: 0, section: 3)
        let cell = self.bilingTableView.cellForRow(at: indexPath) as! EditPaymentsAddCardCell
        if let aNumber = info?.redactedCardNumber, let aCvv = info?.cvv {
            _ = String(format: "Received card info. Number: %@, expiry: %02lu/%lu, cvv: %@.", aNumber, UInt(info?.expiryMonth ?? 0), UInt(info?.expiryYear ?? 0), aCvv)
            self.cardNumber = String(aNumber)
            self.expiryYear = String(UInt(info?.expiryYear ?? 0))
            self.expiryMonth = String(UInt(info?.expiryMonth ?? 0))
            
            
            if UInt(info?.expiryMonth ?? 0) < 10{
                self.expiryMonth = "0" + self.expiryMonth
            }
            self.cvv = aCvv
            cell.cardHolderTextField.text = ""
            cell.cardNumberTextField.text = self.cardNumber
            cell.expMonthTextField.text = self.expiryMonth
            cell.expYearTextField.text = self.expiryYear
            cell.cvvTextField.text = self.cvv
            self.bilingTableView.reloadData()
        }
    }
    
    func userDidCancel(_ paymentViewController: CardIOPaymentViewController?) {
        print("User cancelled scan")
        dismiss(animated: true)
    }
}

//MARK:- MY account header delgate
extension MyAccountBillingVC : MyAccountHeaderSectionDelegate {
    func didTapOnImage() {
        imagePicker.delegate = self
        imagePicker.sourceType = .savedPhotosAlbum;
        imagePicker.allowsEditing = false
        
        
        let alert = UIAlertController(title: "Profile Picture Options", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let gallaryAction = UIAlertAction(title: "Open Gallery", style: UIAlertActionStyle.default)
        {
            UIAlertAction in self.openGallary()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
        {
            UIAlertAction in self.cancel()
        }
        
        let cameraAction = UIAlertAction(title: "Open Camera", style: UIAlertActionStyle.default)
        {
            UIAlertAction in self.openCamera()
        }
        alert.addAction(gallaryAction)
        alert.addAction(cameraAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func didTapOnLogout(){
        DataBaseHelper.shared.emptyCoreData()
        UserShared.shared.myBasketModel.myBasketData = []
        UserShared.shared.myBasketModel.totalQAR = 0.0
        UserShared.shared.myBasketModel.totalCart = 0
        UserShared.shared.isSubscriptionMode = false
        UserShared.shared.userSavedAddress = nil
        UserShared.shared.currentAddress = ""
        UserShared.shared.userMode = "subscription"
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginVC") as! UINavigationController
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
}

//MARK:- Image picker Delegate
extension MyAccountBillingVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        
        DispatchQueue.main.async {
            self.tableHeader?.headerImageView.layer.cornerRadius = 57.5
            self.tableHeader?.headerImageView.contentMode = .scaleAspectFill //3
            self.tableHeader?.headerImageView.layer.cornerRadius = 57.5
        }
        
        let user = DataBaseHelper.shared.getData().first
        let token = user?.tokenId ?? ""
        var userid = String()
        var email = String()
        do{
            let jwt = try decode(jwt: token)
            if jwt.expired{
                //     self.performLogout()
            }else{
                let body = jwt.body
                userid = (body["uid"] as? String) ?? ""
                email = (body["uemail"] as? String) ?? ""
            }
        }catch{
            print("Data not fetched")
        }
        let data = UIImageJPEGRepresentation(chosenImage, 0)!
        if Connectivity.isConnectedToInternet{
            let parameters = [
                "first_name": "\(UserShared.shared.user.firstName)",
                "last_name": "\(UserShared.shared.user.lastName)",
                "email": "\(email)",
                "age": "\(UserShared.shared.user.age)",
                "gender": "\(UserShared.shared.user.gender)",
                "height": "\(UserShared.shared.user.height)",
                "weight": "\(UserShared.shared.user.weight)",
                "daily_calorie_allowance": "\(UserShared.shared.user.dailyCaloryAllowance)",
                "activity_level_id": "\(UserShared.shared.user.activityLevelID)",
                "weight_recommendation": "\(UserShared.shared.user.weightRecommendation.lowercasingFirstLetter())",
                "bmi_value": "\(UserShared.shared.user.bmiValue)",
                "bmi_classification": "\(UserShared.shared.user.bmiClassification)",
                "weight_goal" : "\(UserShared.shared.user.weightGoals)"
                ] as [String : Any]
            self.showHud(message: "Uploading ...")
            
            _ = WebAPIHandler.sharedHandler.updateUserMultiparts(parameter: parameters, uid: userid, token: token, imageData: data, success: { (response) in
                debugPrint(response)
                self.hideHud()
                let success = (response["success"] as? Bool) ?? false
                if success{
                    self.hasChanged = true
                    self.profileImage = chosenImage
                    UserShared.shared.user.userImage = chosenImage
                    self.tableHeader?.headerImageView.image = chosenImage //4
                }else{
                    let meta = (response["meta"] as? [String:Any]) ?? [:]
                    let message = (meta["message"] as? String) ?? ""
                    self.showAlertViewWithTitle(title: "", Message: message, CancelButtonTitle: "Ok")
                }
            }, failure: { (error) in
                debugPrint(error)
                self.hideHud()
                self.showAlertViewWithTitle(title: "", Message: "Some error occured", CancelButtonTitle: "Ok")
            })
            
        }else{
            self.showAlertViewWithTitle(title: "", Message: Messages.internetUnavailable, CancelButtonTitle: "Ok")
        }
        
        dismiss(animated:true, completion: nil) //5
    }
}



