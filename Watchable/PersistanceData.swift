//
//  PersistanceData.swift
//  PersistanceData
//
//  Created by Luke Drushell on 7/29/21.
//

import Foundation
import SwiftUI
import CoreData

struct History: Hashable, Codable, LocalFileStorable {
    static var fileName: String {
        return "History"
    }
    var mov: MovieV3
    var show: ShowV3
    var isMovie: Bool
    var change: Int
    var date: Date
    //Deleted = 0
    //Restored = 1
    //Favorited = 2
    
}


struct UserSettings: Hashable, Codable, LocalFileStorable {
    static var fileName: String {
        return "UserSettings"
    }
    var showFavorites: Bool
    var colorScheme: String
}

struct WatchableItems: Hashable, Codable, LocalFileStorable {
    static var fileName: String {
        return "WatchableItems"
    }
    var title: String
    var subtitle: String
    var themes: [String]
    var release: Date
    var synopsis: String
    var sources: [String]
    var itemType: Int
    var poster: URL
    var seasons: Int
    var releaseDay: Int
    var currentlyReleasing: Bool
    
    var remindMe: Bool
    var currentlyWatching: Bool
}

struct Movie: Hashable, Codable, LocalFileStorable {
    static var fileName: String {
        return "Movie"
    }
    var name: String
    var icon: String
    var releaseDate: Date
    var active: Bool
    var info: String
    var platform: String
}

struct Show: Hashable, Codable, LocalFileStorable {
    static var fileName: String {
        return "Show"
    }
    var name: String
    var icon: String
    var releaseDate: Date
    var active: Bool
    var info: String
    var platform: String
    var reoccuring: Bool
}

struct ShowV2: Hashable, Codable, LocalFileStorable {
    static var fileName: String {
        return "Show"
    }
    var name: String
    var icon: String
    var releaseDate: Date
    var active: Bool
    var info: String
    var platform: String
    var reoccuring: Bool
    var reoccuringDate: Date
}

struct ShowV3: Hashable, Codable, LocalFileStorable {
    static var fileName: String {
        return "ShowV3"
    }
    var name: String
    var icon: String
    var releaseDate: Date
    var active: Bool
    var info: String
    var platform: String
    var reoccuring: Bool
    var reoccuringDate: Date
    var favorited: Bool
}

struct MovieV3: Hashable, Codable, LocalFileStorable {
    static var fileName: String {
        return "MovieV3"
    }
    var name: String
    var icon: String
    var releaseDate: Date
    var active: Bool
    var info: String
    var platform: String
    var favorited: Bool
}

struct VersionNumber: Hashable, Codable, LocalFileStorable {
    static var fileName: String {
        return "VersionNumber"
    }
    var ver: Int
}


protocol LocalFilesStorable: Codable {
    static var fileName: String { get }
}

extension LocalFilesStorable {
    static var localStorageURL: URL {
        guard let documentDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Can NOT access file in Documents.")
        }
        
        return documentDirectory
            .appendingPathComponent(self.fileName)
            .appendingPathExtension("json")
    }
}

extension LocalFilesStorable {
    static func loadFromFile() -> [Self] {
        do {
            let fileWrapper = try FileWrapper(url: Self.localStorageURL, options: .immediate)
            guard let data = fileWrapper.regularFileContents else {
                throw NSError()
            }
            return try JSONDecoder().decode([Self].self, from: data)
            
        } catch _ {
            print("Could not load \(Self.self) the model uses an empty collection (NO DATA).")
            return []
        }
    }
}

extension LocalFilesStorable {
    static func saveToFile(_ collection: Self) {
        do {
            let data = try JSONEncoder().encode(collection)
            let jsonFileWrapper = FileWrapper(regularFileWithContents: data)
            try jsonFileWrapper.write(to: self.localStorageURL, options: .atomic, originalContentsURL: nil)
        } catch _ {
            print("Could not save \(Self.self)s to file named: \(self.localStorageURL.description)")
        }
    }
}

protocol LocalFileStorable: Codable {
    static var fileName: String { get }
}

extension LocalFileStorable {
    static var localStorageURL: URL {
        guard let documentDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Can NOT access file in Documents.")
        }
        
        return documentDirectory
            .appendingPathComponent(self.fileName)
            .appendingPathExtension("json")
    }
}

extension LocalFileStorable {
    static func loadFromFile() -> [Self] {
        do {
            let fileWrapper = try FileWrapper(url: Self.localStorageURL, options: .immediate)
            guard let data = fileWrapper.regularFileContents else {
                throw NSError()
            }
            return try JSONDecoder().decode([Self].self, from: data)
            
        } catch _ {
            print("Could not load \(Self.self) the model uses an empty collection (NO DATA).")
            return []
        }
    }
}

extension LocalFileStorable {
    static func saveToFile(_ collection: [Self]) {
        do {
            let data = try JSONEncoder().encode(collection)
            let jsonFileWrapper = FileWrapper(regularFileWithContents: data)
            try jsonFileWrapper.write(to: self.localStorageURL, options: .atomic, originalContentsURL: nil)
        } catch _ {
            print("Could not save \(Self.self)s to file named: \(self.localStorageURL.description)")
        }
    }
}

extension Array where Element: LocalFileStorable {
    ///Saves an array of LocalFileStorables to a file in Documents
    func saveToFile() {
        Element.saveToFile(self)
    }
}
