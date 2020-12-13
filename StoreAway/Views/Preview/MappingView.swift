//
//  MappingData.swift
//  StoreAway
//
//  Created by JayFi on 14.11.20.
//

import SwiftUI

struct MappingView: View {

  var mapping: Mapping

  var body: some View {

    HStack {

      ZStack {
        Circle().foregroundColor(.accentColor)
        if mapping.isCustom {
          Text(mapping.fileExtensions!.joined(separator: ", ")).multilineTextAlignment(.center)
        } else {
          VStack {
            Image(systemName: mapping.fileType!.symbol).font(Font.system(.title2))
            Text(mapping.fileType!.displayString).multilineTextAlignment(.center)
          }
        }

      }.frame(width: 60, height: 60, alignment: .center)

      Text(mapping.path.path)
        .padding(.leading)

    }.frame(width: 380, height: 65, alignment: .leading)
  }
}

struct MappingView_Previews: PreviewProvider {
  static var previews: some View {
    MappingView(mapping: Mapping(path: URL(fileURLWithPath: "/Users/juergen/Nextcloud/Making/3D Druck/3D Bibliothek/"), fileExtensions: ["gcode", "svg"]))
  }
}
