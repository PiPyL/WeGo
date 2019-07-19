//
//  RegisterVC.swift
//  WeGo
//
//  Created by PiPyL on 6/5/19.
//  Copyright © 2019 PiPyL. All rights reserved.
//

import UIKit
import Material
import Firebase
import FirebaseStorage
import FirebaseAuth
import SVProgressHUD

class RegisterVC: UIViewController {

    @IBOutlet weak var emailTF: TextField!
    @IBOutlet weak var passwordTF: TextField!
    @IBOutlet weak var confirmPassword: TextField!
    @IBOutlet weak var phoneTF: TextField!
    @IBOutlet weak var addressTF: TextField!
    @IBOutlet weak var nameTF: TextField!
    
    var addressGet: Address?
    
    //MARK: - View LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //MARK: - Action
    
    @IBAction func didClickRegister(_ sender: Any) {
        registerMethod()
    }
    
    @IBAction func didClickAddAddress(_ sender: Any) {
        let addressVC = self.storyboard?.instantiateViewController(withIdentifier: "AddressVC") as! AddressVC
        addressVC.didAddAddress = { [weak self] (address) in
            self?.addressGet = address
            self?.addressTF.text = address.detail + ", " + address.districtName + ", " + address.provinceName
        }
        self.navigationController?.pushViewController(addressVC, animated: true)
    }
    
    private func registerMethod() {
        if validateInfo() == false {
            return
        }
        let user = UserModel.init()
        SVProgressHUD.show()
        Auth.auth().createUser(withEmail: emailTF.text!, password: passwordTF.text!) { [weak self] (result, error) in
            SVProgressHUD.dismiss()
            if error == nil {
                user.email = self?.emailTF.text
                user.phone = self?.phoneTF.text
                user.name = self?.nameTF.text
                user.address = self?.addressGet
                user.saveUser(completionHandler: { (error) in
                    if error != nil {
                        AlertController.showAlertController(title: "Thông báo", message: error!.localizedDescription, nil)
                    } else {
                        AppDataSingleton.sharedInstance.currentUser = user
                        AppDataSingleton.sharedInstance.startAddressDefault = user.address
                        DispatchQueue.main.async {
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.window!.rootViewController = UIStoryboard.mainStoryboard().instantiateInitialViewController()
                            appDelegate.window!.makeKeyAndVisible()
                        }
                    }
                })
            } else {
                AlertController.showAlertController(title: "Notification", message: error?.localizedDescription ?? "Đã xảy ra lỗi vui lòng thử lại", nil)
            }
        }
    }
    
    private func validateInfo() -> Bool {
        if !emailTF.hasText {
            AlertController.showAlertController(title: "Thông báo", message: "Vui lòng nhập địa chỉ email", nil)
            return false
        }
        
        if emailTF.text?.isValidEmail() == false {
            AlertController.showAlertController(title: "Thông báo", message: "Địa chỉ email không đúng định dạng", nil)
            return false
        }
        
        if nameTF.text?.count == 0 {
            AlertController.showAlertController(title: "Thông báo", message: "Vui lòng nhập họ tên", nil)
            return false
        }
        
        if !passwordTF.hasText {
            AlertController.showAlertController(title: "Thông báo", message: "Vui lòng nhập mật khẩu", nil)
            return false
        }
        
        if !confirmPassword.hasText {
            AlertController.showAlertController(title: "Thông báo", message: "Vui lòng nhập mật khẩu xác nhận", nil)
            return false
        }
        
        if (passwordTF.text?.count)! < 6 {
            AlertController.showAlertController(title: "Thông báo", message: "Mật khẩu không được nhỏ hơn 6 kí tự", nil)
            return false
        }
        
        if (confirmPassword.text?.count)! < 6 {
            AlertController.showAlertController(title: "Thông báo", message: "Mật khẩu xác nhận không được nhỏ hơn 6 kí tự", nil)
            return false
        }
        
        if passwordTF.text != confirmPassword.text {
            AlertController.showAlertController(title: "Thông báo", message: "Mật khẩu xác nhận không chính xác", nil)
            return false
        }
        
        if !addressTF.hasText {
            AlertController.showAlertController(title: "Thông báo", message: "Vui lòng nhập họ tên", nil)
            return false
        }
        
        if !phoneTF.hasText {
            AlertController.showAlertController(title: "Thông báo", message: "Vui lòng nhập số điện thoại", nil)
            return false
        }
        
        if phoneTF.text?.count != 10 && phoneTF.text?.count != 11  {
            AlertController.showAlertController(title: "Thông báo", message: "Số điện thoại không đúng", nil)
            return false
        }
        
        return true
    }
}
