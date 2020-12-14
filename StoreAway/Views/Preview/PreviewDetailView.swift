//
//  PreviewDetailView.swift
//  StoreAway
//
//  Created by Jürgen Fink on 14.12.20.
//

import SwiftUI

struct PreviewDetailView: View {
  @EnvironmentObject var userData: DataHandler
  let filehandler = FileHandler()

  @Binding var preview: Previews?

  var body: some View {

    VStack {
      if preview != nil {

        List {
          //every folder that is watched
          ForEach(preview?.folder ?? [], id: \.self) { folder in

            //only display section if file are found
            if folder.files.count > 0 {
              Section(header: Text("Folder: \(folder.path.path)")) {
                ForEach(folder.files, id: \.self) { file in
                  VStack {
                    //Text("Current: ~/\(file.relativePath) \tNew:\(preview!.map.path.path)/\(file.relativePath)")
                    Text("~/\(file.relativePath)")
                  }.frame(width: 500, height: 20, alignment: .leading)
                }
              }
            }
          }
        }

      } else {
        Text("No mapping selected")
      }

    }

  }
}
