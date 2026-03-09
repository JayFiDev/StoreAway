//
//  LaunchAtLoginHandler.swift
//  StoreAway
//

import Foundation
import ServiceManagement

class LaunchAtLoginHandler {

  static var isEnabled: Bool {
    if #available(macOS 13.0, *) {
      return SMAppService.mainApp.status == .enabled
    }
    return false
  }

  static func setEnabled(_ enabled: Bool) {
    if #available(macOS 13.0, *) {
      do {
        if enabled {
          try SMAppService.mainApp.register()
        } else {
          try SMAppService.mainApp.unregister()
        }
      } catch {
        print("LaunchAtLoginHandler: Failed to \(enabled ? "register" : "unregister") — \(error)")
      }
    }
  }

}
