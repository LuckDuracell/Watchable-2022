//
//  ContentView.swift
//  ContentView
//
//  Created by Luke Drushell on 7/29/21.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    
    @State var settings = UserSettings.loadFromFile()
    
    init() {
        if isFirstTimeOpening() {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    print("All set!")
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    
    var body: some View {
        MainPage(settings: $settings)
            .preferredColorScheme(updateColors(settings: settings))
    }
}
