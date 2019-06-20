//
//  APIService.swift
//  PodcastLearn
//
//  Created by Chen Kelvin on 2019/5/8.
//  Copyright © 2019 Chen Kelvin. All rights reserved.
//

import Foundation
import Alamofire
import FeedKit

class APIService {
    //Singleton
    static let share = APIService()
    
    struct SearchResults: Decodable {
        let resultCount: Int
        let results: [Podcast]
    }
    
    func fetchEpisode(withURL feedUrl: String, completionHandler: @escaping ([Episode]) -> ()) {
        
        guard let url = URL(string: feedUrl.toSecureHTTPS()) else { return }
        
        DispatchQueue.global(qos: .background).async {
            let parser = FeedParser(URL: url)
            
            parser?.parseAsync(result: { (result) in
                print("Successfully parse feed:", result.isSuccess)
                
                if let err = result.error {
                    print("Failed to parse XML feed:", err)
                    return
                }
                
                guard let feed = result.rssFeed else { return }
                let episodes = feed.toEpisodes()
                completionHandler(episodes)
            })
        }
    }
    
    func fetchPodcasts(withText searchText: String, completionHandler: @escaping ([Podcast]) -> ()) {
        print("Searching for podcasts...")
        
        let url = "https://itunes.apple.com/search"
        let parameters = ["term": searchText, "media": "podcast"]
        
        AF.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil, interceptor: nil).responseData { (dataResponse) in
            if let err = dataResponse.error {
                print("Failed to contact iTunes API", err)
                return
            }
            guard let data = dataResponse.data else {return}
            
            do {
                let searchResult = try JSONDecoder().decode(SearchResults.self, from: data)
                completionHandler(searchResult.results)
//                self.podcasts = searchResult.results
//                self.tableView.reloadData()
            } catch let decodeErr {
                print("Failed to decode:", decodeErr)
            }
        }
    }
}
