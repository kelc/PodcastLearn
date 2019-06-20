//
//  String.swift
//  PodcastLearn
//
//  Created by Chen Kelvin on 2019/5/14.
//  Copyright © 2019 Chen Kelvin. All rights reserved.
//

import Foundation

extension String {
    func toSecureHTTPS() -> String {
        return self.contains("https") ? self : self.replacingOccurrences(of: "http", with: "https")
    }
}
