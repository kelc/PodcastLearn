//
//  DownloadsController.swift
//  PodcastLearn
//
//  Created by Chen Kelvin on 2019/6/24.
//  Copyright © 2019 Chen Kelvin. All rights reserved.
//

import UIKit

class DownloadsController: UITableViewController {
    
    fileprivate let cellId = "cellId"
    
    var episodes = UserDefaults.standard.downloadedEpisodes()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupObservers()
    }
    
    fileprivate func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress), name: .downloadProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadComplete), name: .downloadComplete, object: nil)
    }
    
    @objc fileprivate func handleDownloadComplete(notification: NSNotification) {
        guard let epDownloadComplete = notification.object as? APIService.EPDownloadCompleteTuple else { return }
        guard let index = self.episodes.firstIndex(where: { $0.title == epDownloadComplete.episodeTitle }) else { return }
        self.episodes[index].fileUrl = epDownloadComplete.fileUrl == "" ? nil : epDownloadComplete.fileUrl
    }
    
    @objc fileprivate func handleDownloadProgress(notification: NSNotification) {
        guard let userInfo = notification.userInfo as? [String: Any] else { return }
        
        guard let progress = userInfo["progress"] as? Double else { return }
        guard let title = userInfo["title"] as? String else { return }
        
        guard let index = self.episodes.firstIndex(where: { $0.title == title }) else { return }
        guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell else { return }
        cell.progressLabel.text = "\(Int(progress * 100))"
        cell.progressLabel.isHidden = false
        
        if progress == 1 {
            cell.progressLabel.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        episodes = UserDefaults.standard.downloadedEpisodes()
        tableView.reloadData()
    }
    
    //MARK:- Setup
    fileprivate func setupTableView() {
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
    }
    
    //MARK:- TableView
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = self.episodes[indexPath.row]
        if episode.fileUrl != nil {
            UIApplication.mainTabBarController()?.maximizePlayerDetail(with: episode, playlistEpisodes: self.episodes)
        } else {
            let alertController = UIAlertController(title: "File URL not found", message: "Can't find local file, play using stream url instead", preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
                UIApplication.mainTabBarController()?.maximizePlayerDetail(with: episode, playlistEpisodes: self.episodes)
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            present(alertController, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let episode = self.episodes[indexPath.row]
        episodes.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        UserDefaults.standard.deleteEpisode(episode: episode)
        
        //Remove the local episode if exists
        guard let url = episode.fileUrl else { return }
        guard let path = URL(string: url) else { return }
        if FileManager.default.fileExists(atPath: path.path) {
            do {
                try FileManager.default.removeItem(at: path)
            } catch let error {
                print("Failed to remove local...", error)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        cell.episode = self.episodes[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134
    }
}
