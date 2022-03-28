//
//  ContentView.swift
//  ContentView
//
//  Created by Luke Drushell on 7/29/21.
//

import SwiftUI
import UserNotifications

struct dayOfNotifs {
    let day: Date
    var episodes: [String]
    var premeires: [String]
}

struct MainPage: View {
    
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

    @Binding var settings: [UserSettings]
    @State var loadItemsTrigger: Bool = false
    
    fileprivate func gatherLatestData() {
        if versionNumber.isEmpty {
            movies = Movie.loadFromFile()
            showsV2 = ShowV2.loadFromFile()
            
            moviesV3 = MovieV3.loadFromFile()
            showsV3 = ShowV3.loadFromFile()
            
            for i in movies.indices {
                moviesV3.append(MovieV3(name: movies[i].name, icon: movies[i].icon, releaseDate: movies[i].releaseDate, active: movies[i].active, info: movies[i].info, platform: movies[i].platform == "Funimation" ? "Funimation" : movies[i].platform, favorited: false))
                
            }
            for i in showsV2.indices {
                showsV3.append(ShowV3(name: showsV2[i].name, icon: showsV2[i].icon, releaseDate: showsV2[i].releaseDate, active: showsV2[i].active, info: showsV2[i].info, platform: showsV2[i].platform == "Funimation" ? "Funimation" : showsV2[i].platform, reoccuring: showsV2[i].reoccuring, reoccuringDate: showsV2[i].reoccuringDate, favorited: false))
            }
            versionNumber.append(VersionNumber(ver: 1))
            VersionNumber.saveToFile(versionNumber)
            MovieV3.saveToFile(moviesV3)
            ShowV3.saveToFile(showsV3)
        } else {
            if versionNumber.first!.ver == 1 {
                let moviesTemp = moviesV3
                let showsTemp = showsV3
                moviesV3.removeAll()
                showsV3.removeAll()
                for i in moviesTemp.indices {
                    moviesV3.append(MovieV3(name: moviesTemp[i].name, icon: moviesTemp[i].icon, releaseDate: moviesTemp[i].releaseDate, active: moviesTemp[i].active, info: moviesTemp[i].info, platform: moviesTemp[i].platform == "Funimation" ? "Crunchyroll" : moviesTemp[i].platform, favorited: moviesTemp[i].favorited))
                }
                for i in showsTemp.indices {
                    showsV3.append(ShowV3(name: showsTemp[i].name, icon: showsTemp[i].icon, releaseDate: showsTemp[i].releaseDate, active: showsTemp[i].active, info: showsTemp[i].info, platform: showsTemp[i].platform == "Funimation" ? "Crunchyroll" : showsTemp[i].platform, reoccuring: showsTemp[i].reoccuring, reoccuringDate: showsTemp[i].reoccuringDate, favorited: showsTemp[i].favorited))
                }
                versionNumber[0].ver = 2
                VersionNumber.saveToFile(versionNumber)
                MovieV3.saveToFile(moviesV3)
                ShowV3.saveToFile(showsV3)
            }
        }
    }
    
