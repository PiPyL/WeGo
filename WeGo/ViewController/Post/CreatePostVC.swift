//
//  CreatePostVC.swift
//  WeGo
//
//  Created by PiPyL on 6/5/19.
//  Copyright © 2019 PiPyL. All rights reserved.
//

import UIKit
import Material
import DatePickerDialog
import Firebase
import FirebaseAuth

class CreatePostVC: UIViewController {

    @IBOutlet weak var endAddressTF: TextField!
    @IBOutlet weak var startAddressTF: TextField!
    @IBOutlet weak var startTimeTF: TextField!
    @IBOutlet weak var infoTF: TextField!
    
    var endAddressModel = Address()
    var startAddressModel = Address()
    var topicModel = Topic()
    
    //MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: - Action
    
    private func setupData() {
        self.navigationItem.title = "Đăng Bài Mới"
        if let user = AppDataSingleton.sharedInstance.currentUser {
            startAddressModel = user.address
        }
    }
    
    @IBAction func didClickEndAddress(_ sender: Any) {
        let addressVC = UIStoryboard.authenticationStoryboard().instantiateViewController(withIdentifier: "AddressVC") as! AddressVC
        addressVC.didAddAddress = { [weak self] (address) in
            self?.endAddressModel = address
            self?.endAddressTF.text = address.detail + ", " + address.districtName + ", " + address.provinceName
        }
        self.navigationController?.pushViewController(addressVC, animated: true)
    }
    
    @IBAction func didClickStartAddress(_ sender: Any) {
        let addressVC = UIStoryboard.authenticationStoryboard().instantiateViewController(withIdentifier: "AddressVC") as! AddressVC
        addressVC.didAddAddress = { [weak self] (address) in
            self?.startAddressModel = address
            self?.startAddressTF.text = address.detail + ", " + address.districtName + ", " + address.provinceName
        }
        self.navigationController?.pushViewController(addressVC, animated: true)
    }
    
    @IBAction func didClickSelectStartTime(_ sender: Any) {
        let currentDate = Date()
        var dateComponents = DateComponents()
        dateComponents.month = +2
        let threeMonthAgo = Calendar.current.date(byAdding: dateComponents, to: currentDate)
        
        let datePicker = DatePickerDialog(textColor: UIColor.init(hex: "007AFF"),
                                          buttonColor: UIColor.init(hex: "007AFF"),
                                          font: UIFont.boldSystemFont(ofSize: 15),
                                          locale:Locale.init(identifier: "vi_VN"),
                                          showCancelButton: true)
        datePicker.show("Thời gian xuất phát",
                        doneButtonTitle: "Xong",
                        cancelButtonTitle: "Hủy",
                        minimumDate: currentDate,
                        maximumDate: threeMonthAgo,
                        datePickerMode: .dateAndTime) { [weak self] (date) in
                            if let dt = date {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "HH:mm dd/MM/yyyy"
                                self?.startTimeTF.text = formatter.string(from: dt)
                                self?.topicModel.timeStart = dt.getTimeStampFromDate()
                                
                                let dateCreateStr = formatter.string(from: Date())
                                let dateCreate = formatter.date(from: dateCreateStr)
                                self?.topicModel.timeCreate = dateCreate?.getTimeStampFromDate()
                            }
        }
    }
    
    @IBAction func didClickCreate(_ sender: Any) {
        if validateInfo() == true {
            createTopic()
        }
    }
    
    private func validateInfo() -> Bool {
        if !endAddressTF.hasText {
            AlertController.showAlertController(title: "Thông báo", message: "Vui lòng nhập điểm đến", nil)
            return false
        }
        
        if !startAddressTF.hasText {
            AlertController.showAlertController(title: "Thông báo", message: "Vui lòng nhập điểm xuất phát", nil)
            return false
        }
        
        if !startTimeTF.hasText {
            AlertController.showAlertController(title: "Thông báo", message: "Vui lòng chọn thời gian xuất phát", nil)
            return false
        }
        
        return true
    }
    
    private func createTopic() {
        topicModel.addressStart = startAddressModel
        topicModel.addressEnd = endAddressModel
        topicModel.note = infoTF.text
        topicModel.saveTopic(provinceCode: String(endAddressModel.province), districtCode: String(endAddressModel.district), email: AppDataSingleton.sharedInstance.currentUser!.email) { [weak self] (error) in
            if let error = error {
                AlertController.showAlertController(title: "Thông báo", message: error.localizedDescription, nil)
            } else {
                self?.topicModel = Topic()
                self?.endAddressModel = Address()
                self?.startAddressModel = Address()
                self?.endAddressTF.text = ""
                self?.startTimeTF.text = ""
                self?.startAddressTF.text = ""
                self?.infoTF.text = ""
                self?.tabBarController?.selectedIndex = 0
            }
        }
    }
}
