//
//  SettingMappingView.swift
//  StoreAway
//
//  Created by JayFi on 19.11.20.
//

import SwiftUI

struct SettingsMappingView: View {
  
  @EnvironmentObject var userData: UserData
  @State var selection = Set<Mapping>()
  @State var addMapping = false

  
    var body: some View {
      VStack {
//        HStack {
//          //Text("Mappings").font(.title)
//          Label(
//            title: { Text("Mapping") },
//            icon: { Image(systemName: "doc.text.magnifyingglass") }
//          ).font(.title3)
//          Spacer()
//        }.padding([.top, .leading])
//        

        List(userData.mappingData, id: \.self, selection: $selection) { mapping in
          MappingView(mapping: mapping)
        }
        .frame(width: 400,
                height: self.userData.mappingData.count > 3 ? 320 : 15 + self.userData.mappingData.reduce(0) { i, _ in i + 80 },
                alignment: .center)
        .animation(.default)
        
        HStack {
          
          Button(action: {
            addMapping = true
          }, label: {
            Text("+")
          })

          Button(action: {
            if selection.count == 0 { return }
            if let index = self.userData.mappingData.firstIndex(of: selection.first!) //todo do for every selected item
            {
              userData.removeMapping(index: index)
              selection = Set<Mapping>()
            }
            
          }, label: {
            Text("-")
          })
          Spacer()
          
        }.padding([.leading, .bottom])
        .sheet(isPresented: $addMapping) {
            AddMappingView()
            .onAppear(perform: {print("Appear sheet")})
            .onDisappear(perform: {print("Disappear sheet")})
        }
        
      }.frame(width: 400)
    }
}

struct SettingMappingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMappingView().environmentObject(UserData())
    }
}
