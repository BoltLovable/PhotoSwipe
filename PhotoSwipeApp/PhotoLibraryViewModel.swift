import Foundation
import Combine
import Photos
import SwiftUI
import UIKit

@MainActor
final class PhotoLibraryViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case requestingPermission
        case denied
        case loading
        case empty
        case ready
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var currentImage: UIImage?
    @Published var shouldPresentLimitedPicker: Bool = false

    private var remainingAssetIds: [String] = []
    private var currentAssetId: String?

    private let imageManager = PHCachingImageManager()

    func start() async {
        state = .requestingPermission

        let status = await requestReadWriteAuthorizationIfNeeded()
        guard status == .authorized || status == .limited else {
            state = .denied
            return
        }

        if status == .limited {
            shouldPresentLimitedPicker = true
        }

        state = .loading
        reloadAssets()

        if remainingAssetIds.isEmpty {
            state = .empty
            currentImage = nil
            currentAssetId = nil
            return
        }

        state = .ready
        showNextRandomPhoto()
    }

    func keepCurrent() {
        guard state == .ready else { return }
        guard let currentAssetId else { return }
        removeFromRemaining(assetId: currentAssetId)
        showNextRandomPhoto()
    }

    func deleteCurrent() {
        guard state == .ready else { return }
        guard let assetId = currentAssetId else { return }

        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil)
        guard let asset = assets.firstObject else {
            removeFromRemaining(assetId: assetId)
            showNextRandomPhoto()
            return
        }

        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets([asset] as NSArray)
        }, completionHandler: { [weak self] _, _ in
            DispatchQueue.main.async {
                guard let self else { return }
                self.removeFromRemaining(assetId: assetId)
                self.showNextRandomPhoto()
            }
        })
    }

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    private func reloadAssets() {
        let result = PHAsset.fetchAssets(with: .image, options: nil)
        var ids: [String] = []
        ids.reserveCapacity(result.count)
        result.enumerateObjects { asset, _, _ in
            ids.append(asset.localIdentifier)
        }
        remainingAssetIds = ids
    }

    private func removeFromRemaining(assetId: String) {
        if let idx = remainingAssetIds.firstIndex(of: assetId) {
            remainingAssetIds.remove(at: idx)
        }
    }

    private func showNextRandomPhoto() {
        guard !remainingAssetIds.isEmpty else {
            state = .empty
            currentImage = nil
            currentAssetId = nil
            return
        }

        let idx = Int.random(in: 0..<remainingAssetIds.count)
        let assetId = remainingAssetIds[idx]
        currentAssetId = assetId

        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil)
        guard let asset = assets.firstObject else {
            removeFromRemaining(assetId: assetId)
            showNextRandomPhoto()
            return
        }

        let scale = UIScreen.main.scale
        let targetSize = CGSize(width: UIScreen.main.bounds.width * scale, height: UIScreen.main.bounds.height * scale)

        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true

        imageManager.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFit,
            options: options
        ) { [weak self] image, _ in
            guard let self else { return }
            self.currentImage = image
        }
    }

    private func requestReadWriteAuthorizationIfNeeded() async -> PHAuthorizationStatus {
        let current = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch current {
        case .authorized, .limited, .denied, .restricted:
            return current
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                    continuation.resume(returning: newStatus)
                }
            }
        @unknown default:
            return current
        }
    }
}
