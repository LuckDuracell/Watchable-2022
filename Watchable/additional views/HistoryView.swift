//
//  HistoryView.swift
//  Watchable
//
//  Created by Luke Drushell on 2/27/22.
//

import SwiftUI

struct HistoryView: View {
    
    @State var history = History.loadFromFile()
    
    @State var searchText = ""
    
    @State var versionNumber = VersionNumber.loadFromFile()
    
    @State var showsV2 = ShowV2.loadFromFile()
    @State var movies = Movie.loadFromFile()
    
    @State var showsV3 = ShowV3.loadFromFile()
    @State var moviesV3 = MovieV3.loadFromFile()

    @State var upcomingMovies: [MovieV3] = []
    @State var upcomingMoviesIndexs: [Int] = []
    @State var upcomingShows: [ShowV3] = []
    @State var upcomingShowsIndexs: [Int] = []
    
    @State var activeMovies: [MovieV3] = []
    @State var activeMoviesIndexs: [Int] = []
    @State var activeShows: [ShowV3] = []
    @State var activeShowsIndexs: [Int] = []
    
    @State var inactiveMovies: [MovieV3] = []
    @State var inactiveMoviesIndexs: [Int] = []
    @State var inactiveShows: [ShowV3] = []
    @State var inactiveShowsIndexs: [Int] = []
    
    @State var showNewSheet = false
    @State var showTotalOverlay = false
    
    @State var selectedItemTheme = "Default"
    @State var selectedItemPlatform = "Youtube TV"
    
    @State var ytEasterEgg = false
    
    @State private var total = 0
    
    @State var showItems = true
    
