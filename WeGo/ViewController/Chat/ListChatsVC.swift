//
//  ListChatsVC.swift
//  WeGo
//
//  Created by PiPyL on 6/8/19.
//  Copyright © 2019 PiPyL. All rights reserved.
//

import UIKit
import SVProgressHUD

class ListChatsVC: UIViewController {

    var myDiscussion = [Discussion]()
    var myDiscussionsRef: [String]?
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
    }
    
    //MARK: - Action
    
    private func setupData() {
        fetchAllMyDiscussions()
        tableView.tableFooterView = UIView()
    }
    
    private func fetchAllMyDiscussions() {
        if let chats = AppDataSingleton.sharedInstance.currentUser?.chats {
            if chats.count > 0 {
                myDiscussionsRef = chats
                fetchDiscussion(chatRef: myDiscussionsRef![0])
            }
        }
    }
    
    //MARK: - API
    
    private func fetchDiscussion(chatRef: String) {
        SVProgressHUD.show()
        Discussion.sharedInstance.fetchADiscussion(refChat: chatRef) { [weak self] (discussion, error) in
            if error != nil {
                SVProgressHUD.dismiss()
                AlertController.showAlertController(title: "Thông báo", message: "Lỗi khi lấy bài đăng của bạn", nil)
            } else {
                self?.myDiscussion.append(discussion!)
                
                if self?.myDiscussionsRef != nil {
                    self?.myDiscussionsRef?.remove(at: 0)
                    if (self?.myDiscussionsRef?.count)! > 0 {
                        self?.fetchDiscussion(chatRef: (self?.myDiscussionsRef![0])!)
                    } else {
                        SVProgressHUD.dismiss()
                        DispatchQueue.main.async {
                            self?.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
}

extension ListChatsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myDiscussion.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListChatCell", for: indexPath) as! ListChatCell
        cell.setupData(discussion: myDiscussion[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        chatVC.refChatGet = myDiscussion[indexPath.row].chatID
        if myDiscussion[indexPath.row].users[0] != AppDataSingleton.sharedInstance.currentUser?.getEmailRef() {
            chatVC.receiverEmail = myDiscussion[indexPath.row].users[0]
        } else {
            chatVC.receiverEmail = myDiscussion[indexPath.row].users[1]
        }
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
}

class ListChatCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var discussionGet: Discussion?
    
    //MARK: - Lifecyle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK:- Action
    
    func setupData(discussion: Discussion) {
        if discussion.users[0] != AppDataSingleton.sharedInstance.currentUser?.getEmailRef() {
            fetchInfoUser(emailRef: discussion.users[0])
        } else {
            fetchInfoUser(emailRef: discussion.users[1])
        }
    }
    
    private func fetchInfoUser(emailRef: String) {
        UserModel.sharedInstance.fetchAUser(email: emailRef) { [weak self] (user, error) in
            if let user = user {
                DispatchQueue.main.async {
                    self?.nameLabel.text = user.name
                    if let avatar = user.avatar, let url = URL.init(string: avatar) {
                        self?.avatarImageView.sd_setImage(with: url, completed: nil)
                    }
                }
            }
        }
    }
    
}
