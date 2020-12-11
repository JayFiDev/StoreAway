//
//  PreviewView.swift
//  StoreAway
//
//  Created by Jürgen Fink on 25.11.20.
//

import SwiftUI

struct PreviewView: View {

  @EnvironmentObject var userData: DataHandler
  @Environment(\.presentationMode) var presentationMode
  @State private var selectedPreview: Previews?

  var body: some View {

    VStack {
      NavigationView {
        SidebarView(preview: $selectedPreview)
        DetailView(preview: $selectedPreview)

      }

      Button(action: {

        self.presentationMode.wrappedValue.dismiss()

      }, label: {
        Text("Close")
      })

    }.padding(.all)
    .frame(width: 900, height: 500, alignment: .center/*@END_MENU_TOKEN@*/)
    .onAppear(perform: {
      userData.update()
      if userData.previews.count > 0 {
        selectedPreview = userData.previews.first
      }

    })

  }
}

struct SidebarView: View {

  @EnvironmentObject var userData: DataHandler
  let filehandler = FileHandler()
  @Binding var preview: Previews?

  var body: some View {
    List(userData.previews, id: \.self, selection: $preview) { preview in
      Text("\(preview.map.filetypes.joined(separator: ", "))")
    }
    .listStyle(SidebarListStyle())
    .frame(width: 200)
  }
}

struct DetailView: View {
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

struct PreviewView_Previews: PreviewProvider {
  static var previews: some View {
    PreviewView().environmentObject(DataHandler())
  }
}
