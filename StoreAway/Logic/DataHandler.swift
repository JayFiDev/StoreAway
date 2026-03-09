//
//  DataHandler.swift
//  StoreAway
//
//  Created by JayFi on 14.11.20.
//
import Foundation
import UniformTypeIdentifiers
import SwiftUI

extension Notification.Name {
  static let storeAwayDidRun = Notification.Name("storeAwayDidRun")
  static let showPreviewNotification = Notification.Name("showPreviewNotification")
  static let optionsDidChange = Notification.Name("optionsDidChange")
}

class DataHandler: ObservableObject {

  let fileHandler = FileHandler()
  let bookmarkHandler = BookmarkHandler()
  let userDataHandler = UserDataHandler()

  @Published var previews: [Previews] = []
  @Published var statistics: [Stats] = []
  @Published var isRunning = false
  @Published var operationHistory: [OperationRecord] = []

  // Set options first in init so watchedFolders.didSet can safely access it
  @Published var options: Options {
    didSet {
      userDataHandler.saveOptions(options: options)
      if options.autoOrganize != oldValue.autoOrganize {
        options.autoOrganize ? startFolderWatcher() : stopFolderWatcher()
      }
      if options.launchAtLogin != oldValue.launchAtLogin {
        LaunchAtLoginHandler.setEnabled(options.launchAtLogin)
      }
      if options.showDockIcon != oldValue.showDockIcon ||
         options.showMenuBarIcon != oldValue.showMenuBarIcon {
        NotificationCenter.default.post(name: .optionsDidChange, object: nil)
      }
    }
  }

  @Published var watchedFolders: [URL] = [] {
    didSet {
      guard !isInitializing else { return }
      update()
      if options.autoOrganize {
        startFolderWatcher()
      }
    }
  }

  @Published var mappingData: [Mapping] = [] {
    didSet {
      guard !isInitializing else { return }
      update()
    }
  }

  private var folderWatcher: FolderWatcher?
  private var isAutoOrganizing = false
  private var isInitializing = true

  init() {
    // Initialize options first — watchedFolders.didSet references options
    options = userDataHandler.loadOptions()
    operationHistory = userDataHandler.loadHistory()
    watchedFolders = userDataHandler.loadURL()
    mappingData = userDataHandler.loadMapping()

    isInitializing = false

    enableFileAccess()
    statistics = fileHandler.getStats(folders: watchedFolders, mappings: mappingData)
    previews = fileHandler.preview(mapping: mappingData, folders: watchedFolders)
    disableFileAccess()

    if options.autoOrganize {
      startFolderWatcher()
    }
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

  func removeMapping(id: UUID) {
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

  // MARK: - Run Actions

  func runAction(triggerSource: TriggerSource = .manual) {
    guard !isRunning else { return }
    guard !watchedFolders.isEmpty && !mappingData.isEmpty else { return }

    DispatchQueue.main.async { self.isRunning = true }

    DispatchQueue.global().async {
      self.action()
      let moved = self.fileHandler.lastMovedCount
      let copied = self.fileHandler.lastCopiedCount

      DispatchQueue.main.async {
        self.isRunning = false
        self.update()
        self.recordOperation(moved: moved, copied: copied, triggerSource: triggerSource)
      }
    }
  }

  func action() {
    bookmarkHandler.enableFileAccess()
    fileHandler.action(mapping: mappingData, folders: watchedFolders, options: options)
    bookmarkHandler.disableFileAccess()
  }

  func dropAction(folders: [URL], files: [URL]) {
    bookmarkHandler.enableFileAccess()
    fileHandler.action(mapping: mappingData, folders: folders, options: options)
    fileHandler.actionFiles(mapping: mappingData, files: files, options: options)
    bookmarkHandler.disableFileAccess()
  }

  func dropHandler(_ providers: [NSItemProvider]) -> Bool {
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

  // MARK: - History

  private func recordOperation(moved: Int, copied: Int, triggerSource: TriggerSource) {
    let total = moved + copied
    guard total > 0 else { return }

    let record = OperationRecord(date: Date(), filesMoved: moved, filesCopied: copied, triggerSource: triggerSource)

    var history = operationHistory
    history.insert(record, at: 0)
    if history.count > 100 {
      history = Array(history.prefix(100))
    }
    operationHistory = history
    userDataHandler.saveHistory(history: operationHistory)

    NotificationHandler.sendOrganizeComplete(moved: moved, copied: copied)
    NotificationCenter.default.post(
      name: .storeAwayDidRun,
      object: nil,
      userInfo: ["total": total, "date": record.date]
    )
  }

  // MARK: - Folder Watcher

  func startFolderWatcher() {
    stopFolderWatcher()
    guard !watchedFolders.isEmpty else { return }

    let watcher = FolderWatcher()
    watcher.onChange = { [weak self] in
      guard let self = self, !self.isAutoOrganizing, !self.isRunning else { return }
      self.isAutoOrganizing = true
      DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
        self.action()
        let moved = self.fileHandler.lastMovedCount
        let copied = self.fileHandler.lastCopiedCount
        DispatchQueue.main.async {
          self.isAutoOrganizing = false
          self.update()
          self.recordOperation(moved: moved, copied: copied, triggerSource: .autoWatch)
        }
      }
    }
    watcher.start(watching: watchedFolders)
    folderWatcher = watcher
  }

  func stopFolderWatcher() {
    folderWatcher?.stop()
    folderWatcher = nil
  }

}