    fileprivate func loadItems() {
        
        loadItemsTrigger = false
        print(" V NUM \(versionNumber)")
        print(movies)
        print(showsV2)
        
        gatherLatestData()
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        moviesV3 = MovieV3.loadFromFile()
        showsV3 = ShowV3.loadFromFile()
        
        settings = UserSettings.loadFromFile()
        
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
        NavigationView {
            ScrollView {
                ZStack {
                    //background object to reload page
                    if movies.count == 0 && showsV2.count == 0 {
                        VStack {
                            Spacer()
                            Text("Welcome to Watchable!")
                                .font(.title2)
                                .multilineTextAlignment(.center)
                                .padding()
                            Image(systemName: "tv.inset.filled")
                                .resizable()
                                .frame(width: 200, height: 160, alignment: .center)
                                .foregroundColor(.pink)
                            Text("Hit the plus in the top right to add your first Movie or Show")
                                .font(.title2)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                    }
                    VStack {
                        if (upcomingMovies.count != 0 || upcomingShows.count != 0) {
                            if (arrayContains(movies: upcomingMovies, shows: upcomingShows, text: searchText, showsFavorites: (settings.first?.showFavorites ?? true)) || searchText == "") {
                                HStack {
                                    Text("Upcoming:")
                                        .foregroundColor(.gray)
                                        .padding(.top, 25)
                                        .onTapGesture(count: 3, perform: {
                                            //ytEasterEgg.toggle()
                                        })
                                    Spacer()
                                } .padding(.horizontal)
                                    .onAppear(perform: {
                                        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                                            loadItems()
                                        })
                                    })
                            }
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], content: {
                                ForEach(upcomingMovies.indices, id:\.self, content: { index in
                                    if upcomingMovies[index].name.lowercased().contains(searchText.lowercased()) || upcomingMovies[index].info.lowercased().contains(searchText.lowercased()) || getTypeForImage(image: upcomingMovies[index].icon).lowercased().contains(searchText.lowercased()) || upcomingMovies[index].platform.lowercased().contains(searchText.lowercased()) || searchText == "" {
                                        if upcomingMovies[index].favorited == false || (settings.first?.showFavorites ?? true) {
                                    NavigationLink(destination: {
                                        editPage(movies: $moviesV3, showsV3: $showsV3, upcomingMovies: $upcomingMovies, upcomingMoviesIndexs: $upcomingMoviesIndexs, upcomingShows: $upcomingShows, upcomingShowsIndexs: $upcomingShowsIndexs, activeMovies: $activeMovies, activeMoviesIndexs: $activeMoviesIndexs, activeShows: $activeShows, activeShowsIndexs: $activeShowsIndexs, inactiveMovies: $inactiveMovies, inactiveMoviesIndexs: $inactiveMoviesIndexs, inactiveShows: $inactiveShows, inactiveShowsIndexs: $inactiveShowsIndexs, iconTheme: selectedItemTheme, theTitle: upcomingMovies[index].name, theSelectedDate: upcomingMovies[index].releaseDate, theShowDate: true, theNotes: upcomingMovies[index].info, type: "Movie", theIconTheme: getTypeForImage(image: upcomingMovies[index].icon), thePlatform: upcomingMovies[index].platform, theReoccuringDay: "Sunday", theActive: upcomingMovies[index].active, theReoccuring: false, theFavorite: upcomingMovies[index].favorited, ogType: 0, typeIndex: index)
                                    }, label: {
                                        VStack {
                                            HStack {
                                                ZStack {
                                                    Circle()
                                                        .frame(width: 28, height: 28, alignment: .center)
                                                        .foregroundColor(.pink)
                                                    Image(systemName: upcomingMovies[index].icon)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 12, height: 12)
                                                        .foregroundColor(.white)
                                                } .padding(-5)
                                                Text("  Days: \(dayDifference(date1: Date(), date2: upcomingMovies[index].releaseDate))")
                                                    .frame(height: 20)
                                                    .truncationMode(.tail)
                                                Spacer()
                                            }

                                            Text("\(upcomingMovies[index].name)")
                                                .font(.system(size: 16, weight: .medium))
                                                .frame(height: 20)
                                                .truncationMode(.tail)
                                        }
                                        .foregroundColor(.primary)
                                        .padding()
                                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                                    })
                                    }
                                    }
                                })
                            }) .padding(.horizontal)
                            if upcomingMovies.count != 0 && upcomingShows.count != 0 && searchText == "" {
                                Rectangle()
                                    .frame(height: 2, alignment: .center)
                                    .foregroundColor(.gray.opacity(0.3))
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                            }
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], content: {
                                ForEach(upcomingShows.indices, id: \.self, content: { index in
                                    if upcomingShows[index].name.lowercased().contains(searchText.lowercased()) || upcomingShows[index].info.lowercased().contains(searchText.lowercased()) || getTypeForImage(image: upcomingShows[index].icon).lowercased().contains(searchText.lowercased()) || upcomingShows[index].platform.lowercased().contains(searchText.lowercased()) || searchText == "" {
                                        if upcomingShows[index].favorited == false || (settings.first?.showFavorites ?? true) {
                                    NavigationLink(destination: {
                                        editPage(movies: $moviesV3, showsV3: $showsV3, upcomingMovies: $upcomingMovies, upcomingMoviesIndexs: $upcomingMoviesIndexs, upcomingShows: $upcomingShows, upcomingShowsIndexs: $upcomingShowsIndexs, activeMovies: $activeMovies, activeMoviesIndexs: $activeMoviesIndexs, activeShows: $activeShows, activeShowsIndexs: $activeShowsIndexs, inactiveMovies: $inactiveMovies, inactiveMoviesIndexs: $inactiveMoviesIndexs, inactiveShows: $inactiveShows, inactiveShowsIndexs: $inactiveShowsIndexs, iconTheme: selectedItemTheme, theTitle: upcomingShows[index].name, theSelectedDate: upcomingShows[index].releaseDate, theShowDate: true, theNotes: upcomingShows[index].info, type: "Show", theIconTheme: getTypeForImage(image: upcomingShows[index].icon), thePlatform: upcomingShows[index].platform, theReoccuringDay: dateToWeekdayString(day: upcomingShows[index].reoccuringDate), theActive: upcomingShows[index].active, theReoccuring: upcomingShows[index].reoccuring, theFavorite: upcomingShows[index].favorited, ogType: 0, typeIndex: index)
                                    }, label: {
                                        VStack {
                                            HStack {
                                                ZStack {
                                                    Circle()
                                                        .frame(width: 28, height: 28, alignment: .center)
                                                        .foregroundColor(.pink)
                                                    Image(systemName: upcomingShows[index].icon)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 12, height: 12)
                                                        .foregroundColor(.white)
                                                } .padding(-5)
                                                Text("  Days: \(dayDifference(date1: Date(), date2: upcomingShows[index].releaseDate))")
                                                    .frame(height: 20)
                                                    .truncationMode(.tail)
                                                Spacer()
                                            }

                                            Text("\(upcomingShows[index].name)")
                                                .font(.system(size: 16, weight: .medium))
                                                .frame(height: 20)
                                                .truncationMode(.tail)
                                        }
                                        .foregroundColor(.primary)
                                        .padding()
                                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                                    })
                                }
                                    }
                                })
                            }) .padding(.horizontal)
                        }
                        if (activeMovies.count != 0 || activeShows.count != 0) {
                            if (arrayContains(movies: activeMovies, shows: activeShows, text: searchText, showsFavorites: (settings.first?.showFavorites ?? true)) || searchText == "") {
                                HStack {
                                    Text("Watching:")
                                        .foregroundColor(.gray)
                                        .padding(.top, 25)
                                    Spacer()
                                } .padding(.horizontal)
                            }
                        ForEach(activeMovies.indices, id: \.self, content: { index in
                            if activeMovies[index].name.lowercased().contains(searchText.lowercased()) || activeMovies[index].info.lowercased().contains(searchText.lowercased()) || getTypeForImage(image: activeMovies[index].icon).lowercased().contains(searchText.lowercased()) || activeMovies[index].platform.lowercased().contains(searchText.lowercased()) || searchText == "" {
                                if activeMovies[index].favorited == false || (settings.first?.showFavorites ?? true) {
                            NavigationLink(destination: {
                                editPage(movies: $moviesV3, showsV3: $showsV3, upcomingMovies: $upcomingMovies, upcomingMoviesIndexs: $upcomingMoviesIndexs, upcomingShows: $upcomingShows, upcomingShowsIndexs: $upcomingShowsIndexs, activeMovies: $activeMovies, activeMoviesIndexs: $activeMoviesIndexs, activeShows: $activeShows, activeShowsIndexs: $activeShowsIndexs, inactiveMovies: $inactiveMovies, inactiveMoviesIndexs: $inactiveMoviesIndexs, inactiveShows: $inactiveShows, inactiveShowsIndexs: $inactiveShowsIndexs, iconTheme: selectedItemTheme, theTitle: activeMovies[index].name, theSelectedDate: activeMovies[index].releaseDate, theShowDate: false, theNotes: activeMovies[index].info, type: "Movie", theIconTheme: getTypeForImage(image: activeMovies[index].icon), thePlatform: activeMovies[index].platform, theReoccuringDay: "Sunday", theActive: activeMovies[index].active, theReoccuring: false, theFavorite: activeMovies[index].favorited, ogType: 1, typeIndex: index)
                            }, label: {
                                HStack {
                                    Image(systemName: activeMovies[index].icon)
                                        .foregroundColor(.pink)
                                        .font(.system(size: 20, weight: .medium))
                                    Text(activeMovies[index].name)
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
                        }
                            }
                        })
                        if activeMovies.count != 0 && activeShows.count != 0 && searchText == "" {
                            Rectangle()
                                .frame(height: 2, alignment: .center)
                                .foregroundColor(.gray.opacity(0.3))
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                        ForEach(activeShows.indices, id: \.self, content: { index in
                            if activeShows[index].name.lowercased().contains(searchText.lowercased()) || activeShows[index].info.lowercased().contains(searchText.lowercased()) || getTypeForImage(image: activeShows[index].icon).lowercased().contains(searchText.lowercased()) || activeShows[index].platform.lowercased().contains(searchText.lowercased()) || searchText == "" {
                                if activeShows[index].favorited == false || (settings.first?.showFavorites ?? true) {
                            NavigationLink(destination: {
                                editPage(movies: $moviesV3, showsV3: $showsV3, upcomingMovies: $upcomingMovies, upcomingMoviesIndexs: $upcomingMoviesIndexs, upcomingShows: $upcomingShows, upcomingShowsIndexs: $upcomingShowsIndexs, activeMovies: $activeMovies, activeMoviesIndexs: $activeMoviesIndexs, activeShows: $activeShows, activeShowsIndexs: $activeShowsIndexs, inactiveMovies: $inactiveMovies, inactiveMoviesIndexs: $inactiveMoviesIndexs, inactiveShows: $inactiveShows, inactiveShowsIndexs: $inactiveShowsIndexs, iconTheme: selectedItemTheme, theTitle: activeShows[index].name, theSelectedDate: activeShows[index].releaseDate, theShowDate: false, theNotes: activeShows[index].info, type: "Show", theIconTheme: getTypeForImage(image: activeShows[index].icon), thePlatform: activeShows[index].platform, theReoccuringDay: dateToWeekdayString(day: activeShows[index].reoccuringDate), theActive: activeShows[index].active, theReoccuring: activeShows[index].reoccuring, theFavorite: activeShows[index].favorited, ogType: 1, typeIndex: index)
                            }, label: {
                                HStack {
                                    Image(systemName: activeShows[index].icon)
                                        .foregroundColor(.pink)
                                        .font(.system(size: 20, weight: .medium))
                                    Text(activeShows[index].name)
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
                        }
                            }
                        })
                        }
                        if inactiveMovies.count != 0 || inactiveShows.count != 0 {
                            if (arrayContains(movies: inactiveMovies, shows: inactiveShows, text: searchText, showsFavorites: (settings.first?.showFavorites ?? true)) || searchText == "") {
                                HStack {
                                    Text("Need to Watch:")
                                        .foregroundColor(.gray)
                                        .padding(.top, 25)
                                    Spacer()
                                } .padding(.horizontal)
                            }
                        ForEach(inactiveMovies.indices, id: \.self, content: { index in
                            if inactiveMovies[index].name.lowercased().contains(searchText.lowercased()) || inactiveMovies[index].info.lowercased().contains(searchText.lowercased()) || getTypeForImage(image: inactiveMovies[index].icon).lowercased().contains(searchText.lowercased()) || inactiveMovies[index].platform.lowercased().contains(searchText.lowercased()) || searchText == "" {
                                if inactiveMovies[index].favorited == false || (settings.first?.showFavorites ?? true) {
                            NavigationLink(destination: {
                                editPage(movies: $moviesV3, showsV3: $showsV3, upcomingMovies: $upcomingMovies, upcomingMoviesIndexs: $upcomingMoviesIndexs, upcomingShows: $upcomingShows, upcomingShowsIndexs: $upcomingShowsIndexs, activeMovies: $activeMovies, activeMoviesIndexs: $activeMoviesIndexs, activeShows: $activeShows, activeShowsIndexs: $activeShowsIndexs, inactiveMovies: $inactiveMovies, inactiveMoviesIndexs: $inactiveMoviesIndexs, inactiveShows: $inactiveShows, inactiveShowsIndexs: $inactiveShowsIndexs, iconTheme: selectedItemTheme, theTitle: inactiveMovies[index].name, theSelectedDate: inactiveMovies[index].releaseDate, theShowDate: false, theNotes: inactiveMovies[index].info, type: "Movie", theIconTheme: getTypeForImage(image: inactiveMovies[index].icon), thePlatform: inactiveMovies[index].platform, theReoccuringDay: "Sunday", theActive: inactiveMovies[index].active, theReoccuring: false, theFavorite: inactiveMovies[index].favorited, ogType: 2, typeIndex: index)
                            }, label: {
                                HStack {
                                    Image(systemName: inactiveMovies[index].icon)
                                        .foregroundColor(.pink)
                                        .font(.system(size: 20, weight: .medium))
                                    Text(inactiveMovies[index].name)
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
                            }
                            }
                        })
                        if inactiveMovies.count != 0 && inactiveShows.count != 0 && searchText == "" {
                            Rectangle()
                                .frame(height: 2, alignment: .center)
                                .foregroundColor(.gray.opacity(0.3))
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                            ForEach(inactiveShows.indices, id: \.self, content: { index in
                            if inactiveShows[index].name.lowercased().contains(searchText.lowercased()) || inactiveShows[index].info.lowercased().contains(searchText.lowercased()) || getTypeForImage(image: inactiveShows[index].icon).lowercased().contains(searchText.lowercased()) || inactiveShows[index].platform.lowercased().contains(searchText.lowercased()) || searchText == "" {
                                if inactiveShows[index].favorited == false || (settings.first?.showFavorites ?? true) {
                            NavigationLink(destination: {
                                editPage(movies: $moviesV3, showsV3: $showsV3, upcomingMovies: $upcomingMovies, upcomingMoviesIndexs: $upcomingMoviesIndexs, upcomingShows: $upcomingShows, upcomingShowsIndexs: $upcomingShowsIndexs, activeMovies: $activeMovies, activeMoviesIndexs: $activeMoviesIndexs, activeShows: $activeShows, activeShowsIndexs: $activeShowsIndexs, inactiveMovies: $inactiveMovies, inactiveMoviesIndexs: $inactiveMoviesIndexs, inactiveShows: $inactiveShows, inactiveShowsIndexs: $inactiveShowsIndexs, iconTheme: selectedItemTheme, theTitle: inactiveShows[index].name, theSelectedDate: inactiveShows[index].releaseDate, theShowDate: false, theNotes: inactiveShows[index].info, type: "Show", theIconTheme: getTypeForImage(image: inactiveShows[index].icon), thePlatform: inactiveShows[index].platform, theReoccuringDay: dateToWeekdayString(day: inactiveShows[index].reoccuringDate), theActive: inactiveShows[index].active, theReoccuring: inactiveShows[index].reoccuring, theFavorite: inactiveShows[index].favorited, ogType: 2, typeIndex: index)
                            }, label: {
                                HStack {
                                    Image(systemName: inactiveShows[index].icon)
                                        .foregroundColor(.pink)
                                        .font(.system(size: 20, weight: .medium))
                                    Text(inactiveShows[index].name)
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
                            }
                            }
                        })
                    }
                    }
                }
               // .navigationBarTitle("Watchable", displayMode: showTotalOverlay ? .inline : .automatic)
                .navigationBarTitle("Watchable", displayMode: .inline)
                .navigationBarItems(
                    leading:
//                        Button {
//                            withAnimation {
//                                showTotalOverlay.toggle()
//                            }
//                        } label: {
//                            Text("\(total)")
//                        }
                    NavigationLink(destination: {
                        SettingsPage(settings: $settings, activeMovies: $activeMovies, activeShows: $activeShows, inactiveMovies: $inactiveMovies, inactiveShows: $inactiveShows, upcomingMovies: $upcomingMovies, upcomingShows: $upcomingShows, loadItemsTrigger: $loadItemsTrigger)
                            .onAppear(perform: {
                                loadItems()
                            })
                            .onChange(of: loadItemsTrigger, perform: { value in
                                loadItems()
                            })
                    }, label: {
                        Image(systemName: "gearshape")
                    })
                    ,
                    trailing:
                        Button {
                            showNewSheet.toggle()
                        } label: {
                            Image(systemName: "plus")
                        }
                )
                
            }
            .searchable(text: $searchText)
            .disableAutocorrection(true)
            .onAppear(perform: {
                loadItems()
                if settings.isEmpty {
                    settings.append(UserSettings(showFavorites: true, colorScheme: "Match System"))
                    UserSettings.saveToFile(settings)
                }
            })
            .sheet(isPresented: $showNewSheet, onDismiss: {
                loadItems()
            },content: {
                NewSheet(showSheet: $showNewSheet, movies: $moviesV3, showsV3: $showsV3)
                    .interactiveDismissDisabled(true)
                    .accentColor(.pink)
                    .toggleStyle(SwitchToggleStyle(tint: Color.pink))
            })
        } .accentColor(.pink)
//        .alert(isPresented: $ytEasterEgg, content: {
//            Alert(title: Text("Oh cool you found an easter egg!"), primaryButton: .destructive(Text(UIApplication.shared.alternateIconName == "AppIcon-1" ? "Give me the old icon back" : "Gimme my prize"), action: {
//                if UIApplication.shared.alternateIconName == "AppIcon-1" {
//                    UIApplication.shared.setAlternateIconName(nil)
//                } else {
//                    UIApplication.shared.setAlternateIconName("AppIcon-1")
//                }
//                ytEasterEgg = true
//                print("toggling icon")
//            }), secondaryButton: .cancel(Text("Ew gross go away")))
//        })
    }
}

func checkUpcoming(date: Date) -> Bool {
    
    let calendar = Calendar(identifier: .gregorian)
    var components = DateComponents()
    components.calendar = Calendar.current
    components.month = calendar.component(.month, from: date)
    components.day = calendar.component(.day, from: date)
    components.year = calendar.component(.year, from: date)
    components.hour = 0
    components.minute = 1
    components.second = 0
    components.timeZone = .current

    let itemDate = calendar.date(from: components)!
    
    if itemDate > Date() {
        return true
    } else {
        return false
    }
}

struct NavigationConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void = { _ in }

    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>) -> UIViewController {
        UIViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationConfigurator>) {
        if let nc = uiViewController.navigationController {
            self.configure(nc)
        }
    }

}


func dayDifference(date1: Date, date2: Date) -> Int {
    let day1 = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: date1)!
    let day2 = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: date2)!
    
    let diffs = Calendar.current.dateComponents([.day], from: day1, to: day2)
    return diffs.day!
}

struct editPage: View {
    
    @State var history = History.loadFromFile()
    
    @Binding var movies: [MovieV3]
    @Binding var showsV3: [ShowV3]
    @Binding var upcomingMovies: [MovieV3]
    @Binding var upcomingMoviesIndexs: [Int]
    @Binding var upcomingShows: [ShowV3]
    @Binding var upcomingShowsIndexs: [Int]
    
    @Binding var activeMovies: [MovieV3]
    @Binding var activeMoviesIndexs: [Int]
    @Binding var activeShows: [ShowV3]
    @Binding var activeShowsIndexs: [Int]
    
    @Binding var inactiveMovies: [MovieV3]
    @Binding var inactiveMoviesIndexs: [Int]
    @Binding var inactiveShows: [ShowV3]
    @Binding var inactiveShowsIndexs: [Int]
    
    @State var showPickers = false
    
    @State private var selectedDate: Date = Date()
    @State private var showDate: Bool = false
    @State var title = ""
    @State private var notes = ""
    @State var iconTheme = "Default"
    @State var themeTypes = ["Default", "Action", "Fantasy", "Sci-Fi", "Drama", "Comedy", "Romance", "Horror", "Documentary", "Game Show"]
    @State var platformTypes = ["Theater", "Netflix", "Hulu", "HBO Max", "Prime Video", "Disney+", "Youtube TV", "Apple TV", "Peacock", "Crunchyroll", "Paid Only", "Unknown"]
    @State var platform = "Theater"
    @State var reoccuringTypes = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    @State var reoccuringDay = "Sunday"
    @State var active = false
    @State var reoccuring = false
    @State var favorited = false
    
    let theTitle: String
    let theSelectedDate: Date
    let theShowDate: Bool
    let theNotes: String
    let type: String
    let theIconTheme: String
    let thePlatform: String
    let theReoccuringDay: String
    let theActive: Bool
    let theReoccuring: Bool
    
    let theFavorite: Bool
    
    let ogType: Int
    let typeIndex: Int
    
    @State var showAlert = false
    
    @State var deleting = false
    
    @State var neverLoaded = true
    
    @FocusState var showKeyboard: Bool
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        Form {
            
            if checkUpcoming(date: selectedDate) {
                HStack {
                    Spacer()
                    Text("\(type) releases in \(dayDifference(date1: Date(), date2: selectedDate)) Day\(dayDifference(date1: Date(), date2: selectedDate) == 1 ? "" : "s")")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.pink)
                    Spacer()
                }
            }
            
            Section(header: Text("Title"), content: {
                TextField("", text: $title)
                    .autocapitalization(.words)
                    .disableAutocorrection(true)
                    .keyboardType(.alphabet)
                    .focused($showKeyboard)
            })
            Section(header: Text("Notes"), content: {
                TextEditor(text: $notes)
                    .keyboardType(.alphabet)
                    .focused($showKeyboard)
            })
            
            if showPickers {
                Section {
                    Picker("Theme", selection: $iconTheme, content: {
                        ForEach(themeTypes, id: \.self, content: {
                            editPickerLabel(name: $0, image: getImageForType(type: $0))
                                .foregroundColor(.pink)
                        })
                    })
                    Picker("Platform", selection: $platform, content: {
                        ForEach(platformTypes, id: \.self, content: {
                            Text($0)
                                .foregroundColor(.pink)
                        })
                    })
                }
            }
            
            Section {
                if active != true {
                    Toggle("Upcoming", isOn: $showDate)
                        
                    if showDate {
                        DatePicker("Release Date", selection: $selectedDate, in: Date()...,displayedComponents: .date)
                            .datePickerStyle(.automatic)
                            .animation(.default, value: 1)
                    }
                }
            }
            
            Section {
                Toggle("Currently Watching", isOn: $active)
                if type == "Show" {
                    Toggle("Reocurring", isOn: $reoccuring)
                    if reoccuring {
                        Picker("Releases", selection: $reoccuringDay, content: {
                            ForEach(reoccuringTypes, id: \.self, content: {
                                Text($0)
                            })
                        })
                    }
                }
            }
            
            if platform != "Default" && platform != "Theater" && platform != "Unknown" && platform != "Paid Only" {
            Section {
                Button {
                    let titleReformatted = title.replacingOccurrences(of: "?", with: "%3F").replacingOccurrences(of: " ", with: "%20")
//                    searchLink = "https://reelgood.com/search?q=\(titleReformatted)"
//                    showWeb = true
                    
//                   UIApplication.shared.open(URL(string: "https://tv.apple.com/us/search/id?q=\(titleReformatted)")!)
                   //UIApplication.shared.open(URL(string: "videos://search?=\(titleReformatted)")!)
                    
                    switch platform {
                    case "Netflix":
                        UIApplication.shared.open(URL(string: "https://netflix.com/search?q=\(titleReformatted)")!)
                    case "Hulu":
                        UIApplication.shared.open(URL(string: "hulu://search")!)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            UIApplication.shared.open(URL(string: "https://hulu.com")!)
                        })
                    case "HBO Max":
                        UIApplication.shared.open(URL(string: "https://play.hbomax.com/search/")!)
                    case "Prime Video":
                        UIApplication.shared.open(URL(string: "aiv://aiv/search")!)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            UIApplication.shared.open(URL(string: "https://primevideo.com")!)
                        })
                    case "Disney+":
                        UIApplication.shared.open(URL(string: "https://disneyplus.com/search/")!)
                    case "Youtube TV":
                        UIApplication.shared.open(URL(string: "https://tv.youtube.com/search/\(titleReformatted)")!)
                    case "Apple TV":
                        UIApplication.shared.open(URL(string: "videos://search")!)
                    case "Peacock":
                        UIApplication.shared.open(URL(string: "peacock://")!)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            UIApplication.shared.open(URL(string: "https://peacocktv.com")!)
                        })
                    case "Crunchyroll":
                        UIApplication.shared.open(URL(string: "crunchyroll://")!)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            UIApplication.shared.open(URL(string: "https://crunchyroll.com")!)
                        })
                    default:
                        print("ERROR: NO APPLICATION ASSOSIATED WITH PLATFORM, THIS BUTTON SHOULD NOT HAVE BEEN VISIBLE")
                    }
                } label: {
                    Label("Open \(platform)", systemImage: "arrow.up.right.square.fill")
                }
            }
            }
            
            Section {
                Button {
                    showAlert.toggle()
                } label: {
                    Text("Delete")
                        .foregroundColor(.white)
                        .bold()
                        .frame(width: 300, height: 50, alignment: .center)
                        .background(Color.pink)
                        .cornerRadius(15)
                        //.shadow(color: .black.opacity(0.4), radius: 15)
                        //.padding()
                }
            }
            .listRowBackground(Color.clear)
            
        }
        .toolbar(content: {
            ToolbarItemGroup(placement: .keyboard, content: {
                HStack {
                    Spacer()
                    Button {
                        showKeyboard = false
                    } label: {
                        Text("Done")
                    }
                }
            })
        })
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle("Edit \(type)")
        .navigationBarItems(trailing:
                                HStack {
            Button {
                favorited.toggle()
                if favorited {
                    if type == "Movie" {
                        history.insert(History(mov: MovieV3(name: title, icon: getImageForType(type: iconTheme), releaseDate: selectedDate, active: active, info: notes, platform: platform, favorited: favorited), show: ShowV3(name: title, icon: getImageForType(type: iconTheme), releaseDate: selectedDate, active: active, info: notes, platform: platform, reoccuring: reoccuring, reoccuringDate: createDate(weekday: dayToInt(day: reoccuringDay)), favorited: favorited), isMovie: true, change: 2, date: Date()), at: 0)
                    } else {
                        history.insert(History(mov: MovieV3(name: title, icon: getImageForType(type: iconTheme), releaseDate: selectedDate, active: active, info: notes, platform: platform, favorited: favorited), show: ShowV3(name: title, icon: getImageForType(type: iconTheme), releaseDate: selectedDate, active: active, info: notes, platform: platform, reoccuring: reoccuring, reoccuringDate: createDate(weekday: dayToInt(day: reoccuringDay)), favorited: favorited), isMovie: false, change: 2, date: Date()), at: 0)
                    }
                } else {
                    if type == "Movie" {
                        history.insert(History(mov: MovieV3(name: title, icon: getImageForType(type: iconTheme), releaseDate: selectedDate, active: active, info: notes, platform: platform, favorited: favorited), show: ShowV3(name: title, icon: getImageForType(type: iconTheme), releaseDate: selectedDate, active: active, info: notes, platform: platform, reoccuring: reoccuring, reoccuringDate: createDate(weekday: dayToInt(day: reoccuringDay)), favorited: favorited), isMovie: true, change: 3, date: Date()), at: 0)
                    } else {
                        history.insert(History(mov: MovieV3(name: title, icon: getImageForType(type: iconTheme), releaseDate: selectedDate, active: active, info: notes, platform: platform, favorited: favorited), show: ShowV3(name: title, icon: getImageForType(type: iconTheme), releaseDate: selectedDate, active: active, info: notes, platform: platform, reoccuring: reoccuring, reoccuringDate: createDate(weekday: dayToInt(day: reoccuringDay)), favorited: favorited), isMovie: false, change: 3, date: Date()), at: 0)
                    }
                }
                History.saveToFile(history)
            } label: {
                Image(systemName: favorited ? "star.fill" : "star" )
            }
            Button {
                print("disappear")
                if deleting != true {
                    if type == "Movie" {
                        switch ogType {
                            case 0:
                                print("0")
                                movies.remove(at: upcomingMoviesIndexs[typeIndex])
                            case 1:
                                print("1")
                                movies.remove(at: activeMoviesIndexs[typeIndex])
                            default:
                                print("2")
                                movies.remove(at: inactiveMoviesIndexs[typeIndex])
                        }
                    } else {
                        switch ogType {
                            case 0:
                                print("0")
                                showsV3.remove(at: upcomingShowsIndexs[typeIndex])
                            case 1:
                                print("1")
                                showsV3.remove(at: activeShowsIndexs[typeIndex])
                            default:
                                print("2")
                                showsV3.remove(at: inactiveShowsIndexs[typeIndex])
                        }
                    }
                    if type == "Movie" {
                        if title != "" {
                            if active {
                                selectedDate = Date()
                            }
                            movies.insert(MovieV3(name: title, icon: getImageForType(type: iconTheme), releaseDate: selectedDate, active: active, info: notes, platform: platform, favorited: favorited), at: 0)
                            MovieV3.saveToFile(movies)
                        }
                    } else {
                        if title != "" {
                            if active {
                                selectedDate = Date()
                            }
                            showsV3.insert(ShowV3(name: title, icon: getImageForType(type: iconTheme), releaseDate: selectedDate, active: active, info: notes, platform: platform, reoccuring: reoccuring, reoccuringDate: createDate(weekday: dayToInt(day: reoccuringDay)), favorited: favorited), at: 0)
                            ShowV3.saveToFile(showsV3)
                        }
                    }
                    self.presentationMode.wrappedValue.dismiss()
                }
            } label: {
                Text("Save")
            }
        }
        )
        .alert("Delete \(type)?", isPresented: $showAlert, actions: {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if type == "Movie" {
                    
                    history.append(History(mov: MovieV3(name: title, icon: getImageForType(type: iconTheme), releaseDate: selectedDate, active: active, info: notes, platform: platform, favorited: favorited), show: ShowV3(name: title, icon: getImageForType(type: iconTheme), releaseDate: selectedDate, active: active, info: notes, platform: platform, reoccuring: reoccuring, reoccuringDate: createDate(weekday: dayToInt(day: reoccuringDay)), favorited: favorited), isMovie: true, change: 0, date: Date()))
                    
                    switch ogType {
                        case 0:
                            print("0")
                            movies.remove(at: upcomingMoviesIndexs[typeIndex])
                        case 1:
                            print("1")
                            movies.remove(at: activeMoviesIndexs[typeIndex])
                        default:
                            print("2")
                            movies.remove(at: inactiveMoviesIndexs[typeIndex])
                    }
                } else {
                        
                    history.append(History(mov: MovieV3(name: title, icon: getImageForType(type: iconTheme), releaseDate: selectedDate, active: active, info: notes, platform: platform, favorited: favorited), show: ShowV3(name: title, icon: getImageForType(type: iconTheme), releaseDate: selectedDate, active: active, info: notes, platform: platform, reoccuring: reoccuring, reoccuringDate: createDate(weekday: dayToInt(day: reoccuringDay)), favorited: favorited), isMovie: false, change: 0, date: Date()))
                        
                    switch ogType {
                        case 0:
                            print("0")
                        showsV3.remove(at: upcomingShowsIndexs[typeIndex])
                        case 1:
                            print("1")
                        showsV3.remove(at: activeShowsIndexs[typeIndex])
                        default:
                            print("2")
                        showsV3.remove(at: inactiveShowsIndexs[typeIndex])
                    }
                }
                History.saveToFile(history)
                MovieV3.saveToFile(movies)
                ShowV3.saveToFile(showsV3)
                deleting = true
                self.presentationMode.wrappedValue.dismiss()
            }
        })
        .padding(.top, -30)
        .edgesIgnoringSafeArea(.bottom)
        .edgesIgnoringSafeArea(.horizontal)
        .background(Color(.systemGroupedBackground))
        .onAppear(perform: {
            if neverLoaded {
                //withAnimation {
                    DispatchQueue.main.async {
                        title = theTitle
                        notes = theNotes
                    }
                    selectedDate = theSelectedDate
                    showDate = theShowDate
                    if showPickers == false {
                        iconTheme = theIconTheme
                        platform = thePlatform
                        reoccuringDay = theReoccuringDay
                    }
                    DispatchQueue.main.async {
                        showPickers = true
                    }
                    active = theActive
                    reoccuring = theReoccuring
                    favorited = theFavorite
                //}
                neverLoaded = false
            }
        })
