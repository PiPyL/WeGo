//
//  AddressVC.swift
//  WeGo
//
//  Created by PiPyL on 6/5/19.
//  Copyright © 2019 PiPyL. All rights reserved.
//

import UIKit
import Material
import DropDown

class AddressVC: UIViewController {

    @IBOutlet weak var provinceTF: TextField!
    @IBOutlet weak var districtTF: TextField!
    @IBOutlet weak var detailAddressTF: TextField!
    @IBOutlet weak var provinceButton: UIButton!
    @IBOutlet weak var districtButton: UIButton!
    
    var didAddAddress: ((_ address: Address)->Void)?
    
    let provinceDropDown = DropDown()
    let districtDropDown = DropDown()
    
    var provinceModel: ProvinceModel?
    var districtModel: DistrictModel?
    
    var nameVC = ""

    //MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    //MARK: - Action
    
    private func setupData() {
        if HandleDataController.sharedInstance.provincesArray.count == 0 {
            HandleDataController.sharedInstance.loadDataLocation()
        }
        setupProvinceDropDown()
        setupDistrictDropDown()
    }
    
    @IBAction func didClickProvince(_ sender: Any) {
        provinceDropDown.show()
    }
    
    @IBAction func didClickDistrict(_ sender: Any) {
        if (provinceTF.hasText)  {
            districtDropDown.show()
        }
    }
    
    @IBAction func didClickConfirm(_ sender: Any) {
        if nameVC == "ListPostsVC" {
            if provinceTF.hasText && districtTF.hasText {
                setupAddressVC()
            } else {
                AlertController.showAlertController(title: "Thông báo", message: "Vui lòng nhập đầy đủ thông tin", nil)
            }
        } else {
            if provinceTF.hasText && districtTF.hasText && detailAddressTF.hasText {
                setupAddressVC()
            } else {
                AlertController.showAlertController(title: "Thông báo", message: "Vui lòng nhập đầy đủ thông tin", nil)
            }
        }
    }
    
    private func setupAddressVC() {
        let address = Address()
        address.detail = detailAddressTF.text
        address.province = Int(provinceModel!.code)
        address.district = Int(districtModel!.code)
        address.districtName = districtModel?.name
        address.provinceName = provinceModel?.name
        self.didAddAddress?(address)
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: -  Setup data dropdown
    
    func setupProvinceDropDown() {
        
        provinceDropDown.anchorView = provinceButton
        provinceDropDown.bottomOffset = CGPoint(x: 0, y: provinceButton.bounds.height)
        
        provinceDropDown.dataSource = HandleDataController.sharedInstance.getAllNameProvinces()
        
        provinceDropDown.selectionAction = { [weak self] (index, item) in
            self?.districtTF.text = ""
            self?.provinceTF.text = item
            
            if let provinceSelected: ProvinceModel = HandleDataController.sharedInstance.getProvinceWithName(name: (self?.provinceTF.text)!) {
                self?.districtDropDown.dataSource = HandleDataController.sharedInstance.getAllNameDistrictsByProvince(provinceCode: provinceSelected.code)
                self?.provinceModel = provinceSelected
            }
        }
    }
    
    func setupDistrictDropDown() {
        
        districtDropDown.anchorView = districtButton
        districtDropDown.bottomOffset = CGPoint(x: 0, y: districtButton.bounds.height)
        
        districtDropDown.selectionAction = { [weak self] (index, item) in
            self?.districtTF.text = item
            self?.districtModel = HandleDataController.sharedInstance.getDistrictWithName(name: item)
        }
    }
}
