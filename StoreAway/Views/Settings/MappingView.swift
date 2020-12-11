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
        Text(mapping.filetypes.joined(separator: ", ")).multilineTextAlignment(.center)

      }.frame(width: 60, height: 60, alignment: .center)

      Text(mapping.path.path)
        .padding(.leading)

    }.frame(width: 380, height: 65, alignment: .leading)
  }
}

struct MappingView_Previews: PreviewProvider {
  static var previews: some View {
    MappingView(mapping: Mapping(id: UUID(), filetypes: ["gcode", "svg"],
                                path: URL(fileURLWithPath: "/Users/juergen/Nextcloud/Making/3D Druck/3D Bibliothek/")))
  }
}
