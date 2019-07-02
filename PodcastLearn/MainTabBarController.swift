//
//  MainTabBarController.swift
//  PodcastLearn
//
//  Created by Chen Kelvin on 2019/5/7.
//  Copyright © 2019 Chen Kelvin. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UINavigationBar.appearance().prefersLargeTitles = true
        
        tabBar.tintColor = .purple
        
        setupViewController()
        
        setupPlayerDetailView()
    }
    
    @objc func minimizePlayerDetail() {
        maxTopAnchorConstraint.isActive = false
        buttonAnchorConstraint.constant = view.frame.height
//        minTopAnchorConstraint.constant = -64
        minTopAnchorConstraint.isActive = true
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            self.tabBar.transform = .identity
            self.playerDetailView.maximizedStackView.alpha = 0
            self.playerDetailView.miniPlayerView.alpha = 1
        })
    }
    
    func maximizePlayerDetail(with episode: Episode?, playlistEpisodes: [Episode] = []) {
        minTopAnchorConstraint.isActive = false
        maxTopAnchorConstraint.isActive = true
        maxTopAnchorConstraint.constant = 0
        buttonAnchorConstraint.constant = 0
        
        if episode != nil {
            playerDetailView.episode = episode
        }
        
        playerDetailView.playlistEpisodes = playlistEpisodes
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            self.tabBar.transform = CGAffineTransform(translationX: 0, y: 100)
            self.playerDetailView.maximizedStackView.alpha = 1
            self.playerDetailView.miniPlayerView.alpha = 0
        })
    }
    
    //MARK:- Setup Functions
    let playerDetailView = PlayerDetailView.initFromNib()
    
    var maxTopAnchorConstraint: NSLayoutConstraint!
    var minTopAnchorConstraint: NSLayoutConstraint!
    var buttonAnchorConstraint: NSLayoutConstraint!
    
    fileprivate func setupPlayerDetailView() {
        view.insertSubview(playerDetailView, belowSubview: tabBar)
        
        playerDetailView.translatesAutoresizingMaskIntoConstraints = false
        
        maxTopAnchorConstraint = playerDetailView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        
        buttonAnchorConstraint = playerDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
        buttonAnchorConstraint.isActive = true
        
        minTopAnchorConstraint =  playerDetailView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
//        minTopAnchorConstraint.isActive = true
        
        playerDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        playerDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    func setupViewController() {
        let layout = UICollectionViewFlowLayout()
        let favoritesController = FavoritesController(collectionViewLayout: layout)
        viewControllers = [
            generateNavigationController(for: favoritesController, title: "Favorites", image: #imageLiteral(resourceName: "favorites")),
            generateNavigationController(for: PodcastSearchController(), title: "Search", image: #imageLiteral(resourceName: "search")),
            generateNavigationController(for: DownloadsController(), title: "Downloads", image: #imageLiteral(resourceName: "downloads"))
        ]
    }
    
    //MARK:- Helper Functions
    
    fileprivate func generateNavigationController(for rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        rootViewController.navigationItem.title = title
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        return navController
    }
}
