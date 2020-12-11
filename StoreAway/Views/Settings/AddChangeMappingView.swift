//
//  ChangeMappingView.swift
//  StoreAway
//
//  Created by Jürgen Fink on 10.12.20.
//

import SwiftUI

struct AddChangeMappingView: View {

  let input = InputHandler()

  @EnvironmentObject var userData: DataHandler
  @Environment(\.presentationMode) var mode
  var mapping: Mapping
  var addNew: Bool = false

  @State var pathDisplay: String = ""
  @State var path: URL
  @State var filetype: String = "type1, type2"

  init(mapping: Mapping, addNew: Bool) {
    self.mapping = mapping
    self._filetype = State(wrappedValue: mapping.filetypes.joined(separator: ", "))
    self._path = State(wrappedValue: mapping.path) // _editedValue is State<String>

    if !addNew {
      self._pathDisplay = State(wrappedValue: mapping.path.path)
    } else {
      self.pathDisplay = ""
    }

    self.addNew = addNew
  }

  var body: some View {

    VStack(alignment: .leading) {

      Group {
        Label(
          title: { Text("Filetype(s) [seperate by ,]") },
          icon: { Image(systemName: "doc.text.magnifyingglass") }
        )

        TextField("Filetype", text: $filetype).frame(width: 250, height: 20, alignment: .leading)
        Divider().padding(.vertical, 2.0)
      }

      Group {
        Label(
          title: { Text("Destinationn") },
          icon: { Image(systemName: "tray") }
        )

        Text(pathDisplay)
          .multilineTextAlignment(.leading)
          .padding(.top, 0.5)
          .frame(width: 250, height: 40, alignment: .topLeading)

        Button(action: {
          let selectedFolder = input.showInputSelectDialog()
          if selectedFolder != nil {
            path = selectedFolder!
            pathDisplay = selectedFolder!.path
          }

        }, label: {
          Text("Select destination")
        })

        Divider().padding(.vertical, 2.0)
      }

      HStack {
        Button(action: {

          let temp = filetype.replacingOccurrences(of: " ", with: "")
          let filetypes: [String] = temp.components(separatedBy: ",")

          if !addNew {
            userData.updateMapping(id: mapping.id, replaceWith: Mapping(id: mapping.id, filetypes: filetypes, path: path, isCustom: false))
          } else {
            userData.addMapping(name: filetypes, path: path)
          }

          self.mode.wrappedValue.dismiss()

        }, label: {
          Text("Save")
        })

        Button(action: {
          self.mode.wrappedValue.dismiss()
        }, label: {
          Text("Cancel")
        })
        Spacer()
        Button(action: {
          userData.removeMapping(id: mapping.id)
          self.mode.wrappedValue.dismiss()
        }, label: {
          Text("Delete").foregroundColor(.red)
        }).disabled(addNew)
      }

    }.padding(.all).frame(width: 300, height: 230, alignment: .topLeading)

  }
}

struct AddChangeMappingView_Previews: PreviewProvider {
  static var previews: some View {
    AddChangeMappingView(mapping: Mapping(id: UUID(), filetypes: ["String"],
                                          path: URL(fileURLWithPath: "/this/is/a/test")), addNew: false).environmentObject(DataHandler())
  }
}
