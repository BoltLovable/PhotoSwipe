import Foundation
import Photos
import UIKit

class PhotoLibraryService: ObservableObject {
    @Published var currentAsset: PHAsset?
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var errorMessage: String?
    @Published var hasMorePhotos = true
    
    private let imageManager = PHImageManager.default()
    private let seenAssetsKey = "SeenAssets"
    private var allAssets: PHFetchResult<PHAsset>?
    
    init() {
        checkAuthorizationStatus()
    }
    
    func requestAuthorization() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            DispatchQueue.main.async {
                self?.authorizationStatus = status
                if status == .authorized {
                    self?.loadAssets()
                }
            }
        }
    }
    
    private func checkAuthorizationStatus() {
        authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if authorizationStatus == .authorized {
            loadAssets()
        }
    }
    
    private func loadAssets() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        
        allAssets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        loadRandomAsset()
    }
    
    private func getSeenAssets() -> Set<String> {
        guard let data = UserDefaults.standard.data(forKey: seenAssetsKey),
              let seenAssets = try? JSONDecoder().decode(Set<String>.self, from: data) else {
            return Set()
        }
        return seenAssets
    }
    
    private func saveSeenAssets(_ seenAssets: Set<String>) {
        if let data = try? JSONEncoder().encode(seenAssets) {
            UserDefaults.standard.set(data, forKey: seenAssetsKey)
        }
    }
    
    func loadRandomAsset() {
        guard let assets = allAssets else { return }
        
        var seenAssets = getSeenAssets()
        var availableAssets: [PHAsset] = []
        
        assets.enumerateObjects { asset, _, _ in
            if !seenAssets.contains(asset.localIdentifier) {
                availableAssets.append(asset)
            }
        }
        
        if availableAssets.isEmpty {
            currentAsset = nil
            hasMorePhotos = false
            return
        }
        
        let randomAsset = availableAssets.randomElement()
        currentAsset = randomAsset
        hasMorePhotos = true
    }
    
    func skipCurrentAsset() {
        guard let asset = currentAsset else { return }
        
        var seenAssets = getSeenAssets()
        seenAssets.insert(asset.localIdentifier)
        saveSeenAssets(seenAssets)
        
        loadRandomAsset()
    }
    
    func deleteCurrentAsset() {
        guard let asset = currentAsset else { return }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets([asset] as NSArray)
        }) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.skipCurrentAsset()
                } else {
                    self?.errorMessage = error?.localizedDescription ?? "Failed to delete photo"
                }
            }
        }
    }
    
    func getImage(for asset: PHAsset, size: CGSize, completion: @escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        
        imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: options) { image, _ in
            completion(image)
        }
    }
    
    func resetSeenAssets() {
        UserDefaults.standard.removeObject(forKey: seenAssetsKey)
        loadRandomAsset()
    }
}
