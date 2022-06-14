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
            let key = API().key
            
            let (data, _) = try await URLSession.shared.data(from: URL(string:"https://api.themoviedb.org/3/\(item.itemType == 0 ? "movie" : "tv")/\(item.id)/watch/providers?api_key=\(key)")!)
            let decodedResponse = try? JSONDecoder().decode(Source.self, from: data)
            if decodedResponse?.results.US.count != 0 {
                for i in 0...(Int(decodedResponse?.results.US.count ?? 1)) - 1 {
                    for i2 in 0...(Int(decodedResponse?.results.US[i].flatrate.count ?? 1)) - 1 {
                        output.append(decodedResponse?.results.US[i].flatrate[i2].provider_name ?? "")
                    }
                }
            }
            item.sources = output
        }
    }
    
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
            ScrollView(showsIndicators: false) {
                HStack {
                    AsyncImage(url: URL(string: "\(item.poster)")) { image in
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
                    VStack(alignment: .leading) {
                        VStack {
                            Text("\(item.title)")
                                .font(.title2)
                                .bold()
                                .multilineTextAlignment(.leading)
                            Text(item.subtitle)
                                .font(.title3)
                                .bold()
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 2)
                        }
                        Text(themesToString(themes: item.themes))
                            .font(.subheadline)
                            .bold()
                            .padding()
                            .frame(width: UIScreen.main.bounds.width * 0.55, height: 50, alignment: .leading)
                            .background(getBackgroundColors(cScheme: cScheme))
                            .cornerRadius(15)
                        if item.release > Date() {
                            Text("Releasing \(item.release.formatted(date: .abbreviated, time: .omitted))")
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(.red)
                                .padding()
                                .frame(width: UIScreen.main.bounds.width * 0.55, height: 50, alignment: .leading)
                                .background(getBackgroundColors(cScheme: cScheme))
                                .cornerRadius(15)
                        } else {
                            Text("\(item.itemType == 1 ? "Premiered" : "Released") \(item.release.formatted(date: .abbreviated, time: .omitted))")
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(.red)
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
                                    .foregroundColor(.red)
                                    .padding()
                                    .frame(width: UIScreen.main.bounds.width * 0.55, height: 50, alignment: .leading)
                                    .background(getBackgroundColors(cScheme: cScheme))
                                    .cornerRadius(15)
                            } else {
                                Text("\(item.seasons) Seasons")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.red)
                                    .padding()
                                    .frame(width: UIScreen.main.bounds.width * 0.55, height: 50, alignment: .leading)
                                    .background(getBackgroundColors(cScheme: cScheme))
                                    .cornerRadius(15)
                            }
                            
                        }
                    }
                    
                }
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
                VStack(alignment: .leading) {
                    Text("WHERE TO WATCH:")
                        .font(Font.footnote)
                        .foregroundColor(.gray)
                    ForEach(item.sources, id: \.self,  content: { source in
                        if source == "Theater" {
                            Button {
                                UIApplication.shared.open(URL(string: "https://fandengo.com/search?q=\(titleToFandengoLink(title: item.title))")!)
                            } label: {
                                HStack {
                                    Text("Get Tickets")
                                        .foregroundColor(.red)
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                        .foregroundColor(.red)
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
                                        .foregroundColor(.red)
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                        .foregroundColor(.red)
                                }
                                .frame(width: UIScreen.main.bounds.width * 0.85, alignment: .leading)
                                .padding()
                                .background(getBackgroundColors(cScheme: cScheme))
                                .cornerRadius(15)
                            }
                        }
                    })
                }
                Divider()
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .opacity(0.5)
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
                Spacer()
                Button {
                    watchableList.append(itemToItems(item: item))
                    WatchableItems.saveToFile(watchableList)
                    //showSheet.toggle()
                    
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
        })
    }
}

//struct APIAdd_Previews: PreviewProvider {
//    static var previews: some View {
//        APIAdd(item: WatchableItem(title: "", subtitle: "", themes: <#T##[String]#>, release: <#T##Date#>, synopsis: <#T##String#>, sources: <#T##[String]#>, itemType: <#T##Int#>, poster: <#T##URL#>, seasons: <#T##Int#>, releaseDay: <#T##Int#>, currentlyReleasing: <#T##Bool#>, remindMe: <#T##Bool#>, currentlyWatching: <#T##Bool#>, folder: <#T##String#>))
//    }
//}


//func movieDate() -> Date {
//    var dateComponents = DateComponents()
//    dateComponents.month = 5
//    dateComponents.day = 6
//    dateComponents.year = 2022
//    let date = Calendar.current.date(from: dateComponents)
//    return date ?? Date()
//}
//
//func themesToString(themes: [String]) -> String {
//    var output = ""
//    for i in themes.indices {
//        output.append(themes[i])
//        if i < themes.count - 1 {
//            output.append(", ")
//        }
//    }
//    return output
//}
//
//func titleToFandengoLink(title: String) -> String{
//    var output = ""
//    let items = title.components(separatedBy: " ")
//    for i in items.indices {
//        output.append("\(items[i])")
//        if i < items.count - 1 {
//            output.append("+")
//        }
//    }
//    return output
//}
//
//func openSource(source: String, title: String) {
//    let youtube = "https://tv.youtube.com/search/\(titleToFandengoLink(title: title))"
//    let netflix = "https://netflix.com/search?q=\(titleToFandengoLink(title: title))"
//    switch source {
//    case "Netflix":
//        UIApplication.shared.open(URL(string: netflix)!)
//    case "Hulu":
//        UIApplication.shared.open(URL(string: "hulu://search")!)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
//            UIApplication.shared.open(URL(string: "https://hulu.com")!)
//        })
//    case "HBO Max":
//        UIApplication.shared.open(URL(string: "https://play.hbomax.com/search/")!)
//    case "Prime Video":
//        UIApplication.shared.open(URL(string: "aiv://aiv/search")!)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
//            UIApplication.shared.open(URL(string: "https://primevideo.com")!)
//        })
//    case "Disney+":
//        UIApplication.shared.open(URL(string: "https://disneyplus.com/search/")!)
//    case "Youtube TV":
//        UIApplication.shared.open(URL(string: youtube)!)
//    case "Apple TV":
//        UIApplication.shared.open(URL(string: "videos://search")!)
//    case "Peacock":
//        UIApplication.shared.open(URL(string: "peacock://")!)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
//            UIApplication.shared.open(URL(string: "https://peacocktv.com")!)
//        })
//    case "Crunchyroll":
//        UIApplication.shared.open(URL(string: "crunchyroll://")!)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
//            UIApplication.shared.open(URL(string: "https://crunchyroll.com")!)
//        })
//    default:
//        print("ERROR: NO APPLICATION ASSOSIATED WITH PLATFORM, THIS BUTTON SHOULD NOT HAVE BEEN VISIBLE")
//    }
//}
//
//func intToDayString(int: Int) -> String {
//    var output = ""
//    switch int {
//    case 0:
//        output = "Sun"
//    case 1:
//        output = "Mon"
//    case 2:
//        output = "Tue"
//    case 3:
//        output = "Wed"
//    case 4:
//        output = "Thu"
//    case 5:
//        output = "Fri"
//    default:
//        output = "Sat"
//    }
//    return output
//}