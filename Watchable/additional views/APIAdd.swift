//
//  APIAdd.swift
//  Watchable
//
//  Created by Luke Drushell on 4/1/22.
//

import SwiftUI

struct APIAdd: View {
    
    let key = API().key
    
    
    @Environment(\.colorScheme) var cScheme
    @State var item: WatchableItem
    @State var watchableList = WatchableItems.loadFromFile()
    
    func gatherSources() {
        Task {
            var output: [String] = []
            var buyOutput: [String] = []
            let key = API().key
            
            let (data, _) = try await URLSession.shared.data(from: URL(string:"https://api.themoviedb.org/3/\(item.itemType == 0 ? "movie" : "tv")/\(item.id)/watch/providers?api_key=\(key)")!)
            let decodedResponse = try? JSONDecoder().decode(Source.self, from: data)
            let res = decodedResponse?.results.US ?? Provider(buy: [], flatrate: [], ads: [])
            if (res.flatrate != nil) {
                for i in res.flatrate!.indices {
                    output.append(res.flatrate![i].provider_name)
                }
            }
            if (res.ads != nil) {
                for i in res.ads!.indices {
                    if output.contains(res.ads![i].provider_name) != true {
                        output.append(res.ads![i].provider_name)
                    }
                }
            }
            if (res.buy != nil) {
                for i in res.buy!.indices {
                    buyOutput.append(res.buy![i].provider_name)
                }
            }
            print("url https://api.themoviedb.org/3/\(item.itemType == 0 ? "movie" : "tv")/\(item.id)/watch/providers?api_key=\(key)")
            print("id \(item.id)")
            print("key \(key)")
//            print("decoded \(decodedResponse)")
//            print("results \(decodedResponse?.results)")
//            print("us \(decodedResponse?.results.US)")
            item.sources = output
            item.buySources = buyOutput
        }
    }
    
    func getDetails() {
        Task {
            let key = API().key
            
            let (data, _) = try await URLSession.shared.data(from: URL(string:"https://api.themoviedb.org/3/\(item.itemType == 0 ? "movie" : "tv")/\(item.id)?api_key=\(key)&language=en-US")!)
            let decodedResponse = try? JSONDecoder().decode(TVDetails.self, from: data)
            print("DETAILS:")
            print("url https://api.themoviedb.org/3/\(item.itemType == 0 ? "movie" : "tv")/\(item.id)?api_key=\(key)&language=en-US")
            print("id \(item.id)")
            print("key \(key)")
            let res = decodedResponse ?? TVDetails(networks: [], number_of_seasons: 0, genres: [])
            item.seasons = res.number_of_seasons ?? 0
            if res.genres.count != 0 {
                for i in res.genres.indices  {
                    item.themes.append(res.genres[i].name)
                }
            }
            for i in res.networks.indices {
                if res.networks[i].name == "tv asahi" && item.sources.contains("Crunchryoll") == false { item.sources.append("Crunchyroll") }
            }
        }
    }
    
