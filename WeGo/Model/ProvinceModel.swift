//
//	ProvinceModel.swift
//
//	Create by phước Lê on 4/6/2019
//	Copyright © 2019. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation


class ProvinceModel : NSObject, NSCoding{

	var code : String!
	var name : String!
	var nameWithType : String!
	var slug : String!
	var type : String!

    
	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any]){
		code = dictionary["code"] as? String
		name = dictionary["name"] as? String
		nameWithType = dictionary["name_with_type"] as? String
		slug = dictionary["slug"] as? String
		type = dictionary["type"] as? String
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if code != nil{
			dictionary["code"] = code
		}
		if name != nil{
			dictionary["name"] = name
		}
		if nameWithType != nil{
			dictionary["name_with_type"] = nameWithType
		}
		if slug != nil{
			dictionary["slug"] = slug
		}
		if type != nil{
			dictionary["type"] = type
		}
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         code = aDecoder.decodeObject(forKey: "code") as? String
         name = aDecoder.decodeObject(forKey: "name") as? String
         nameWithType = aDecoder.decodeObject(forKey: "name_with_type") as? String
         slug = aDecoder.decodeObject(forKey: "slug") as? String
         type = aDecoder.decodeObject(forKey: "type") as? String

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
	{
		if code != nil{
			aCoder.encode(code, forKey: "code")
		}
		if name != nil{
			aCoder.encode(name, forKey: "name")
		}
		if nameWithType != nil{
			aCoder.encode(nameWithType, forKey: "name_with_type")
		}
		if slug != nil{
			aCoder.encode(slug, forKey: "slug")
		}
		if type != nil{
			aCoder.encode(type, forKey: "type")
		}

	}

}
