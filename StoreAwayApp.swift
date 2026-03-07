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

    Settings {
      SettingsView()
        .environmentObject(userData)
    }
  }
}
