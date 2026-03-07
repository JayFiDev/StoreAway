//
//  AppDelegate.swift
//  StoreAway
//

import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {

  var statusItem: NSStatusItem?
  var dataHandler: DataHandler?

  private var lastRunMenuItem: NSMenuItem?
  private var storeNowMenuItem: NSMenuItem?

  func applicationDidFinishLaunching(_ notification: Notification) {
    setupStatusItem()
    NotificationHandler.requestAuthorization()

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleDidRun(_:)),
      name: .storeAwayDidRun,
      object: nil
    )
  }

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }

  // Called from StoreAwayApp once DataHandler is ready
  func setup(dataHandler: DataHandler) {
    self.dataHandler = dataHandler
    updateStoreNowState()

    if dataHandler.options.showDockIcon {
      NSApp.setActivationPolicy(.regular)
    } else {
      NSApp.setActivationPolicy(.accessory)
    }
  }

  // MARK: - Status Item

  private func setupStatusItem() {
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    if let button = statusItem?.button {
      button.image = NSImage(systemSymbolName: "archivebox.fill", accessibilityDescription: "StoreAway")
      button.image?.isTemplate = true
    }

    let menu = NSMenu()

    let storeItem = NSMenuItem(
      title: "Store Away Now",
      action: #selector(storeAwayNow),
      keyEquivalent: ""
    )
    storeItem.target = self
    menu.addItem(storeItem)
    storeNowMenuItem = storeItem

    let previewItem = NSMenuItem(
      title: "Preview...",
      action: #selector(showPreview),
      keyEquivalent: ""
    )
    previewItem.target = self
    menu.addItem(previewItem)

    menu.addItem(.separator())

    let lastRun = NSMenuItem(title: "Last run: Never", action: nil, keyEquivalent: "")
    lastRun.isEnabled = false
    menu.addItem(lastRun)
    lastRunMenuItem = lastRun

    menu.addItem(.separator())

    let showWindowItem = NSMenuItem(
      title: "Show Window",
      action: #selector(showMainWindow),
      keyEquivalent: ""
    )
    showWindowItem.target = self
    menu.addItem(showWindowItem)

    let prefsItem = NSMenuItem(
      title: "Preferences...",
      action: #selector(openPreferences),
      keyEquivalent: ","
    )
    prefsItem.target = self
    menu.addItem(prefsItem)

    menu.addItem(.separator())

    let quitItem = NSMenuItem(
      title: "Quit StoreAway",
      action: #selector(NSApplication.terminate(_:)),
      keyEquivalent: "q"
    )
    menu.addItem(quitItem)

    statusItem?.menu = menu
  }

  // MARK: - Menu Actions

  @objc func storeAwayNow() {
    dataHandler?.runAction(triggerSource: .menuBar)
  }

  @objc func showPreview() {
    showMainWindow()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
      NotificationCenter.default.post(name: .showPreviewNotification, object: nil)
    }
  }

  @objc func showMainWindow() {
    NSApp.activate(ignoringOtherApps: true)
    // Try to find and show the main content window (not preferences)
    let window = NSApp.windows.first { win in
      win.isKind(of: NSWindow.self) && !(win.title.lowercased().contains("preferences") || win.title.lowercased().contains("settings"))
    }
    window?.makeKeyAndOrderFront(nil)

    // If no window found, activate anyway so SwiftUI WindowGroup opens one
    if window == nil {
      for window in NSApp.windows {
        window.makeKeyAndOrderFront(nil)
        break
      }
    }
  }

  @objc func openPreferences() {
    NSApp.activate(ignoringOtherApps: true)
    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
  }

  // MARK: - Update menu state

  @objc func handleDidRun(_ notification: Notification) {
    guard let total = notification.userInfo?["total"] as? Int,
          let date = notification.userInfo?["date"] as? Date else { return }

    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .abbreviated
    let relativeDate = formatter.localizedString(for: date, relativeTo: Date())
    lastRunMenuItem?.title = "Last run: \(relativeDate) – \(total) file(s)"
  }

  private func updateStoreNowState() {
    guard let handler = dataHandler else { return }
    let canRun = !handler.watchedFolders.isEmpty && !handler.mappingData.isEmpty
    storeNowMenuItem?.isEnabled = canRun
  }

}
