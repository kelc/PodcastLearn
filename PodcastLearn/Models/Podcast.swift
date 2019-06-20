//
//  Podcast.swift
//  PodcastLearn
//
//  Created by Chen Kelvin on 2019/5/7.
//  Copyright © 2019 Chen Kelvin. All rights reserved.
//

import Foundation

struct Podcast: Decodable {
    var trackName: String?
    var artistName: String?
    var artworkUrl600: String?
    var trackCount: Int?
    var feedUrl: String?
}
