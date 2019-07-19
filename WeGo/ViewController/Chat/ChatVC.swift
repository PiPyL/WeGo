//
//  ChatVC.swift
//  BBI
//
//  Created by PiPyL on 1/4/19.
//  Copyright © 2019 Stdio.Hue. All rights reserved.
//

import UIKit
import SVProgressHUD
import SDWebImage
import IQKeyboardManager
import Photos
import Firebase
import CoreLocation

@objc class ChatVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sendButton: UIButton!
    
    let barHeight: CGFloat = 50
    var items = [MessageModel]()
    var refChatGet: String?
    var receiverEmail: String?
    var guestUser: UserModel?
    let imagePicker = UIImagePickerController()

    //MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        self.tabBarController?.tabBar.isHidden = true
    }
    
    deinit {
        removeObservers()
    }
    
    //MARK: - Action
    
    private func setupData() {
        registerObservers()
        
        self.imagePicker.delegate = self
        self.tableView.estimatedRowHeight = barHeight
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.contentInset.bottom = barHeight
        self.tableView.scrollIndicatorInsets.bottom = barHeight
        textView.delegate = self
        self.sendButton.setTitle("Gửi", for: .normal)
        
        var checkChat = false
        if let ref = refChatGet {
            if let chats = AppDataSingleton.sharedInstance.currentUser?.chats {
                for refChat in chats {
                    if refChat == ref {
                        checkChat = true
                        break
                    }
                }
                if checkChat == false {
                    setupDiscussionData(chatRef: ref)
                }
            } else {
                setupDiscussionData(chatRef: ref)
            }
            fetchAllMessages(chatRef: ref)
        }
        
        if let user = guestUser {
            self.navigationItem.title = user.name
        } else {
            if let name = receiverEmail {
                UserModel.sharedInstance.fetchAUser(email: name) { [weak self] (user, error) in
                    if let user = user {
                        self?.guestUser = user
                        DispatchQueue.main.async {
                            self?.navigationItem.title = user.name
                        }
                    }
                }
            }
        }
    }
    
    func scrollToBottom() {
        if items.count > 0 {
            DispatchQueue.main.async {
                let indexPath = IndexPath(row: self.items.count*2 - 1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    
    @IBAction func selectGallery(_ sender: Any) {
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == .authorized || status == .notDetermined) {
            self.imagePicker.sourceType = .savedPhotosAlbum;
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func selectCamera(_ sender: Any) {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if (status == .authorized || status == .notDetermined) {
            self.imagePicker.sourceType = .camera
            self.imagePicker.allowsEditing = false
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func didClickSendMessageButton(_ sender: Any) {
        if textView.hasText && textView.text != " " {
            let messageNew = MessageModel()
            messageNew.content = textView.text
            messageNew.createBy = AppDataSingleton.sharedInstance.currentUser?.getEmailRef()
            messageNew.dateCreate = Int(NSDate().timeIntervalSince1970 * 1000)
            
            if let ref = refChatGet {
                messageNew.send(refChat: ref) { (status) in
                    
                }
            }
            textView.text = ""
        }
    }
    
    //MARK: API
    
    private func fetchAllMessages(chatRef: String) {
        MessageModel.sharedInstance.fetchAllMessages(refChat: chatRef) { [weak self] (message, error) in
            if let error = error {
                AlertController.showAlertController(title: "Thông báo", message: "Lỗi khi tải tin nhắn", nil)
            } else {
                self?.items.append(message)
                DispatchQueue.main.async {
                    if let state = self?.items.isEmpty, state == false {
                        self?.tableView.reloadData()
                        self?.scrollToBottom()
                    }
                }
            }
        }
    }
    
    private func setupDiscussionData(chatRef: String) {
        
        if let emailGuest = receiverEmail {
            let discussion = Discussion()
            discussion.chatID = chatRef
            discussion.users = ([AppDataSingleton.sharedInstance.currentUser?.getEmailRef(), emailGuest] as! [String])
            discussion.saveDiscussionWithRef(chatID: chatRef) { [weak self] (error) in
                if error != nil {
                    AlertController.showAlertController(title: "Thông báo", message: "Lỗi khi lưu dữ liệu chat", nil)
                } else {
                    self?.saveChatRefForUserCurrent()
                }
            }
        }
    }
    
    private func saveChatRefForUserCurrent() {
        if let user = AppDataSingleton.sharedInstance.currentUser, let ref = refChatGet {
            var chats = [String]()
            if let chatsUser = user.chats {
                chats = chatsUser
            }
            chats.append(ref)
            user.chats = chats
            user.saveUser { [weak self] (error) in
                if error != nil {
                    AlertController.showAlertController(title: "Thông báo", message: "Lỗi khi lưu ref chat người dùng", nil)
                } else {
                    AppDataSingleton.sharedInstance.currentUser = user
                    self?.saveChatRefForGuest()
                }
            }
        }
    }
    
    private func saveChatRefForGuest() {
        if let user = guestUser, let ref = refChatGet {
            var chats = [String]()
            if let chatsUser = user.chats {
                chats = chatsUser
            }
            chats.append(ref)
            user.chats = chats
            user.saveUser { (error) in
                if error != nil {
                    AlertController.showAlertController(title: "Thông báo", message: "Lỗi khi lưu ref chat người dùng", nil)
                }
            }
        }
    }
    
    //MARK: - Notification
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            
            let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0

            if bottom == 0 {
                bottomConstraint.constant = keyboardHeight
            } else {
                bottomConstraint.constant = keyboardHeight - 37
            }
            tableViewBottomConstraint.constant = keyboardHeight
            let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue ?? 0.25
            UIView.animate(withDuration: duration, animations: {
                self.view.layoutIfNeeded()
            }) { _ in
                self.scrollToBottom()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue ?? 0.25
        bottomConstraint.constant = 0
        tableViewBottomConstraint.constant = 0
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func registerObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: - Image

extension ChatVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.editedImage] as? UIImage {
            pickedImage.uploadImage { [weak self] (urlString, error) in
                if error == nil {
                    if let ref = self?.refChatGet {
                        let messageNew = MessageModel()
                        messageNew.content = urlString
                        messageNew.createBy = AppDataSingleton.sharedInstance.currentUser?.getEmailRef()
                        messageNew.dateCreate = Int(NSDate().timeIntervalSince1970 * 1000)
                        messageNew.send(refChat: ref, completion: { (error) in
                            if error == true {
                                AlertController.showAlertController(title: "Thông báo", message: "Lỗi khi gửi ảnh!", nil)
                            }
                        })
                    }
                }
            }
        } else {
            let pickedImage = info[.originalImage] as! UIImage
            pickedImage.uploadImage { [weak self] (urlString, error) in
                if error == nil {
                    if let ref = self?.refChatGet {
                        let messageNew = MessageModel()
                        messageNew.content = urlString
                        messageNew.createBy = AppDataSingleton.sharedInstance.currentUser?.getEmailRef()
                        messageNew.dateCreate = Int(NSDate().timeIntervalSince1970 * 1000)
                        messageNew.send(refChat: ref, completion: { (error) in
                            if error == true {
                                AlertController.showAlertController(title: "Thông báo", message: "Lỗi khi gửi ảnh!", nil)
                            }
                        })
                    }
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

//MARK: - TableView

extension ChatVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count*2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row % 2 == 0 {
            let model: MessageModel = self.items[indexPath.row/2]

            if let userModel = AppDataSingleton.sharedInstance.currentUser {
                if model.createBy != userModel.getEmailRef() {
                    
                    if model.content.contains("https://firebasestorage.googleapis.com") {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageSenderCell", for: indexPath) as! ImageSenderCell
                        cell.clearCellData()
                        cell.tableViewParent = self.tableView
                        if let url = URL.init(string: model.content) {
                            cell.setupImage(url: url) { [weak self] (error) in
//                                self?.tableView.reloadRows(at: [indexPath], with: .none)
                            }
                        }
                        if let user = guestUser, let avatar = user.avatar, let url = URL.init(string: avatar) {
                            cell.profilePic.sd_setImage(with: url, completed: nil)
                        } else {
                            cell.profilePic.image = UIImage.init(named: "ic_wego")
                        }
                        return cell
                    } else {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "Sender", for: indexPath) as! SenderCell
                        cell.clearCellData()
                        cell.message.text = model.content
                        if let user = guestUser, let avatar = user.avatar, let url = URL.init(string: avatar) {
                            cell.profilePic.sd_setImage(with: url, completed: nil)
                        } else {
                            cell.profilePic.image = UIImage.init(named: "ic_wego")
                        }
                        return cell
                    }
                }
            }
            
            if model.content.contains("https://firebasestorage.googleapis.com") {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ImageReceiverCell", for: indexPath) as! ImageReceiverCell
                cell.clearCellData()
                cell.tableViewParent = self.tableView
                if let url = URL.init(string: model.content) {
                    cell.setupImage(url: url) { [weak self] (error) in
//                        self?.tableView.reloadRows(at: [indexPath], with: .none)
                    }
                }
                if let userModel = AppDataSingleton.sharedInstance.currentUser, let avatar = userModel.avatar, let url = URL.init(string: avatar) {
                    cell.profilePic.sd_setImage(with: url, completed: nil)
                } else {
                    cell.profilePic.image = UIImage.init(named: "ic_wego")
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Receiver", for: indexPath) as! ReceiverCell
                cell.clearCellData()
                cell.message.text = model.content
                if let userModel = AppDataSingleton.sharedInstance.currentUser, let avatar = userModel.avatar, let url = URL.init(string: avatar) {
                    cell.profilePic.sd_setImage(with: url, completed: nil)
                } else {
                    cell.profilePic.image = UIImage.init(named: "ic_wego")
                }
                return cell
            }
        } else {
            let model: MessageModel = self.items[indexPath.row/2]
            let cell = tableView.dequeueReusableCell(withIdentifier: "TimeCell", for: indexPath) as! TimeCell

            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm, dd-MM-yyyy"
            let myString = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(model.dateCreate/1000)))

            cell.timeLabel.text = myString

            if let userModel = AppDataSingleton.sharedInstance.currentUser {
                if model.createBy != userModel.getEmailRef() {
                    cell.timeLabel.textAlignment = .left
                    return cell
                }
            }
            cell.timeLabel.textAlignment = .right

            return cell
        }
    }
}

extension ChatVC: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.textView.inputAccessoryView = nil
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.textView.inputAccessoryView = nil
    }
}

class SenderCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var messageBackground: UIImageView!
    
    func clearCellData()  {
        self.message.text = nil
        self.message.isHidden = false
        self.messageBackground.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let radius: CGFloat = 18
        self.profilePic.layer.cornerRadius = radius
        self.profilePic.clipsToBounds = true
        self.selectionStyle = .none
        self.message.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        self.messageBackground.layer.cornerRadius = 15
        self.messageBackground.clipsToBounds = true
    }
}

class ReceiverCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var messageBackground: UIImageView!
    
    func clearCellData()  {
        self.message.text = nil
        self.message.isHidden = false
        self.messageBackground.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let radius: CGFloat = 18
        self.profilePic.layer.cornerRadius = radius
        self.profilePic.clipsToBounds = true
        self.selectionStyle = .none
        self.message.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        self.messageBackground.layer.cornerRadius = 15
        self.messageBackground.clipsToBounds = true
    }
}

class ImageSenderCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var messageBackground: UIImageView!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var tableViewParent: UITableView?
    
    func clearCellData()  {
        self.messageBackground.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let radius: CGFloat = 18
        self.profilePic.layer.cornerRadius = radius
        self.profilePic.clipsToBounds = true
        self.messageBackground.layer.cornerRadius = 15
        self.messageBackground.clipsToBounds = true
    }
    
    func setupImage(url: URL, completionHandler: @escaping (_ error: Bool?) -> ()) {
        messageBackground.sd_setImage(with: url) { [weak self] (image, error, type, url) in
            if let img = image {
                let ratio = img.width/img.height
                
                if img.width > img.height {
                    if img.width <= 260 {
                        self?.widthConstraint.constant = img.width
                        self?.heightConstraint.constant = img.height
                    } else {
                        if img.width > 260 {
                            self?.widthConstraint.constant = 260
                            self?.heightConstraint.constant = 260/ratio
                        }
                    }
                } else {
                    if img.height <= 260 {
                        self?.widthConstraint.constant = img.width
                        self?.heightConstraint.constant = img.height
                    } else {
                        if img.height > 260 {
                            self?.heightConstraint.constant = 260
                            self?.widthConstraint.constant = 260*ratio
                        }
                    }
                }
                if let tableView = self?.tableViewParent {
                    tableView.beginUpdates()
                    tableView.endUpdates()
                }
                completionHandler(false)
            } else {
                completionHandler(true)
            }
        }
    }
}

class ImageReceiverCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var messageBackground: UIImageView!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var tableViewParent: UITableView?

    func clearCellData()  {
        self.messageBackground.image = nil
        self.heightConstraint.constant = 30
        self.widthConstraint.constant = 20
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let radius: CGFloat = 18
        self.profilePic.layer.cornerRadius = radius
        self.profilePic.clipsToBounds = true
        self.messageBackground.layer.cornerRadius = 15
        self.messageBackground.clipsToBounds = true
    }
    
    func setupImage(url: URL, completionHandler: @escaping (_ error: Bool?) -> ()) {
        messageBackground.sd_setImage(with: url) { [weak self] (image, error, type, url) in
            if let img = image {
                let ratio = img.width/img.height
                
                if img.width > img.height {
                    if img.width <= 260 {
                        self?.widthConstraint.constant = img.width
                        self?.heightConstraint.constant = img.height
                    } else {
                        if img.width > 260 {
                            self?.widthConstraint.constant = 260
                            self?.heightConstraint.constant = 260/ratio
                        }
                    }
                } else {
                    if img.height <= 260 {
                        self?.widthConstraint.constant = img.width
                        self?.heightConstraint.constant = img.height
                    } else {
                        if img.height > 260 {
                            self?.heightConstraint.constant = 260
                            self?.widthConstraint.constant = 260*ratio
                        }
                    }
                }
                if let tableView = self?.tableViewParent {
                    tableView.beginUpdates()
                    tableView.endUpdates()
                }
                completionHandler(false)
            } else {
                completionHandler(true)
            }
        }
    }
}

class TimeCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
