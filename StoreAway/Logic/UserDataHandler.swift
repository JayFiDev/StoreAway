//
//  UserDataHandler.swift
//  StoreAway
//
//  Created by JayFi on 14.11.20.
//
import Foundation
import SwiftUI


class UserData : ObservableObject {
  
  let fh = FileHandler()
  
  @Published var watchedFolders : [URL] = []{
    didSet {
      updateStats()
      updatePreviews()
    }
  }
  
  @Published var mappingData : [Mapping] = []{
    didSet {
      updateStats()
      updatePreviews()
    }
  }
  
  @Published var previews : [Previews] = []
  
  @Published var statistics : [Stats] = []
  
  @Published var detailViewEnabled : Bool = false {
    didSet {
      UserDefaults.standard.set(detailViewEnabled, forKey: "DetailView")
    }
  }
  
  @Published var copyObjects : Bool = false{
    didSet {
      UserDefaults.standard.set(copyObjects, forKey: "CopyOnly")
    }
  }
  
  @Published var askEveryFile : Bool = false{
    didSet {
      UserDefaults.standard.set(askEveryFile, forKey: "AskEveryFileDialog")
    }
  }
  
  

  
  init(){
    watchedFolders = loadURL()
    mappingData = loadMapping()
    readSettings()
    
    statistics = fh.getStats(folders: watchedFolders, mappings: mappingData)
  }
  
  func updateStats(){
    statistics = fh.getStats(folders: watchedFolders, mappings: mappingData)
  }
  
  func updatePreviews(){
    previews = fh.preview(mapping: mappingData, folders: watchedFolders)
  }
  
  func readSettings(){
    detailViewEnabled = UserDefaults.standard.bool(forKey: "DetailView")
    copyObjects = UserDefaults.standard.bool(forKey: "CopyOnly" )
    askEveryFile = UserDefaults.standard.bool(forKey: "AskEveryFileDialog")
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
        return temp
      }
    }
    return []
  }
  
  
  
}

