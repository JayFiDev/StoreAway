//
//  SettingsGeneralView.swift
//  StoreAway
//
//  Created by Jürgen Fink on 23.11.20.
//

import SwiftUI

struct SettingsGeneralView: View {

  @EnvironmentObject var userData: DataHandler

  var body: some View {
    VStack(alignment: .leading) {

      HStack {
        Toggle(isOn: $userData.options.detailViewEnabled) {
          Text("Show details")
        }
        Spacer()
      }

      Divider().frame(width: 380, height: 2, alignment: .center)

      HStack {
        Toggle(isOn: $userData.options.keepFolderStructure) {
          Text("Keep folder structure")
        }
        Spacer()
      }

      Divider().frame(width: 380, height: 2, alignment: .center)

      HStack {
        Toggle(isOn: $userData.options.copyObjects) {
          Text("Copy instead of move")
        }
        Spacer()
      }

      HStack {
        Toggle(isOn: $userData.options.askEveryFile) {
          Text("Ask for every file")
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
    SettingsGeneralView().environmentObject(DataHandler())
  }
}
