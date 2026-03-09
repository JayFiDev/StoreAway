//
//  UserDataHandler.swift
//  StoreAway
//
//  Created by Jürgen Fink on 06.12.20.
//

import Foundation

class UserDataHandler {
  public func setBoolValue(for key: String, value: Bool) {
    UserDefaults.standard.set(value, forKey: key)
  }

  public func saveOptions(options: Options) {
    setBoolValue(for: "DetailView", value: options.detailViewEnabled)
    setBoolValue(for: "CopyOnly", value: options.copyObjects)
    setBoolValue(for: "AskEveryFileDialog", value: options.askEveryFile)
    setBoolValue(for: "keepFolderStructure", value: options.keepFolderStructure)
    setBoolValue(for: "autoOrganize", value: options.autoOrganize)
    setBoolValue(for: "launchAtLogin", value: options.launchAtLogin)
    setBoolValue(for: "showDockIcon", value: options.showDockIcon)
    setBoolValue(for: "showMenuBarIcon", value: options.showMenuBarIcon)
  }

  public func loadOptions() -> Options {
    let defaults = UserDefaults.standard

    // Use object(forKey:) to detect if the key exists, then apply defaults for new installs
    let detail = defaults.bool(forKey: "DetailView")
    let copy = defaults.bool(forKey: "CopyOnly")
    let askEvery = defaults.bool(forKey: "AskEveryFileDialog")

    // keepFolderStructure defaults to true
    let keepFolder = defaults.object(forKey: "keepFolderStructure") == nil
      ? true
      : defaults.bool(forKey: "keepFolderStructure")

    let autoOrganize = defaults.bool(forKey: "autoOrganize")
    let launchAtLogin = defaults.bool(forKey: "launchAtLogin")

    // showDockIcon defaults to true
    let showDockIcon = defaults.object(forKey: "showDockIcon") == nil
      ? true
      : defaults.bool(forKey: "showDockIcon")

    // showMenuBarIcon defaults to false
    let showMenuBarIcon = defaults.bool(forKey: "showMenuBarIcon")

    return Options(
      detailViewEnabled: detail,
      copyObjects: copy,
      askEveryFile: askEvery,
      keepFolderStructure: keepFolder,
      autoOrganize: autoOrganize,
      launchAtLogin: launchAtLogin,
      showDockIcon: showDockIcon,
      showMenuBarIcon: showMenuBarIcon
    )
  }

  public func saveWatchedFoldersToUserData(current: [URL]) {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(current) {
      UserDefaults.standard.set(encoded, forKey: "WatchedFolders")
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

  public func saveMappingToUserData(current: [Mapping]) {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(current) {
      UserDefaults.standard.set(encoded, forKey: "Mapping")
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

  public func saveHistory(history: [OperationRecord]) {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(history) {
      UserDefaults.standard.set(encoded, forKey: "OperationHistory")
    }
  }

  public func loadHistory() -> [OperationRecord] {
    if let data = UserDefaults.standard.object(forKey: "OperationHistory") as? Data {
      let decoder = JSONDecoder()
      if let temp = try? decoder.decode([OperationRecord].self, from: data) {
        return temp
      }
    }
    return []
  }

}
