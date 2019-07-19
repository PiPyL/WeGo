//
//  LoginVC.swift
//  WeGo
//
//  Created by PiPyL on 6/5/19.
//  Copyright © 2019 PiPyL. All rights reserved.
//

import UIKit
import Material
import Firebase
import FirebaseAuth
import SVProgressHUD

class LoginVC: UIViewController {

    @IBOutlet weak var heightContraintView: NSLayoutConstraint!
    @IBOutlet weak var emailTF: TextField!
    @IBOutlet weak var passwordTF: TextField!
    
    //MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
    }

    //MARK: - Action
    
    private func setupData() {
//        heightContraintView.constant = UIScreen.main.bounds.size.height
    }
    
    @IBAction func didClickLogin(_ sender: Any) {
        SVProgressHUD.show()
        Auth.auth().signIn(withEmail: emailTF.text!, password: passwordTF.text!) { [weak self] user, error in
            if let error = error {
                SVProgressHUD.dismiss()
                DispatchQueue.main.async {
                    AlertController.showAlertController(title: "Thông báo", message: error.localizedDescription, nil)
                }
            } else {
                self?.fetchUserInfo(email: (self?.emailTF.text!.replacingOccurrences(of: ".", with: "_"))!)
            }
        }
    }
    
    @IBAction func didClickRegister(_ sender: Any) {
    }
    
    @IBAction func didClickForgetPassword(_ sender: Any) {
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
        
        if !passwordTF.hasText {
            AlertController.showAlertController(title: "Thông báo", message: "Vui lòng nhập mật khẩu", nil)
            return false
        }
        
        return true
    }
    
    private func fetchUserInfo(email: String) {
//        SVProgressHUD.show()
        UserModel.sharedInstance.fetchAUser(email: email) { [weak self] (userModel, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                DispatchQueue.main.async {
                    AlertController.showAlertController(title: "Thông báo", message: error.localizedDescription, nil)
                }
            } else {
                AppDataSingleton.sharedInstance.currentUser = userModel
                AppDataSingleton.sharedInstance.startAddressDefault = userModel?.address
                DispatchQueue.main.async {
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window!.rootViewController = UIStoryboard.mainStoryboard().instantiateInitialViewController()
                    appDelegate.window!.makeKeyAndVisible()
                }
            }
        }
    }
}
