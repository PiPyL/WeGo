//
//  ListPostsVC.swift
//  WeGo
//
//  Created by PiPyL on 6/4/19.
//  Copyright © 2019 PiPyL. All rights reserved.
//

import UIKit
import DropDown
import SVProgressHUD

class ListPostsVC: UIViewController {
    
    @IBOutlet weak var heightConstraintViewSearch: NSLayoutConstraint!
    @IBOutlet weak var heightConstraintViewStartAdress: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var provinceButton: UIButton!
    @IBOutlet weak var districtButton: UIButton!
    @IBOutlet weak var provinceNameLabel: UILabel!
    @IBOutlet weak var districtNameLabel: UILabel!
    @IBOutlet weak var provinceStartButton: UIButton!
    @IBOutlet weak var districtStartButton: UIButton!
    @IBOutlet weak var provinceStartLabel: UILabel!
    @IBOutlet weak var districtStartLabel: UILabel!
    
    let provinceDropDown = DropDown()
    let districtDropDown = DropDown()
    var provinceModel: ProvinceModel?
    var districtModel: DistrictModel?
    
    let provinceStartDropDown = DropDown()
    let districtStartDropDown = DropDown()
    var provinceStartModel: ProvinceModel?
    var districtStartModel: DistrictModel?

    var topicsByAddress = [Topic]()
    var endAddressCurrent: Address?
    var startAddressCurrent: Address?
    var searchType = ""
    var emptyLabel = UILabel()
    
