//
//  UserDataHandler.swift
//  StoreAway
//
//  Created by Jürgen Fink on 06.12.20.
//

import Foundation

class UserDataHandler
{
  public func setBoolValue(for key: String, value: Bool){
    UserDefaults.standard.set(value, forKey: key)
  }
  
  public  func saveWatchedFoldersToUserData(current: [URL]){
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(current) {
      let defaults = UserDefaults.standard
      defaults.set(encoded, forKey: "WatchedFolders")
    }
  }
  
  func loadURL() -> [URL] {
    if let data = UserDefaults.standard.object(forKey: "WatchedFolders") as? Data {
      let decoder = JSONDecoder()
      if let temp = try? decoder.decode([URL].self, from: data) {
        return temp
      }
    }
    return []
  }
  
  public func saveMappingToUserData(current: [Mapping]){
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(current) {
      let defaults = UserDefaults.standard
      defaults.set(encoded, forKey: "Mapping")
    }
  }
  
  public func loadMapping() -> [Mapping] {
    if let data = UserDefaults.standard.object(forKey: "Mapping") as? Data {
      let decoder = JSONDecoder()
      if let temp = try? decoder.decode([Mapping].self, from: data) {
        return temp
      }
    }
    return []
  }
  
  
}
