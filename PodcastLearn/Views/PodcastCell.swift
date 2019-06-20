//
//  PodcastCell.swift
//  PodcastLearn
//
//  Created by Chen Kelvin on 2019/5/8.
//  Copyright © 2019 Chen Kelvin. All rights reserved.
//

import UIKit
import SDWebImage

class PodcastCell: UITableViewCell {
    
    @IBOutlet weak var podcastImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var episodeCountLabel: UILabel!
    
    var podcast: Podcast! {
        didSet {
            trackNameLabel.text = podcast.trackName
            artistNameLabel.text = podcast.artistName
            
            episodeCountLabel.text = "\(podcast.trackCount ?? 0) episodes"
            
            guard let url = URL(string: podcast.artworkUrl600?.toSecureHTTPS() ?? "") else {
                return
            }
//            URLSession.shared.dataTask(with: url) { (data, _, _) in
//                print("Finish downloading image data:", data ?? "")
//
//                guard let data = data else {return}
//                DispatchQueue.main.async {
//                    self.podcastImageView.image = UIImage(data: data)
//                }
//
//            }.resume()
            
            podcastImageView.sd_setImage(with: url, completed: nil)
        }
    }
}
