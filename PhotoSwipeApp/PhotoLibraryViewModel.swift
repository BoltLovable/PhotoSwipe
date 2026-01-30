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
    @Published private(set) var trashCount: Int = 0

    private var remainingAssetIds: [String] = []
    private var currentAssetId: String?

    private var keptAssetIds: Set<String> = []
    private var trashedAssetIds: Set<String> = []

    private let keptDefaultsKey = "photoswipe.keptAssetIds"
    private let trashDefaultsKey = "photoswipe.trashedAssetIds"

    private let imageManager = PHCachingImageManager()

    func start() async {
        state = .requestingPermission

        loadPersistedState()

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
        keptAssetIds.insert(currentAssetId)
        persistState()
        removeFromRemaining(assetId: currentAssetId)
        showNextRandomPhoto()
    }

    func deleteCurrent() {
        guard state == .ready else { return }
        guard let assetId = currentAssetId else { return }
        trashedAssetIds.insert(assetId)
        persistState()
        removeFromRemaining(assetId: assetId)
        showNextRandomPhoto()
    }

    func deleteTrashed() {
        let ids = Array(trashedAssetIds)
        guard !ids.isEmpty else { return }

        let assets = PHAsset.fetchAssets(withLocalIdentifiers: ids, options: nil)
        guard assets.count > 0 else {
            trashedAssetIds.removeAll()
            persistState()
            reloadAssets()
            showNextRandomPhoto()
            return
        }

        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assets)
        }, completionHandler: { [weak self] _, _ in
            DispatchQueue.main.async {
                guard let self else { return }
                self.trashedAssetIds.removeAll()
                self.persistState()
                self.reloadAssets()
                if self.remainingAssetIds.isEmpty {
                    self.state = .empty
                    self.currentImage = nil
                    self.currentAssetId = nil
                } else {
                    self.state = .ready
                    self.showNextRandomPhoto()
                }
            }
        })
    }

    func resetData() {
        keptAssetIds.removeAll()
        trashedAssetIds.removeAll()
        persistState()
        reloadAssets()
        if remainingAssetIds.isEmpty {
            state = .empty
            currentImage = nil
            currentAssetId = nil
        } else {
            state = .ready
            showNextRandomPhoto()
        }
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
            let id = asset.localIdentifier
            if !self.keptAssetIds.contains(id) && !self.trashedAssetIds.contains(id) {
                ids.append(id)
            }
        }
        remainingAssetIds = ids
        trashCount = trashedAssetIds.count
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

    private func loadPersistedState() {
        let kept = UserDefaults.standard.array(forKey: keptDefaultsKey) as? [String] ?? []
        keptAssetIds = Set(kept)
        let trash = UserDefaults.standard.array(forKey: trashDefaultsKey) as? [String] ?? []
        trashedAssetIds = Set(trash)
        trashCount = trashedAssetIds.count
    }

    private func persistState() {
        UserDefaults.standard.set(Array(keptAssetIds), forKey: keptDefaultsKey)
        UserDefaults.standard.set(Array(trashedAssetIds), forKey: trashDefaultsKey)
        trashCount = trashedAssetIds.count
    }
}