    func checkIfTheaters() {
        Task {
            let key = API().key
            
            let (data, _) = try await URLSession.shared.data(from: URL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(key)&language=en-US&page=1")!)
            let decodedResponse = try? JSONDecoder().decode(TheaterMovies.self, from: data)
            let res = decodedResponse?.results ?? []
            for i in res.indices {
                if res[i].id == item.id && item.sources.contains("Theater") == false { item.sources.insert("Theater", at: 0) }
            }
        }
    }
    
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
            ScrollView(showsIndicators: false) {
                HStack {
                    ZStack {
                        AsyncImage(url: URL(string: "\(item.backdrop)")) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width * 0.35, height: (UIScreen.main.bounds.width * 0.35) * (1.6), alignment: .center)
                                .cornerRadius(15)
                        } placeholder: {
                            Color.gray.opacity(0.2)
                                .frame(width: UIScreen.main.bounds.width * 0.35, height: (UIScreen.main.bounds.width * 0.35) * (1.6), alignment: .center)
                                .cornerRadius(15)
                        }
                        AsyncImage(url: URL(string: "\(item.poster)")) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width * 0.35, height: (UIScreen.main.bounds.width * 0.35) * (1.6), alignment: .center)
                                .cornerRadius(15)
                        } placeholder: {
                        }
                    }
                    VStack(alignment: .leading) {
                        VStack {
                            Text("\(item.title)")
                                .font(.title2)
                                .bold()
                                .multilineTextAlignment(.leading)
//                            Text(item.subtitle)
//                                .font(.title3)
//                                .bold()
//                                .multilineTextAlignment(.center)
//                                .padding(.bottom, 2)
                        }
                        if item.themes.isEmpty != true {
                            Text(themesToString(themes: item.themes))
                                .font(.subheadline)
                                .bold()
                                .padding()
                                .frame(width: UIScreen.main.bounds.width * 0.55, height: 50, alignment: .leading)
                                .background(getBackgroundColors(cScheme: cScheme))
                                .cornerRadius(15)
                        }
                        if item.release > Date() {
                            Text("Releasing \(item.release.formatted(date: .abbreviated, time: .omitted))")
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(.pink)
                                .padding()
                                .frame(width: UIScreen.main.bounds.width * 0.55, height: 50, alignment: .leading)
                                .background(getBackgroundColors(cScheme: cScheme))
                                .cornerRadius(15)
                        } else {
                            Text("\(item.itemType == 1 ? "Premiered" : "Released") \(item.release.formatted(date: .abbreviated, time: .omitted))")
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(.pink)
                                .padding()
                                .frame(width: UIScreen.main.bounds.width * 0.55, height: 50, alignment: .leading)
                                .background(getBackgroundColors(cScheme: cScheme))
                                .cornerRadius(15)
                        }
                        
                        if item.itemType == 1 {
                            //show season count if it's a show, and what season they're on if it's currently releasing
                            if item.currentlyReleasing {
                                Text("Season \(item.seasons) - Every \(intToDayString(int: item.releaseDay))")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.pink)
                                    .padding()
                                    .frame(width: UIScreen.main.bounds.width * 0.55, height: 50, alignment: .leading)
                                    .background(getBackgroundColors(cScheme: cScheme))
                                    .cornerRadius(15)
                            } else {
                                Text("\(item.seasons) Seasons")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.pink)
                                    .padding()
                                    .frame(width: UIScreen.main.bounds.width * 0.55, height: 50, alignment: .leading)
                                    .background(getBackgroundColors(cScheme: cScheme))
                                    .cornerRadius(15)
                            }
                            
                        }
                    }
                    
                } .padding(.top)
                Divider()
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .opacity(0.5)
                VStack(alignment: .leading) {
                    Text("SYNOPSIS:")
                        .font(Font.footnote)
                        .foregroundColor(.gray)
                    Text(item.synopsis)
                        .frame(width: UIScreen.main.bounds.width * 0.85, alignment: .leading)
                        .padding()
                        .background(getBackgroundColors(cScheme: cScheme))
                        .cornerRadius(15)
                }
                Divider()
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .opacity(0.5)
                VStack {
                    if item.sources.isEmpty != true {
                        VStack(alignment: .leading) {
                            Text("WHERE TO WATCH:")
                                .font(Font.footnote)
                                .foregroundColor(.gray)
                            ForEach(item.sources, id: \.self,  content: { source in
                                if source == "Theater" {
                                    Button {
                                        UIApplication.shared.open(URL(string: "https://fandango.com/search?q=\(titleToFandengoLink(title: item.title))")!)
                                    } label: {
                                        HStack {
                                            Text("Get Tickets")
                                                .foregroundColor(.pink)
                                            Spacer()
                                            Image(systemName: "arrow.up.right.square")
                                                .foregroundColor(.pink)
                                        } .frame(width: UIScreen.main.bounds.width * 0.85, alignment: .leading)
                                            .padding()
                                            .background(getBackgroundColors(cScheme: cScheme))
                                            .cornerRadius(15)
                                    }
                                } else {
                                    Button {
                                        openSource(source: source, title: item.title)
                                    } label: {
                                        HStack {
                                            Text(source)
                                                .foregroundColor(.pink)
                                            Spacer()
                                            if checkSource(source) {
                                                Image(systemName: "arrow.up.right.square")
                                                    .foregroundColor(.pink)
                                            }
                                        }
                                        .frame(width: UIScreen.main.bounds.width * 0.85, alignment: .leading)
                                        .padding()
                                        .background(getBackgroundColors(cScheme: cScheme))
                                        .cornerRadius(15)
                                    }
                                }
                            })
                        }
                    }
                    if item.buySources.isEmpty == false && item.sources.isEmpty == false {
                        Divider()
                    }
                    if item.buySources.isEmpty != true {
                        VStack(alignment: .leading) {
                            Text("WHERE TO BUY:")
                                .font(Font.footnote)
                                .foregroundColor(.gray)
                            ForEach(item.buySources, id: \.self,  content: { source in
                                Button {
                                    openSource(source: source, title: item.title)
                                } label: {
                                    HStack {
                                        Text(source)
                                            .foregroundColor(.pink)
                                        Spacer()
                                        Image(systemName: "arrow.up.right.square")
                                            .foregroundColor(.pink)
                                    }
                                    .frame(width: UIScreen.main.bounds.width * 0.85, alignment: .leading)
                                    .padding()
                                    .background(getBackgroundColors(cScheme: cScheme))
                                    .cornerRadius(15)
                                }
                            })
                        }
                    }
                }
                Divider()
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .opacity(0.5)
                VStack {
                    if item.release < Date() {
                        Toggle("Currently Watching", isOn: $item.currentlyWatching)
                            .frame(width: UIScreen.main.bounds.width * 0.85, alignment: .leading)
                            .padding(15)
                            .background(getBackgroundColors(cScheme: cScheme))
                            .cornerRadius(15)
                    }
                    Toggle("Remind Me", isOn: $item.remindMe)
                        .frame(width: UIScreen.main.bounds.width * 0.85, alignment: .leading)
                        .padding(15)
                        .background(getBackgroundColors(cScheme: cScheme))
                        .cornerRadius(15)
                }
                Spacer()
                Button {

                } label: {
                    Text("Add to List")
                        .foregroundColor(.white)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 20).frame(width: UIScreen.main.bounds.width * 0.9, height: 60, alignment: .center).foregroundColor(.pink))
                        .padding(30)
                        .padding(.bottom, 40)
                }
            }
            .padding(10)
        }
        .padding(.vertical, 25)
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.98, alignment: .center)
        .padding()
        .onAppear(perform: {
            gatherSources()
            getDetails()
            if item.itemType == 0 {
                checkIfTheaters()
            }
        })
    }
}

