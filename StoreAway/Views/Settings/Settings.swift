//
//  Settings.swift
//  StoreAway
//
//  Created by JayFi on 14.11.20.
//

import SwiftUI

struct SettingsView: View {

  @EnvironmentObject var userData: DataHandler

  var body: some View {
    SettingsGeneralView()
      .frame(minWidth: 400)
  }

}

struct Settings_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView().environmentObject(DataHandler())
  }
}
