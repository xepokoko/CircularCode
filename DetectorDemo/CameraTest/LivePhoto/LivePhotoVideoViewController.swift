//
//  LivePhotoVideoViewController.swift
//  CameraTest
//
//  Created by 谢恩平 on 2024/12/25.
//

import UIKit
import Photos
import AVKit

class LivePhotoVideoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestPhotoLibraryAccess()
    }
    
    private func requestPhotoLibraryAccess() {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                DispatchQueue.main.async {
                    self.presentImagePickerController()
                }
            case .denied, .restricted, .notDetermined:
                print("Photo Library Access Denied")
            @unknown default:
                fatalError()
            }
        }
    }
    
    private func presentImagePickerController() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.mediaTypes = ["public.image"]
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let assetURL = info[UIImagePickerController.InfoKey.referenceURL] as? URL else {
            print("No asset URL")
            return
        }
        
        let assets = PHAsset.fetchAssets(withALAssetURLs: [assetURL], options: nil)
        
        guard let asset = assets.firstObject, asset.mediaSubtypes.contains(.photoLive) else {
            print("Selected photo is not a Live Photo")
            return
        }
        
        fetchLivePhotoVideo(for: asset)
    }
    
    private func fetchLivePhotoVideo(for asset: PHAsset) {
        let assetResources = PHAssetResource.assetResources(for: asset)
        let videoResources = assetResources.filter { $0.type == .fullSizePairedVideo }
        
        guard let videoResource = videoResources.first else {
            print("No video resource found")
            return
        }
        
        let videoFileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")

        PHAssetResourceManager.default().writeData(for: videoResource, toFile: videoFileURL, options: nil) { (error) in
            if let error = error {
                print("Error writing video resource: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.playVideo(from: videoFileURL)
                }
            }
        }
    }
    
    private func playVideo(from url: URL) {
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.videoGravity = .resizeAspect
        self.present(playerViewController, animated: true) {
            playerViewController.player?.play()
        }
    }
}
