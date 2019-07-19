//
//	Address.swift
//
//	Create by phước Lê on 5/6/2019
//	Copyright © 2019. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation


class Address : NSObject, NSCoding{

	var detail : String!
	var district : Int!
	var province : Int!
    var districtName : String!
    var provinceName : String!

    func getFullAddress() -> String {
        return detail + ", " + districtName + ", " + provinceName
    }
    
    static let sharedInstance = Address()
    
    override init() {
        super.init()
    }
	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any]){
		detail = dictionary["detail"] as? String
		district = dictionary["district"] as? Int
		province = dictionary["province"] as? Int
        districtName = dictionary["districtName"] as? String
        provinceName = dictionary["provinceName"] as? String
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if detail != nil{
			dictionary["detail"] = detail
		}
		if district != nil{
			dictionary["district"] = district
		}
		if province != nil{
			dictionary["province"] = province
		}
        if districtName != nil{
            dictionary["districtName"] = districtName
        }
        if provinceName != nil{
            dictionary["provinceName"] = provinceName
        }
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         detail = aDecoder.decodeObject(forKey: "detail") as? String
         district = aDecoder.decodeObject(forKey: "district") as? Int
         province = aDecoder.decodeObject(forKey: "province") as? Int
        districtName = aDecoder.decodeObject(forKey: "districtName") as? String
        provinceName = aDecoder.decodeObject(forKey: "provinceName") as? String

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
	{
		if detail != nil{
			aCoder.encode(detail, forKey: "detail")
		}
        if provinceName != nil{
            aCoder.encode(detail, forKey: "provinceName")
        }
        if districtName != nil{
            aCoder.encode(detail, forKey: "districtName")
        }
		if district != nil{
			aCoder.encode(district, forKey: "district")
		}
		if province != nil{
			aCoder.encode(province, forKey: "province")
		}

	}

}