//        .overlay(
//            Button {
//                showAlert.toggle()
//            } label: {
//                Text("Delete")
//                    .foregroundColor(.white)
//                    .bold()
//                    .frame(width: 300, height: 50, alignment: .center)
//                    .background(Color.red)
//                    .cornerRadius(15)
//                    .shadow(color: .black.opacity(0.4), radius: 15)
//                    //.padding()
//            },
//            alignment: .bottom
//        )
    }
}

struct editPickerLabel: View {
    
    let name: String
    let image: String
    
    var body: some View {
        Label(name, systemImage: image)
    }
    
}


func isFirstTimeOpening() -> Bool {
  let defaults = UserDefaults.standard

  if(defaults.integer(forKey: "hasRun") == 0) {
      defaults.set(1, forKey: "hasRun")
      return true
  }
  return false

}

func createDate(weekday: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.hour = 0
        components.minute = 1
        components.weekday = weekday // sunday = 1 ... saturday = 7
        components.weekdayOrdinal = 10
        components.timeZone = .current

        return calendar.date(from: components)!
    }


func scheduleNotification(title: String, info: String, date: Date) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = info
    
    // Configure the recurring date.
    var dateComponents = DateComponents()
    let calendar = Calendar.current
    dateComponents.calendar = Calendar.current
    dateComponents.month = calendar.component(.month, from: date)
    dateComponents.day = calendar.component(.day, from: date)
    dateComponents.year = calendar.component(.year, from: date)
    dateComponents.hour = 0
    dateComponents.minute = 1
    dateComponents.second = 0
    
    // Create the trigger as a repeating event.
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
    
    // Create the request
    let uuidString = UUID().uuidString
    let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)

    // Schedule the request with the system.
    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter.add(request) { (error) in
       if error != nil {
          // Handle any errors.
           print("NOTIFICATION ERROR HAS OCCURRED")
       }
    }
    
}

