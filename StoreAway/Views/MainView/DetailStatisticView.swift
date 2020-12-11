//
//  DetailStatisticView.swift
//  StoreAway
//
//  Created by Jürgen Fink on 24.11.20.
//

import SwiftUI

struct DetailStatisticView: View {
    
  let stats : Stats
  
  var body: some View {
      HStack{
        
        ZStack{
          Circle().foregroundColor(.accentColor)
          Text(stats.filetypes.joined(separator: ", ")).multilineTextAlignment(.center)
          
        }.frame(width: 60, height: 60, alignment: .center)
        
        Text("\(stats.numberOfFiles) Files").font(.title3)
          .padding(.leading)
        
        Spacer()
        Text("\(stats.sizeString)").font(.title3)
          .padding(.trailing)
        
      }.frame(width: 250, height: 65)
    }
}

struct DetailStatisticView_Previews: PreviewProvider {
    static var previews: some View {
      DetailStatisticView(stats: Stats(filetypes: ["stl", "gcode", "obj"], numberOfFiles: 11, size: 22, sizeString: "22kb"))
    }
}
