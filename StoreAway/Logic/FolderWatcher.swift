//
//  FolderWatcher.swift
//  StoreAway
//

import Foundation
import CoreServices

class FolderWatcher {

  var onChange: (() -> Void)?
  private var streamRef: FSEventStreamRef?
  private var isActive = false

  func start(watching urls: [URL]) {
    stop()
    guard !urls.isEmpty else { return }

    let paths = urls.map { $0.path } as CFArray
    var context = FSEventStreamContext(
      version: 0,
      info: Unmanaged.passUnretained(self).toOpaque(),
      retain: nil,
      release: nil,
      copyDescription: nil
    )

    let callback: FSEventStreamCallback = { _, info, _, _, _, _ in
      guard let info = info else { return }
      let watcher = Unmanaged<FolderWatcher>.fromOpaque(info).takeUnretainedValue()
      watcher.onChange?()
    }

    let flags = UInt32(kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagNoDefer)
    streamRef = FSEventStreamCreate(
      kCFAllocatorDefault,
      callback,
      &context,
      paths,
      FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
      1.5,
      flags
    )

    if let stream = streamRef {
      FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
      FSEventStreamStart(stream)
      isActive = true
    }
  }

  func stop() {
    guard let stream = streamRef else { return }
    FSEventStreamStop(stream)
    FSEventStreamInvalidate(stream)
    FSEventStreamRelease(stream)
    streamRef = nil
    isActive = false
  }

  deinit {
    stop()
  }

}
