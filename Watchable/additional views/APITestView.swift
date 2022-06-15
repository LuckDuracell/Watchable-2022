//
//  APITestView.swift
//  Watchable
//
//  Created by Luke Drushell on 3/30/22.
//

import SwiftUI

struct APITestView: View {
    
    let device = deviceScreen()
    let key = API().key
    @State var query = ""
    @State var movies: [NewMovie] = []
    @State var shows: [NewShow] = []
    @Environment(\.colorScheme) var colorScheme
    private var columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    @State var showingPop = true
    
    func runSearch() {
        withAnimation {
            showingPop = false
        }
        Task {
            let (data, _) = try await URLSession.shared.data(from: URL(string:"https://api.themoviedb.org/3/search/tv?api_key=\(key)&language=en-US&page=1&query=\(query.urlSafe)&include_adult=false")!)
            shows = []
            let decodedResponse = try? JSONDecoder().decode(ShowResult.self, from: data)
            if decodedResponse?.results.count != 0 {
                for i in 0...(Int(decodedResponse?.results.count ?? 1)) - 1 {
                    let res = decodedResponse?.results[i] ?? NewShow(backdrop_path: "", first_air_date: "", id: 0, name: "", overview: "")
                    shows.append(NewShow(backdrop_path: res.backdrop_path, first_air_date: res.first_air_date, id: res.id, name: res.name, overview: res.overview, poster_path: res.poster_path))
                }
            }
            
            let (data2, _) = try await URLSession.shared.data(from: URL(string:"https://api.themoviedb.org/3/search/movie?api_key=\(key)&language=en-US&page=1&query=\(query.urlSafe)&include_adult=false")!)
            movies = []
            let decodedResponse2 = try? JSONDecoder().decode(MovieResult.self, from: data2)
            if decodedResponse2?.results.count != 0 {
                for i in 0...(Int(decodedResponse2?.results.count ?? 1)) - 1 {
                    let res = decodedResponse2?.results[i] ?? NewMovie(backdrop_path: "", id: 0, overview: "", release_date: "", title: "")
                    movies.append(NewMovie(backdrop_path: res.backdrop_path, id: res.id, overview: res.overview, release_date: res.release_date, title: res.title, poster_path: res.poster_path))
                }
            }
            if movies == [NewMovie(backdrop_path: "", id: 0, overview: "", release_date: "", title: "")] {  movies = []  }
            if shows == [NewShow(backdrop_path: "", first_air_date: "", id: 0, name: "", overview: "")] {  shows = []  }
            if movies.count > 4 { movies.removeSubrange(4...(movies.count - 1)) }
            if shows.count > 4 { shows.removeSubrange(4...(shows.count - 1)) }
        }
    }
    
