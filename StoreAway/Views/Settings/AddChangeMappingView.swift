//
//  ChangeMappingView.swift
//  StoreAway
//
//  Created by Jürgen Fink on 10.12.20.
//

import SwiftUI

struct AddChangeMappingView: View {

  @EnvironmentObject var data: DataHandler
  @Environment(\.presentationMode) var mode

  @State var pathDisplay: String = ""
  @State var path: URL
  @State var filetype: String = ""
  @State var isCustom: Bool = false
  @State var typeChoice: Int = 0

  let input = InputHandler()
  let types: [Type] = DefinedTypes.types

  var mapping: Mapping
  var addNew: Bool = false

  init(mapping: Mapping, addNew: Bool) {

    self.mapping = mapping
    self._path = State(wrappedValue: mapping.path)
    self.addNew = addNew

    if !addNew {
      self._pathDisplay = State(wrappedValue: mapping.path.path)
    } else {
      self.pathDisplay = ""
    }

    if !addNew {
      if mapping.isCustom {
        self._filetype = State(wrappedValue: mapping.fileExtensions!.joined(separator: ", "))
        self._isCustom = State(wrappedValue: mapping.isCustom)
        print("isCustom")

      } else {

        if let type = mapping.fileType {
          if let index = types.firstIndex(of: type) {
            _typeChoice = State(initialValue: index)
          }
        }

      }
    } else {
      _typeChoice = State(initialValue: 0)

    }

  }

  var body: some View {

    VStack(alignment: .leading) {

      Group {
        Label(
          title: {
            Text(isCustom ? "Extension" : "Filetype")
          },
          icon: { Image(systemName: "doc.text.magnifyingglass") }
        )

        HStack {
          if !isCustom {
            Picker("", selection: $typeChoice) {
              ForEach(0 ..< types.count) { index in
                Text(self.types[index].displayString)
                  .tag(index)
              }
            }
            .padding(.leading, -7.0)
            .disabled(isCustom)
          } else {
            TextField("Filetype(s) [seperate by ,]", text: $filetype)
              .frame(height: 20, alignment: .leading)
          }
          Toggle("custom", isOn: $isCustom)
        }
      }

      Divider().padding(.vertical, 2.0)

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

      }

      Divider().padding(.vertical, 2.0)

      HStack {
        Button(action: {

          createOrUpdateMapping()

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
          data.removeMapping(id: mapping.id)
          self.mode.wrappedValue.dismiss()

        }, label: {
          Text("Delete").foregroundColor(.red)
        }).disabled(addNew)
      }

    }.padding(.all).frame(width: 320, height: 350, alignment: .topLeading)

  }

  fileprivate func createOrUpdateMapping() {
    let temp = filetype.replacingOccurrences(of: " ", with: "")
    let filetypes: [String] = temp.components(separatedBy: ",")

    if !addNew {

      if isCustom {
        data.updateMapping(id: mapping.id, replaceWith: Mapping(id: mapping.id, path: path, fileExtensions: filetypes))
      } else {
        data.updateMapping(id: mapping.id, replaceWith: Mapping(id: mapping.id, path: path, fileType: types[typeChoice]))
      }

    } else {
      if isCustom {
        data.addMapping(path: path, fileExtensions: filetypes)
      } else {
        data.addMapping(path: path, fileType: types[typeChoice])
      }
    }
  }

}

struct AddChangeMappingView_Previews: PreviewProvider {
  static var previews: some View {
    AddChangeMappingView(mapping: Mapping(path: URL(fileURLWithPath: "/this/is/a/test"),
                                          fileExtensions: ["String"]), addNew: false).environmentObject(DataHandler())
  }
}
