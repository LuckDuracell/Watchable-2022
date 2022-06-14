//
//  APITestView.swift
//  Watchable
//
//  Created by Luke Drushell on 3/30/22.
//

import SwiftUI

struct APITestView: View {
    
    @State private var device = deviceScreen()
    
    @State var query = ""
    @State var movies: [NewMovie] = []
    @State var shows: [NewShow] = []
    @Environment(\.colorScheme) var colorScheme
    
    private var columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    func runSearch() {
        Task {
            let (data, _) = try await URLSession.shared.data(from: URL(string:"https://api.themoviedb.org/3/search/tv?api_key=[key]&language=en-US&page=1&query=\(query.urlSafe)&include_adult=false")!)
            shows = []
            print("data: \(data)")
            let decodedResponse = try? JSONDecoder().decode(ShowResult.self, from: data)
            //shows.append(NewShow(name: decodedResponse!.name, overview: decodedResponse!.overview))
            //print("total: \(decodedResponse)")
            print("name: \(decodedResponse?.results.first?.name ?? "oops")")
            if decodedResponse?.results.count != 0 {
                for i in 0...(Int(decodedResponse?.results.count ?? 1)) - 1 {
                    shows.append(NewShow(backdrop_path: decodedResponse?.results[i].backdrop_path ?? "", id: decodedResponse?.results[i].id ?? 0, name: decodedResponse?.results[i].name ?? "", overview: decodedResponse?.results[i].overview ?? ""))
                }
            }
            
            let (data2, _) = try await URLSession.shared.data(from: URL(string:"https://api.themoviedb.org/3/search/movie?api_key=[key]]&language=en-US&page=1&query=\(query.urlSafe)&include_adult=false")!)
            movies = []
            print("data: \(data2)")
            let decodedResponse2 = try? JSONDecoder().decode(MovieResult.self, from: data2)
            //shows.append(NewShow(name: decodedResponse!.name, overview: decodedResponse!.overview))
            //print("total: \(decodedResponse2)")
            print("name: \(decodedResponse2?.results.first?.title ?? "oops")")
            if decodedResponse2?.results.count != 0 {
                for i in 0...(Int(decodedResponse?.results.count ?? 1)) - 1 {
                    movies.append(NewMovie(backdrop_path: decodedResponse2?.results[i].backdrop_path ?? "", id: decodedResponse2?.results[i].id ?? 0, overview: decodedResponse2?.results[i].overview ?? "", release_date: decodedResponse2?.results[i].release_date ?? "",title: decodedResponse2?.results[i].title ?? ""))
                }
            }
            
        }
    }

    
    var body: some View {
        ScrollView {
            HStack {
                TextField("Search", text: $query)
                    .onSubmit {
                        runSearch()
                    }
                Spacer()
                Button {
                    runSearch()
                } label: {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.pink)
                } .padding(.trailing, 3)
            }
            .padding(8)
            .frame(width: device.width * 0.95)
            .background(.regularMaterial)
            .cornerRadius(radius: 10, corners: .allCorners)
            Divider()
            LazyVGrid(columns: columns, content: {
                ForEach(movies, id: \.self, content: { movie in
                    NavigationLink(destination: {
                        //APIAdd(item: WatchableItem(title: movie.title, subtitle: "", themes: [], release: movie.release_date.convertToDate(), synopsis: movie.overview, sources: [], itemType: <#T##Int#>, poster: <#T##URL#>, seasons: <#T##Int#>, releaseDay: <#T##Int#>, currentlyReleasing: <#T##Bool#>, remindMe: <#T##Bool#>, currentlyWatching: <#T##Bool#>, folder: <#T##String#>))
                    }, label: {
                        AsyncImage(url: URL(string: "https://www.themoviedb.org/t/p/original\(movie.backdrop_path ?? "")"), content: { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: device.width * 0.45, height: device.width * 0.4 * 1.5, alignment: .center)
                                .clipped()
                                .cornerRadius(radius: 15, corners: .allCorners)
                                .overlay(alignment: .bottom,content: {
                                    Text(movie.title)
                                        .foregroundColor(.primary)
                                        .padding(.vertical, 8)
                                        .frame(width: device.width * 0.45)
                                        .background(.thinMaterial)
                                        .cornerRadius(radius: 15, corners: [.bottomLeft, .bottomRight])
                                })
                                .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(.pink, lineWidth: 4)
                                )
                        }, placeholder: {
                            
                            VStack {
                                Text(movie.title)
                                    .foregroundColor(.primary)
                                    .padding(8)
                                    .frame(width: device.width * 0.4)
                                    .background(.thinMaterial)
                                    .cornerRadius(radius: 10, corners: .allCorners)
                                    .lineLimit(3)
                                    .minimumScaleFactor(0.5)
                            }
                            .padding()
                            .frame(width: device.width * 0.45, height: device.width * 0.4 * 1.5)
                            .background(.pink)
                            .cornerRadius(radius: 10, corners: .allCorners)
                        })
                    })
                })
            })
            if shows != [] && movies != [] {
                Divider()
            }
            LazyVGrid(columns: columns, content: {
                ForEach(shows, id: \.self, content: { show in
                    NavigationLink(destination: {
                        //APIAdd(item: WatchableItem(title: movie.title, subtitle: "", themes: [], release: movie.release_date.convertToDate(), synopsis: movie.overview, sources: [], itemType: , poster: <#T##URL#>, seasons: <#T##Int#>, releaseDay: <#T##Int#>, currentlyReleasing: <#T##Bool#>, remindMe: <#T##Bool#>, currentlyWatching: <#T##Bool#>, folder: <#T##String#>))
                    }, label: {
                        AsyncImage(url: URL(string: "https://www.themoviedb.org/t/p/original\(show.backdrop_path ?? "")"), content: { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: device.width * 0.45, height: device.width * 0.4 * 1.5, alignment: .center)
                                .clipped()
                                .cornerRadius(radius: 15, corners: .allCorners)
                                .overlay(alignment: .bottom,content: {
                                    Text(show.name)
                                        .foregroundColor(.primary)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 5)
                                        .frame(width: device.width * 0.45)
                                        .background(.thinMaterial)
                                        .cornerRadius(radius: 15, corners: [.bottomLeft, .bottomRight])
                                })
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(.pink, lineWidth: 4)
                                )
                        }, placeholder: {
                            
                            VStack {
                                Text(show.name)
                                    .foregroundColor(.primary)
                                    .padding(8)
                                    .frame(width: device.width * 0.4)
                                    .background(.thinMaterial)
                                    .cornerRadius(radius: 10, corners: .allCorners)
                                    .lineLimit(3)
                                    .minimumScaleFactor(0.5)
                            }
                            .padding()
                            .frame(width: device.width * 0.45, height: device.width * 0.4 * 1.5)
                            .background(.pink)
                            .cornerRadius(radius: 10, corners: .allCorners)
                        })
                    })
                })
            })
        }
    }
}

