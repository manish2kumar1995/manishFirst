//
//  EditPaymentsViewController.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 11/09/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit

class EditPaymentsViewController: BaseViewController,CardIOPaymentViewControllerDelegate {
    
    @IBOutlet weak var editPaymentsTableView: UITableView!
    
    //Various string value to perform action
    fileprivate struct ReusableIdentifier {
        static let paymentSectionHeader = "PaymentsSectionHesder"
        static let editPaymentsAddCardCell = "EditPaymentsAddCardCell"
        static let editPaymentsCell = "EditPaymentsCell"
        static let addCardCell = "AddCardCell"
    }
    
    //MARK:- Custom variables
    var editPaymentDataSource = [[:],["sectionTitle":"New Card" , "data" : PaymentScetionInfoClass.init(section: 1, sectionTitle: "", isExpanded: true)]]
    var isCheckedAddCard:Bool = false
    var cardNumber = ""
    var expiryMonth = ""
    var expiryYear = ""
    var cvv = ""
    var dataSource : Payments = Payments()
    
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigation(title: "Edit payments")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.configTableView()
        CardIOUtilities.preload()
    }
}

//MARK:- Custom Methods
extension EditPaymentsViewController{
    
    func configTableView(){
        //Registering scetion header
        let sectionHeader = UINib(nibName: ReusableIdentifier.paymentSectionHeader, bundle: nil)
        self.editPaymentsTableView.register(sectionHeader, forCellReuseIdentifier: ReusableIdentifier.paymentSectionHeader)
        
        //Registering card cell
        let cardCell = UINib(nibName: ReusableIdentifier.editPaymentsAddCardCell, bundle: nil)
        self.editPaymentsTableView.register(cardCell, forCellReuseIdentifier: ReusableIdentifier.editPaymentsAddCardCell)
        
        //Registering edit payment cell
        let editPayment = UINib(nibName: ReusableIdentifier.editPaymentsCell, bundle: nil)
        self.editPaymentsTableView.register(editPayment, forCellReuseIdentifier: ReusableIdentifier.editPaymentsCell)
        //Registering add card cell
        //Registering edit payment cell
        let addCardCell = UINib(nibName: ReusableIdentifier.addCardCell, bundle: nil)
        self.editPaymentsTableView.register(addCardCell, forCellReuseIdentifier: ReusableIdentifier.addCardCell)
        
    }
    
    @objc func loadCardContents(cell : AddCardCell?){
        for index in 0..<UserShared.shared.paymentMethods.payments.count {
            if index == UserShared.shared.paymentMethods.payments.count - 1{
                UserShared.shared.paymentMethods.payments[index].isCheck = true
            }else{
                UserShared.shared.paymentMethods.payments[index].isCheck = false
            }
        }
        ((self.editPaymentDataSource[1])["data"] as! PaymentScetionInfoClass).isExpanded = !((self.editPaymentDataSource[1])["data"] as! PaymentScetionInfoClass).isExpanded
        self.editPaymentsTableView.reloadData()
    }
    
    @objc func buttonToggleAction(_ sender: UIButton, cell : PaymentsSectionHesder?) {
        ((self.editPaymentDataSource[sender.tag])["data"] as! PaymentScetionInfoClass).isExpanded = !((self.editPaymentDataSource[sender.tag])["data"] as! PaymentScetionInfoClass).isExpanded
        self.editPaymentsTableView.reloadData()
    }
}

//MARK:- scanner methods
extension EditPaymentsViewController{
    
    @objc func scanCardClicked() {
        let scanViewController = CardIOPaymentViewController(paymentDelegate: self)
        scanViewController?.modalPresentationStyle = .formSheet
        present(scanViewController!, animated: true)
    }
    
    func userDidProvide(_ info: CardIOCreditCardInfo?, in paymentViewController: CardIOPaymentViewController?) {
        if let anInfo = info {
            print("Scan succeeded with info: \(anInfo)")
        }
        // Do whatever needs to be done to deliver the purchased items.
        dismiss(animated: true)
        
        if let aNumber = info?.redactedCardNumber, let aCvv = info?.cvv {
            _ = String(format: "Received card info. Number: %@, expiry: %02lu/%lu, cvv: %@.", aNumber, UInt(info?.expiryMonth ?? 0), UInt(info?.expiryYear ?? 0), aCvv)
            self.cardNumber = String(aNumber)
            self.expiryYear = String(UInt(info?.expiryYear ?? 0))
            self.expiryMonth = String(UInt(info?.expiryMonth ?? 0))
            if UInt(info?.expiryMonth ?? 0) < 10{
                self.expiryMonth = "0" + self.expiryMonth
            }
            self.cvv = aCvv
            self.editPaymentsTableView.reloadData()
            
        }
        
    }
    func userDidCancel(_ paymentViewController: CardIOPaymentViewController?) {
        print("User cancelled scan")
        dismiss(animated: true)
    }
    
}

//MARK:- IB Action
extension EditPaymentsViewController{
    
