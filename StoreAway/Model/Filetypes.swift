//
//  Filetypes.swift
//  StoreAway
//
//  Created by Jürgen Fink on 13.12.20.
//

import Foundation
import UniformTypeIdentifiers

struct DefinedTypes: Encodable, Decodable, Hashable {

  // Common file types (most used at top)
  static var documents = Type(type: .pdf, displayString: "Documents", longDescription: "pdf, doc, docx, xls, xlsx, ...", symbol: "doc.fill")
  static var image = Type(type: .image, displayString: "Images", longDescription: "jpeg, png, bmp, heic, ...", symbol: "photo")
  static var video = Type(type: .movie, displayString: "Videos", longDescription: "mov, mp4, avi, ...", symbol: "video.fill")
  static var audio = Type(type: .audio, displayString: "Music", longDescription: "mp3, wav, aac, ...", symbol: "music.note")
  static var archives = Type(type: .archive, displayString: "Archives", longDescription: "zip, rar, 7z, tar, gz, ...", symbol: "archivebox.fill")

  // Additional file types
  static var ebooks = Type(type: .epub, displayString: "E-Books", longDescription: "epub, mobi, azw, ...", symbol: "book.fill")
  static var fonts = Type(type: .font, displayString: "Fonts", longDescription: "ttf, otf, woff, ...", symbol: "textformat")
  static var presentations = Type(type: .presentation, displayString: "Presentations", longDescription: "ppt, pptx, key, ...", symbol: "play.rectangle.fill")
  static var spreadsheets = Type(type: .spreadsheet, displayString: "Spreadsheets", longDescription: "xls, xlsx, csv, ...", symbol: "tablecells.fill")
  static var sourcecode = Type(type: .sourceCode, displayString: "Source Code", longDescription: "swift, c, cpp, py, js, ...", symbol: "chevron.left.slash.chevron.right")
  static var text = Type(type: .text, displayString: "Text", longDescription: "txt, rtf, ...", symbol: "doc.richtext")
  static var database = Type(type: .database, displayString: "Databases", longDescription: "sql, sqlite, db, ...", symbol: "cylinder.fill")

  static let types: [Type] = [
    documents, image, video, audio, archives,
    ebooks, fonts, presentations, spreadsheets,
    sourcecode, text, database
  ]

}

struct Type: Encodable, Decodable, Hashable {
  let type: UTType
  let displayString: String
  let longDescription: String
  let symbol: String
}
