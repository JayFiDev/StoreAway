//
//  StoreAwayApp.swift
//  StoreAway
//
//  Created by JayFi on 14.11.20.
//

import SwiftUI

@main
struct StoreAwayApp: App {
  
    var userData = DataObject()
    
    
    var body: some Scene {
        WindowGroup {
          MainView()
            .environmentObject(userData)
        }
      
        Settings {
          SettingsView()
            .environmentObject(userData)
        }
      
        
    }
}
