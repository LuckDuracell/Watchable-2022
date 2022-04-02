//
//  Prototype.swift
//  Watchable
//
//  Created by Luke Drushell on 4/1/22.
//

import SwiftUI

struct Prototype: View {
    
    let movie = WatchableItem(title: "Doctor Strange 2", subtitle: "Multiverse of Madness", themes: ["Action", "Fantasy", "Horror"], release:  movieDate(), synopsis: "Dr Stephen Strange casts a forbidden spell that opens a portal to the multiverse. However, a threat emerges that may be too big for his team to handle.", sources: ["Theater"], itemType: 0, poster: URL(string: "https://nerdist.com/wp-content/uploads/2021/01/DoctorStrangeInTheMultiverseOfMadness_Teaser2_Printed_1-Sht_v4_lg.jpg")!, seasons: 0, releaseDay: 8, currentlyReleasing: false)
    @State var remindMe = false
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
            ScrollView {
                HStack {
                    AsyncImage(url: URL(string: "\(movie.poster)")) { image in
                        image
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width * 0.35, height: (UIScreen.main.bounds.width * 0.35) * (1.6), alignment: .center)
                            .scaledToFill()
                            .cornerRadius(15)
                    } placeholder: {
                        Color.gray.opacity(0.2)
                            .frame(width: UIScreen.main.bounds.width * 0.4, height: (UIScreen.main.bounds.width * 0.4) * (1.6), alignment: .center)
                            .cornerRadius(15)
                    }
                    VStack(alignment: .leading) {
                        VStack {
                            Text("\(movie.title)")
                                .font(.title2)
                                .bold()
                                .multilineTextAlignment(.leading)
                            Text(movie.subtitle)
                                .font(.title3)
                                .bold()
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 3)
                        }
                        Text(themesToString(themes: movie.themes))
                            .font(.subheadline)
                            .bold()
                            .padding()
                            .frame(width: UIScreen.main.bounds.width * 0.55, height: 50, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(10)
                        Text("Releasing \(movie.release.formatted(date: .abbreviated, time: .omitted))")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.red)
                            .padding()
                            .frame(width: UIScreen.main.bounds.width * 0.55, height: 50, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(15)
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
                    Text(movie.synopsis)
                        .frame(width: UIScreen.main.bounds.width * 0.85, alignment: .leading)
                        .padding()
                        .background(Color.white)
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
                    Button {
                        
                    } label: {
                        HStack {
                            Text("Get Tickets")
                                .foregroundColor(.red)
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.red)
                        } .frame(width: UIScreen.main.bounds.width * 0.85, alignment: .leading)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                    }
                }
                Divider()
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .opacity(0.5)
                Toggle("Remind Me", isOn: $remindMe)
                    .frame(width: UIScreen.main.bounds.width * 0.85, alignment: .leading)
                    .padding(15)
                    .background(Color.white)
                    .cornerRadius(15)
                Spacer()
                Button {
                    
                } label: {
                    Text("Add to List")
                        .foregroundColor(.white)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 20).frame(width: UIScreen.main.bounds.width * 0.9, height: 60, alignment: .center).foregroundColor(.pink))
                        .padding(30)
                }
            }
            .padding(10)
        }
    }
}

struct Prototype_Previews: PreviewProvider {
    static var previews: some View {
        Prototype()
    }
}


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
