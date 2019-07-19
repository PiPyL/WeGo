//
//  MyTopicsVC.swift
//  WeGo
//
//  Created by PiPyL on 6/7/19.
//  Copyright © 2019 PiPyL. All rights reserved.
//

import UIKit
import SVProgressHUD

class MyTopicsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var myTopics = [Topic]()
    var myTopicsRef: [String]?
    var emptyLabel = UILabel()

    //MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        fetchAllMyTopic()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
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
        if let topics = AppDataSingleton.sharedInstance.currentUser?.topics {
            if topics.count > 0 {
                myTopicsRef = topics
                fetchTopic(topicRef: myTopicsRef![0])
            } else {
                emptyLabel.isHidden = false
                emptyLabel.text = "Không tìm thấy bài đăng nào :I"
            }
        } else {
            emptyLabel.isHidden = false
            emptyLabel.text = "Không tìm thấy bài đăng nào :I"
        }
    }
    
    //MARK: - API
    
    private func fetchTopic(topicRef: String) {
        SVProgressHUD.show()
        Topic.sharedInstance.fetchATopic(refTopic: topicRef) { [weak self] (topic, error) in
            if error != nil {
                SVProgressHUD.dismiss()
                AlertController.showAlertController(title: "Thông báo", message: "Lỗi khi lấy bài đăng của bạn", nil)
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
                                    self?.emptyLabel.isHidden = true
                                    self?.emptyLabel.text = ""
                                } else {
                                    self?.emptyLabel.isHidden = false
                                    self?.emptyLabel.text = "Không tìm thấy bài đăng nào :I"
                                }
                            }
                            self?.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
}

extension MyTopicsVC: UITableViewDelegate, UITableViewDataSource {
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyTopicCell", for: indexPath) as! MyTopicCell
        cell.setupData(topic: topic)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let topic = myTopics[indexPath.row]
        let editTopicVC = self.storyboard?.instantiateViewController(withIdentifier: "EditTopicVC") as! EditTopicVC
        editTopicVC.topicGet = topic
        editTopicVC.didUpdateTopic = {
            self.tableView.reloadData()
        }
        self.navigationController!.pushViewController(editTopicVC, animated: true)
    }
}

class MyTopicCell: UITableViewCell {
    
    @IBOutlet weak var bossLabel: UILabel!
    @IBOutlet weak var timeStartLabel: UILabel!
    @IBOutlet weak var addressEndLabel: UILabel!
    @IBOutlet weak var addressStartLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    
    //MARK: - Lifecyle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupData(topic: Topic) {
        bossLabel.text = topic.bossName
        addressEndLabel.text = topic.addressEnd.detail + ", " + topic.addressEnd.districtName + ", " + topic.addressEnd.provinceName
        addressStartLabel.text = topic.addressStart.detail + ", " + topic.addressStart.districtName + ", " + topic.addressStart.provinceName
        timeStartLabel.text = HandleDataController.sharedInstance.getDateFromTimeStamp(timeStamp: topic.timeStart)
        if topic.status == "Ẩn" {
            statusImageView.isHidden = false
            statusImageView.image = UIImage.init(named: "ic_hide_blue")
        } else {
            statusImageView.isHidden = true
        }
    }
    
    //MARK: - Helper
    
    func setupDataForCell() {
    }
}
