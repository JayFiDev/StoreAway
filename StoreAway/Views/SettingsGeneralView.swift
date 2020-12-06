//
//  SettingsGeneralView.swift
//  StoreAway
//
//  Created by Jürgen Fink on 23.11.20.
//

import SwiftUI

struct SettingsGeneralView: View {
  
  @EnvironmentObject var userData: DataObject
  
  var body: some View {
    VStack(alignment: .leading) {
      
      HStack {
        Toggle(isOn: $userData.copyObjects) {
          Text("Copy instead of move")
        }
        Spacer()
      }
      
      HStack {
        Toggle(isOn: $userData.askEveryFile) {
          Text("Ask for every file")
        }
        Spacer()
      }
      
      HStack {
        Toggle(isOn: $userData.detailViewEnabled) {
          Text("Show details")
        }
        Spacer()
      }
      
      HStack {
        Toggle(isOn: $userData.keepFolderStructure) {
          Text("Keep folder structure")
        }
        Spacer()
      }
      
    }
    .frame(width: 400)
    .padding([.top, .leading, .bottom])
    
  }
}

struct SettingsGeneralView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsGeneralView().environmentObject(DataObject())
  }
}
