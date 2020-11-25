//
//  SettingsGeneralView.swift
//  StoreAway
//
//  Created by Jürgen Fink on 23.11.20.
//

import SwiftUI

struct SettingsGeneralView: View {
  
  @EnvironmentObject var userData: UserData
  
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
      
    }
    .frame(width: 400)
    .padding([.top, .leading, .bottom])
    
  }
}

struct SettingsGeneralView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsGeneralView().environmentObject(UserData())
  }
}
