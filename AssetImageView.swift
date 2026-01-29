import SwiftUI
import Photos
import UIKit

struct AssetImageView: View {
    let asset: PHAsset
    @State private var image: UIImage?
    @State private var isLoading = true
    
    private let imageManager = PHImageManager.default()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Text("Failed to load image")
                                .foregroundColor(.secondary)
                        )
                }
            }
        }
        .onAppear {
            loadImage(size: CGSize(width: 800, height: 800))
        }
        .onChange(of: asset) { _ in
            loadImage(size: CGSize(width: 800, height: 800))
        }
    }
    
    private func loadImage(size: CGSize) {
        isLoading = true
        image = nil
        
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        
        imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: options) { [self] result, _ in
            DispatchQueue.main.async {
                self.image = result
                self.isLoading = false
            }
        }
    }
}
