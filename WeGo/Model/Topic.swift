//
//	Topic.swift
//
//	Create by phước Lê on 5/6/2019
//	Copyright © 2019. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation
import SVProgressHUD

class Topic : NSObject, NSCoding{

	var addressEnd : Address!
	var addressStart : Address!
	var bossEmail : String!
	var bossName : String!
	var note : String!
    var status : String!
	var timeCreate : Int!
	var timeStart : Int!
    
    func fetchTopicsByAddress(provinceCode: String, districtCode: String, completionHandler: @escaping (_ topics: [Topic]?,_ error: Error?) -> ()) {
        var arrayGet = [Topic]();
        
        AppDataSingleton.sharedInstance.ref.child("Topic").child(provinceCode).child(districtCode).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                value.allKeys.forEach({ (key) in
                    let model = Topic.init(fromDictionary: value.object(forKey: key) as! [String : Any])
                    arrayGet.append(model)
                })
                completionHandler(arrayGet, nil)
            } else {
                completionHandler([], nil)
            }
        }) { (error) in
            completionHandler(nil, error)
        }
    }
    
    func fetchTopicsByBothAddress(provinceCode: String, districtCode: String, districtStartCode: String, completionHandler: @escaping (_ topics: [Topic]?,_ error: Error?) -> ()) {
        var arrayGet = [Topic]();
        AppDataSingleton.sharedInstance.ref.child("Topic").child(provinceCode).child(districtCode).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                value.allKeys.forEach({ (key) in
                    let model = Topic.init(fromDictionary: value.object(forKey: key) as! [String : Any])
                    if String(model.addressStart.district) == districtStartCode {
                        arrayGet.append(model)
                    }
                })
                completionHandler(arrayGet, nil)
            } else {
                completionHandler([], nil)
            }
        }) { (error) in
            completionHandler(nil, error)
        }
    }

    func saveTopic(provinceCode: String, districtCode: String, email: String, completionHandler: @escaping (_ error: Error?) -> ()) {
        self.bossEmail = AppDataSingleton.sharedInstance.currentUser?.email
        self.bossName = AppDataSingleton.sharedInstance.currentUser?.name
        self.status = "Hiển thị"
        let keyTopic = provinceCode + "/" + districtCode + "/" + email.replacingOccurrences(of: ".", with: "_") + String(self.timeCreate)
        SVProgressHUD.show()
        AppDataSingleton.sharedInstance.ref.child("Topic").child(keyTopic).setValue(self.toDictionary()) { (error, ref) in
            SVProgressHUD.dismiss()
            if error != nil {
                completionHandler(error)
            } else {
                if let user = AppDataSingleton.sharedInstance.currentUser {
                    if user.topics != nil {
                        user.topics.append(keyTopic)
                    } else {
                        var topicsArray = [String]()
                        topicsArray.append(keyTopic)
                        user.topics = topicsArray
                    }
                    user.saveUser(completionHandler: { (error) in
                        if let error = error {
                            AlertController.showAlertController(title: "Thông báo", message: "Lỗi khi tạo bài đăng" + error.localizedDescription, nil)
                        } else {
                            if let user = AppDataSingleton.sharedInstance.currentUser {
                                if user.topics != nil {
                                    user.topics.append(keyTopic)
                                } else {
                                    var topicsArray = [String]()
                                    topicsArray.append(keyTopic)
                                    user.topics = topicsArray
                                }
                                AppDataSingleton.sharedInstance.currentUser = user
                            }
                        }
                    })
                }
                completionHandler(nil)
            }
        }
    }
    
    func deleteTopic(keyTopic: String, completionHandler: @escaping (_ error: Error?) -> ()) {
        SVProgressHUD.show()
        AppDataSingleton.sharedInstance.ref.child("Topic").child(keyTopic).setValue(nil) { (error, ref) in
            SVProgressHUD.dismiss()
            if error != nil {
                completionHandler(error)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    func updateTopic(provinceCode: String, districtCode: String, keyTopicOld: String, completionHandler: @escaping (_ error: Error?) -> ()) {
        
        SVProgressHUD.show()
        AppDataSingleton.sharedInstance.ref.child("Topic").child(keyTopicOld).setValue(self.toDictionary()) { (error, ref) in
            SVProgressHUD.dismiss()
            if error != nil {
                completionHandler(error)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    func fetchATopic(refTopic: String, completionHandler: @escaping (_ topic: Topic?, _ error: Error?) -> ()) {
        var strArray = refTopic.components(separatedBy: "/")
        let provinceCode: String = strArray[0]
        let districtCode: String = strArray[1]
        let keyTopic: String = strArray[2]
        AppDataSingleton.sharedInstance.ref.child("Topic").child(provinceCode).child(districtCode).child(keyTopic).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                let model = Topic.init(fromDictionary: value as! [String : Any])
                completionHandler(model, nil)
            }
        }) { (error) in
            completionHandler(nil, error)
        }
    }
    
    func fetchAllTopicOfAUser(refTopic: String, completionHandler: @escaping (_ topic: Topic?, _ error: Error?) -> ()) {
        var strArray = refTopic.components(separatedBy: "/")
        let provinceCode: String = strArray[0]
        let districtCode: String = strArray[1]
        let keyTopic: String = strArray[2]
        AppDataSingleton.sharedInstance.ref.child("Topic").child(provinceCode).child(districtCode).child(keyTopic).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                let model = Topic.init(fromDictionary: value as! [String : Any])
                completionHandler(model, nil)
            }
        }) { (error) in
            completionHandler(nil, error)
        }
    }
    
    func getRefTopic() -> String {
        return String(self.addressEnd.province) + "/" + String(self.addressEnd.district) + "/" + self.bossEmail.replacingOccurrences(of: ".", with: "_") + String(self.timeCreate)
    }
    
    static let sharedInstance = Topic()
    
    override init() {
        super.init()
    }
	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any]){
		if let addressEndData = dictionary["AddressEnd"] as? [String:Any]{
			addressEnd = Address(fromDictionary: addressEndData)
		}
		if let addressStartData = dictionary["AddressStart"] as? [String:Any]{
			addressStart = Address(fromDictionary: addressStartData)
		}
		bossEmail = dictionary["BossEmail"] as? String
		bossName = dictionary["BossName"] as? String
        status = dictionary["Status"] as? String
		note = dictionary["Note"] as? String
		timeCreate = dictionary["TimeCreate"] as? Int
		timeStart = dictionary["TimeStart"] as? Int
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if addressEnd != nil{
			dictionary["AddressEnd"] = addressEnd.toDictionary()
		}
		if addressStart != nil{
			dictionary["AddressStart"] = addressStart.toDictionary()
		}
		if bossEmail != nil{
			dictionary["BossEmail"] = bossEmail
		}
        if status != nil{
            dictionary["Status"] = status
        }
		if bossName != nil{
			dictionary["BossName"] = bossName
		}
		if note != nil{
			dictionary["Note"] = note
		}
		if timeCreate != nil{
			dictionary["TimeCreate"] = timeCreate
		}
		if timeStart != nil{
			dictionary["TimeStart"] = timeStart
		}
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         addressEnd = aDecoder.decodeObject(forKey: "AddressEnd") as? Address
         addressStart = aDecoder.decodeObject(forKey: "AddressStart") as? Address
         bossEmail = aDecoder.decodeObject(forKey: "BossEmail") as? String
         bossName = aDecoder.decodeObject(forKey: "BossName") as? String
         note = aDecoder.decodeObject(forKey: "Note") as? String
         timeCreate = aDecoder.decodeObject(forKey: "TimeCreate") as? Int
         timeStart = aDecoder.decodeObject(forKey: "TimeStart") as? Int
         status = aDecoder.decodeObject(forKey: "Status") as? String

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
	{
		if addressEnd != nil{
			aCoder.encode(addressEnd, forKey: "AddressEnd")
		}
		if addressStart != nil{
			aCoder.encode(addressStart, forKey: "AddressStart")
		}
		if bossEmail != nil{
			aCoder.encode(bossEmail, forKey: "BossEmail")
		}
		if bossName != nil{
			aCoder.encode(bossName, forKey: "BossName")
		}
        if status != nil{
            aCoder.encode(status, forKey: "Status")
        }
		if note != nil{
			aCoder.encode(note, forKey: "Note")
		}
		if timeCreate != nil{
			aCoder.encode(timeCreate, forKey: "TimeCreate")
		}
		if timeStart != nil{
			aCoder.encode(timeStart, forKey: "TimeStart")
		}

	}

}
