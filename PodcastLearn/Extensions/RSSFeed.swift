//
//  RSSFeed.swift
//  PodcastLearn
//
//  Created by Chen Kelvin on 2019/5/14.
//  Copyright © 2019 Chen Kelvin. All rights reserved.
//

import FeedKit

extension RSSFeed {
    func toEpisodes() -> [Episode] {
        let imageUrl = iTunes?.iTunesImage?.attributes?.href
        
        var episodes = [Episode]() // Blank Episode Array
        
        items?.forEach({ (feedItem) in
            var episode = Episode(withFeed: feedItem)
            
            if episode.imageUrl == nil {
                episode.imageUrl = imageUrl
            }
            episodes.append(episode)
        })
        
        return episodes
    }
}
