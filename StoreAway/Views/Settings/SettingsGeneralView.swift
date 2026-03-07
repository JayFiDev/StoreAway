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
    Form {
      Section("File Operations") {
        Toggle("Copy instead of move", isOn: $userData.options.copyObjects)
        Toggle("Ask for every file", isOn: $userData.options.askEveryFile)
        Toggle("Keep folder structure", isOn: $userData.options.keepFolderStructure)
      }

      Section("Automation") {
        Toggle(isOn: $userData.options.autoOrganize) {
          VStack(alignment: .leading, spacing: 2) {
            Text("Auto-organize watched folders")
            Text("Automatically move files when new items appear in watched folders.")
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }
      }

      Section("System") {
        Toggle(isOn: $userData.options.launchAtLogin) {
          VStack(alignment: .leading, spacing: 2) {
            Text("Launch at Login")
            Text("Start StoreAway automatically when you log in.")
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }

        Toggle(isOn: $userData.options.showDockIcon) {
          VStack(alignment: .leading, spacing: 2) {
            Text("Show Dock icon")
            Text("Show StoreAway in the Dock and App Switcher. Requires restart.")
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }
      }
    }
    .formStyle(.grouped)
    .frame(width: 420)
  }
}

struct SettingsGeneralView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsGeneralView().environmentObject(DataHandler())
  }
}
