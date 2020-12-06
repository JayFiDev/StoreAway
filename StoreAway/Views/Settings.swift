//
//  Settings.swift
//  StoreAway
//
//  Created by JayFi on 14.11.20.
//

import SwiftUI

struct SettingsView: View {
  

  @EnvironmentObject var userData: DataObject
  let filehandler = FileHandler()
  let input = InputHandler()
  
  
  var body: some View {
    
    TabView {
      
      SettingsGeneralView()
      .tabItem {
              Image(systemName: "gear").imageScale(.large)
              Text("General")
      }
      
      SettingsMappingView()
      .tabItem {
              Image(systemName: "tray.2").imageScale(.large)
              Text("Mappings")
      }
      
      SettingsWatchedFolderView()
      .tabItem {
              Image(systemName: "folder").imageScale(.large)
              Text("Watched Folders")
      }
    
    }.frame(minWidth: 400)
    
  }
  
}

struct Settings_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView().environmentObject(DataObject())
  }
}
