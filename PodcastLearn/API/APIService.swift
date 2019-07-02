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

extension NSNotification.Name {
    static let downloadProgress = NSNotification.Name("downloadProgress")
    static let downloadComplete = NSNotification.Name("downloadComplete")
}

class APIService {
    typealias EPDownloadCompleteTuple = (fileUrl: String, episodeTitle: String)
    
    //Singleton
    static let share = APIService()
    
    struct SearchResults: Decodable {
        let resultCount: Int
        let results: [Podcast]
    }
    
    func downloadEpisode(episode: Episode) {
        print("Downloading episode using Alamofire at:", episode.streamUrl)
        
        let downloadRequest = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory, in: .userDomainMask, options: .removePreviousFile)
        
        AF.download(episode.streamUrl, to: downloadRequest).response { (resp) in
            print("Get the URL:", resp.fileURL)
            
            let epDownloadComplete = EPDownloadCompleteTuple(fileUrl: resp.fileURL?.absoluteURL.absoluteString ?? "", episode.title)
            NotificationCenter.default.post(name: .downloadComplete, object: epDownloadComplete, userInfo: nil)
            
            var downloadEpisodes = UserDefaults.standard.downloadedEpisodes()
            guard let index = downloadEpisodes.firstIndex(where: {
                $0.title == episode.title && $0.author == episode.author
            }) else { return }
            downloadEpisodes[index].fileUrl = resp.fileURL?.absoluteURL.absoluteString ?? nil

            do {
                let data = try JSONEncoder().encode(downloadEpisodes)
                UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)
            } catch let err {
                print("Failed to encode downloaded episode with file url update:", err)
            }
            
        }.downloadProgress { (progress) in
            //print(progress.fractionCompleted)
            NotificationCenter.default.post(name: .downloadProgress, object: nil, userInfo: ["title": episode.title, "progress": progress.fractionCompleted])
        }
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
