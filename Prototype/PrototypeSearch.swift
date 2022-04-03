//
//  PrototypeSearch.swift
//  Watchable
//
//  Created by Luke Drushell on 4/3/22.
//

import SwiftUI

struct PrototypeSearch: View {
    
    @Binding var showSheet: Bool
    @State var search = searchInfo(text: "", movies: true, shows: true, themes: [""])
    @State var items: [WatchableItem] = [WatchableItem(title: "Doctor Strange 2", subtitle: "Multiverse of Madness", themes: ["Action", "Fantasy", "Horror"], release:  movieDate(), synopsis: "Dr Stephen Strange casts a forbidden spell that opens a portal to the multiverse. However, a threat emerges that may be too big for his team to handle.", sources: ["Theater"], itemType: 0, poster: URL(string: "https://nerdist.com/wp-content/uploads/2021/01/DoctorStrangeInTheMultiverseOfMadness_Teaser2_Printed_1-Sht_v4_lg.jpg")!, seasons: 0, releaseDay: 8, currentlyReleasing: false, remindMe: false, currentlyWatching: false), WatchableItem(title: "The Lost City", subtitle: "", themes: ["Comedy", "Action"], release:  movieDate(), synopsis: "Funny movie with the comedies than go to the place author something something famous movie star", sources: ["Theater"], itemType: 0, poster: URL(string: "https://m.media-amazon.com/images/M/MV5BMmIwYzFhODAtY2I1YS00ZDdmLTkyYWQtZjI5NDIwMDc2MjEyXkEyXkFqcGdeQXVyODk4OTc3MTY@._V1_.jpg")!, seasons: 0, releaseDay: 8, currentlyReleasing: false, remindMe: false, currentlyWatching: false), WatchableItem(title: "The Witcher", subtitle: "", themes: ["Action", "Fantasy"], release: Date(), synopsis: "Henry Cavill is super handsome and saves the world with his magical horse and his magical sword skills and drugs", sources: ["Netflix"], itemType: 1, poster: URL(string: "https://resizing.flixster.com/IfomupSdCO8TeDf8kmqq3Py4tys=/ems.ZW1zLXByZC1hc3NldHMvdHZzZWFzb24vZTk1NGUyZTItMWEzZC00MzY2LTkxODktZjAyY2NkNzY2ZmU3LmpwZw==")!, seasons: 2, releaseDay: 8, currentlyReleasing: false, remindMe: false, currentlyWatching: false), WatchableItem(title: "The Flash", subtitle: "", themes: ["Action", "Sci-Fi", "Comedy"], release:  Date(), synopsis: "When a random science dude gets stuck by lightning his whole life is turned upsidedown in this wacky show about how a genius with the ability to think at superspeed and move faster than god somehow manages to fail at even being slightly helpful", sources: ["CW Seed", "Youtube TV", "Netflix"], itemType: 1, poster: URL(string: "https://images.cwtv.com/images/cw/show-vertical/the-flash.jpg")!, seasons: 8, releaseDay: 3, currentlyReleasing: true, remindMe: true, currentlyWatching: false)]
    
    var body: some View {
        NavigationView {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
                ScrollView {
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("SEARCH:")
                                    .font(Font.subheadline)
                                    .foregroundColor(.gray)
                                Spacer()
                                Button {
                                    search.movies.toggle()
                                } label: {
                                    HStack {
                                        Text("Movies")
                                        Image(systemName: search.movies ? "checkmark" : "")
                                    }
                                    .frame(width: UIScreen.main.bounds.width * 0.19, alignment: .leading)
                                    .font(.footnote)
                                    .padding(7)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                }
                                Button {
                                    search.shows.toggle()
                                } label: {
                                    HStack() {
                                        Text("Shows")
                                        Image(systemName: search.shows ? "checkmark" : "")
                                    }
                                    .frame(width: UIScreen.main.bounds.width * 0.19, alignment: .leading)
                                    .font(.footnote)
                                    .padding(7)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                }
                            } .padding(.horizontal)
                                .accentColor(.pink)
                            TextField("", text: $search.text)
                                .frame(width: UIScreen.main.bounds.width * 0.85, alignment: .leading)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(15)
                        }
                        Divider()
                            .padding()
                            .opacity(0.5)
                        if search.text == "" {
                        VStack(alignment: .leading) {
                            Text("FEATURED:")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding()
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], content: {
                                ForEach(items.indices, id: \.self, content: { index  in
                                    NavigationLink(destination: Prototype(showSheet: $showSheet, item: items[index]), label: {
                                        AsyncImage(url: URL(string: "\(items[index].poster)")) { image in
                                            image
                                                .resizable()
                                                .frame(width: UIScreen.main.bounds.width * 0.4, height: (UIScreen.main.bounds.width * 0.4) * (1.6), alignment: .center)
                                                .scaledToFill()
                                                .cornerRadius(15)
                                                .padding(.horizontal)
                                        } placeholder: {
                                            Color.gray.opacity(0.2)
                                                .frame(width: UIScreen.main.bounds.width * 0.4, height: (UIScreen.main.bounds.width * 0.4) * (1.6), alignment: .center)
                                                .cornerRadius(15)
                                                .padding(.horizontal)
                                        }
                                    })
                                })
                            })
                        }
                        } else {
                            ForEach(items.indices, id: \.self, content: { index in
                                if items[index].title.contains(search.text) {
                                    Text("\(items[index].title)\(items[index].subtitle != "" ? " - " : "")\(items[index].subtitle != "" ? items[index].subtitle : "")")
                                }
                            })
                        }
                    } .padding()
                }
            } .navigationBarTitle("Add Item")
        }
        //.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center)
        .edgesIgnoringSafeArea(.all)
    }
}

struct PrototypeSearch_Previews: PreviewProvider {
    static var previews: some View {
        PrototypeSearch(showSheet: .constant(true))
    }
}

struct searchInfo {
    var text: String
    var movies: Bool
    var shows: Bool
    var themes: [String]
}