//struct APIAdd_Previews: PreviewProvider {
//    static var previews: some View {
//        APIAdd(item: WatchableItem(title: "", subtitle: "", themes: <#T##[String]#>, release: <#T##Date#>, synopsis: <#T##String#>, sources: <#T##[String]#>, itemType: <#T##Int#>, poster: <#T##URL#>, seasons: <#T##Int#>, releaseDay: <#T##Int#>, currentlyReleasing: <#T##Bool#>, remindMe: <#T##Bool#>, currentlyWatching: <#T##Bool#>, folder: <#T##String#>))
//    }
//}


func movieDate() -> Date {
    var dateComponents = DateComponents()
    dateComponents.month = 5
    dateComponents.day = 6
    dateComponents.year = 2022
    let date = Calendar.current.date(from: dateComponents)
    return date ?? Date()
}

func themesToString(themes: [String]) -> String {
    var output = ""
    for i in themes.indices {
        output.append(themes[i])
        if i < themes.count - 1 {
            output.append(", ")
        }
    }
    return output
}

func titleToFandengoLink(title: String) -> String{
    var output = ""
    let items = title.components(separatedBy: " ")
    for i in items.indices {
        output.append("\(items[i])")
        if i < items.count - 1 {
            output.append("+")
        }
    }
    return output
}

