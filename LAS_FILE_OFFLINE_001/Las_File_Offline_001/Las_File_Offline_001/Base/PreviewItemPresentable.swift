//
//  PreviewItemPresentable.swift
//  Las_File_Offline_001
//
//  Created by Đức Anh Trần on 02/08/2023.
//

import UIKit
import QuickLook

protocol PreviewItemPresentable {
	func previewDocx(currentPreviewItemIndex: Int, parentVC: UIViewController & QLPreviewControllerDataSource)
}

extension PreviewItemPresentable {
	func previewDocx(currentPreviewItemIndex: Int, parentVC: UIViewController & QLPreviewControllerDataSource) {
		let quickLookViewController = QLPreviewController()
		quickLookViewController.dataSource = parentVC
		quickLookViewController.currentPreviewItemIndex = currentPreviewItemIndex
		parentVC.present(quickLookViewController, animated: true)
	}
}
