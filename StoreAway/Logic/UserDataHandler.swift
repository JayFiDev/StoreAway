//
//  UserDataHandler.swift
//  StoreAway
//
//  Created by JayFi on 14.11.20.
//
import Foundation

class UserData : ObservableObject {
  
  @Published var watchedFolders : [URL] = []
  @Published var mappingData : [Mapping] = []
  
  init(){
    watchedFolders = loadURL()
    mappingData = loadMapping()
  }


  func addMapping(name: [String], path: URL)
  {
    mappingData.append(Mapping(id: UUID(), name: name, path: path))
    saveMappingToUserData(current: mappingData)
  }
  
  func removeMapping(index: Int){
    mappingData.remove(at: index)
    saveMappingToUserData(current: mappingData)
  }
  
  func saveMappingToUserData(current: [Mapping]){
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(current) {
      let defaults = UserDefaults.standard
      defaults.set(encoded, forKey: "Mapping")
    }
  }
  
  func loadMapping() -> [Mapping] {
    if let data = UserDefaults.standard.object(forKey: "Mapping") as? Data {
      let decoder = JSONDecoder()
      if let temp = try? decoder.decode([Mapping].self, from: data) {
        print(temp.count)
        return temp
      }
    }
    return []
  }
  
  
  func addFolderWatch(path: URL)
  {
    watchedFolders.append(path)
    saveWatchedFoldersToUserData(current: self.watchedFolders)
  }
  
  func removeFolderWatch(index : Int){
    watchedFolders.remove(at: index)
    saveWatchedFoldersToUserData(current: self.watchedFolders)
  }
  
  func saveWatchedFoldersToUserData(current: [URL]){
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
        print(temp.count)
        return temp
      }
    }
    return []
  }
  
  
  
}

