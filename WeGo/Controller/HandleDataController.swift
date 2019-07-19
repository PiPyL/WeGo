//
//  HandleDataController.swift
//  WeGo
//
//  Created by PiPyL on 6/4/19.
//  Copyright © 2019 PiPyL. All rights reserved.
//

import UIKit

class HandleDataController: NSObject {

    static let sharedInstance = HandleDataController()
    var provinces = [String : AnyObject]()
    var districts = [String : AnyObject]()
    var provincesArray = [ProvinceModel]()
    var districtsArray = [DistrictModel]()
    var districtsAllArray = [DistrictModel]()
    var districtsByProvinceArray = [DistrictModel]()

    func loadDataLocation() {
        
        //load data provinces
        if let path = Bundle.main.path(forResource: "tinh_tp", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject> {
                    provinces = jsonResult
                    
                    for key in provinces.keys {
                        let province = ProvinceModel.init(fromDictionary: provinces[key] as! [String : Any])
                        provincesArray.append(province)
                    }
                    let arraySorted = provincesArray.sorted(by: {$0.code < $1.code})
                    provincesArray = arraySorted
                }
            } catch {
                
            }
        }
        
        //load data districts
        if let path = Bundle.main.path(forResource: "quan_huyen", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject> {
                    districts = jsonResult
                    
                    for key in districts.keys {
                        let district = DistrictModel.init(fromDictionary: districts[key] as! [String : Any])
                        districtsAllArray.append(district)
                    }
                }
            } catch {
                
            }
        }
    }
    
    //MARK: - District
    
    func getDistrictsByProvince(provinceCode: String) -> [DistrictModel] {
        var districtsArray = [DistrictModel]()
        for district in districtsAllArray {
            if Int(district.parentCode) == Int(provinceCode) {
                districtsArray.append(district)
            }
        }
        return districtsArray
    }
    
    func getAllNameDistrictsByProvince(provinceCode: String) -> [String] {
        var districtsName = [String]()
        districtsByProvinceArray.removeAll()
        for district in districtsAllArray {
            if Int(district.parentCode) == Int(provinceCode) {
                districtsName.append(district.name)
                districtsByProvinceArray.append(district)
            }
        }
        districtsName = districtsName.sorted(by: {$0 < $1})
        return districtsName
    }
    
    func getDistrictWithName(name: String) -> DistrictModel? {
        for district in districtsByProvinceArray {
            if district.name == name {
                return district
            }
        }
        return nil
    }
    
    func getDistrictWithCode(code: String) -> DistrictModel? {
        for district in districtsByProvinceArray {
            if Int(district.code) == Int(code) {
                return district
            }
        }
        return nil
    }
    
    //MARK: - Province
  
    func getAllNameProvinces() -> [String] {
        var provincesName = [String]()
        for province in provincesArray {
            provincesName.append(province.name)
        }
        return provincesName
    }
    
    func getProvinceWithName(name: String) -> ProvinceModel? {
        for province in provincesArray {
            if province.name == name {
                return province
            }
        }
        return nil
    }
    
    func getProvinceWithCode(code: String) -> ProvinceModel? {
        for province in provincesArray {
            if province.code == code {
                return province
            }
        }
        return nil
    }
    
    //MARK: - Hanlde date
    
    func getDateFromTimeStamp(timeStamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timeStamp))
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.init(identifier: "vi_VN")
        dateFormatter.dateFormat = "HH:mm dd/MM/yyyy"
        let strDate = dateFormatter.string(from: date)
        
        return strDate
    }
    
    func getDateFromTimeStamp(timeStamp: Int, formatDate: String) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timeStamp))
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.init(identifier: "vi_VN")
        dateFormatter.dateFormat = formatDate
        let strDate = dateFormatter.string(from: date)
        
        return strDate
    }
}
