//
//	MessageModel.swift
//
//	Create by phước Lê on 8/6/2019
//	Copyright © 2019. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation


class MessageModel : NSObject, NSCoding{

	var content : String!
	var createBy : String!
	var dateCreate : Int!

    static let sharedInstance = MessageModel()
    
    override init() {
        super.init()
    }
    
    func fetchAllMessages(refChat: String, completionHandler: @escaping (_ arrayGet: MessageModel, _ error: Error?) -> ()) {
        
        AppDataSingleton.sharedInstance.ref.child("Chat").child(refChat).observe(.childAdded) { (snapshot) in
            
            if let value = snapshot.value as? NSDictionary {
                let model = MessageModel.init(fromDictionary: (value as? [String: Any])!)
                completionHandler(model, nil)
            } else {
            }
        }
        
    }
    
    func send(refChat: String, completion: @escaping (Bool) -> Swift.Void)  {
        uploadMessageWithName(refChat: refChat) { (error) in
            if error == nil {
                completion(false)
            } else {
                completion(true)
            }
            
        }
    }
    
    func uploadMessageWithName(refChat: String, completionHandler: @escaping (_ error: Error?) -> ()) {
        let time = Int(NSDate().timeIntervalSince1970 * 1000)
        AppDataSingleton.sharedInstance.ref.child("Chat").child(refChat).child(String(time)).setValue(toDictionary()) { (error, ref) in
            if let error = error {
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
		content = dictionary["content"] as? String
		createBy = dictionary["createBy"] as? String
		dateCreate = dictionary["dateCreate"] as? Int
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if content != nil{
			dictionary["content"] = content
		}
		if createBy != nil{
			dictionary["createBy"] = createBy
		}
		if dateCreate != nil{
			dictionary["dateCreate"] = dateCreate
		}
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         content = aDecoder.decodeObject(forKey: "content") as? String
         createBy = aDecoder.decodeObject(forKey: "createBy") as? String
         dateCreate = aDecoder.decodeObject(forKey: "dateCreate") as? Int

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
	{
		if content != nil{
			aCoder.encode(content, forKey: "content")
		}
		if createBy != nil{
			aCoder.encode(createBy, forKey: "createBy")
		}
		if dateCreate != nil{
			aCoder.encode(dateCreate, forKey: "dateCreate")
		}

	}

}