    func runPopSearch() {
        Task {
            let (data, _) = try await URLSession.shared.data(from: URL(string:"https://api.themoviedb.org/3/trending/tv/week?api_key=\(key)")!)
            shows = []
            let decodedResponse = try? JSONDecoder().decode(ShowResult.self, from: data)
            if decodedResponse?.results.count != 0 {
                for i in 0...(Int(decodedResponse?.results.count ?? 1)) - 1 {
                    let res = decodedResponse?.results[i] ?? NewShow(backdrop_path: "", first_air_date: "", id: 0, name: "", overview: "")
                    shows.append(NewShow(backdrop_path: res.backdrop_path, first_air_date: res.first_air_date, id: res.id, name: res.name, overview: res.overview, poster_path: res.poster_path))
                }
            }
            
            let (data2, _) = try await URLSession.shared.data(from: URL(string:"https://api.themoviedb.org/3/trending/movie/week?api_key=\(key)")!)
            movies = []
            let decodedResponse2 = try? JSONDecoder().decode(MovieResult.self, from: data2)
            if decodedResponse2?.results.count != 0 {
                for i in 0...(Int(decodedResponse2?.results.count ?? 1)) - 1 {
                    let res = decodedResponse2?.results[i] ?? NewMovie(backdrop_path: "", id: 0, overview: "", release_date: "", title: "")
                    movies.append(NewMovie(backdrop_path: res.backdrop_path, id: res.id, overview: res.overview, release_date: res.release_date, title: res.title, poster_path: res.poster_path))
                }
            }
            if movies == [NewMovie(backdrop_path: "", id: 0, overview: "", release_date: "", title: "")] {  movies = []  }
            if shows == [NewShow(backdrop_path: "", first_air_date: "", id: 0, name: "", overview: "")] {  shows = []  }
            if movies.count > 4 { movies.removeSubrange(4...(movies.count - 1)) }
            if shows.count > 4 { shows.removeSubrange(4...(shows.count - 1)) }
        }
    }

    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    TextField("Search", text: $query)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                        .keyboardType(.alphabet)
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
            }
            Divider()
            if showingPop {
                HStack {
                    Text("TRENDING:")
                        .font(Font.footnote)
                        .foregroundColor(.gray)
                        .padding(.leading)
                    Spacer()
                }
            }
            LazyVGrid(columns: columns, content: {
                ForEach(movies, id: \.self, content: { movie in
                    NavigationLink(destination: {
                        APIAdd(item: WatchableItem(title: movie.title, subtitle: "", themes: [], release: movie.release_date.convertToDate(), synopsis: movie.overview, sources: [], buySources: [], itemType: 0, backdrop: URL(string: "https://www.themoviedb.org/t/p/original\(movie.backdrop_path ?? "")")!, poster: URL(string: "https://www.themoviedb.org/t/p/w500/\(movie.poster_path ?? "")")!, seasons: 0, releaseDay: 0, currentlyReleasing: false, remindMe: false, currentlyWatching: false, folder: "", id: movie.id))
                    }, label: {
                        ZStack {
                            AsyncImage(url: URL(string: "https://www.themoviedb.org/t/p/original\(movie.backdrop_path ?? "")")!, content: { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: device.width * 0.42, height: device.width * 0.4 * 1.5, alignment: .center)
                                    .clipped()
                                    .cornerRadius(radius: 15, corners: .allCorners)
                                    .overlay(alignment: .bottom,content: {
                                        Text(movie.title)
                                            .foregroundColor(.primary)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 5)
                                            .frame(width: device.width * 0.42)
                                            .background(.ultraThinMaterial)
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
                                        .frame(width: device.width * 0.38)
                                        .background(.ultraThinMaterial)
                                        .cornerRadius(radius: 10, corners: .allCorners)
                                        .lineLimit(3)
                                        .minimumScaleFactor(0.5)
                                }
                                .padding()
                                .frame(width: device.width * 0.42, height: device.width * 0.4 * 1.5)
                                .background(.pink)
                                .cornerRadius(radius: 10, corners: .allCorners)
                            })
                            AsyncImage(url: URL(string: "https://www.themoviedb.org/t/p/w500\(movie.poster_path ?? "")"), content: { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: device.width * 0.42, height: device.width * 0.4 * 1.5, alignment: .center)
                                    .clipped()
                                    .cornerRadius(radius: 15, corners: .allCorners)
                                    .overlay(alignment: .bottom,content: {
                                        Text(movie.title)
                                            .foregroundColor(.primary)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 5)
                                            .frame(width: device.width * 0.42)
                                            .background(.ultraThinMaterial)
                                            .cornerRadius(radius: 15, corners: [.bottomLeft, .bottomRight])
                                    })
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(.pink, lineWidth: 4)
                                    )
                            }, placeholder: {
                            })
                        }
                    })
                })
            })
            if shows != [] && movies != [] {
                Divider()
            }
            LazyVGrid(columns: columns, content: {
                ForEach(shows, id: \.self, content: { show in
                    NavigationLink(destination: {
                        APIAdd(item: WatchableItem(title: show.name, subtitle: "", themes: [], release: show.first_air_date?.convertToDate() ?? Date(), synopsis: show.overview, sources: [], buySources: [], itemType: 1, backdrop: URL(string: "https://www.themoviedb.org/t/p/original\(show.backdrop_path ?? "")")!, poster: URL(string: "https://www.themoviedb.org/t/p/w500/\(show.poster_path ?? "")")!, seasons: 0, releaseDay: 0, currentlyReleasing: false, remindMe: false, currentlyWatching: false, folder: "", id: show.id))
                    }, label: {
                        ZStack {
                            AsyncImage(url: URL(string: "https://www.themoviedb.org/t/p/original\(show.backdrop_path ?? "")")!, content: { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: device.width * 0.42, height: device.width * 0.4 * 1.5, alignment: .center)
                                    .clipped()
                                    .cornerRadius(radius: 15, corners: .allCorners)
                                    .overlay(alignment: .bottom,content: {
                                        Text(show.name)
                                            .foregroundColor(.primary)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 5)
                                            .frame(width: device.width * 0.42)
                                            .background(.ultraThinMaterial)
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
                                        .frame(width: device.width * 0.38)
                                        .background(.ultraThinMaterial)
                                        .cornerRadius(radius: 10, corners: .allCorners)
                                        .lineLimit(3)
                                        .minimumScaleFactor(0.5)
                                }
                                .padding()
                                .frame(width: device.width * 0.42, height: device.width * 0.4 * 1.5)
                                .background(.pink)
                                .cornerRadius(radius: 10, corners: .allCorners)
                            })
                            AsyncImage(url: URL(string: "https://www.themoviedb.org/t/p/w500/\(show.poster_path ?? "")"), content: { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: device.width * 0.42, height: device.width * 0.4 * 1.5, alignment: .center)
                                    .clipped()
                                    .cornerRadius(radius: 15, corners: .allCorners)
                                    .overlay(alignment: .bottom,content: {
                                        Text(show.name)
                                            .foregroundColor(.primary)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 5)
                                            .frame(width: device.width * 0.42)
                                            .background(.ultraThinMaterial)
                                            .cornerRadius(radius: 15, corners: [.bottomLeft, .bottomRight])
                                    })
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(.pink, lineWidth: 4)
                                    )
                            }, placeholder: {
                            })
                        }
                    })
                })
            })
        } .onAppear(perform: {
            runPopSearch()
        })
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
    var first_air_date: String?
    var id: Int
    var name: String
    var overview: String
    var poster_path: String?
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
    var poster_path: String?
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
