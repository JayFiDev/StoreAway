//
//  PreviewSidebarView.swift
//  StoreAway
//
//  Created by Jürgen Fink on 14.12.20.
//

import SwiftUI

struct PreviewSidebarView: View {
  @EnvironmentObject var userData: DataHandler
  let filehandler = FileHandler()
  @Binding var preview: Previews?

  var body: some View {
    List(userData.previews, id: \.self, selection: $preview) { preview in

      if preview.map.isCustom {
        Text(preview.map.fileExtensions!.joined(separator: ", ")).multilineTextAlignment(.center)
      } else {
        HStack {
          Image(systemName: preview.map.fileType!.symbol)
            .font(Font.system(.title3))
            .frame(width: 30)

          Text(preview.map.fileType!.displayString).multilineTextAlignment(.center)
        }
      }

    }
    .listStyle(SidebarListStyle())
    .frame(width: 200)
  }
}
