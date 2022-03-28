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
    @State var cScheme = "Match System"
    
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
            .if(cScheme != "Match System", transform: { view in
                view.preferredColorScheme(colorToScheme(theScheme: cScheme))
            })
            .onAppear(perform: {
                cScheme = settings.first?.colorScheme ?? "Match System"
            })
            .onChange(of: settings, perform: { value in
                cScheme = settings[0].colorScheme
                print("CSCHEME   " + cScheme)
            })
    }
}

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
