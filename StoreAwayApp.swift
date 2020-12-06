//
//  StoreAwayApp.swift
//  StoreAway
//
//  Created by JayFi on 14.11.20.
//

import SwiftUI

@main
struct StoreAwayApp: App {
  
    //@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var userData = DataHandler()
    
    
    var body: some Scene {
        WindowGroup {
          MainView()
            .environmentObject(userData)
        }
        .commands {
          CommandGroup(replacing: .help){
            Button("Help") {
              if let url = URL(string: "https://github.com/JayFiDev/StoreAway") {
                      NSWorkspace.shared.open(url)
                  }
            }
          }
          //removing of not needed items in menubar
          CommandGroup(replacing: .windowArrangement){ }
          CommandGroup(replacing: .windowList){ }
          CommandGroup(replacing: .windowSize){ }
          CommandGroup(replacing: .toolbar){ }
          CommandGroup(replacing: .systemServices){ }
          CommandGroup(replacing: .sidebar){ }
          CommandGroup(replacing: .saveItem){ }
          
        }
      
        Settings {
          SettingsView()
            .environmentObject(userData)
        }
        
      //shared.open(URL(string: "https://github.com/JayFiDev/StoreAway")!)
      
        
    }
}

//class AppDelegate: NSObject, NSApplicationDelegate {
//    @IBOutlet var window: NSWindow!
//    func applicationDidFinishLaunching(_ aNotification: Notification) {
//
//    }
//    func applicationWillTerminate(_ aNotification: Notification) {
//    }
//
//
//}
