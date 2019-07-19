//
//  EditTopicVC.swift
//  WeGo
//
//  Created by PiPyL on 6/10/19.
//  Copyright © 2019 PiPyL. All rights reserved.
//

import UIKit
import Material
import DatePickerDialog
import Firebase
import FirebaseAuth

class EditTopicVC: UIViewController {

    @IBOutlet weak var endAddressTF: TextField!
    @IBOutlet weak var startAddressTF: TextField!
    @IBOutlet weak var startTimeTF: TextField!
    @IBOutlet weak var infoTF: TextField!
    @IBOutlet weak var statusLabel: UILabel!
    
    var didUpdateTopic: (()->Void)?
    
    var topicGet: Topic?
    var keyTopicOld: String?
    
    //MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
    }
    
    //MARK: - Action
    
    private func setupData() {
        if let topic = topicGet {
            keyTopicOld = String(topic.addressEnd.province) + "/" + String(topic.addressEnd.district) + "/" + topic.bossEmail.replacingOccurrences(of: ".", with: "_") + String(topic.timeCreate)
            
            endAddressTF.text = topic.addressEnd.getFullAddress()
            startAddressTF.text = topic.addressStart.getFullAddress()
            infoTF.text = topic.note != nil ? topic.note : ""
            startTimeTF.text = HandleDataController.sharedInstance.getDateFromTimeStamp(timeStamp: topic.timeStart)
            statusLabel.text = topic.status
        }
    }

    @IBAction func didClickUpdate(_ sender: Any) {
        
        if let topic = topicGet, let key = keyTopicOld {
            topic.note = infoTF.text
            
            topic.updateTopic(provinceCode: String(topic.addressEnd.province), districtCode: String(topic.addressStart.district), keyTopicOld: key) { [weak self] (error) in
                if error != nil {
                    AlertController.showAlertController(title: "Thông báo", message: "Lỗi khi cập nhật bài đăng", nil)
                } else {
                    self?.didUpdateTopic?()
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    @IBAction func didClickDelete(_ sender: Any) {
        AlertController.showOptionAlertController(title: "Thông báo", message: "Bạn có muốn xóa bài đăng này!") { [weak self] (alert, action) in
            self?.deleteTopic()
        }
    }
    
    @IBAction func didClickChangeStatus(_ sender: Any) {
        setupAcionSheetStatus()
    }
    
    @IBAction func didClickEndAddress(_ sender: Any) {
//        let addressVC = UIStoryboard.authenticationStoryboard().instantiateViewController(withIdentifier: "AddressVC") as! AddressVC
//        addressVC.didAddAddress = { [weak self] (address) in
//            if self?.topicGet != nil {
//                self?.topicGet?.addressEnd = address
//            }
//            self?.endAddressTF.text = address.detail + ", " + address.districtName + ", " + address.provinceName
//        }
//        self.navigationController?.pushViewController(addressVC, animated: true)
    }
    
    @IBAction func didClickStartAddress(_ sender: Any) {
        let addressVC = UIStoryboard.authenticationStoryboard().instantiateViewController(withIdentifier: "AddressVC") as! AddressVC
        addressVC.didAddAddress = { [weak self] (address) in
            if self?.topicGet != nil {
                self?.topicGet?.addressStart = address
            }
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
                                
                                if self?.topicGet != nil {
                                    self?.topicGet!.timeStart = dt.getTimeStampFromDate()
                                }
                            }
        }
    }
    
    private func setupAcionSheetStatus() {
        let optionMenu = UIAlertController(title: nil, message: "Trạng thái", preferredStyle: .actionSheet)
        
        let endAction = UIAlertAction(title: "Hiển thị", style: .default) { [weak self] (action) in
            self?.statusLabel.text = "Hiển thị"
            self?.topicGet?.status = "Hiển thị"
        }
        let allAction = UIAlertAction(title: "Ẩn", style: .default) { [weak self] (action) in
            self?.statusLabel.text = "Ẩn"
            self?.topicGet?.status = "Ẩn"
        }
        
        let cancelAction = UIAlertAction(title: "Hủy", style: .cancel)
        
        optionMenu.addAction(endAction)
        optionMenu.addAction(allAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    private func deleteTopic() {
        if let topic = topicGet, let key = keyTopicOld {
            topic.deleteTopic(keyTopic: key) { [weak self] (error) in
                if error != nil {
                    AlertController.showAlertController(title: "Thông báo", message: "Lỗi khi xóa bài đăng", nil)
                } else {
                    self?.deleteRefTopic()
                }
            }
        }
    }
    
    private func deleteRefTopic() {
        if let user = AppDataSingleton.sharedInstance.currentUser, var topics = user.topics, let key = keyTopicOld {
            var i = 0
            for topic in topics {
                if topic == key {
                    topics.remove(at: i)
                    break
                }
                i = i+1
            }
            user.topics = topics
            user.saveUser { [weak self] (error) in
                if error == nil {
                    AlertController.showAlertController(title: "Thông báo", message: "Lỗi khi xóa ref topic", nil)
                    self?.didUpdateTopic?()
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
