//
//  WatchableOverlay.swift
//  WatchableOverlay
//
//  Created by Luke Drushell on 8/7/21.
//

import SwiftUI

struct WatchableOverlay: View {
    
    let activeMovies: [MovieV3]
    let activeShows: [ShowV3]
    let inactiveMovies: [MovieV3]
    let inactiveShows: [ShowV3]
    let upcomingMovies: [MovieV3]
    let upcomingShows: [ShowV3]
    @Binding var showTotalOverlay: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center)
                .background(.black)
                .edgesIgnoringSafeArea(.all)
                .opacity(0.35)
                .onTapGesture(perform: {
                    withAnimation {
                        showTotalOverlay = false
                    }
                })
            VStack {
                Text("Watchable")
                    .bold()
                    .padding(.vertical, 2)
                Text("Movies: \(activeMovies.count + inactiveMovies.count)")
                Text("Shows: \(activeShows.count + inactiveShows.count)")
                Text("Upcoming")
                    .bold()
                    .padding(.vertical, 2)
                Text("Movies: \(upcomingMovies.count)")
                Text("Shows: \(upcomingShows.count)")
//                Text("Total - \(upcomingMovies.count + inactiveMovies.count + activeMovies.count + upcomingShows.count + inactiveShows.count + activeShows.count)")
//                    .bold()
//                    .padding(.vertical, 2)
            }
                .padding()
                .frame(width: UIScreen.main.bounds.width*0.38, height: UIScreen.main.bounds.height*0.24, alignment: .center)
                .background(.regularMaterial)
                .cornerRadius(radius: 14, corners: [.bottomLeft, .bottomRight, .topRight])
                .scaleEffect(showTotalOverlay ? 1 : 0.5)
                .position(x: showTotalOverlay ? screenSize(true)*0.3 : screenSize(true)*0.1, y: showTotalOverlay ? screenSize(false)*0.18 : screenSize(false)*0.08)
        }

    }
}

func screenSize(_ direction: Bool) -> CGFloat {
    print("gathering screen size")
    var output: CGFloat = 0
    if direction {
        output = UIScreen.main.bounds.width
    } else {
        output = UIScreen.main.bounds.height
    }
    return output
}
