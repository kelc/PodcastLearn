//
//  CMTime.swift
//  PodcastLearn
//
//  Created by Chen Kelvin on 2019/5/27.
//  Copyright © 2019 Chen Kelvin. All rights reserved.
//

import AVKit

extension CMTime {
    func toDisplayString() -> String {
        if CMTimeGetSeconds(self).isNaN {
            return "--:--"
        }
        
        let totalSeconds = Int(CMTimeGetSeconds(self))
        let seconds = totalSeconds % 60
        let minutes = totalSeconds / 60 % 60
        let hours = totalSeconds / 60 / 60
        let timeFromString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        return timeFromString        
    }
}
