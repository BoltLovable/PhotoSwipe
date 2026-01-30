import SwiftUI
import Photos
import UIKit

struct ContentView: View {
    @StateObject private var viewModel = PhotoLibraryViewModel()
    @State private var presentLimitedPicker = false
    @State private var confirmBatchDelete = false

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
                    .overlay(alignment: .topTrailing) {
                        HStack(spacing: 12) {
                            Button {
                                viewModel.resetData()
                            } label: {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .padding(10)
                                    .background(.black.opacity(0.35))
                                    .clipShape(Circle())
                            }

                            Button {
                                confirmBatchDelete = true
                            } label: {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "trash")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .padding(10)
                                        .background(.black.opacity(0.35))
                                        .clipShape(Circle())

                                    if viewModel.trashCount > 0 {
                                        Text("\(viewModel.trashCount)")
                                            .font(.caption2.weight(.bold))
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.red)
                                            .clipShape(Capsule())
                                            .offset(x: 6, y: -6)
                                    }
                                }
                            }
                            .disabled(viewModel.trashCount == 0)
                            .opacity(viewModel.trashCount == 0 ? 0.4 : 1.0)
                        }
                        .padding(.top, 14)
                        .padding(.trailing, 14)
                    }
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
        .alert("Trashed photos löschen?", isPresented: $confirmBatchDelete) {
            Button("Löschen", role: .destructive) {
                viewModel.deleteTrashed()
            }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("\(viewModel.trashCount) Foto(s) werden in \"Zuletzt gelöscht\" verschoben.")
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
