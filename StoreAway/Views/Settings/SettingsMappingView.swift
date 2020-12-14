//
//  SettingMappingView.swift
//  StoreAway
//
//  Created by JayFi on 19.11.20.
//

import SwiftUI

struct SettingsMappingView: View {

  @EnvironmentObject var data: DataHandler
  @ObservedObject var select = SelectionHandler()
  @State var showAddSheet = false

  var body: some View {
    VStack {
      //, selection: $selection
      List(data.mappingData, id: \.self) { mapping in
        MappingView(mapping: mapping)
          .contentShape(Rectangle())
          .onTapGesture {
            select.selectedMapping = mapping
          }
      }
      .frame(width: 400,
             height: self.data.mappingData.count > 3 ? 320 : 15 + self.data.mappingData.reduce(0) { index, _ in index + 80 }, alignment: .center)
      .sheet(isPresented: $select.selectionChanged) {
        if select.selectedMapping != nil {
          AddChangeMappingView(mapping: select.selectedMapping!, addNew: false )

        }
      }

      HStack {

        Button(action: {
          showAddSheet = true
        }, label: {
          Text("+")
        })

       Spacer()

      }.padding([.leading, .bottom])

      .sheet(isPresented: $showAddSheet) {
          AddChangeMappingView(mapping: Mapping(path: URL(fileURLWithPath: ""), fileExtensions: ["type"]), addNew: true )
      }

    }.frame(width: 400)
  }
}

struct SettingMappingView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsMappingView().environmentObject(DataHandler())
  }
}
