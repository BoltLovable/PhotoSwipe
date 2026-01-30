import SwiftUI
import Photos
import UIKit

struct ContentView: View {
    @StateObject private var viewModel = PhotoLibraryViewModel()
    @State private var presentLimitedPicker = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            switch viewModel.state {
            case .idle, .requestingPermission, .loading:
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)

            case .denied:
                VStack(spacing: 16) {
                    Text("Photo access is required")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Button("Open Settings") {
                        viewModel.openSettings()
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Try Again") {
                        Task { await viewModel.start() }
                    }
                    .buttonStyle(.bordered)
                }
                .padding()

            case .empty:
                VStack(spacing: 16) {
                    Text("No photos available")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Button("Reload") {
                        Task { await viewModel.start() }
                    }
                    .buttonStyle(.bordered)
                }
                .padding()

            case .ready:
                if let image = viewModel.currentImage {
                    PhotoViewer(
                        image: image,
                        onKeep: { viewModel.keepCurrent() },
                        onDelete: { viewModel.deleteCurrent() }
                    )
                    .overlay(alignment: .bottom) {
                        HStack(spacing: 16) {
                            Button {
                                viewModel.keepCurrent()
                            } label: {
                                Text("Keep")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)

                            Button(role: .destructive) {
                                viewModel.deleteCurrent()
                            } label: {
                                Text("Delete")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                } else {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                }
            }
        }
        .task {
            await viewModel.start()
        }
        .sheet(isPresented: $presentLimitedPicker) {
            LimitedLibraryPicker()
        }
        .onReceive(viewModel.$shouldPresentLimitedPicker) { should in
            if should {
                presentLimitedPicker = true
                viewModel.shouldPresentLimitedPicker = false
            }
        }
    }
}

private struct PhotoViewer: View {
    let image: UIImage
    let onKeep: () -> Void
    let onDelete: () -> Void

    private let swipeThreshold: CGFloat = 80

    var body: some View {
        GeometryReader { proxy in
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: proxy.size.width, height: proxy.size.height)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 12)
                        .onEnded { value in
                            if value.translation.width > swipeThreshold {
                                onKeep()
                            } else if value.translation.width < -swipeThreshold {
                                onDelete()
                            }
                        }
                )
        }
        .ignoresSafeArea()
    }
}