struct ShowResult: Codable {
    var results: [NewShow]
}

struct MovieResult: Codable {
    var results: [NewMovie]
}

struct NewShow: Codable, Hashable {
    //var poster: String
    //var popularity: Float
    //var id: Int
    //var vote_average: Float
    //var first_air_date: String
    //var origin_country: [String]
    //var genre_ids: [Int]
    //var original_language: String
    //var vote_count: Int
    var backdrop_path: String?
    var id: Int
    var name: String
    var overview: String
    //var original_name: String
    //var total_results: Int
    //var total_pages: Int
}

struct NewMovie: Codable, Hashable {
    //var poster: String
    //var popularity: Float
    //var id: Int
    //var vote_average: Float
    //var first_air_date: String
    //var origin_country: [String]
    //var genre_ids: [Int]
    //var original_language: String
    //var vote_count: Int
    var backdrop_path: String?
    var id: Int
    var overview: String
    var release_date: String
    var title: String
    //var original_name: String
    //var total_results: Int
    //var total_pages: Int
}

struct APITestView_Previews: PreviewProvider {
    static var previews: some View {
        APITestView()
    }
}

struct Joke: Codable {
    let value: String
}

func safeQuery(_ query: String) -> String {
    return query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
}

class deviceScreen {
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
}

extension String {
    
    var urlSafe: String { return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "" }
    
    func convertToDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let dt = dateFormatter.date(from: self) {
            return dt
        } else {
            return Date()
        }
    }
    
}
