//
//  Filetypes.swift
//  StoreAway
//
//  Created by Jürgen Fink on 13.12.20.
//

import Foundation
import UniformTypeIdentifiers

struct  DefinedTypes: Encodable, Decodable, Hashable {

  static var image = Type(type: .image, displayString: "Image", longDescription: "jpeg, png, bmp, ...", symbol: "camera")
  static var video = Type(type: .movie, displayString: "Video", longDescription: "avi, mpeg, mov, ...", symbol: "video")
  static var audio = Type(type: .audio, displayString: "Audio", longDescription: "mp3, wav ...", symbol: "music.note")
  static var sourcecode = Type(type: .sourceCode, displayString: "Code", longDescription: "c, cpp, swift, ...", symbol: "chevron.left.slash.chevron.right")
  static var text = Type(type: .text, displayString: "Text", longDescription: "txt, rtf, ...", symbol: "doc.richtext")

  static let types: [Type] = [image, video, audio, sourcecode, text]

}

struct Type: Encodable, Decodable, Hashable {
  let type: UTType
  let displayString: String
  let longDescription: String
  let symbol: String
}