    //MARK: - View LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        registerNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    deinit {
        removeObserver()
    }

    //MARK: - Action
    
    private func setupData() {
        self.navigationItem.title = "Trang Chủ"
        tableView.delegate = self
        tableView.dataSource = self
        if HandleDataController.sharedInstance.provincesArray.count == 0 {
            HandleDataController.sharedInstance.loadDataLocation()
        }
        setupProvinceDropDown()
        setupDistrictDropDown()
        setupDistrictStartDropDown()
        setupProvinceStartDropDown()
        provinceNameLabel.text = "Chọn tỉnh/thành phố"
        districtNameLabel.text = "Chọn quận/huyện"
        
        searchType = "endType"
        heightConstraintViewSearch.constant = 180
        heightConstraintViewStartAdress.constant = 0
        
        if let endAddress = AppDataSingleton.sharedInstance.endAddressDefault {
            endAddressCurrent = endAddress
            districtDropDown.dataSource = HandleDataController.sharedInstance.getAllNameDistrictsByProvince(provinceCode: String(endAddress.province))
            provinceModel = HandleDataController.sharedInstance.getProvinceWithName(name: endAddressCurrent!.provinceName)
            searchTopicByAddress(endAddress: endAddress)
        } else {
            AlertController.showAlertController(title: "Thông báo", message: "Vui lòng chọn địa điểm mà bạn muốn đến và bấm nút tìm kiếm", nil)
        }
        
        if let startAddress = AppDataSingleton.sharedInstance.startAddressDefault {
            startAddressCurrent = startAddress
            provinceStartLabel.text = startAddress.provinceName
            districtStartLabel.text = startAddress.districtName
            districtStartDropDown.dataSource = HandleDataController.sharedInstance.getAllNameDistrictsByProvince(provinceCode: String(startAddress.province))
            provinceStartModel = HandleDataController.sharedInstance.getProvinceWithName(name: startAddress.provinceName)
        }
        
        setupEmptyLabel()
    }
    
    private func setupEmptyLabel() {
        emptyLabel.frame = CGRect(x: 0, y: 335, width: UIScreen.main.bounds.size.width, height: 21)
        emptyLabel.text = ""
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .gray
        self.view.addSubview(emptyLabel)
    }
    
    private func searchTopicByAddress(endAddress: Address) {
        provinceNameLabel.text = endAddress.provinceName
        districtNameLabel.text = endAddress.districtName
        
        fetchTopicsByEndAddress(provinceCode: String(endAddress.province), districtCode: String(endAddress.district))
    }
    
    private func setupAcionSheetSearch() {
        let optionMenu = UIAlertController(title: nil, message: "Tìm kiếm", preferredStyle: .actionSheet)
        
        let endAction = UIAlertAction(title: "Theo địa điểm đến", style: .default) { [weak self] (action) in
            self?.searchType = "endType"
                self?.heightConstraintViewSearch.constant = 180
                self?.heightConstraintViewStartAdress.constant = 0
        }
        let allAction = UIAlertAction(title: "Theo địa điểm đến và địa điểm xuất phát", style: .default) { [weak self] (action) in
            self?.searchType = "bothType"
                self?.heightConstraintViewSearch.constant = 139
                self?.heightConstraintViewStartAdress.constant = 146
        }
        
        let cancelAction = UIAlertAction(title: "Hủy", style: .cancel)
        
        optionMenu.addAction(endAction)
        optionMenu.addAction(allAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    private func setupAcionSheetFilter() {
        let optionMenu = UIAlertController(title: nil, message: "Lọc", preferredStyle: .actionSheet)
        
        let endAction = UIAlertAction(title: "Theo thời gian đăng", style: .default) { [weak self] (action) in
            self?.filterTopicsByTimeCreate()
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        let allAction = UIAlertAction(title: "Theo thời gian xuất phát", style: .default) { [weak self] (action) in
            self?.filterTopicsByTimeStart()
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Hủy", style: .cancel)
        
        optionMenu.addAction(endAction)
        optionMenu.addAction(allAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func selectProvince(_ sender: Any) {
        provinceDropDown.show()
    }
    
    @IBAction func selectDistrict(_ sender: Any) {
        if (provinceNameLabel.text != "Chọn tỉnh/thành phố" || provinceNameLabel.text != "")  {
            districtDropDown.show()
        }
    }
    
    @IBAction func didClickSearch(_ sender: Any) {
        if searchType == "endType" {
            if heightConstraintViewSearch.constant == 0 {
                heightConstraintViewSearch.constant = 180
            } else {
                heightConstraintViewSearch.constant = 0
            }
        } else {
            if heightConstraintViewStartAdress.constant == 0 {
                heightConstraintViewSearch.constant = 139
                heightConstraintViewStartAdress.constant = 146
            } else {
                heightConstraintViewSearch.constant = 0
                heightConstraintViewStartAdress.constant = 0
            }
        }
    }
    
    @IBAction func didClickSearchByEndAddress(_ sender: Any) {
        if let address = endAddressCurrent {
            fetchTopicsByEndAddress(provinceCode: String(address.province), districtCode: String(address.district))
        }
    }
    
    @IBAction func didClickSearchByBothAddress(_ sender: Any) {
        if let endAddress = endAddressCurrent, let startAddress = startAddressCurrent {
            fetchTopicsByBothAddress(provinceCode: String(endAddress.province), districtCode: String(endAddress.district), districtStartCode: String(startAddress.district))
        }
    }
    
    @IBAction func didClickProvinceStartAddress(_ sender: Any) {
        provinceStartDropDown.show()
    }
    
    @IBAction func didClickDistrictStartAddress(_ sender: Any) {
        if (provinceStartLabel.text != "Chọn tỉnh/thành phố" || provinceStartLabel.text != "")  {
            districtStartDropDown.show()
        }
    }
    
    @IBAction func didClickOptionSearch(_ sender: Any) {
        setupAcionSheetSearch()
    }
    
    @IBAction func didClickFilter(_ sender: Any) {
        setupAcionSheetFilter()
    }
    
    //MARK: -  Setup data dropdown
    
    func setupProvinceDropDown() {
        
        provinceDropDown.anchorView = provinceButton
        provinceDropDown.bottomOffset = CGPoint(x: 0, y: provinceButton.bounds.height)
        
        provinceDropDown.dataSource = HandleDataController.sharedInstance.getAllNameProvinces()
        
        provinceDropDown.selectionAction = { [weak self] (index, item) in
            
            self?.districtNameLabel.text = "Chọn quận/huyện"
            self?.districtModel = nil
            self?.endAddressCurrent = nil
            self?.provinceNameLabel.text = item
            
            if let provinceSelected: ProvinceModel = HandleDataController.sharedInstance.getProvinceWithName(name: (self?.provinceNameLabel.text)!) {
                self?.provinceModel = provinceSelected
                self?.districtDropDown.dataSource = HandleDataController.sharedInstance.getAllNameDistrictsByProvince(provinceCode: provinceSelected.code)
            }
        }
    }
    
    func setupDistrictDropDown() {

        districtDropDown.anchorView = districtButton
        districtDropDown.bottomOffset = CGPoint(x: 0, y: districtButton.bounds.height)
        
        districtDropDown.selectionAction = { [weak self] (index, item) in
            self?.districtNameLabel.text = item
            self?.districtModel = HandleDataController.sharedInstance.getDistrictWithName(name: item)
            
            if let district = self?.districtModel, let province = self?.provinceModel {
                
                let endAddress = Address()
                endAddress.detail = ""
                endAddress.district = Int(district.code)
                endAddress.province = Int(province.code)
                endAddress.districtName = district.name
                endAddress.provinceName = province.name
                
                AppDataSingleton.sharedInstance.endAddressDefault = endAddress
                self?.endAddressCurrent = endAddress
            }
        }
    }
    
    func setupProvinceStartDropDown() {
        
        provinceStartDropDown.anchorView = provinceStartButton
        provinceStartDropDown.bottomOffset = CGPoint(x: 0, y: provinceButton.bounds.height)
        
        provinceStartDropDown.dataSource = HandleDataController.sharedInstance.getAllNameProvinces()
        
        provinceStartDropDown.selectionAction = { [weak self] (index, item) in
            self?.districtStartLabel.text = "Chọn quận/huyện"
            self?.districtStartModel = nil
            self?.startAddressCurrent = nil
            self?.provinceStartLabel.text = item
            
            if let provinceSelected: ProvinceModel = HandleDataController.sharedInstance.getProvinceWithName(name: (self?.provinceStartLabel.text)!) {
                self?.provinceStartModel = provinceSelected
                self?.districtStartDropDown.dataSource = HandleDataController.sharedInstance.getAllNameDistrictsByProvince(provinceCode: provinceSelected.code)
            }
        }
    }
    
    func setupDistrictStartDropDown() {
        
        districtStartDropDown.anchorView = districtStartButton
        districtStartDropDown.bottomOffset = CGPoint(x: 0, y: districtStartButton.bounds.height)
        
        districtStartDropDown.selectionAction = { [weak self] (index, item) in
            self?.districtStartLabel.text = item
            self?.districtStartModel = HandleDataController.sharedInstance.getDistrictWithName(name: item)
            
            if let district = self?.districtStartModel, let province = self?.provinceStartModel {
                
                let startAddress = Address()
                startAddress.detail = ""
                startAddress.district = Int(district.code)
                startAddress.province = Int(province.code)
                startAddress.districtName = district.name
                startAddress.provinceName = province.name
                
                AppDataSingleton.sharedInstance.startAddressDefault = startAddress
                self?.startAddressCurrent = startAddress
            }
        }
    }

//MARK: - API

    private func fetchTopicsByEndAddress(provinceCode: String, districtCode: String) {
        SVProgressHUD.show()
        Topic.sharedInstance.fetchTopicsByAddress(provinceCode: provinceCode, districtCode: districtCode) { [weak self] (topics, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                DispatchQueue.main.async {
                    AlertController.showAlertController(title: "Thông báo", message: error.localizedDescription, nil)
                }
            } else {
                self?.topicsByAddress = topics!
                if topics!.count > 0 {
                    self?.filterTopicsByTimeCreate()
                }
                DispatchQueue.main.async {
                    if topics!.count > 0 {
                        self?.emptyLabel.isHidden = true
                    } else {
                        self?.emptyLabel.text = "Không tìm thấy bài đăng nào :I"
                        self?.emptyLabel.isHidden = false
                    }
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    private func fetchTopicsByBothAddress(provinceCode: String, districtCode: String, districtStartCode: String) {
        SVProgressHUD.show()
        Topic.sharedInstance.fetchTopicsByBothAddress(provinceCode: provinceCode, districtCode: districtCode, districtStartCode: districtStartCode) { [weak self] (topics, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                DispatchQueue.main.async {
                    AlertController.showAlertController(title: "Thông báo", message: error.localizedDescription, nil)
                }
            } else {
                self?.topicsByAddress = topics!
                if topics!.count > 0 {
                    self?.filterTopicsByTimeCreate()
                }
                DispatchQueue.main.async {
                    if topics!.count > 0 {
                        self?.emptyLabel.isHidden = true
                    } else {
                        self?.emptyLabel.text = "Không tìm thấy bài đăng nào :I"
                        self?.emptyLabel.isHidden = false
                    }
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    private func filterTopicsByTimeCreate() {
        var topicsShow = [Topic]()
        for topic in topicsByAddress {
            if topic.status == "Hiển thị" {
                topicsShow.append(topic)
            }
        }
        topicsByAddress = topicsShow.sorted { $0.timeCreate > $1.timeCreate }
    }
    
    private func filterTopicsByTimeStart() {
        topicsByAddress = topicsByAddress.sorted { $0.timeStart < $1.timeStart }
    }
    
    @objc private func didUpdateMyFavorite() {
        if self.searchType == "endType" {
            if let address = endAddressCurrent {
                fetchTopicsByEndAddress(provinceCode: String(address.province), districtCode: String(address.district))
            }
        } else {
            if let endAddress = endAddressCurrent, let startAddress = startAddressCurrent {
                fetchTopicsByBothAddress(provinceCode: String(endAddress.province), districtCode: String(endAddress.district), districtStartCode: String(startAddress.district))
            }
        }
    }
    
    //MARK: - Notification
    
    private func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateMyFavorite), name: NSNotification.Name(rawValue: "didUpdateMyFavorite"), object: nil)
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ListPostsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topicsByAddress.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 169
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let topic = topicsByAddress[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        cell.setupData(topic: topic)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let topic = topicsByAddress[indexPath.row]
        let postDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "PostDetailVC") as! PostDetailVC
        postDetailVC.topicGet = topic
        self.navigationController!.pushViewController(postDetailVC, animated: true)
    }
}

class PostCell: UITableViewCell {
    
    @IBOutlet weak var bossLabel: UILabel!
    @IBOutlet weak var timeStartLabel: UILabel!
    @IBOutlet weak var addressEndLabel: UILabel!
    @IBOutlet weak var addressStartLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var favoriteImageView: UIImageView!
    
    var isLiked = false
    var topicGet: Topic?
    
    //MARK: - Lifecyle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK: - Action
    
    func setupData(topic: Topic) {
        topicGet = topic
        bossLabel.text = topic.bossName
        addressEndLabel.text = topic.addressEnd.detail + ", " + topic.addressEnd.districtName + ", " + topic.addressEnd.provinceName
        addressStartLabel.text = topic.addressStart.detail + ", " + topic.addressStart.districtName + ", " + topic.addressStart.provinceName
        timeStartLabel.text = HandleDataController.sharedInstance.getDateFromTimeStamp(timeStamp: topic.timeStart)
        setupFavorite(topic: topic)
    }
    
    private func setupFavorite(topic: Topic) {
        if let user = AppDataSingleton.sharedInstance.currentUser, let favorite = user.favorite {
            for favo in favorite {
                if topic.getRefTopic() == favo {
                    favoriteImageView.image = UIImage.init(named: "ic_like")
                    isLiked = true
                    return
                }
            }
            favoriteImageView.image = UIImage.init(named: "ic_dont_like")
            isLiked = false
        }
    }
    
    @IBAction func didClickFavorite(_ sender: Any) {
        if let user = AppDataSingleton.sharedInstance.currentUser, let topic = topicGet {
            var favoriteNew = [String]()
            if (user.favorite != nil) {
                favoriteNew = user.favorite
            }
            
            if isLiked {
                if let index = favoriteNew.index(of: topic.getRefTopic()) {
                    favoriteNew.remove(at: index)
                    user.favorite = favoriteNew
                    isLiked = !isLiked
                } else {
                    return
                }
            } else {
                favoriteNew.append(topic.getRefTopic())
                isLiked = !isLiked
            }
            user.favorite = favoriteNew
            user.saveUser { [weak self] (error) in
                if error != nil {
                    DispatchQueue.main.async {
                        AlertController.showAlertController(title: "Thông báo", message: "Lỗi khi like bài đăng", nil)
                    }
                } else {
                    if (self?.isLiked)! {
                        self?.favoriteImageView.image = UIImage.init(named: "ic_like")
                    } else {
                        self?.favoriteImageView.image = UIImage.init(named: "ic_dont_like")
                    }
                    AppDataSingleton.sharedInstance.currentUser = user
                }
            }
        }
    }
}

