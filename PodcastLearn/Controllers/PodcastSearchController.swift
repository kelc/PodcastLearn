//
//  PodcastSearchController.swift
//  PodcastLearn
//
//  Created by Chen Kelvin on 2019/5/7.
//  Copyright © 2019 Chen Kelvin. All rights reserved.
//

import UIKit
//import Alamofire

class PodcastSearchController: UITableViewController, UISearchBarDelegate {
    
    var podcasts = [Podcast]()
    
    fileprivate let cellId = "cellId"
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpSearchBar()
        setUpTableView()
        
        searchBar(searchController.searchBar, textDidChange: "妖精教你谈恋爱")
    }
    
    //MARK:- Setup Functions
    
    fileprivate func setUpSearchBar() {
        self.definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    fileprivate func setUpTableView() {
        tableView.tableFooterView = UIView()
        let nib = UINib(nibName: "PodcastCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
    }
    
    //MARK:- Search Functions
    
    var timer: Timer?
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (timer) in
            APIService.share.fetchPodcasts(withText: searchText) { (podcasts) in
                self.podcasts = podcasts
                self.tableView.reloadData()
            }
        })
    }
    
    //MARK:- TableView Functions
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episodeController = EpisodeController()
        let podcast = self.podcasts[indexPath.row]
        episodeController.podcast = podcast
        navigationController?.pushViewController(episodeController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Please enter a search term"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // ternary operator
        return self.podcasts.count > 0 ? 0 : 250
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PodcastCell
        let podcast = podcasts[indexPath.row]
        cell.podcast = podcast
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
}
