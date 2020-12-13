//
//  SettingMappingView.swift
//  StoreAway
//
//  Created by JayFi on 19.11.20.
//

import SwiftUI

struct SettingsMappingView: View {

  @EnvironmentObject var userData: DataHandler
  @State var selection: Mapping?

  @State var showAddSheet = false
  @State var showChangeSheet = false

  var body: some View {
    VStack {

      List(userData.mappingData, id: \.self, selection: $selection) { mapping in
          MappingView(mapping: mapping)

      }
      .frame(width: 400,
             height: self.userData.mappingData.count > 3 ? 320 : 15 + self.userData.mappingData.reduce(0) { index, _ in index + 80 }, alignment: .center)
      .onChange(of: selection) { _ in
          showChangeSheet = true

      }.sheet(isPresented: $showChangeSheet) {
          AddChangeMappingView(mapping: selection!, addNew: false )
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
