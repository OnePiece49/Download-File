//
//  Swifme.swift
//  Las_File_Offline_001
//
//  Created by Tiến Việt Trịnh on 29/07/2023.
//

import Foundation


public struct Swime {
  /// File data
  let data: Data

  ///  A static method to get the `MimeType` that matches the given file data
  ///
  ///  - returns: Optional<MimeType>
  static public func mimeType(data: Data) -> MimeType? {
    return mimeType(swime: Swime(data: data))
  }

  ///  A static method to get the `MimeType` that matches the given bytes
  ///
  ///  - returns: Optional<MimeType>
  static public func mimeType(bytes: [UInt8]) -> MimeType? {
    return mimeType(swime: Swime(bytes: bytes))
  }

  ///  Get the `MimeType` that matches the given `Swime` instance
  ///
  ///  - returns: Optional<MimeType>
  static public func mimeType(swime: Swime) -> MimeType? {
    let bytes = swime.readBytes(count: min(swime.data.count, 262))

    for mime in MimeType.all {
      if mime.matches(bytes: bytes, swime: swime) {
        return mime
      }
    }

	  return 	MimeType(
		mime: "application/txt",
		ext: "txt",
		type: .txt,
		bytesCount: 0,
		matches: { bytes, _ in
			return bytes[0...1] == [0xFF, 0xF1]
		}
	  )
  }

  public init(data: Data) {
    self.data = data
  }

  public init(bytes: [UInt8]) {
    self.init(data: Data(bytes))
  }

  ///  Read bytes from file data
  ///
  ///  - parameter count: Number of bytes to be read
  ///
  ///  - returns: Bytes represented with `[UInt8]`
  internal func readBytes(count: Int) -> [UInt8] {
    var bytes = [UInt8](repeating: 0, count: count)

    data.copyBytes(to: &bytes, count: count)

    return bytes
  }
}
