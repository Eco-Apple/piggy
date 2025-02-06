//
//  AppVersionHelper.swift
//  Piggy
//
//  Created by Jerico Villaraza on 2/6/25.
//

import Foundation

struct AppVersionHelper {
    static var current: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    static var previous: String? {
        return UserDefaults.standard.string(forKey: "previousAppVersion")
    }
    
    static func update() {
        UserDefaults.standard.set(current, forKey: "previousAppVersion")
    }
}
