//
//  NewSheet.swift
//  NewSheet
//
//  Created by Luke Drushell on 7/30/21.
//

import SwiftUI

struct NewSheet: View {
    
    @Binding var showSheet: Bool
    @Binding var movies: [Movie]
    @Binding var showsV2: [ShowV2]
    
    @State private var selectedDate: Date = Date()
    @State private var showDate: Bool = false
    
    @State private var title = ""
    @State private var notes = ""
    
    @State var typePicker = "Movie"
    @State var viewingTypes = ["Movie", "Show"]
    
    @State var iconTheme = "Default"
    @State var themeTypes = ["Default", "Action", "Fantasy", "Sci-Fi", "Drama", "Comedy", "Romance", "Horror", "Documentary", "Game Show"]
    
    @State var platformTypes = ["Theater", "Netflix", "Hulu", "HBO Max", "Prime Video", "Disney+", "Youtube TV", "Apple TV", "Peacock", "Crunchyroll", "Paid Only", "Unknown"]
    @State var platform = "Theater"
    
    @State var reoccuringTypes = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    @State var reoccuringDay = "Sunday"
    
    @State var active = false
    @State var reoccuring = false
    
    
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        Picker("Picker", selection: $typePicker, content: {
                            ForEach(viewingTypes, id:\.self, content: {
                                Text($0)
                            })
                        }) .pickerStyle(.segmented)
                        .listRowBackground(Color(.systemGroupedBackground))
                        .padding(.top)
                    }
                    
                    Section {
                        TextField("Title", text: $title)
                            .autocapitalization(.words)
                            .disableAutocorrection(true)
                            .keyboardType(.alphabet)
                        
                        TextField("Notes", text: $notes)
                    }
                    
                    Section {
                        Picker("Theme", selection: $iconTheme, content: {
                            ForEach(themeTypes, id: \.self, content: {
                                pickerLabel(name: $0, image: getImageForType(type: $0))
                            })
                        })
                        Picker("Platform", selection: $platform, content: {
                            ForEach(platformTypes, id: \.self, content: {
                                Text($0)
                            })
                        })
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
                        if typePicker == "Show" {
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
   
                }
                
                Button {
                    if typePicker == "Movie" {
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
                    showSheet.toggle()
                } label: {
                    Text(title == "" ? "Dismiss" : "Save")
                        .foregroundColor(.white)
                        .bold()
                        .frame(width: 300, height: 50, alignment: .center)
                        .background(Color.pink)
                        .cornerRadius(15)
                        .padding()
                        .padding(.bottom, 30)
                }
            }
            .edgesIgnoringSafeArea(.horizontal)
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarTitle("Add Item", displayMode: .automatic)
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct NewSheet_Previews: PreviewProvider {
    static var previews: some View {
        NewSheet(showSheet: .constant(true), movies: .constant([]), showsV2: .constant([]))
            //.preferredColorScheme(.dark)
    }
}

func getImageForType(type: String) -> String {
    if type == "Action" {
        return "hourglass"
    } else if type == "Fantasy" {
        return "checkerboard.shield"
    } else if type == "Sci-Fi" {
        return "waveform"
    } else if type == "Drama" {
        return "theatermasks.fill"
    } else if type == "Comedy" {
        return "quote.bubble.fill"
    } else if type == "Romance" {
        return "heart.fill"
    } else if type == "Horror" {
        return "exclamationmark.triangle.fill"
    } else if type == "Documentary" {
        return "camera.fill"
    } else if type == "Game Show" {
        return "dice.fill"
    } else {
        return "tv"
    }
}

func getTypeForImage(image: String) -> String {
    if image == "hourglass" {
        return "Action"
    } else if image == "checkerboard.shield" {
        return "Fantasy"
    } else if image == "waveform" {
        return "Sci-Fi"
    } else if image == "theatermasks.fill" {
        return "Drama"
    } else if image == "quote.bubble.fill" {
        return "Comedy"
    } else if image == "heart.fill" {
        return "Romance"
    } else if image == "exclamationmark.triangle.fill" {
        return "Horror"
    } else if image == "camera.fill" {
        return "Documentary"
    } else if image == "dice.fill" {
        return "Game Show"
    } else {
        return "Default"
    }
}

struct pickerLabel: View {
    
    let name: String
    let image: String
    
    var body: some View {
        Label(name, systemImage: image)
    }
    
}

func dayToInt(day: String) -> Int {
    switch day {
    case "Sunday":
        return 1
    case "Monday":
        return 2
    case "Tuesday":
        return 3
    case "Wednesday":
        return 4
    case "Thursday":
        return 5
    case "Friday":
        return 6
    default:
        return 7
    }
}

func dateToWeekdayString(day: Date) -> String {
    
    let calendar = Calendar(identifier: .gregorian)
    switch calendar.component(.weekday, from: day) {
    case 1:
        return "Sunday"
    case 2:
        return "Monday"
    case 3:
        return "Tuesday"
    case 4:
        return "Wednesday"
    case 5:
        return "Thursday"
    case 6:
        return "Friday"
    default:
        return "Saturday"
    }
}