    fileprivate func loadItems() {
        
        print(" V NUM \(versionNumber)")
        print(movies)
        print(showsV2)
        
        history = History.loadFromFile()
        
        if versionNumber.isEmpty {
            movies = Movie.loadFromFile()
            showsV2 = ShowV2.loadFromFile()
            
            moviesV3 = MovieV3.loadFromFile()
            showsV3 = ShowV3.loadFromFile()
            
            for i in movies.indices {
                moviesV3.append(MovieV3(name: movies[i].name, icon: movies[i].icon, releaseDate: movies[i].releaseDate, active: movies[i].active, info: movies[i].info, platform: movies[i].platform, favorited: false))
                
            }
            for i in showsV2.indices {
                showsV3.append(ShowV3(name: showsV2[i].name, icon: showsV2[i].icon, releaseDate: showsV2[i].releaseDate, active: showsV2[i].active, info: showsV2[i].info, platform: showsV2[i].platform, reoccuring: showsV2[i].reoccuring, reoccuringDate: showsV2[i].reoccuringDate, favorited: false))
            }
            versionNumber.append(VersionNumber(ver: 1))
            VersionNumber.saveToFile(versionNumber)
            MovieV3.saveToFile(moviesV3)
            ShowV3.saveToFile(showsV3)
        }
        
        print("loading")
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        movies = Movie.loadFromFile()
        showsV2 = ShowV2.loadFromFile()
        
        moviesV3 = MovieV3.loadFromFile()
        showsV3 = ShowV3.loadFromFile()
        
        inactiveMovies.removeAll()
        inactiveShows.removeAll()
        inactiveMoviesIndexs.removeAll()
        inactiveShowsIndexs.removeAll()
        activeMovies.removeAll()
        activeMoviesIndexs.removeAll()
        activeShows.removeAll()
        activeShowsIndexs.removeAll()
        upcomingMovies.removeAll()
        upcomingMoviesIndexs.removeAll()
        upcomingShows.removeAll()
        upcomingShowsIndexs.removeAll()
        
        var releaseDates: [Date] = []
        var notifs: [String] = []
        var notifIndex = 0
        
        for index in moviesV3.indices {
            
            if moviesV3[index].active {
                activeMovies.append(moviesV3[index])
                activeMoviesIndexs.append(index)
            } else if checkUpcoming(date: moviesV3[index].releaseDate) {
                upcomingMovies.append(moviesV3[index])
                upcomingMoviesIndexs.append(index)
                if releaseDates.contains(moviesV3[index].releaseDate) {
                    notifs[releaseDates.firstIndex(of: moviesV3[index].releaseDate)!].append(", \(moviesV3[index].name)")
                } else {
                    notifIndex += 1
                    releaseDates.append(moviesV3[index].releaseDate)
                    notifs.append(moviesV3[index].name)
                }
                scheduleNotification(title: "Watchable", info: "\(moviesV3[index].name) comes out today!", date: moviesV3[index].releaseDate)
            } else {
                inactiveMovies.append(moviesV3[index])
                inactiveMoviesIndexs.append(index)
            }
        }
        
        for index in showsV3.indices {
            if showsV3[index].active {
                activeShows.append(showsV3[index])
                activeShowsIndexs.append(index)
                if showsV3[index].reoccuring {
                    let day = Calendar.current.dateComponents([.weekday], from: showsV3[index].reoccuringDate)
                    scheduleWeeklyNotification(title: "Watchable", info: "An episode of \(showsV3[index].name) comes out today!", date: createDate(weekday: day.weekday!))
                }
            } else if checkUpcoming(date: showsV3[index].releaseDate) {
                upcomingShows.append(showsV3[index])
                upcomingShowsIndexs.append(index)
                scheduleNotification(title: "Watchable", info: "\(showsV3[index].name) releases today!", date: showsV3[index].releaseDate)
            } else {
                inactiveShows.append(showsV3[index])
                inactiveShowsIndexs.append(index)
            }
        }
        
        total = activeMovies.count + activeShows.count + inactiveMovies.count + inactiveShows.count
    }
    
    
    var body: some View {
        ScrollView {
            VStack {
                if showItems {
                ForEach(history.indices, id: \.self, content: { index in
                    NavigationLink(destination: {
                            VStack {
                                VStack {
                                    Text(history[index].isMovie ? "\(history[index].mov.name) was \(historyAction(num: history[index].change))" : "\(history[index].show.name) was \(historyAction(num: history[index].change))")
                                    Text(history[index].date, format: .dateTime)
                                }
                                VStack {
                                    if history[index].change == 0 {
                                        Button {
                                            if history[index].isMovie {
                                                moviesV3.insert(history[index].mov, at: 0)
                                            } else {
                                                showsV3.insert(history[index].show, at: 0)
                                            }
                                            MovieV3.saveToFile(moviesV3)
                                            ShowV3.saveToFile(showsV3)
                                            
                                            history.insert((History(mov: history[index].mov, show: history[index].show, isMovie: history[index].isMovie, change: 1, date: Date())), at: 0)
                                            History.saveToFile(history)
                                            showItems = false
                                            print("confused")
                                        } label: {
                                            Text("Restore")
                                        }
                                    }
                                }
                            }
                    }, label: {
                        HStack {
                            Image(systemName: historyActionIcon(num: history[index].change))
                                .foregroundColor(.pink)
                                .font(.system(size: 20, weight: .medium))
                            Text(history[index].isMovie ? "\(history[index].mov.name) was \(historyAction(num: history[index].change))" : "\(history[index].show.name) was \(historyAction(num: history[index].change))")
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundColor(.primary)
                                .frame(height: 20)
                                .truncationMode(.tail)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(15)
                        .padding(.horizontal)
                    })
                })
                } else {
                    Text("")
                        .onAppear(perform: {
                            showItems = true
                            loadItems()
                        })
                }
                }  .toolbar(content: {
                    ToolbarItemGroup(placement: .navigationBarTrailing, content: {
                        Button {
                            history = []
                            History.saveToFile(history)
                        } label: {
                            Text("Clear History")
                        }
                    })
                })
        } .onAppear(perform: {
            loadItems()
        })
    }
}

func historyAction(num: Int) -> String {
    var output = ""
    switch num {
    case 0:
        output = "deleted"
    case 1:
        output = "restored"
    case 2:
        output = "favorited"
    case 3:
        output = "unfavorited"
    default:
        output = "error"
    }
    return output
}

func historyActionIcon(num: Int) -> String {
    var output = ""
    switch num {
    case 0:
        output = "trash.fill"
    case 1:
        output = "arrow.uturn.backward"
    case 2:
        output = "star.fill"
    case 3:
        output = "star.slash.fill"
    default:
        output = "error"
    }
    return output
}
