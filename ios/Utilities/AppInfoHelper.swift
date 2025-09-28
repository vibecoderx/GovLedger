//
//  AppInfoHelper.swift
//  GovLedger
//

import Foundation

struct AppInfoHelper {
    
    // A computed property to get the app's version and build number.
    static var versionInfo: String {
        guard let dictionary = Bundle.main.infoDictionary else {
            return "N/A"
        }
        let version = dictionary["CFBundleShortVersionString"] as? String ?? "N/A"
        let build = dictionary["CFBundleVersion"] as? String ?? "N/A"
        return "Version: \(version) (Build: \(build))"
    }
    
    // A new computed property to get the Git Commit SHA.
    static var gitCommitSHA: String {
        guard let dictionary = Bundle.main.infoDictionary else {
            return "N/A"
        }
        // This key matches the one we added to Info.plist and the build script.
        return dictionary["GitCommitSHA"] as? String ?? "N/A"
    }
}

