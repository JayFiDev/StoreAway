//
//  DetailStatisticView.swift
//  StoreAway
//
//  Created by Jürgen Fink on 24.11.20.
//

import SwiftUI

struct DetailStatisticView: View {

  let statistic: Stats

  var body: some View {
      HStack {

        ZStack {
          Circle().foregroundColor(.accentColor)
          if statistic.isCustom {
            Text(statistic.fileExtensions!.joined(separator: ", ")).multilineTextAlignment(.center)
          } else {

            VStack {
              Image(systemName: statistic.fileType!.symbol).font(Font.system(.title2))
              Text(statistic.fileType!.displayString).multilineTextAlignment(.center)
            }

          }

        }.frame(width: 60, height: 60, alignment: .center)

        Text("\(statistic.numberOfFiles) Files").font(.title3)
          .padding(.leading)

        Spacer()
        Text("\(statistic.sizeString)").font(.title3)
          .padding(.trailing)

      }.frame(width: 250, height: 65)
    }
}

struct DetailStatisticView_Previews: PreviewProvider {
    static var previews: some View {
      DetailStatisticView(statistic: Stats(fileExtensions: ["stl", "gcode", "obj"], isCustom: true, numberOfFiles: 11, size: 22, sizeString: "22kb"))
      DetailStatisticView(statistic: Stats(fileType: DefinedTypes.image, isCustom: false, numberOfFiles: 11, size: 22, sizeString: "22kb"))
    }
}
