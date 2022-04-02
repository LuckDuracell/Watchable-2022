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
            //Prototype()
        }
    }
}



func colorToScheme(theScheme: String) -> ColorScheme {
    @Environment(\.colorScheme) var cScheme
    var output: ColorScheme = cScheme
    
    if theScheme == "Always Dark" {
        output = .dark
    } else if theScheme == "Always Light" {
        output = .light
    }
    
    return output
}
