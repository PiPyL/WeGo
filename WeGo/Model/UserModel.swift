//
//	UserModel.swift
//
//	Create by phước Lê on 5/6/2019
//	Copyright © 2019. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation
import SVProgressHUD

class UserModel : NSObject, NSCoding{

	var address : Address!
	var birthday : Int!
	var facebook : String!
	var name : String!
	var phone : String!
	var topics : [String]!
    var email : String!
    var chats : [String]!
    var favorite : [String]!
    var avatar : String!

    func saveUser(completionHandler: @escaping (_ error: Error?) -> ()) {
       SVProgressHUD.show()
        AppDataSingleton.sharedInstance.ref.child("User").child(getEmailRef()).setValue(self.toDictionary()) { (error, ref) in
        SVProgressHUD.dismiss()
            if error != nil {
                completionHandler(error)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    func getAddressDetail() -> String {
        return address.detail + ", " + address.districtName + ", " + address.provinceName
    }
    
    
    func getEmailRef() -> String {
        return email.replacingOccurrences(of: ".", with: "_")
    }
    
    func fetchAUser(email: String, completionHandler: @escaping (_ user: UserModel?, _ error: Error?) -> ()) {
        
        AppDataSingleton.sharedInstance.ref.child("User").child(email).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                let model = UserModel.init(fromDictionary: value as! [String : Any])
                completionHandler(model, nil)
            }
        }) { (error) in
            completionHandler(nil, error)
        }
    }
    
    static let sharedInstance = UserModel()
    
    override init() {
        super.init()
    }
	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any]){
		if let addressData = dictionary["address"] as? [String:Any]{
			address = Address(fromDictionary: addressData)
		}
		birthday = dictionary["birthday"] as? Int
		facebook = dictionary["facebook"] as? String
        avatar = dictionary["avatar"] as? String
		name = dictionary["name"] as? String
		phone = dictionary["phone"] as? String
        email = dictionary["email"] as? String
		topics = dictionary["topics"] as? [String]
        chats = dictionary["chats"] as? [String]
        favorite = dictionary["favorite"] as? [String]
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if address != nil{
			dictionary["address"] = address.toDictionary()
		}
		if birthday != nil{
			dictionary["birthday"] = birthday
		}
		if facebook != nil{
			dictionary["facebook"] = facebook
		}
        if avatar != nil{
            dictionary["avatar"] = avatar
        }
		if name != nil{
			dictionary["name"] = name
		}
		if phone != nil{
			dictionary["phone"] = phone
		}
        if email != nil{
            dictionary["email"] = email
        }
		if topics != nil{
			dictionary["topics"] = topics
		}
        if chats != nil{
            dictionary["chats"] = chats
        }
        if favorite != nil{
            dictionary["favorite"] = favorite
        }
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
    {
        address = aDecoder.decodeObject(forKey: "address") as? Address
        birthday = aDecoder.decodeObject(forKey: "birthday") as? Int
        facebook = aDecoder.decodeObject(forKey: "facebook") as? String
        avatar = aDecoder.decodeObject(forKey: "avatar") as? String
        email = aDecoder.decodeObject(forKey: "email") as? String
        name = aDecoder.decodeObject(forKey: "name") as? String
        phone = aDecoder.decodeObject(forKey: "phone") as? String
        topics = aDecoder.decodeObject(forKey: "topics") as? [String]
        chats = aDecoder.decodeObject(forKey: "chats") as? [String]
        favorite = aDecoder.decodeObject(forKey: "favorite") as? [String]

    }

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
	{
		if address != nil{
			aCoder.encode(address, forKey: "address")
		}
		if birthday != nil{
			aCoder.encode(birthday, forKey: "birthday")
		}
		if facebook != nil{
			aCoder.encode(facebook, forKey: "facebook")
		}
        if avatar != nil{
            aCoder.encode(avatar, forKey: "avatar")
        }
        if email != nil{
            aCoder.encode(email, forKey: "email")
        }
		if name != nil{
			aCoder.encode(name, forKey: "name")
		}
		if phone != nil{
			aCoder.encode(phone, forKey: "phone")
		}
		if topics != nil{
			aCoder.encode(topics, forKey: "topics")
		}
        if chats != nil{
            aCoder.encode(chats, forKey: "chats")
        }
        if favorite != nil{
            aCoder.encode(chats, forKey: "favorite")
        }
	}

}
