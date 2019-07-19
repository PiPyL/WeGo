//
//  MainTabbarVC.swift
//  EventTinder
//
//  Created by mac on 9/12/18.
//  Copyright © 2018 PartyApp. All rights reserved.
//

import UIKit

class MainTabbarVC: UITabBarController {
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        createTabBarController()
    }
    
    //MARK: - Private
    
    func createTabBarController() {
        
        let listPostsVC = UIStoryboard.mainStoryboard().instantiateViewController(withIdentifier: "ListPostsVC")
        let listPostNavVC = UINavigationController.init(rootViewController: listPostsVC);
//        listPostsVC.tabBarItem.image = UIImage.init(named: "ic_home")?.withRenderingMode(.alwaysOriginal)
//        listPostNavVC.tabBarItem.selectedImage = UIImage.init(named: "ic_tab_profile_selected")?.withRenderingMode(.alwaysOriginal)
        
        let postDetailVC = UIStoryboard.mainStoryboard().instantiateViewController(withIdentifier: "PostDetailVC")
//        postDetailVC.tabBarItem.image = UIImage.init(named: "ic_account")?.withRenderingMode(.alwaysOriginal)
        let postDetailNavVC = UINavigationController.init(rootViewController: postDetailVC);
//        postDetailVC.tabBarItem.title = "Detail"
        
        let createPostVC = UIStoryboard.mainStoryboard().instantiateViewController(withIdentifier: "CreatePostVC")
//        createPostVC.tabBarItem.image = UIImage.init(named: "ic_add")?.withRenderingMode(.alwaysOriginal)
        let createPostNavVC = UINavigationController.init(rootViewController: createPostVC);
//        createPostNavVC.tabBarItem.title = "Tạo"
        
        let items = [listPostNavVC, createPostNavVC, postDetailNavVC]
        
        setViewControllers(items, animated: true)
        
    }
}

