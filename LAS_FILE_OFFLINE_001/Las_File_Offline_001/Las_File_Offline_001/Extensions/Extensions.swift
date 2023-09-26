//
//  Extensions.swift
//  Las_File_Offline_001
//
//  Created by Tiến Việt Trịnh on 28/07/2023.
//

import UIKit
import Photos
import AVFoundation
import Toast_Swift
import RealmSwift

let columns: CGFloat = UIDevice.current.is_iPhone ? 3 : 5
let padding: CGFloat = UIDevice.current.is_iPhone ? 20 : 48

extension UIDevice {
    var is_iPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
}

extension CMTime {
    func getTimeString() -> String? {
        let totalSeconds = CMTimeGetSeconds(self)
        guard !(totalSeconds.isNaN || totalSeconds.isInfinite) else {
            return nil
        }
        let hours = Int(totalSeconds / 3600)
        let minutes = Int(totalSeconds / 60) % 60
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        if hours > 0 {
            return String(format: "%i:%02i:%02i",arguments: [hours, minutes, seconds])
        } else {
            return String(format: "%02i:%02i", arguments: [minutes, seconds])
        }
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }

	static let primaryBlue = UIColor(rgb: 0x499AE9)
}

extension UIViewController {
    var insetTop: CGFloat {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let topPadding = window?.safeAreaInsets.top ?? 0
            return topPadding
        }
        return 0
    }
    
    var insetBottom: CGFloat {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let bottomPadding = window?.safeAreaInsets.bottom ?? 0
            return bottomPadding
        }
        return 0
    }
    
    func printPathRealm() {
        print("DEBUG: \(String(describing: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first))")
    }
}

extension UIView {
    func setDimensions(width: CGFloat, height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: width),
            heightAnchor.constraint(equalToConstant: height),
        ])
    }

	func pinToEdges(_ view: UIView) {
		translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			leftAnchor.constraint(equalTo: view.leftAnchor),
			topAnchor.constraint(equalTo: view.topAnchor),
			rightAnchor.constraint(equalTo: view.rightAnchor),
			bottomAnchor.constraint(equalTo: view.bottomAnchor),
		])
	}
    
    func applyBlurBackground(style: UIBlurEffect.Style,
                             alpha: CGFloat = 1,
                             top: CGFloat = 0,
                             bottom: CGFloat = 0) {
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.alpha = alpha
        addSubview(blurEffectView)
        NSLayoutConstraint.activate([
            blurEffectView.leftAnchor.constraint(equalTo: leftAnchor),
            blurEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurEffectView.rightAnchor.constraint(equalTo: rightAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottom),
        ])
    }
    
    func applyGradient(colours: [UIColor])  {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func generateThumbnail(path: URL, identifier: String,
                           completion: @escaping (_ thumbnail: UIImage?, _ identifier: String) -> Void) {
        
        let asset = AVURLAsset(url: path, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        
        imgGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: .zero)]) { _, image, _, _, _ in
            if let image = image {
                DispatchQueue.main.async {
                    completion(UIImage(cgImage: image), identifier)
                }
            }
        }
    }
    
	func displayToast(_ message: String, duration: TimeInterval = 2, position: ToastPosition = .top) {
        guard let window = UIWindow.keyWindow else { return }
        
        window.hideAllToasts()
		window.makeToast(message, duration: duration, position: position )
	}

	func dropShadow() {
		clipsToBounds = false
		self.layer.shadowColor = UIColor.black.cgColor
		self.layer.shadowOpacity = 0.2
		self.layer.shadowOffset = .zero
		self.layer.shadowRadius = 10
	}

	func fadeIn(_ duration: TimeInterval = 0.2, onCompletion: (() -> Void)? = nil) {
		self.alpha = 0
		self.isHidden = false
		UIView.animate(withDuration: duration) {
			self.alpha = 1
		} completion: { _ in
			onCompletion?()
		}
	}

	func fadeOut(_ duration: TimeInterval = 0.2, onCompletion: (() -> Void)? = nil) {
		UIView.animate(withDuration: duration) {
			self.alpha = 0
		} completion: { _ in
			self.isHidden = true
			onCompletion?()
		}
	}
}

extension UIWindow {
    static var keyWindow: UIWindow? {
        // iOS13 or later
        if #available(iOS 13.0, *) {
            guard let scene = UIApplication.shared.connectedScenes.first,
                  let sceneDelegate = scene.delegate as? SceneDelegate else { return nil }
            return sceneDelegate.window
        } else {
            // iOS12 or earlier
            guard let appDelegate = UIApplication.shared.delegate else { return nil }
            return appDelegate.window ?? nil
        }
    }
}

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}


extension UIFont {
    
    static func fontGilroyBold(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "SVN-Gilroy Bold", size: size)
    }

	static func fontGilroySemi(_ size: CGFloat) -> UIFont? {
		return UIFont(name: "SVN-Gilroy SemiBold", size: size)
	}
    
    static func fontGilroyMedium(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "SVN-Gilroy Medium", size: size)
    }
    
    static func fontGilroyRegular(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "SVN-Gilroy Regular", size: size)
    }
    
}

