//
//	Discussion.swift
//
//	Create by phước Lê on 8/6/2019
//	Copyright © 2019. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation


class Discussion : NSObject, NSCoding{

	var chatID : String!
	var users : [String]!
    
    static let sharedInstance = Discussion()
    
    override init() {
        super.init()
    }

    func fetchADiscussion(refChat: String, completionHandler: @escaping (_ discussion: Discussion?, _ error: Error?) -> ()) {
        AppDataSingleton.sharedInstance.ref.child("Discussion").child(refChat).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                let model = Discussion.init(fromDictionary: value as! [String : Any])
                completionHandler(model, nil)
            }
        }) { (error) in
            completionHandler(nil, error)
        }
    }
    
    func saveDiscussionWithRef(chatID: String, completionHandler: @escaping (_ error: Error?) -> ()) { AppDataSingleton.sharedInstance.ref.child("Discussion").child(chatID).setValue(self.toDictionary()) { (error, ref) in
            if error != nil {
                completionHandler(error)
            } else {
                completionHandler(nil)
            }
        }
    }
    
	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any]){
		chatID = dictionary["chatID"] as? String
		users = dictionary["users"] as? [String]
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if chatID != nil{
			dictionary["chatID"] = chatID
		}
		if users != nil{
			dictionary["users"] = users
		}
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         chatID = aDecoder.decodeObject(forKey: "chatID") as? String
         users = aDecoder.decodeObject(forKey: "users") as? [String]

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
	{
		if chatID != nil{
			aCoder.encode(chatID, forKey: "chatID")
		}
		if users != nil{
			aCoder.encode(users, forKey: "users")
		}

	}

}
