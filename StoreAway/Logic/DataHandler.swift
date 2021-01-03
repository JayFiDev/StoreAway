//
//  UserDataHandler.swift
//  StoreAway
//
//  Created by JayFi on 14.11.20.
//
import Foundation
import UniformTypeIdentifiers
import SwiftUI

class DataHandler: ObservableObject {

  let fileHandler = FileHandler()
  let bookmarkHandler = BookmarkHandler()
  let userDataHandler = UserDataHandler()

  @Published var previews: [Previews] = []
  @Published var statistics: [Stats] = []

  @Published var watchedFolders: [URL] = [] {
    didSet {
      update()
    }
  }

  @Published var mappingData: [Mapping] = [] {
    didSet {
      update()
    }
  }

  @Published var options: Options {
    didSet {
      userDataHandler.saveOptions(options: options)
    }
  }

  init() {
    watchedFolders = userDataHandler.loadURL()
    mappingData = userDataHandler.loadMapping()
    options = userDataHandler.loadOptions()

    enableFileAccess()
    statistics = fileHandler.getStats(folders: watchedFolders, mappings: mappingData)
    disableFileAccess()
  }

  func addMapping(path: URL, fileExtensions: [String]) {
    mappingData.append(Mapping(path: path, fileExtensions: fileExtensions))
    bookmarkHandler.saveBookmarkData(for: path)
    userDataHandler.saveMappingToUserData(current: mappingData)
  }

  func addMapping(path: URL, fileType: Type) {
    mappingData.append(Mapping(path: path, fileType: fileType))
    bookmarkHandler.saveBookmarkData(for: path)
    userDataHandler.saveMappingToUserData(current: mappingData)
  }

  func updateMapping(id: UUID, replaceWith: Mapping) {

    if let index = mappingData.firstIndex(where: {$0.id == id}) {

      if mappingData[index].path != replaceWith.path {
        bookmarkHandler.removeBookmarkData(for: mappingData[index].path)
        bookmarkHandler.saveBookmarkData(for: replaceWith.path)
      }
      mappingData[index] = replaceWith
      userDataHandler.saveMappingToUserData(current: mappingData)

    }

  }

  func removeMapping(id: UUID ) {

    if let index = mappingData.firstIndex(where: {$0.id == id}) {
      removeMapping(index: index)
    }
  }

  func removeMapping(index: Int) {
    bookmarkHandler.removeBookmarkData(for: mappingData[index].path)
    mappingData.remove(at: index)
    userDataHandler.saveMappingToUserData(current: mappingData)
  }

  func addFolderWatch(path: URL) {
    watchedFolders.append(path)
    bookmarkHandler.saveBookmarkData(for: path)
    userDataHandler.saveWatchedFoldersToUserData(current: self.watchedFolders)
  }

  func removeFolderWatch(index: Int) {
    bookmarkHandler.removeBookmarkData(for: watchedFolders[index])
    watchedFolders.remove(at: index)
    userDataHandler.saveWatchedFoldersToUserData(current: self.watchedFolders)
  }

  public func enableFileAccess() {
    bookmarkHandler.enableFileAccess()
  }

  public func disableFileAccess() {
    bookmarkHandler.disableFileAccess()
  }

  func update() {
    enableFileAccess()
    statistics = fileHandler.getStats(folders: watchedFolders, mappings: mappingData)
    previews = fileHandler.preview(mapping: mappingData, folders: watchedFolders)
    disableFileAccess()
  }

  func action() {
    bookmarkHandler.enableFileAccess()

    fileHandler.action(mapping: mappingData, folders: watchedFolders, options: options )

    bookmarkHandler.disableFileAccess()
  }

  func dropAction(folders: [URL], files: [URL]) {
    bookmarkHandler.enableFileAccess()
    fileHandler.action(mapping: mappingData, folders: folders, options: options )
    fileHandler.actionFiles(mapping: mappingData, files: files, options: options )

    bookmarkHandler.disableFileAccess()
  }

  func dropHandler(_ providers: [NSItemProvider] ) -> Bool {

    var tempFolders: [URL] = []
    var tempFiles: [URL] = []
    let group = DispatchGroup()

    for provider in providers {
      group.enter()
      DispatchQueue.global().async {
        provider.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, _) in
          if let data = data, let path = NSString(data: data, encoding: 4), let url = URL(string: path as String) {
            if url.isDirectory {
              tempFolders.append(url)
            } else {
              tempFiles.append(url)
            }
          }
          group.leave()
        })
      }
    }

    group.wait()

    DispatchQueue.global().async {
      self.dropAction(folders: tempFolders, files: tempFiles)
    }

    return true
    }

}
