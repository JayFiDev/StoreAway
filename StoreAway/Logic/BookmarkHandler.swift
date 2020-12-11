//
//  BookmarkHandler.swift
//  StoreAway
//
//  Created by Jürgen Fink on 06.12.20.
//

import Foundation

class BookmarkHandler {

  var bookmarks: [URL: Data] = [:]

  init() {
    bookmarks = getBookmarksFromUserData()

    for url in bookmarks.keys {
      restoreFileAccess(with: bookmarks[url]!)
    }
  }

  private func saveBookmarksToUserData() {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(bookmarks) {
      let defaults = UserDefaults.standard
      defaults.set(encoded, forKey: "Bookmarks")
    }
  }

  private func getBookmarksFromUserData() -> [URL: Data] {
    if let data = UserDefaults.standard.object(forKey: "Bookmarks") as? Data {
      let decoder = JSONDecoder()
      if let temp = try? decoder.decode([URL: Data].self, from: data) {
        return temp
      }
    }
    return [:]
  }

  public func saveBookmarkData(for path: URL) {
      do {
        let bookmarkData = try path.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
        bookmarks[path] = bookmarkData
        saveBookmarksToUserData()

      } catch {
          print("Failed to save bookmark data for \(path)", error)
      }
  }

  public func removeBookmarkData(for path: URL) {
        bookmarks[path] = nil
        saveBookmarksToUserData()
  }

  private func restoreFileAccess(with bookmarkData: Data) {
        do {
              var isStale = false
              let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
              if isStale {
                  // bookmarks could become stale as the OS changes
                  print("Bookmark is stale, need to save a new one... ")
                  saveBookmarkData(for: url)
              }
          } catch {
              print("Error resolving bookmark:", error)
          }
      }

  public func enableFileAccess() {
    for url in bookmarks.keys {
      if !url.startAccessingSecurityScopedResource() {
        print("startAccessingSecurityScopedResource returned false")
      }
    }
  }

  public func disableFileAccess() {
    for url in bookmarks.keys {
      url.stopAccessingSecurityScopedResource()
    }
  }

}
