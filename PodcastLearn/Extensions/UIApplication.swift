//
//  UIApplication.swift
//  PodcastLearn
//
//  Created by Chen Kelvin on 2019/6/5.
//  Copyright © 2019 Chen Kelvin. All rights reserved.
//

import UIKit

extension UIApplication {
    static func mainTabBarController() -> MainTabBarController? {
        return shared.keyWindow?.rootViewController as? MainTabBarController
    }
}
