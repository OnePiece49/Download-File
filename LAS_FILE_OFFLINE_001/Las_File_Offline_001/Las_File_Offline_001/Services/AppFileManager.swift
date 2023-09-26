//
//  FileService.swift
//  Las_File_Offline_001
//
//  Created by Đức Anh Trần on 29/07/2023.
//

import Foundation
import ZIPFoundation

class AppFileManager {

	static let shared = AppFileManager()

	private let fileManager = FileManager.default

	func removeFiles(at urls: [URL]) {
		for url in urls {
			if fileManager.fileExists(atPath: url.path) {
				try? fileManager.removeItem(at: url)
			}
		}
	}

	func zipFiles(from srcURLs: [URL], dstURL: URL, completion: @escaping (_ success: Bool) -> Void) {
		let zipQueue = DispatchQueue(label: "zip.queue")

		zipQueue.async { [weak self] in
			guard let tempURL = self?.getTemporaryURL(urls: srcURLs, dstURL: dstURL) else {
				DispatchQueue.main.async { completion(false) }
				return
			}

			do {
				try self?.fileManager.zipItem(at: tempURL, to: dstURL, shouldKeepParent: true, compressionMethod: .deflate)
				DispatchQueue.main.async { completion(true) }

			} catch {
				print("DEBUG: \(#function) - error: \(error)")
				DispatchQueue.main.async { completion(false) }
			}
		}
	}

	private func getTemporaryURL(urls: [URL], dstURL: URL) -> URL? {
		let tempURL = fileManager.temporaryDirectory.appendingPathComponent("Archives")

		do {
			if fileManager.fileExists(atPath: tempURL.path) {
				try fileManager.removeItem(at: tempURL)
			}
			try fileManager.createDirectory(at: tempURL, withIntermediateDirectories: true)

			for url in urls {
				let dstURL = tempURL.appendingPathComponent(url.lastPathComponent)
				try fileManager.copyItem(at: url, to: dstURL)
			}

		} catch {
			print("DEBUG: \(#function) - error: \(error)")
			return nil
		}

		return tempURL
	}
}
