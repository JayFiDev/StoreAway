//
//  InputView.swift
//  StoreAway
//
//  Created by JayFi on 15.11.20.
//

import SwiftUI

struct SettingsWatchedFolderView: View {

  let filehandler = FileHandler()
  let input = InputHandler()
  @EnvironmentObject var userData: DataHandler
  @State var selection = Set<URL>()

  var body: some View {
    VStack {

      List(userData.watchedFolders, id: \.self, selection: $selection) { name in
        Text(name.path)
      }.frame(width: 400,
              height: self.userData.watchedFolders.count > 5 ? 150 : 10 + self.userData.watchedFolders.reduce(0) { index, _ in index + 30 },
              alignment: .center)

      HStack {
        Button(action: {
          let selectedFolder = input.showInputSelectDialog()
          if selectedFolder != nil {

            if !userData.watchedFolders.contains(selectedFolder!) {
              userData.addFolderWatch(path: selectedFolder!)
            }
          }

        }, label: {
          Text("+")
        })

        Button(action: {

          if selection.count == 0 { return }
          if let index = self.userData.watchedFolders.firstIndex(of: selection.first!) {
            userData.removeFolderWatch(index: index)
            selection = Set<URL>()
          }
        }, label: {
          Text("-")
        })
        Spacer()
      }
      .padding([.leading, .bottom])

    }.frame(width: 400)
  }
}

struct InputView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsWatchedFolderView().environmentObject(DataHandler())
  }
}
