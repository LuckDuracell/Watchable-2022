//
//  ContentView.swift
//  ContentView
//
//  Created by Luke Drushell on 7/29/21.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    
    @State var searchText = ""
    
    @State var showsV2 = ShowV2.loadFromFile()
    @State var movies = Movie.loadFromFile()

    @State var upcomingMovies: [Movie] = []
    @State var upcomingMoviesIndexs: [Int] = []
    @State var upcomingShows: [ShowV2] = []
    @State var upcomingShowsIndexs: [Int] = []
    
    @State var activeMovies: [Movie] = []
    @State var activeMoviesIndexs: [Int] = []
    @State var activeShows: [ShowV2] = []
    @State var activeShowsIndexs: [Int] = []
    
    @State var inactiveMovies: [Movie] = []
    @State var inactiveMoviesIndexs: [Int] = []
    @State var inactiveShows: [ShowV2] = []
    @State var inactiveShowsIndexs: [Int] = []
    
    @State var showNewSheet = false
    @State var showTotalOverlay = false
    
    @State var selectedItemTheme = "Default"
    @State var selectedItemPlatform = "Youtube TV"
    
    @State var ytEasterEgg = false
    
    @State private var total = 0
    
    fileprivate func loadItems() {
        print("loading")
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        movies = Movie.loadFromFile()
        showsV2 = ShowV2.loadFromFile()
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
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
//            let center = UNUserNotificationCenter.current()
//            center.getPendingNotificationRequests(completionHandler: { requests in
//                for request in requests {
//                    print(request)
//                }
//            })
//        })
        
        for index in movies.indices {
            if movies[index].active {
                activeMovies.append(movies[index])
                activeMoviesIndexs.append(index)
            } else if checkUpcoming(date: movies[index].releaseDate) {
                upcomingMovies.append(movies[index])
                upcomingMoviesIndexs.append(index)
                scheduleNotification(title: "Watchable", info: "\(movies[index].name) comes out today!", date: movies[index].releaseDate)
            } else {
                inactiveMovies.append(movies[index])
                inactiveMoviesIndexs.append(index)
            }
        }
        
        for index in showsV2.indices {
            if showsV2[index].active {
                activeShows.append(showsV2[index])
                activeShowsIndexs.append(index)
                if showsV2[index].reoccuring {
                    let day = Calendar.current.dateComponents([.weekday], from: showsV2[index].reoccuringDate)
                    scheduleWeeklyNotification(title: "Watchable", info: "An episode of \(showsV2[index].name) comes out today!", date: createDate(weekday: day.weekday!))
                }
            } else if checkUpcoming(date: showsV2[index].releaseDate) {
                upcomingShows.append(showsV2[index])
                upcomingShowsIndexs.append(index)
                scheduleNotification(title: "Watchable", info: "\(showsV2[index].name) releases today!", date: showsV2[index].releaseDate)
            } else {
                inactiveShows.append(showsV2[index])
                inactiveShowsIndexs.append(index)
            }
        }
        
        total = activeMovies.count + activeShows.count + inactiveMovies.count + inactiveShows.count
    }
    
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
                                .frame(width: 200, height: 100, alignment: .center)
                                .foregroundColor(.pink)
                                .padding(-40)
                            Text("Hit the plus in the top right to add your first Movie or Show")
                                .font(.title2)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                    }
                    VStack {
                        if (upcomingMovies.count != 0 || upcomingShows.count != 0) {
                            if (arrayContains(movies: upcomingMovies, shows: upcomingShows, text: searchText) || searchText == "") {
                                HStack {
                                    Text("Upcoming:")
                                        .foregroundColor(.gray)
                                        .padding(.top, 25)
                                        .onTapGesture(count: 3, perform: {
                                            ytEasterEgg.toggle()
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
                                ForEach(upcomingMovies.indices, id: \.self, content: { index in
                                    if upcomingMovies[index].name.lowercased().contains(searchText.lowercased()) || upcomingMovies[index].info.lowercased().contains(searchText.lowercased()) || searchText == "" {
                                    NavigationLink(destination: {
                                        editPage(movies: $movies, showsV2: $showsV2, upcomingMovies: $upcomingMovies, upcomingMoviesIndexs: $upcomingMoviesIndexs, upcomingShows: $upcomingShows, upcomingShowsIndexs: $upcomingShowsIndexs, activeMovies: $activeMovies, activeMoviesIndexs: $activeMoviesIndexs, activeShows: $activeShows, activeShowsIndexs: $activeShowsIndexs, inactiveMovies: $inactiveMovies, inactiveMoviesIndexs: $inactiveMoviesIndexs, inactiveShows: $inactiveShows, inactiveShowsIndexs: $inactiveShowsIndexs, iconTheme: selectedItemTheme, theTitle: upcomingMovies[index].name, theSelectedDate: upcomingMovies[index].releaseDate, theShowDate: true, theNotes: upcomingMovies[index].info, type: "Movie", theIconTheme: getTypeForImage(image: upcomingMovies[index].icon), thePlatform: upcomingMovies[index].platform, theReocurringDay: "Sunday", theActive: upcomingMovies[index].active, theReoccuring: false, ogType: 0, typeIndex: index)
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
                            if upcomingMovies.count != 0 && upcomingShows.count != 0 && searchText == "" {
                                Rectangle()
                                    .frame(height: 2, alignment: .center)
                                    .foregroundColor(.gray.opacity(0.3))
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                            }
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], content: {
                                ForEach(upcomingShows.indices, id: \.self, content: { index in
                                    if upcomingShows[index].name.lowercased().contains(searchText.lowercased()) || upcomingShows[index].info.lowercased().contains(searchText.lowercased()) || searchText == "" {
                                    NavigationLink(destination: {
                                        editPage(movies: $movies, showsV2: $showsV2, upcomingMovies: $upcomingMovies, upcomingMoviesIndexs: $upcomingMoviesIndexs, upcomingShows: $upcomingShows, upcomingShowsIndexs: $upcomingShowsIndexs, activeMovies: $activeMovies, activeMoviesIndexs: $activeMoviesIndexs, activeShows: $activeShows, activeShowsIndexs: $activeShowsIndexs, inactiveMovies: $inactiveMovies, inactiveMoviesIndexs: $inactiveMoviesIndexs, inactiveShows: $inactiveShows, inactiveShowsIndexs: $inactiveShowsIndexs, iconTheme: selectedItemTheme, theTitle: upcomingShows[index].name, theSelectedDate: upcomingShows[index].releaseDate, theShowDate: true, theNotes: upcomingShows[index].info, type: "Show", theIconTheme: getTypeForImage(image: upcomingShows[index].icon), thePlatform: upcomingShows[index].platform, theReocurringDay: dateToWeekdayString(day: upcomingShows[index].reoccuringDate), theActive: upcomingShows[index].active, theReoccuring: upcomingShows[index].reoccuring, ogType: 0, typeIndex: index)
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
                        if (activeMovies.count != 0 || activeShows.count != 0) {
                            if (arrayContains(movies: activeMovies, shows: activeShows, text: searchText) || searchText == "") {
                                HStack {
                                    Text("Watching:")
                                        .foregroundColor(.gray)
                                        .padding(.top, 25)
                                    Spacer()
                                } .padding(.horizontal)
                            }
                        ForEach(activeMovies.indices, id: \.self, content: { index in
                            if activeMovies[index].name.lowercased().contains(searchText.lowercased()) || activeMovies[index].info.lowercased().contains(searchText.lowercased()) || searchText == "" {
                            NavigationLink(destination: {
                                editPage(movies: $movies, showsV2: $showsV2, upcomingMovies: $upcomingMovies, upcomingMoviesIndexs: $upcomingMoviesIndexs, upcomingShows: $upcomingShows, upcomingShowsIndexs: $upcomingShowsIndexs, activeMovies: $activeMovies, activeMoviesIndexs: $activeMoviesIndexs, activeShows: $activeShows, activeShowsIndexs: $activeShowsIndexs, inactiveMovies: $inactiveMovies, inactiveMoviesIndexs: $inactiveMoviesIndexs, inactiveShows: $inactiveShows, inactiveShowsIndexs: $inactiveShowsIndexs, iconTheme: selectedItemTheme, theTitle: activeMovies[index].name, theSelectedDate: activeMovies[index].releaseDate, theShowDate: false, theNotes: activeMovies[index].info, type: "Movie", theIconTheme: getTypeForImage(image: activeMovies[index].icon), thePlatform: activeMovies[index].platform, theReocurringDay: "Sunday", theActive: activeMovies[index].active, theReoccuring: false, ogType: 1, typeIndex: index)
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
                        if activeMovies.count != 0 && activeShows.count != 0 && searchText == "" {
                            Rectangle()
                                .frame(height: 2, alignment: .center)
                                .foregroundColor(.gray.opacity(0.3))
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                        ForEach(activeShows.indices, id: \.self, content: { index in
                            if activeShows[index].name.lowercased().contains(searchText.lowercased()) || activeShows[index].info.lowercased().contains(searchText.lowercased()) || searchText == "" {
                            NavigationLink(destination: {
                                editPage(movies: $movies, showsV2: $showsV2, upcomingMovies: $upcomingMovies, upcomingMoviesIndexs: $upcomingMoviesIndexs, upcomingShows: $upcomingShows, upcomingShowsIndexs: $upcomingShowsIndexs, activeMovies: $activeMovies, activeMoviesIndexs: $activeMoviesIndexs, activeShows: $activeShows, activeShowsIndexs: $activeShowsIndexs, inactiveMovies: $inactiveMovies, inactiveMoviesIndexs: $inactiveMoviesIndexs, inactiveShows: $inactiveShows, inactiveShowsIndexs: $inactiveShowsIndexs, iconTheme: selectedItemTheme, theTitle: activeShows[index].name, theSelectedDate: activeShows[index].releaseDate, theShowDate: false, theNotes: activeShows[index].info, type: "Show", theIconTheme: getTypeForImage(image: activeShows[index].icon), thePlatform: activeShows[index].platform, theReocurringDay: dateToWeekdayString(day: activeShows[index].reoccuringDate), theActive: activeShows[index].active, theReoccuring: activeShows[index].reoccuring, ogType: 1, typeIndex: index)
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
                        }
                        if inactiveMovies.count != 0 || inactiveShows.count != 0 {
                            if (arrayContains(movies: inactiveMovies, shows: inactiveShows, text: searchText) || searchText == "") {
                                HStack {
                                    Text("Need to Watch:")
                                        .foregroundColor(.gray)
                                        .padding(.top, 25)
                                    Spacer()
                                } .padding(.horizontal)
                            }
                        ForEach(inactiveMovies.indices, id: \.self, content: { index in
                            if inactiveMovies[index].name.lowercased().contains(searchText.lowercased()) || inactiveMovies[index].info.lowercased().contains(searchText.lowercased()) || searchText == "" {
                            NavigationLink(destination: {
                                editPage(movies: $movies, showsV2: $showsV2, upcomingMovies: $upcomingMovies, upcomingMoviesIndexs: $upcomingMoviesIndexs, upcomingShows: $upcomingShows, upcomingShowsIndexs: $upcomingShowsIndexs, activeMovies: $activeMovies, activeMoviesIndexs: $activeMoviesIndexs, activeShows: $activeShows, activeShowsIndexs: $activeShowsIndexs, inactiveMovies: $inactiveMovies, inactiveMoviesIndexs: $inactiveMoviesIndexs, inactiveShows: $inactiveShows, inactiveShowsIndexs: $inactiveShowsIndexs, iconTheme: selectedItemTheme, theTitle: inactiveMovies[index].name, theSelectedDate: inactiveMovies[index].releaseDate, theShowDate: false, theNotes: inactiveMovies[index].info, type: "Movie", theIconTheme: getTypeForImage(image: inactiveMovies[index].icon), thePlatform: inactiveMovies[index].platform, theReocurringDay: "Sunday", theActive: inactiveMovies[index].active, theReoccuring: false, ogType: 2, typeIndex: index)
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
                        if inactiveMovies.count != 0 && inactiveShows.count != 0 && searchText == "" {
                            Rectangle()
                                .frame(height: 2, alignment: .center)
                                .foregroundColor(.gray.opacity(0.3))
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                        ForEach(inactiveShows.indices, id: \.self, content: { index in
                            if inactiveShows[index].name.lowercased().contains(searchText.lowercased()) || inactiveShows[index].info.lowercased().contains(searchText.lowercased()) || searchText == "" {
                            NavigationLink(destination: {
                                editPage(movies: $movies, showsV2: $showsV2, upcomingMovies: $upcomingMovies, upcomingMoviesIndexs: $upcomingMoviesIndexs, upcomingShows: $upcomingShows, upcomingShowsIndexs: $upcomingShowsIndexs, activeMovies: $activeMovies, activeMoviesIndexs: $activeMoviesIndexs, activeShows: $activeShows, activeShowsIndexs: $activeShowsIndexs, inactiveMovies: $inactiveMovies, inactiveMoviesIndexs: $inactiveMoviesIndexs, inactiveShows: $inactiveShows, inactiveShowsIndexs: $inactiveShowsIndexs, iconTheme: selectedItemTheme, theTitle: inactiveShows[index].name, theSelectedDate: inactiveShows[index].releaseDate, theShowDate: false, theNotes: inactiveShows[index].info, type: "Show", theIconTheme: getTypeForImage(image: inactiveShows[index].icon), thePlatform: inactiveShows[index].platform, theReocurringDay: dateToWeekdayString(day: inactiveShows[index].reoccuringDate), theActive: inactiveShows[index].active, theReoccuring: inactiveShows[index].reoccuring, ogType: 2, typeIndex: index)
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
                    }
                    }
                }
               // .navigationBarTitle("Watchable", displayMode: showTotalOverlay ? .inline : .automatic)
                .navigationBarTitle("Watchable", displayMode: .inline)
                .navigationBarItems(
                    leading:
                        Button {
                            withAnimation {
                                showTotalOverlay.toggle()
                            }
                        } label: {
                            Text("\(total)")
                        },
                    trailing:
                        Button {
                            showNewSheet.toggle()
                        } label: {
                            Image(systemName: "plus")
                        }
                )
                
            }
            .searchable(text: $searchText)
            .onAppear(perform: { loadItems() })
            .sheet(isPresented: $showNewSheet, onDismiss: {
                loadItems()
            },content: {
                NewSheet(showSheet: $showNewSheet, movies: $movies, showsV2: $showsV2)
                    .interactiveDismissDisabled(true)
                    .accentColor(.pink)
                    .toggleStyle(SwitchToggleStyle(tint: Color.pink))
            })
        } .accentColor(.pink)
            .overlay(
                WatchableOverlay(activeMovies: activeMovies, activeShows: activeShows, inactiveMovies: inactiveMovies, inactiveShows: inactiveShows, upcomingMovies: upcomingMovies, upcomingShows: upcomingShows, showTotalOverlay: $showTotalOverlay)
                        .opacity(showTotalOverlay ? 1 : 0)
                        .animation(.easeIn, value: 3)
                        .transition(.move(edge: .leading))
            )
        .alert(isPresented: $ytEasterEgg, content: {
            Alert(title: Text("Oh cool you found an easter egg!"), primaryButton: .destructive(Text(UIApplication.shared.alternateIconName == "AppIcon-1" ? "Give me the old icon back" : "Gimme my prize"), action: {
                if UIApplication.shared.alternateIconName == "AppIcon-1" {
                    UIApplication.shared.setAlternateIconName(nil)
                } else {
                    UIApplication.shared.setAlternateIconName("AppIcon-1")
                }
                ytEasterEgg = true
                print("toggling icon")
            }), secondaryButton: .cancel(Text("Ew gross go away")))
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
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
    
    @Binding var movies: [Movie]
    @Binding var showsV2: [ShowV2]
    @Binding var upcomingMovies: [Movie]
    @Binding var upcomingMoviesIndexs: [Int]
    @Binding var upcomingShows: [ShowV2]
    @Binding var upcomingShowsIndexs: [Int]
    
    @Binding var activeMovies: [Movie]
    @Binding var activeMoviesIndexs: [Int]
    @Binding var activeShows: [ShowV2]
    @Binding var activeShowsIndexs: [Int]
    
    @Binding var inactiveMovies: [Movie]
    @Binding var inactiveMoviesIndexs: [Int]
    @Binding var inactiveShows: [ShowV2]
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
    
    let theTitle: String
    let theSelectedDate: Date
    let theShowDate: Bool
    let theNotes: String
    let type: String
    let theIconTheme: String
    let thePlatform: String
    let theReocurringDay: String
    let theActive: Bool
    let theReoccuring: Bool
    
    let ogType: Int
    let typeIndex: Int
    
    @State var showAlert = false
    
    @State var deleting = false
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        Form {
            if checkUpcoming(date: selectedDate) {
                Text("\(type) releases in \(dayDifference(date1: Date(), date2: selectedDate)) Day\(dayDifference(date1: Date(), date2: selectedDate) == 1 ? "" : "s")")
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.pink)
            } else {
                Text(type)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.pink)
            }
            
            Section {
                TextField("Title", text: $title)
                    .autocapitalization(.words)
                    .disableAutocorrection(true)
                    .keyboardType(.alphabet)
                
                TextField("Notes", text: $notes)
            }
            
            if showPickers {
                Section {
                    Picker("Theme", selection: $iconTheme, content: {
                        ForEach(themeTypes, id: \.self, content: {
                            editPickerLabel(name: $0, image: getImageForType(type: $0))
                        })
                    })
                    Picker("Platform", selection: $platform, content: {
                        ForEach(platformTypes, id: \.self, content: {
                            Text($0)
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
                    Toggle("Reoccuring", isOn: $reoccuring)
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
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle("Edit Item")
        .navigationBarItems(trailing:
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
                                showsV2.remove(at: upcomingShowsIndexs[typeIndex])
                            case 1:
                                print("1")
                                showsV2.remove(at: activeShowsIndexs[typeIndex])
                            default:
                                print("2")
                                showsV2.remove(at: inactiveShowsIndexs[typeIndex])
                        }
                    }
                    if type == "Movie" {
                        if title != "" {
                            if active {
                                selectedDate = Date()
                            }
                            movies.insert(Movie(name: title, icon: getImageForType(type: iconTheme), releaseDate: selectedDate, active: active, info: notes, platform: platform), at: 0)
                            Movie.saveToFile(movies)
                        }
                    } else {
                        if title != "" {
                            if active {
                                selectedDate = Date()
                            }
                            showsV2.insert(ShowV2(name: title, icon: getImageForType(type: iconTheme), releaseDate: selectedDate, active: active, info: notes, platform: platform, reoccuring: reoccuring, reoccuringDate: createDate(weekday: dayToInt(day: reoccuringDay))), at: 0)
                            ShowV2.saveToFile(showsV2)
                        }
                    }
                    self.presentationMode.wrappedValue.dismiss()
                }
            } label: {
                Text("Save")
            }
        )
        .alert("Delete \(type)?", isPresented: $showAlert, actions: {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
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
                            showsV2.remove(at: upcomingShowsIndexs[typeIndex])
                        case 1:
                            print("1")
                            showsV2.remove(at: activeShowsIndexs[typeIndex])
                        default:
                            print("2")
                            showsV2.remove(at: inactiveShowsIndexs[typeIndex])
                    }
                }
                Movie.saveToFile(movies)
                ShowV2.saveToFile(showsV2)
                deleting = true
                self.presentationMode.wrappedValue.dismiss()
            }
        })
        .padding(.top, -30)
        .edgesIgnoringSafeArea(.bottom)
        .edgesIgnoringSafeArea(.horizontal)
        .background(Color(.systemGroupedBackground))
        .onAppear(perform: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                title = theTitle
                notes = theNotes
            })
            selectedDate = theSelectedDate
            showDate = theShowDate
            if showPickers == false {
                iconTheme = theIconTheme
                platform = thePlatform
                reoccuringDay = theReocurringDay
            }
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                showPickers = true
            })
            active = theActive
            reoccuring = theReoccuring
        })
        .overlay(
            Button {
                showAlert.toggle()
            } label: {
                Text("Delete")
                    .foregroundColor(.white)
                    .bold()
                    .frame(width: 300, height: 50, alignment: .center)
                    .background(Color.red)
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.4), radius: 15)
                    //.padding()
            },
            alignment: .bottom
        )
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
    
        let triggerWeekly = Calendar.current.dateComponents([.weekday,.hour, .minute, .second,], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerWeekly, repeats: true)

        let request = UNNotificationRequest(identifier: "textNotification", content: content, trigger: trigger)

        let notificationCenter = UNUserNotificationCenter.current()
        //UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        notificationCenter.add(request) { (error) in
            if error != nil {
                print("NOTIFICATION ERROR HAS OCCURRED")
            }
        }
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

func arrayContains(movies: [Movie], shows: [ShowV2], text: String) -> Bool {
    for movie in movies {
        if movie.name.lowercased().contains(text.lowercased()) || movie.info.lowercased().contains(text.lowercased()) { return true }
    }
    for show in shows {
        if show.name.lowercased().contains(text.lowercased()) || show.info.lowercased().contains(text.lowercased()) { return true }
    }
    
    return false
    
}
