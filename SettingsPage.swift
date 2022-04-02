//
//  SettingsPage.swift
//  Watchable
//
//  Created by Luke Drushell on 3/26/22.
//

import SwiftUI

struct SettingsPage: View {
    
    @Binding var settings: [UserSettings]
    
    @Binding var activeMovies: [MovieV3]
    @Binding var activeShows: [ShowV3]
    @Binding var inactiveMovies: [MovieV3]
    @Binding var inactiveShows: [ShowV3]
    @Binding var upcomingMovies: [MovieV3]
    @Binding var upcomingShows: [ShowV3]
    
    @Binding var loadItemsTrigger: Bool
    @State var copySettings = [UserSettings(showFavorites: true, colorScheme: "nil")]
    
    let options = ["Match System", "Always Light", "Always Dark"]
    
    var body: some View {
        ScrollView {
            VStack {
                if settings.isEmpty == false {
                    VStack {
                        HStack {
                            VStack {
                                Text("Watchable")
                                    .bold()
                                    .padding(.vertical, 2)
                                Text("Movies: \(activeMovies.count + inactiveMovies.count - movFavoritesCount(movies: activeMovies, visible: settings[0].showFavorites) - movFavoritesCount(movies: inactiveMovies, visible: settings[0].showFavorites))")
                                Text("Shows: \(activeShows.count + inactiveShows.count - showFavoritesCount(shows: activeShows, visible: settings.first?.showFavorites ?? true) - showFavoritesCount(shows: inactiveShows, visible: settings[0].showFavorites))")
                            }
                            Divider()
                            VStack {
                                Text("Upcoming")
                                    .bold()
                                    .padding(.vertical, 2)
                                Text("Movies: \(upcomingMovies.count - movFavoritesCount(movies: upcomingMovies, visible: settings.first?.showFavorites ?? true))")
                                Text("Shows: \(upcomingShows.count - showFavoritesCount(shows: upcomingShows, visible: settings.first?.showFavorites ?? true))")
                            }
                            Divider()
                            VStack {
                                Text("Totals")
                                    .bold()
                                    .padding(.vertical, 2)
                                Text("Movies: \(upcomingMovies.count + activeMovies.count + inactiveMovies.count - movFavoritesCount(movies: activeMovies, visible: settings.first?.showFavorites ?? true) - movFavoritesCount(movies: inactiveMovies, visible: settings.first?.showFavorites ?? true) - movFavoritesCount(movies: upcomingMovies, visible: settings.first?.showFavorites ?? true))")
                                Text("Shows: \(upcomingShows.count + activeShows.count + inactiveShows.count - showFavoritesCount(shows: activeShows, visible: settings.first?.showFavorites ?? true) - showFavoritesCount(shows: inactiveShows, visible: settings.first?.showFavorites ?? true) - showFavoritesCount(shows: upcomingShows, visible: settings.first?.showFavorites ?? true) )")
                            }
                        }
                        Text("\(upcomingMovies.count + activeMovies.count + inactiveMovies.count + upcomingShows.count + activeShows.count + inactiveShows.count  - showFavoritesCount(shows: activeShows, visible: settings.first?.showFavorites ?? true) - showFavoritesCount(shows: inactiveShows, visible: settings.first?.showFavorites ?? true) - showFavoritesCount(shows: upcomingShows, visible: settings.first?.showFavorites ?? true) - movFavoritesCount(movies: activeMovies, visible: settings.first?.showFavorites ?? true) - movFavoritesCount(movies: inactiveMovies, visible: settings.first?.showFavorites ?? true) - movFavoritesCount(movies: upcomingMovies, visible: settings.first?.showFavorites ?? true))")
                            .bold()
                            .padding(.vertical, 2)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(15)
                    .padding(.horizontal)
                }
                Divider()
                
                NavigationLink(destination: {
                    FavoritesView()
                }, label: {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.pink)
                            .font(.system(size: 20, weight: .medium))
                        Text("Favorites")
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
                
                NavigationLink(destination: {
                    HistoryView()
                }, label: {
                    HStack {
                        Image(systemName: "archivebox.fill")
                            .foregroundColor(.pink)
                            .font(.system(size: 20, weight: .medium))
                        Text("History")
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
                
                NavigationLink(destination: {
                    AppIconView()
                }, label: {
                    HStack {
                        Image(systemName: "questionmark.app.fill")
                            .foregroundColor(.pink)
                            .font(.system(size: 20, weight: .medium))
                        Text("App Icon")
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
//                NavigationLink(destination: {
//                    APITestView()
//                }, label: {
//                    HStack {
//                        Image(systemName: "antenna.radiowaves.left.and.right")
//                            .foregroundColor(.pink)
//                            .font(.system(size: 20, weight: .medium))
//                        Text("API Test")
//                            .font(.system(size: 20, weight: .medium, design: .rounded))
//                            .foregroundColor(.primary)
//                            .frame(height: 20)
//                            .truncationMode(.tail)
//                        Spacer()
//                        Image(systemName: "chevron.right")
//                            .foregroundColor(.gray)
//                    }
//                    .padding()
//                    .background(Color.gray.opacity(0.2))
//                    .cornerRadius(15)
//                    .padding(.horizontal)
//                        
//                })
                
                if settings.isEmpty == false {
                    Divider()
                        Toggle(isOn: $settings[0].showFavorites, label: {
                            Label(title: {
                                Text("Favorites on Watchlist")
                            }, icon: {
                                Image(systemName: "star.slash.fill")
                                    .foregroundColor(.pink)
                                    .font(.system(size: 20, weight: .medium))
                            })
                        })
                        .onChange(of: settings[0].showFavorites) { value in
                            UserSettings.saveToFile(settings)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(15)
                        .padding(.horizontal)
                    Picker("App Appearance", selection: $copySettings[0].colorScheme, content: {
                        ForEach(options, id: \.self, content: { option in
                            Text(option)
                        })
                    })
                    .onAppear(perform: { copySettings = settings })
                    .onChange(of: copySettings[0].colorScheme, perform: { value in
                        UserSettings.saveToFile(copySettings)
                        loadItemsTrigger = true
                    })
                    .pickerStyle(.segmented)
                    .padding()
                }
            }
            
            Button {
                UIApplication.shared.open(URL(string: "https://twitter.com/luckduracell")!)
            } label: {
                HStack {
                    Image("twitter")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 20, height: 20, alignment: .center)
                        .foregroundColor(.pink)
                    Text("Creator's Twitter")
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(15)
                .padding(.horizontal)
            }
            
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                Button {
                    guard let urlShare = URL(string: "https://apps.apple.com/us/app/watchable/id1586489845") else { return }
                           let activityVC = UIActivityViewController(activityItems: [urlShare], applicationActivities: nil)
                    activityVC.title = "Share the app with your friends!"
                    
                    UIApplication.shared.windows.first?.rootViewController?
                        .present(activityVC, animated: true, completion: nil)
                    
                } label: {
                    Text("Share App")
                        .padding()
                }
            }
            Text("1.5.4")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(80)
        }
    }
}

func movFavoritesCount(movies: [MovieV3], visible: Bool) -> Int {
    var output: Int = 0
    for i in movies.indices {
        if movies[i].favorited == true && visible == false { output += 1 }
    }
    return output
}

func showFavoritesCount(shows: [ShowV3], visible: Bool) -> Int {
    var output: Int = 0
    for i in shows.indices {
        if shows[i].favorited == true && visible == false { output += 1 }
    }
    return output
}
