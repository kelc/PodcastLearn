//
//  Episode.swift
//  PodcastLearn
//
//  Created by Chen Kelvin on 2019/5/13.
//  Copyright © 2019 Chen Kelvin. All rights reserved.
//

import Foundation
import FeedKit

struct Episode {
    let title: String
    let pubDate: Date
    let description: String
    var imageUrl: String?
    let author: String
    let streamUrl: String
    
    init(withFeed feedItem: RSSFeedItem) {
        self.streamUrl = feedItem.enclosure?.attributes?.url ?? ""
        
        self.title = feedItem.title ?? ""
        self.pubDate = feedItem.pubDate ?? Date()
        self.description = feedItem.iTunes?.iTunesSubtitle ?? feedItem.description ?? ""
        self.author = feedItem.iTunes?.iTunesAuthor ?? ""
        
        self.imageUrl = feedItem.iTunes?.iTunesImage?.attributes?.href
    }
}
