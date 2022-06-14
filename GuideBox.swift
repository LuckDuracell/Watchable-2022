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
    var themes: [String] //action, comedy, drama, etc.
    var release: Date //day that item premiered
    var synopsis: String
    var sources: [String] //theater, netflix, crunchyroll ---- need seasons availible
    var itemType: Int //0 = movie, 1 = show
    var poster: URL //link to poster, needs AsyncImage
    var seasons: Int //amount of seasons released
    var releaseDay: Int //day of the week that it releases
    var currentlyReleasing: Bool // if the show is coming out each week
    
    var remindMe: Bool //if the user wants to be reminded
    var currentlyWatching: Bool //goes in watching section of list
    var folder: String
    var id: Int
}

func itemToItems(item: WatchableItem) -> WatchableItems {
    return WatchableItems(title: item.title, subtitle: item.subtitle, themes: item.themes, release: item.release, synopsis: item.synopsis, sources: item.sources, itemType: item.itemType, poster: item.poster, seasons: item.seasons, releaseDay: item.releaseDay, currentlyReleasing: item.currentlyReleasing, remindMe: item.remindMe, currentlyWatching: item.currentlyWatching, folder: item.folder)
}
