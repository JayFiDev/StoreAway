//
//  NotificationHandler.swift
//  StoreAway
//

import UserNotifications

class NotificationHandler {

  static func requestAuthorization() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
  }

  static func sendOrganizeComplete(moved: Int, copied: Int) {
    let total = moved + copied
    guard total > 0 else { return }

    let content = UNMutableNotificationContent()
    content.title = "StoreAway"

    if moved > 0 && copied > 0 {
      content.body = "\(moved) file(s) moved, \(copied) copied"
    } else if moved > 0 {
      content.body = "\(moved) file(s) moved successfully"
    } else {
      content.body = "\(copied) file(s) copied successfully"
    }
    content.sound = .default

    let request = UNNotificationRequest(
      identifier: UUID().uuidString,
      content: content,
      trigger: nil
    )
    UNUserNotificationCenter.current().add(request)
  }

}
