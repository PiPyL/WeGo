//
//  InfoUserVC.swift
//  WeGo
//
//  Created by PiPyL on 6/7/19.
//  Copyright © 2019 PiPyL. All rights reserved.
//

import UIKit

class InfoUserVC: UITableViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var fbLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    
    var emailUserGet: String?
    var userGet: UserModel?
    
    //MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchInfoUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    //MARK: - Action
    
    private func fetchInfoUser() {
        if let email = emailUserGet {
            UserModel.sharedInstance.fetchAUser(email: email.replacingOccurrences(of: ".", with: "_")) { [weak self] (user, error) in
                if error != nil {
                    AlertController.showAlertController(title: "Thông báo", message: "Lỗi khi lấy thông tin user", nil)
                } else {
                    self?.userGet = user
                    self?.setupInfoUser()
                }
            }
        }
    }
    
    private func setupInfoUser() {
        if let user = userGet {
            self.navigationItem.title = user.name
            phoneLabel.text = user.phone
            emailLabel.text = user.email
            addressLabel.text = user.getAddressDetail()
            fbLabel.text = user.facebook != nil ? user.facebook : ""
            birthdayLabel.text = user.birthday != nil ? HandleDataController.sharedInstance.getDateFromTimeStamp(timeStamp: user.birthday, formatDate: "dd/MM/yyyy") : ""
            if let avatar = user.avatar, let url = URL.init(string: avatar) {
                avatarImageView.sd_setImage(with: url, completed: nil)
            }
        }
    }
    
    @IBAction func didClickChat(_ sender: Any) {
        
        if let email = emailUserGet {
            if email == AppDataSingleton.sharedInstance.currentUser?.email {
                let listChatsVC = UIStoryboard.accountStoryboard().instantiateViewController(withIdentifier: "ListChatsVC") as! ListChatsVC
                self.navigationController?.pushViewController(listChatsVC, animated: true)
            } else {
                if let user = userGet {
                    let chatVC = UIStoryboard.accountStoryboard().instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
                    chatVC.receiverEmail = email.replacingOccurrences(of: ".", with: "_")
                    chatVC.refChatGet = getRefChat()
                    chatVC.guestUser = user
                    self.navigationController?.pushViewController(chatVC, animated: true)
                }
            }
        }
    }

    //MARK: - TableView

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    private func getRefChat() -> String? {
        if let chats = userGet?.chats, let user = AppDataSingleton.sharedInstance.currentUser {
            for ref in chats {
                if ref.contains((userGet?.getEmailRef())!) && ref.contains(user.getEmailRef()) {
                    return ref
                }
            }
            return (AppDataSingleton.sharedInstance.currentUser?.getEmailRef())! + "--" + (userGet?.getEmailRef())!
        }
        return (AppDataSingleton.sharedInstance.currentUser?.getEmailRef())! + "--" + (userGet?.getEmailRef())!
    }
}