    @objc func addCardButtonAction() {
        
        let indexPath = IndexPath.init(row: 0, section: 1)
        let cell = self.editPaymentsTableView.cellForRow(at: indexPath) as! EditPaymentsAddCardCell
        let cardHolderName = cell.cardHolderTextField.text ?? ""
        let cardNumber = cell.cardNumberTextField.text ?? ""
        let expMonth = cell.expMonthTextField.text ?? ""
        let expYear = cell.expYearTextField.text ?? ""
        
        if (cell.cardHolderTextField.text?.isEmpty)!{
            self.showAlertViewWithTitle(title: "Alert", Message: "Please fill card holder name", CancelButtonTitle: "Ok")
        }else if (cell.cardNumberTextField.text?.isEmpty)!{
            self.showAlertViewWithTitle(title: "Alert", Message: "Please fill card number", CancelButtonTitle: "Ok")
            
        }else if (cell.expMonthTextField.text?.isEmpty)!{
            self.showAlertViewWithTitle(title: "Alert", Message: "Please expiry month", CancelButtonTitle: "Ok")
        }else if (cell.expYearTextField.text?.isEmpty)!{
            self.showAlertViewWithTitle(title: "Alert", Message: "Please fill expiry year", CancelButtonTitle: "Ok")
        }else if (cell.cvvTextField.text?.isEmpty)!{
            self.showAlertViewWithTitle(title: "Alert", Message: "Please fill cvv number", CancelButtonTitle: "Ok")
        }else if cell.cardNumberTextField.text?.count != 16{
            self.showAlertViewWithTitle(title: "Alert", Message: "Please enter 16 digit card number", CancelButtonTitle: "Ok")
        }else if cell.cvvTextField.text?.count != 3{
            self.showAlertViewWithTitle(title: "Alert", Message: "Please enter 3 digit cvv number", CancelButtonTitle: "Ok")
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
            self.editPaymentsTableView.reloadData()
        }
    }
}

//MARK:- Table view delegate datasource
extension EditPaymentsViewController : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return UserShared.shared.paymentMethods.payments.count-1
        }else{
            let expand = UserShared.shared.paymentMethods.payments[UserShared.shared.paymentMethods.payments.count - 1].isCheck
            if expand{
                return 1
            }else{
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            let cell  = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.editPaymentsCell, for: indexPath) as! EditPaymentsCell
            cell.dataSource = UserShared.shared.paymentMethods.payments[indexPath.row]
            cell.delegate = self
            cell.row = indexPath.row
            return cell
        }else{
            let cell  = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.editPaymentsAddCardCell, for: indexPath) as! EditPaymentsAddCardCell
            cell.scanCardButton.addTarget(self, action: #selector(EditPaymentsViewController.scanCardClicked), for: .touchUpInside)
            cell.addButton.addTarget(self, action: #selector(EditPaymentsViewController.addCardButtonAction), for: .touchUpInside)
            cell.cardHolderTextField.text = ""
            cell.cardNumberTextField.text = self.cardNumber
            cell.expMonthTextField.text = self.expiryMonth
            cell.expYearTextField.text = self.expiryYear
            cell.cvvTextField.text = self.cvv
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifier.addCardCell) as! AddCardCell
        cell.delegate = self
        cell.dataSource = UserShared.shared.paymentMethods.payments[UserShared.shared.paymentMethods.payments.count - 1]
        cell.checkButton.addTarget(self, action: #selector(EditPaymentsViewController.loadCardContents), for: .touchUpInside)
        
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0
        }else{
            return 70
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 70
        }else{
            return 270
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}

//MARK:- Edit payment cell delgate
extension EditPaymentsViewController : EditPaymentsCellDelegate{
    
    func didTapCheckButton(row: Int) {
        for index in 0..<UserShared.shared.paymentMethods.payments.count {
            if index == row{
                UserShared.shared.paymentMethods.payments[index].isCheck = true
            }else{
                UserShared.shared.paymentMethods.payments[index].isCheck = false
            }
        }
        self.editPaymentsTableView.reloadData()
    }
    
    func didTapOnCrossButton(row: Int) {
        UserShared.shared.paymentMethods.payments.remove(at: row)
        self.editPaymentsTableView.reloadData()
    }
}

//MARK:- Add card delegate
extension EditPaymentsViewController : AddCardCellDelegate{
    
    func didTapOnAddCardCheck(row: Int){
        for index in 0..<UserShared.shared.paymentMethods.payments.count {
            if index == row{
                UserShared.shared.paymentMethods.payments[index].isCheck = true
            }else{
                UserShared.shared.paymentMethods.payments[index].isCheck = false
            }
        }
        ((self.editPaymentDataSource[1])["data"] as! PaymentScetionInfoClass).isExpanded = !((self.editPaymentDataSource[1])["data"] as! PaymentScetionInfoClass).isExpanded
        self.editPaymentsTableView.reloadData()
    }
}