func openSource(source: String, title: String) {
    let youtube = "https://tv.youtube.com/search/\(titleToFandengoLink(title: title))"
    let netflix = "https://netflix.com/search?q=\(titleToFandengoLink(title: title))"
    switch source {
    case "Netflix":
        UIApplication.shared.open(URL(string: netflix)!)
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
    case "Disney Plus":
        UIApplication.shared.open(URL(string: "https://disneyplus.com/search/")!)
    case "Youtube TV":
        UIApplication.shared.open(URL(string: youtube)!)
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
}

func checkSource(_ source: String) -> Bool {
    var output = false
    let known = ["Netflix", "Hulu", "HBO Max", "Amazon Prime Video", "Disney Plus", "Youtube TV", "Apple TV", "Peacock", "Crunchyroll", "Funimation Now"]
    for i in known.indices {
        if source.contains(known[i]) { output = true }
    }
    return output
}


func intToDayString(int: Int) -> String {
    var output = ""
    switch int {
    case 0:
        output = "Sun"
    case 1:
        output = "Mon"
    case 2:
        output = "Tue"
    case 3:
        output = "Wed"
    case 4:
        output = "Thu"
    case 5:
        output = "Fri"
    default:
        output = "Sat"
    }
    return output
}


struct Source: Codable, Hashable {
    var results: ProviderLocale
}

struct ProviderLocale: Codable, Hashable {
    var US: Provider
}
struct Provider: Codable, Hashable {
    var buy: [ProviderName]?
    var flatrate: [ProviderName]?
    var ads: [ProviderName]?
}

struct ProviderName: Codable, Hashable {
    var provider_name: String
}


struct TVDetails: Codable, Hashable {
    var networks: [Network]
    var number_of_seasons: Int?
    var genres: [Genre]
}

struct Network: Codable, Hashable {
    var name: String
}

struct Genre: Codable, Hashable {
    var name: String
}

struct TheaterMovies: Codable, Hashable {
    var results: [idInfo]
}

struct idInfo: Codable, Hashable {
    var id: Int
}

struct WatchableItem: Codable {
    var title: String
    var subtitle: String
    var themes: [String] //action, comedy, drama, etc.
    var release: Date //day that item premiered
    var synopsis: String
    var sources: [String] //theater, netflix, crunchyroll ---- need seasons availible
    var buySources: [String]
    var itemType: Int //0 = movie, 1 = show
    var backdrop: URL //link to backdrop Poster, needs AsyncImage
    var poster: URL //link to poster, needs AsyncImage
    var seasons: Int //amount of seasons released
    var releaseDay: Int //day of the week that it releases
    var currentlyReleasing: Bool // if the show is coming out each week
    
    var remindMe: Bool //if the user wants to be reminded
    var currentlyWatching: Bool //goes in watching section of list
    var folder: String
    var id: Int
}

//func itemToItems(item: WatchableItem) -> WatchableItems {
//    return WatchableItems(title: item.title, subtitle: item.subtitle, themes: item.themes, release: item.release, synopsis: item.synopsis, sources: item.sources., itemType: item.itemType, poster: item.poster, seasons: item.seasons, releaseDay: item.releaseDay, currentlyReleasing: item.currentlyReleasing, remindMe: item.remindMe, currentlyWatching: item.currentlyWatching, folder: item.folder)
//}


//struct searchInfo {
//    var text: String
//    var movies: Bool
//    var shows: Bool
//    var themes: [String]
//}

func getBackgroundColors(cScheme: ColorScheme) -> Color {
    let settings = UserSettings.loadFromFile()
    var output = Color.green
    if (settings.first?.colorScheme ?? "Match System") == "Match System" {
        if cScheme == .dark {
            output = .gray.opacity(0.25)
        } else {
            output = .white
        }
    } else {
        if (settings.first?.colorScheme ?? "Always Dark") == "Always Dark" {
            output = .gray.opacity(0.25)
        } else {
            output = .white
        }
    }
    return output
}
