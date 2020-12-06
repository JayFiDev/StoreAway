//
//  UserDataHandler.swift
//  StoreAway
//
//  Created by JayFi on 14.11.20.
//
import Foundation
import SwiftUI


class DataObject : ObservableObject {
  
  let fileHandler = FileHandler()
  let bookmarkHandler = BookmarkHandler()
  let userDataHandler = UserDataHandler()
  
  @Published var watchedFolders : [URL] = []{
    didSet {
      update()
    }
  }
  
  @Published var mappingData : [Mapping] = []{
    didSet {
      update()
    }
  }
  
  @Published var previews : [Previews] = []
  
  @Published var statistics : [Stats] = []
  
  
  @Published var detailViewEnabled : Bool = false {
    didSet {
      userDataHandler.setBoolValue(for: "DetailView", value: detailViewEnabled)
    }
  }
  
  @Published var copyObjects : Bool = false{
    didSet {
      userDataHandler.setBoolValue(for: "CopyOnly", value: copyObjects)
    }
  }
  
  @Published var askEveryFile : Bool = false{
    didSet {
      userDataHandler.setBoolValue(for: "AskEveryFileDialog", value: askEveryFile)
    }
  }
  
  @Published var keepFolderStructure : Bool = false{
    didSet {
      userDataHandler.setBoolValue(for: "keepFolderStructure", value: keepFolderStructure)
    }
  }
  
  init(){
    watchedFolders = userDataHandler.loadURL()
    mappingData = userDataHandler.loadMapping()
    readSettings()
    
    enableFileAccess()
    statistics = fileHandler.getStats(folders: watchedFolders, mappings: mappingData)
    disableFileAccess()
    
  }
  
  func readSettings(){
    detailViewEnabled = UserDefaults.standard.bool(forKey: "DetailView")
    copyObjects = UserDefaults.standard.bool(forKey: "CopyOnly" )
    askEveryFile = UserDefaults.standard.bool(forKey: "AskEveryFileDialog")
    keepFolderStructure = UserDefaults.standard.bool(forKey: "keepFolderStructure")
  }
  
  func addMapping(name: [String], path: URL)
  {
    mappingData.append(Mapping(id: UUID(), name: name, path: path))
    bookmarkHandler.saveBookmarkData(for: path)
    userDataHandler.saveMappingToUserData(current: mappingData)
  }
  
  func removeMapping(index: Int){
    bookmarkHandler.removeBookmarkData(for: mappingData[index].path)
    mappingData.remove(at: index)
    userDataHandler.saveMappingToUserData(current: mappingData)
  }
  
  func addFolderWatch(path: URL)
  {
    watchedFolders.append(path)
    bookmarkHandler.saveBookmarkData(for: path)
    userDataHandler.saveWatchedFoldersToUserData(current: self.watchedFolders)
  }
  
  func removeFolderWatch(index : Int){
    bookmarkHandler.removeBookmarkData(for: watchedFolders[index])
    watchedFolders.remove(at: index)
    userDataHandler.saveWatchedFoldersToUserData(current: self.watchedFolders)
  }

  
}

extension DataObject {
  
  public func enableFileAccess() {
    bookmarkHandler.enableFileAccess()
  }
  
  public func disableFileAccess() {
    bookmarkHandler.disableFileAccess()
  }
  
  func update(){
    enableFileAccess()
    statistics = fileHandler.getStats(folders: watchedFolders, mappings: mappingData)
    previews = fileHandler.preview(mapping: mappingData, folders: watchedFolders)
    disableFileAccess()
  }
  
  func action(){
    bookmarkHandler.enableFileAccess()
    
    fileHandler.action(mapping : mappingData, folders: watchedFolders,
              copyOrMove: copyObjects, keepFolderStructure: keepFolderStructure )
    
    bookmarkHandler.disableFileAccess()
  }
  
}
