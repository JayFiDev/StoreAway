//
//  StoreAwayApp.swift
//  StoreAway
//
//  Created by JayFi on 14.11.20.
//

import SwiftUI

@main
struct StoreAwayApp: App {

  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @StateObject var userData = DataHandler()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(userData)
        .onAppear {
          appDelegate.setup(dataHandler: userData)
        }
    }
    .commands {
      CommandGroup(replacing: .appSettings) {
        if #available(macOS 14.0, *) {
          SettingsLink {
            Text("Settings...")
          }
          .keyboardShortcut(",", modifiers: .command)
        } else {
          Button("Settings...") {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
          }
          .keyboardShortcut(",", modifiers: .command)
        }
      }
    }

    Settings {
      SettingsView()
        .environmentObject(userData)
    }
  }
}
