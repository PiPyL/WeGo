//
//  PostDetailVC.swift
//  WeGo
//
//  Created by PiPyL on 6/4/19.
//  Copyright © 2019 PiPyL. All rights reserved.
//

import UIKit

class PostDetailVC: UIViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameBossLabel: UILabel!
    @IBOutlet weak var addressStartLabel: UILabel!
    @IBOutlet weak var addressEndLabel: UILabel!
    @IBOutlet weak var timeStartLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var timeCreateLabel: UILabel!

    var topicGet: Topic?
    
    //MARK: - View LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    //MARK: - Action
    
    private func setupData() {
        self.navigationItem.title = "Chi Tiết"
        
        if let topic = topicGet {
            setupDataWithTopic(topic: topic)
        }
    }
    
    func setupDataWithTopic(topic: Topic) {
        nameBossLabel.text = topic.bossName
        addressStartLabel.text = topic.addressStart.detail + ", " + topic.addressStart.districtName + ", " + topic.addressStart.provinceName
        addressEndLabel.text = topic.addressEnd.detail + ", " + topic.addressEnd.districtName + ", " + topic.addressEnd.provinceName
        timeCreateLabel.text = HandleDataController.sharedInstance.getDateFromTimeStamp(timeStamp: topic.timeStart)
        timeCreateLabel.text = HandleDataController.sharedInstance.getDateFromTimeStamp(timeStamp: topic.timeCreate)
        
        UserModel.sharedInstance.fetchAUser(email: topic.bossEmail.replacingOccurrences(of: ".", with: "_")) { [weak self] (user, error) in
            if let user = user, let avatar = user.avatar, let url = URL.init(string: avatar)  {
                DispatchQueue.main.async {
                    self?.avatarImageView.sd_setImage(with: url, completed: nil)
                }
            }
        }
    }
    
    @IBAction func didClickShowBossInfo(_ sender: Any) {
        if let topic = topicGet {
            let infoUserVC = self.storyboard?.instantiateViewController(withIdentifier: "InfoUserVC") as! InfoUserVC
            infoUserVC.emailUserGet = topic.bossEmail
            self.navigationController?.pushViewController(infoUserVC, animated: true)
        }
    }
    
    @IBAction func didClickShowAppleMaps(_ sender: Any) {
        
        if let topic = topicGet {
            var urlString = "http://maps.apple.com/?saddr=" + topic.addressStart.getFullAddress() + "&daddr=" + topic.addressEnd.getFullAddress()
            urlString = urlString.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!
            if let url = URL.init(string: urlString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}
