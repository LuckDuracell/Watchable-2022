//
//  WatchableApp.swift
//  WatchableApp
//
//  Created by Luke Drushell on 7/29/21.
//

import SwiftUI

@main
struct WatchableApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


func updateColors(settings: [UserSettings]) -> ColorScheme {
    @Environment(\.colorScheme) var deviceColor
    var output = deviceColor
    if settings.isEmpty == false {
        if settings[0].colorScheme == "Always Light" {
            output = .light
        } else if settings[0].colorScheme == "Always Dark" {
            output = .dark
        }
    }
    print(deviceColor)
    return output
}
