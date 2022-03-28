//
//  FavoritesView.swift
//  Watchable
//
//  Created by Luke Drushell on 3/1/22.
//

import SwiftUI

struct FavoritesView: View {
    
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
    
    fileprivate func loadItems() {
        
        print(" V NUM \(versionNumber)")
        print(movies)
        print(showsV2)
        
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
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], content: {
                        ForEach(upcomingMovies.indices, id:\.self, content: { index in
                            if upcomingMovies[index].favorited {
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
                        })
                    }) .padding(.horizontal)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], content: {
                        ForEach(upcomingShows.indices, id: \.self, content: { index in
                            if upcomingShows[index].favorited {
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
                        })
                    }) .padding(.horizontal)
                }
                ForEach(activeMovies.indices, id: \.self, content: { index in
                    if activeMovies[index].favorited {
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
                })
                ForEach(activeShows.indices, id: \.self, content: { index in
                    if activeShows[index].favorited {
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
                })
                ForEach(inactiveMovies.indices, id: \.self, content: { index in
                    if inactiveMovies[index].favorited {
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
                })
                    ForEach(inactiveShows.indices, id: \.self, content: { index in
                        if inactiveShows[index].favorited {
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
                })
        } .onAppear(perform: {
            loadItems()
        })
        }
    }
