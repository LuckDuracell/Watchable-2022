//
//  GuideBox.swift
//  Watchable
//
//  Created by Luke Drushell on 3/30/22.
//

import Foundation

struct WatchableItem: Codable {
    var title: String
    var release: Date
    var source: String
    var sourceType: String
    var poster: URL
    var season: Int
}
