//
//  PersistanceData.swift
//  PersistanceData
//
//  Created by Luke Drushell on 7/29/21.
//

import Foundation
import SwiftUI
import CoreData

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
