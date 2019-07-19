//
//  MyTopicsVC.swift
//  WeGo
//
//  Created by PiPyL on 6/7/19.
//  Copyright © 2019 PiPyL. All rights reserved.
//

import UIKit
import SVProgressHUD

class MyFavoriteVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var myTopics = [Topic]()
    var myTopicsRef: [String]?
    var myTopicsFavoriteRef: [String]?
    var emptyLabel = UILabel()
    var isChanged = false
    
    //MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        fetchAllMyTopic()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isChanged {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "didUpdateMyFavorite"), object: nil)
        }
    }
    
    //MARK: - Action
    
    private func setupData() {
        tableView.delegate = self
        tableView.dataSource = self
        setupEmptyLabel()
    }
    
    private func setupEmptyLabel() {
        emptyLabel.frame = CGRect(x: 0, y: 170, width: UIScreen.main.bounds.size.width, height: 21)
        emptyLabel.text = ""
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .gray
        self.view.addSubview(emptyLabel)
    }
    
    private func fetchAllMyTopic() {
        if let topics = AppDataSingleton.sharedInstance.currentUser?.favorite {
            if topics.count > 0 {
                myTopicsRef = topics
                myTopicsFavoriteRef = topics
                fetchTopic(topicRef: myTopicsRef![0])
            } else {
                emptyLabel.isHidden = false
                emptyLabel.text = "Không có bài đăng nào đã lưu :)"
            }
        } else {
            emptyLabel.isHidden = false
            emptyLabel.text = "Không có bài đăng nào đã lưu :)"
        }
    }
    
    //MARK: - API
    
    private func fetchTopic(topicRef: String) {
        SVProgressHUD.show()
        Topic.sharedInstance.fetchATopic(refTopic: topicRef) { [weak self] (topic, error) in
            if error != nil {
                SVProgressHUD.dismiss()
                AlertController.showAlertController(title: "Thông báo", message: "Lỗi khi lấy bài đăng đã lưu", nil)
            } else {
                self?.myTopics.append(topic!)
                
                if self?.myTopicsRef != nil {
                    self?.myTopicsRef?.remove(at: 0)
                    if (self?.myTopicsRef?.count)! > 0 {
                        self?.fetchTopic(topicRef: (self?.myTopicsRef?[0])!)
                    } else {
                        SVProgressHUD.dismiss()
                        DispatchQueue.main.async {
                            if let topics = self?.myTopics {
                                if topics.count > 0 {
                                    self?.emptyLabel.text = ""
                                    self?.emptyLabel.isHidden = true
                                } else {
                                    self?.emptyLabel.isHidden = false
                                    self?.emptyLabel.text = "Không có bài đăng nào đã lưu :)"
                                }
                            }
                            self?.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    private func deleteTopicInFavotive(topic: Topic) {
        
        if let user = AppDataSingleton.sharedInstance.currentUser, var favorite = user.favorite {
            for refTopic in favorite {
                if refTopic == topic.getRefTopic() {
                    let index = favorite.index(of: refTopic)
                    favorite.remove(at: index!)
                    user.favorite = favorite
                    user.saveUser { [weak self] (error) in
                        if error != nil {
                            AlertController.showAlertController(title: "Thông báo", message: "Lỗi khi xóa bài đăng đã lưu", nil)
                        } else {
                            self?.isChanged = true
                            let index = self?.myTopics.index(of: topic)
                            self?.myTopics.remove(at: index!)
                            let indexRef = self?.myTopicsFavoriteRef?.index(of: topic.getRefTopic())
                            self?.myTopicsFavoriteRef?.remove(at: indexRef!)
                            AppDataSingleton.sharedInstance.currentUser = user
                            DispatchQueue.main.async {
                                if self?.myTopics.count == 0 {
                                    self?.emptyLabel.isHidden = false
                                    self?.emptyLabel.text = "Không có bài đăng nào đã lưu :)"
                                }
                                self?.tableView.reloadData()
                            }
                        }
                    }
                    break
                }
            }
        }
    }
}

extension MyFavoriteVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myTopics.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 169
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let topic = myTopics[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteTopicCell", for: indexPath) as! FavoriteTopicCell
        cell.setupData(topic: topic)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let topic = myTopics[indexPath.row]
        let postDetailVC = UIStoryboard.mainStoryboard().instantiateViewController(withIdentifier: "PostDetailVC") as! PostDetailVC
        postDetailVC.topicGet = topic
        self.navigationController!.pushViewController(postDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let topic = myTopics[indexPath.row]
        if (editingStyle == .delete) {
            deleteTopicInFavotive(topic: topic)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Xóa"
    }
}

class FavoriteTopicCell: UITableViewCell {
    
    @IBOutlet weak var bossLabel: UILabel!
    @IBOutlet weak var timeStartLabel: UILabel!
    @IBOutlet weak var addressEndLabel: UILabel!
    @IBOutlet weak var addressStartLabel: UILabel!
    
    //MARK: - Lifecyle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK: - Action
    
    func setupData(topic: Topic) {
        bossLabel.text = topic.bossName
        addressEndLabel.text = topic.addressEnd.detail + ", " + topic.addressEnd.districtName + ", " + topic.addressEnd.provinceName
        addressStartLabel.text = topic.addressStart.detail + ", " + topic.addressStart.districtName + ", " + topic.addressStart.provinceName
        timeStartLabel.text = HandleDataController.sharedInstance.getDateFromTimeStamp(timeStamp: topic.timeStart)
    }
}
