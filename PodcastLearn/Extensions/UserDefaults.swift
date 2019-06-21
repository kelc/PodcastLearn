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
}