//Schedule Notification with weekly bases.
func scheduleWeeklyNotification(title: String, info: String, date: Date) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = info

    //let triggerWeekly = Calendar.current.dateComponents([.weekday, .hour, .minute, .second,], from: date)
    let triggerWeekly = Calendar.current.dateComponents([.weekday, .hour, .minute, .second,], from: date)
    print("SCHEDULING WEEKLY: \(triggerWeekly)")
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerWeekly, repeats: true)

    let request = UNNotificationRequest(identifier: "textNotification", content: content, trigger: trigger)

    let notificationCenter = UNUserNotificationCenter.current()
    //UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    notificationCenter.add(request) { (error) in
        if error != nil {
            print("NOTIFICATION ERROR HAS OCCURRED")
        }
    }
    //Printing all Pending Notifications for Debugging
        notificationCenter.getPendingNotificationRequests { notifications in
            var copy = notifications
            for _ in notifications {
                let notif = copy.removeFirst()
                let title = notif.content.title
                let body = notif.content.body
                let trigger = notif.trigger
                print(title)
                print("\(body)")
                print(trigger!)
            }
        }
    //------------
}

struct CornerRadiusStyle: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner

    struct CornerRadiusShape: Shape {

        var radius = CGFloat.infinity
        var corners = UIRectCorner.allCorners

        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            return Path(path.cgPath)
        }
    }

    func body(content: Content) -> some View {
        content
            .clipShape(CornerRadiusShape(radius: radius, corners: corners))
    }
}

extension View {
    func cornerRadius(radius: CGFloat, corners: UIRectCorner) -> some View {
        ModifiedContent(content: self, modifier: CornerRadiusStyle(radius: radius, corners: corners))
    }
}

func arrayContains(movies: [MovieV3], shows: [ShowV3], text: String, showsFavorites: Bool) -> Bool {
    for movie in movies {
        if movie.name.lowercased().contains(text.lowercased()) || movie.info.lowercased().contains(text.lowercased()) || getTypeForImage(image: movie.icon).lowercased().contains(text.lowercased()) || movie.platform.lowercased().contains(text.lowercased()) {
            if showsFavorites == true || movie.favorited == false {
                return true
            }
        }
    }
    for show in shows {
        if show.name.lowercased().contains(text.lowercased()) || show.info.lowercased().contains(text.lowercased()) ||  getTypeForImage(image: show.icon).lowercased().contains(text.lowercased()) || show.platform.lowercased().contains(text.lowercased()) {
            if showsFavorites == true || show.favorited == false {
                return true
            }
        }
    }
    
    return false
    
}

struct notif {
    let name: String
    let announceDate: Date
}

