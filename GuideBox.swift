//
//  GuideBox.swift
//  Watchable
//
//  Created by Luke Drushell on 3/30/22.
//

import Foundation

struct WatchableItem: Codable {
    var title: String
    var subtitle: String
    var themes: [String]
    var release: Date
    var synopsis: String
    var sources: [String]
    var itemType: Int
    var poster: URL
    var seasons: Int
    var releaseDay: Int
    var currentlyReleasing: Bool
}
