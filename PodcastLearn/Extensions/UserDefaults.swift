//
//  UserDefault.swift
//  PodcastLearn
//
//  Created by Chen Kelvin on 2019/6/21.
//  Copyright © 2019 Chen Kelvin. All rights reserved.
//

import Foundation

extension UserDefaults {
    static let favoritedPodcastKey = "favoritedPodcastKey"
    static let downloadedEpisodesKey = "downloadedEpisodesKey"
    
    func deleteEpisode(episode: Episode) {
        let saveEpisodes = downloadedEpisodes()
        let filterEpisodes = saveEpisodes.filter { (e) -> Bool in
            return e.title != episode.title
        }
        
        do {
            let data = try JSONEncoder().encode(filterEpisodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)
        } catch let encodeErr {
            print("Failed to encode episode when delete:", encodeErr)
        }
    }
    
    func downloadEpisode(episode: Episode) {
        do {
            var downloadEpisodes = downloadedEpisodes()
            downloadEpisodes.append(episode)
            let data = try JSONEncoder().encode(downloadEpisodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)
        } catch let encodeErr {
            print("Failed to encode episode:", encodeErr)
        }
    }
    
    func downloadedEpisodes() -> [Episode] {
        guard let episodeData = data(forKey: UserDefaults.downloadedEpisodesKey) else { return [] }
        
        do {
            let episodes = try JSONDecoder().decode([Episode].self, from: episodeData)
            return episodes
        } catch let decodeErr {
            print("Failed to decode:", decodeErr)
        }
        return []
    }
    
    func savedPodcast() -> [Podcast] {
        guard let savedPodcastsData = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastKey) else { return [] }
        var savedPodcasts = [Podcast]()
        do {
            savedPodcasts = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPodcastsData) as? [Podcast] ?? []
        } catch let error {
            print("Can't fetch out:", error)
        }
        return savedPodcasts
    }
    
    func deletePodcast(podcast: Podcast) {
        let podcasts = savedPodcast()
        let filterPodcasts = podcasts.filter { (p) -> Bool in
            return p.trackName != podcast.trackName && p.artistName != podcast.artistName
        }
        var data = Data()
        do {
            data = try NSKeyedArchiver.archivedData(withRootObject: filterPodcasts, requiringSecureCoding: true)
        } catch let error {
            print("Can't save data", error)
        }
        UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
    }
}