extension UICollectionViewCell {
    static var cellId: String {
        return String(describing: self)
    }
}

extension UITableViewCell {
    static var cellId: String {
        return String(describing: self)
    }
}

extension URL {
    static func cache() -> URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    static func document() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    static func createFolder(folderName: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory,
                                                       in: .userDomainMask).first else {return nil}
        let folderURL = documentDirectory.appendingPathComponent(folderName)
        
        if !fileManager.fileExists(atPath: folderURL.path) {
            do {
                
                try fileManager.createDirectory(atPath: folderURL.path,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }
        return folderURL
    }

    static func downloadFolder() -> URL? {
        return self.createFolder(folderName: "Download")
    }

	static func importFolder() -> URL? {
		return self.createFolder(folderName: "Import")
	}

	static func zipItemFolder() -> URL? {
		return self.createFolder(folderName: "ZipItem")
	}

	static func getFolderSize(urls: [URL]) -> String {
		var totalSize: UInt64 = 0
		for url in urls {
			totalSize += url.fileSize
		}
		return ByteCountFormatter.string(fromByteCount: Int64(totalSize), countStyle: .file)
	}

    var attributes: [FileAttributeKey : Any]? {
        do {
            return try FileManager.default.attributesOfItem(atPath: path)
        } catch let error as NSError {
            print("FileAttribute error: \(error)")
        }
        return nil
    }

    var fileSize: UInt64 {
        return attributes?[.size] as? UInt64 ?? UInt64(0)
    }

    var fileSizeString: String {
        return ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
    }

    var creationDate: Date? {
        return attributes?[.creationDate] as? Date
    }
}

/// Get folder size
extension URL {
	/// check if the URL is a directory and if it is reachable
	func isDirectoryAndReachable() throws -> Bool {
		guard try resourceValues(forKeys: [.isDirectoryKey]).isDirectory == true else {
			return false
		}
		return try checkResourceIsReachable()
	}

	/// returns total allocated size of a the directory including its subFolders or not
	func directoryTotalAllocatedSize(includingSubfolders: Bool = true) throws -> Int? {
		guard try isDirectoryAndReachable() else { return nil }
		if includingSubfolders {
			guard
				let urls = FileManager.default.enumerator(at: self, includingPropertiesForKeys: nil)?.allObjects as? [URL] else { return nil }
			return try urls.lazy.reduce(0) {
				(try $1.resourceValues(forKeys: [.totalFileAllocatedSizeKey]).totalFileAllocatedSize ?? 0) + $0
			}
		}
		return try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil).lazy.reduce(0) {
			(try $1.resourceValues(forKeys: [.totalFileAllocatedSizeKey])
				.totalFileAllocatedSize ?? 0) + $0
		}
	}

	/// returns the directory total size on disk
	func sizeOnDisk() throws -> String? {
		guard let size = try directoryTotalAllocatedSize() else { return nil }
		return ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
	}
}

extension String {
	var fileURL: URL {
		return URL(fileURLWithPath: self)
	}

	var pathExtension: String {
		return fileURL.pathExtension
	}

	var lastPathComponent: String {
		return fileURL.lastPathComponent
	}

	var fileName: String {
		return fileURL.lastPathComponent
	}
}

extension PHAsset {
    
    var getImageMaxSize : UIImage {
        var thumbnail = UIImage()
        let imageManager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        imageManager.requestImage(for: self, targetSize: CGSize.init(width: 720, height: 1080), contentMode: .aspectFit, options: option, resultHandler: { image, _ in
            thumbnail = image!
        })
        return thumbnail
    }
    
    
    var getImageThumb : UIImage {
        var thumbnail = UIImage()
        let imageManager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        
        imageManager.requestImage(for: self, targetSize: CGSize.init(width: 400, height: 400), contentMode: .aspectFit, options: option, resultHandler: { image, _ in
            guard let image = image else {return}
            thumbnail = image
        })
        return thumbnail
    }
    
    var originalFilename: String? {
        return PHAssetResource.assetResources(for: self).first?.originalFilename
    }
    var originalName: String? {
        let str = PHAssetResource.assetResources(for: self).first?.originalFilename.dropLast(4)
        return "\(str ?? "Video")"
    }
    
    func getDuration(videoAsset: PHAsset?) -> String {
        guard let asset = videoAsset else { return "00:00" }
        let duration: TimeInterval = asset.duration
        let s: Int = Int(duration) % 60
        let m: Int = Int(duration) / 60
        let formattedDuration = String(format: "%02d:%02d", m, s)
        return formattedDuration
    }
}

extension Results {
	func toArray<T>(ofType: T.Type) -> [T] {
		var array = [T]()
		for i in 0 ..< count {
			if let result = self[i] as? T {
				array.append(result)
			}
		}

		return array
	}
}

extension List {
	func toArray<T>(ofType: T.Type) -> [T] {
		var array = [T]()
		self.forEach {
			if let element = $0 as? T {
				array.append(element)
			}
		}
		return array
	}
}

extension Array where Element: RealmCollectionValue {
	func toList() -> List<Element> {
		var listFiles = List<Element>()
		for element in self {
			listFiles.append(element)
		}
		return listFiles
	}
}
