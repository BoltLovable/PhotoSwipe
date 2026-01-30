import PhotosUI
import SwiftUI
import UIKit

struct LimitedLibraryPicker: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        DispatchQueue.main.async {
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: controller)
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
