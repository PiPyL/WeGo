//
//  AccountVC.swift
//  WeGo
//
//  Created by PiPyL on 6/7/19.
//  Copyright © 2019 PiPyL. All rights reserved.
//

import UIKit
import DatePickerDialog
import Photos
import Firebase
import CoreLocation
import SDWebImage

class AccountVC: UITableViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var fbLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    
    var userUpdate: UserModel?
    let imagePicker = UIImagePickerController()

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
        
        self.imagePicker.delegate = self

        if let user = AppDataSingleton.sharedInstance.currentUser {
            nameLabel.text = user.name
            phoneLabel.text = user.phone
            emailLabel.text = user.email
            addressLabel.text = user.getAddressDetail()
            fbLabel.text = user.facebook != nil ? user.facebook : "Cập nhật facebook"
            birthdayLabel.text = user.birthday != nil ? HandleDataController.sharedInstance.getDateFromTimeStamp(timeStamp: user.birthday
                , formatDate: "dd/MM/yyyy") : "Cập nhật ngày sinh"
            userUpdate = user
            if let avatar = user.avatar, let url = URL.init(string: avatar) {
                avatarImageView.sd_setImage(with: url, completed: nil)
            }
        }
    }
    
    private func setupUpdatePhoneNumber() {
        let alert = UIAlertController(title: "Số điện thoại", message: "", preferredStyle:
            UIAlertController.Style.alert)
        
        alert.addTextField(configurationHandler: phoneTFHandler)
        
        alert.addAction(UIAlertAction(title: "Xong", style: UIAlertAction.Style.default, handler: { [weak self] (UIAlertAction) in
            let firstTextField = alert.textFields![0] as UITextField
            if firstTextField.hasText {
                self?.phoneLabel.text = firstTextField.text
                self?.userUpdate?.phone = firstTextField.text
                self?.updateInfoUser()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Hủy", style: UIAlertAction.Style.cancel, handler:{ (UIAlertAction) in
            
        }))
        
        self.present(alert, animated: true, completion:nil)
    }
    
    private func phoneTFHandler(textField: UITextField!) {
        textField.keyboardType = .phonePad
    }
    
    private func setupUpdateFacebook() {
        let alert = UIAlertController(title: "Link Facebook", message: "Ví dụ: https://www.facebook.com/wego", preferredStyle:
            UIAlertController.Style.alert)
        
        alert.addTextField(configurationHandler: facebookTFHandler)
        
        alert.addAction(UIAlertAction(title: "Xong", style: UIAlertAction.Style.default, handler: { [weak self] (UIAlertAction) in
            let firstTextField = alert.textFields![0] as UITextField
            if firstTextField.hasText {
                self?.fbLabel.text = firstTextField.text
                self?.userUpdate?.facebook = firstTextField.text
                self?.updateInfoUser()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Hủy", style: UIAlertAction.Style.cancel, handler:{ (UIAlertAction) in
            
        }))
        
        self.present(alert, animated: true, completion:nil)
    }
    
    private func facebookTFHandler(textField: UITextField!) {
        textField.keyboardType = .default
    }
    
    private func setupSelectBirthday() {
        let currentDate = Date()
        var dateComponents = DateComponents()
        dateComponents.month = -1100
        let monthAgo = Calendar.current.date(byAdding: dateComponents, to: currentDate)
        
        let datePicker = DatePickerDialog(textColor: UIColor.init(hex: "007AFF"),
                                          buttonColor: UIColor.init(hex: "007AFF"),
                                          font: UIFont.boldSystemFont(ofSize: 15),
                                          locale:Locale.init(identifier: "vi_VN"),
                                          showCancelButton: true)
        datePicker.show("Ngày sinh",
                        doneButtonTitle: "Xong",
                        cancelButtonTitle: "Hủy",
                        minimumDate: monthAgo,
                        maximumDate: currentDate,
                        datePickerMode: .date) { [weak self] (date) in
                            if let dt = date {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "dd/MM/yyyy"
                                self?.birthdayLabel.text = formatter.string(from: dt)
                                self?.userUpdate?.birthday = dt.getTimeStampFromDate()
                                self?.updateInfoUser()
                            }
        }
    }
    
    private func setupUpdateAddress() {
        let addressVC = UIStoryboard.authenticationStoryboard().instantiateViewController(withIdentifier: "AddressVC") as! AddressVC
        addressVC.didAddAddress = { [weak self] (address) in
            self?.addressLabel.text = address.detail + ", " + address.districtName + ", "
            self?.addressLabel.text = (self?.addressLabel.text)! + address.provinceName
            self?.userUpdate?.address = address
            self?.updateInfoUser()
        }
        self.navigationController?.pushViewController(addressVC, animated: true)
    }
    
    private func setupManagerMyTopics() {
        let myTopicsVC = self.storyboard?.instantiateViewController(withIdentifier: "MyTopicsVC") as! MyTopicsVC
        self.navigationController?.pushViewController(myTopicsVC, animated: true)
    }
    
    private func updateInfoUser() {
        userUpdate?.saveUser(completionHandler: { [weak self] (error) in
            if error != nil {
                AlertController.showAlertController(title: "Thông báo", message: "Lỗi khi cập nhật thông tin", nil)
            } else {
                AppDataSingleton.sharedInstance.currentUser = self?.userUpdate
            }
        })
    }
    
    private func setupSignOut() {
        AppDataSingleton.sharedInstance.currentUser = nil
        AppDataSingleton.sharedInstance.endAddressDefault = nil
        AppDataSingleton.sharedInstance.startAddressDefault = nil
        let initialViewController = UIStoryboard.authenticationStoryboard().instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = initialViewController!
    }
    
    private func setupMyFavorite() {
        let myFavoriteVC = self.storyboard?.instantiateViewController(withIdentifier: "MyFavoriteVC") as! MyFavoriteVC
        self.navigationController?.pushViewController(myFavoriteVC, animated: true)
    }
    
    private func setupUpdateAvatar() {
        let optionMenu = UIAlertController(title: nil, message: "Avatar", preferredStyle: .actionSheet)
        
        let endAction = UIAlertAction(title: "Chụp ảnh", style: .default) { [weak self] (action) in
            self?.selectCamera()
        }
        let allAction = UIAlertAction(title: "Thư viện ảnh", style: .default) { [weak self] (action) in
            self?.selectGallery()
        }
        
        let cancelAction = UIAlertAction(title: "Hủy", style: .cancel)
        
        optionMenu.addAction(endAction)
        optionMenu.addAction(allAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    private func selectGallery() {
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == .authorized || status == .notDetermined) {
            self.imagePicker.sourceType = .savedPhotosAlbum;
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
    }
    
    private func selectCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if (status == .authorized || status == .notDetermined) {
            self.imagePicker.sourceType = .camera
            self.imagePicker.allowsEditing = false
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    //MARK: - TableView
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            setupUpdateAvatar()
            break
        case 1:
            setupUpdatePhoneNumber()
            break
        case 3:
            setupUpdateAddress()
            break
        case 4:
            setupSelectBirthday()
            break
        case 5:
            setupUpdateFacebook()
            break
        case 6:
            setupManagerMyTopics()
            break
        case 7:
            setupMyFavorite()
            break
        case 8:
            setupSignOut()
            break
        default:
            break
            
        }
    }
}

//MARK: - Image

extension AccountVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.editedImage] as? UIImage {
            uploadImage(pickedImage: pickedImage)
        } else {
            let pickedImage = info[.originalImage] as! UIImage
            uploadImage(pickedImage: pickedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func uploadImage(pickedImage: UIImage) {
        pickedImage.uploadAvatar { [weak self] (urlString, error) in
            if error == nil, let url = URL.init(string: urlString) {
                self?.avatarImageView.sd_setImage(with: url, completed: nil)
                if let user = AppDataSingleton.sharedInstance.currentUser {
                    user.avatar = urlString
                    AppDataSingleton.sharedInstance.currentUser = user
                    user.saveUser(completionHandler: { (error) in
                        if error != nil {
                            DispatchQueue.main.async {
                                AlertController.showAlertController(title: "Thông báo", message: "Lỗi khi lưu url avatar của người dùng", nil)
                            }
                        }
                    })
                }
            }
        }
    }
}
