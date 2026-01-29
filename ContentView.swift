import SwiftUI
import Photos

struct ContentView: View {
    @StateObject private var photoLibraryService = PhotoLibraryService()
    @State private var showingErrorAlert = false
    @State private var dragOffset: CGSize = .zero
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if photoLibraryService.authorizationStatus == .authorized {
                    if let asset = photoLibraryService.currentAsset {
                        AssetImageView(asset: asset)
                            .offset(dragOffset)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        dragOffset = value.translation
                                    }
                                    .onEnded { value in
                                        handleSwipeGesture(translation: value.translation)
                                        dragOffset = .zero
                                    }
                            )
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: dragOffset)
                        
                        VStack {
                            Spacer()
                            HStack(spacing: 50) {
                                Button(action: skipPhoto) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.red)
                                        .background(Color.black.opacity(0.7))
                                        .clipShape(Circle())
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: deletePhoto) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.green)
                                        .background(Color.black.opacity(0.7))
                                        .clipShape(Circle())
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.bottom, 50)
                        }
                    } else if photoLibraryService.hasMorePhotos {
                        ProgressView("Loading photos...")
                            .foregroundColor(.white)
                            .scaleEffect(1.5)
                    } else {
                        VStack(spacing: 20) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 80))
                                .foregroundColor(.gray)
                            
                            Text("No more photos")
                                .font(.title)
                                .foregroundColor(.white)
                            
                            Text("You've seen all photos in your library")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Button("Reset Seen Photos") {
                                showingResetAlert = true
                            }
                            .foregroundColor(.blue)
                            .padding(.top, 20)
                        }
                    }
                } else if photoLibraryService.authorizationStatus == .denied {
                    VStack(spacing: 20) {
                        Image(systemName: "photo.on.rectangle.slash")
                            .font(.system(size: 80))
                            .foregroundColor(.red)
                        
                        Text("Photo Access Denied")
                            .font(.title)
                            .foregroundColor(.white)
                        
                        Text("Please enable photo access in Settings to use this app")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "photo")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text("PhotoSwift")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Button("Grant Photo Access") {
                            photoLibraryService.requestAuthorization()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                }
            }
            .navigationTitle("PhotoSwift")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if photoLibraryService.authorizationStatus == .authorized && photoLibraryService.currentAsset != nil {
                        Button("Reset") {
                            showingResetAlert = true
                        }
                    }
                }
            }
            .alert("Error", isPresented: $showingErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(photoLibraryService.errorMessage ?? "An unknown error occurred")
            }
            .alert("Reset Seen Photos", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    photoLibraryService.resetSeenAssets()
                }
            } message: {
                Text("This will reset all photos you've seen and you'll start seeing them again from the beginning.")
            }
        }
    }
    
    private func handleSwipeGesture(translation: CGSize) {
        let threshold: CGFloat = 100
        
        if abs(translation.x) > threshold {
            if translation.x > 0 {
                deletePhoto()
            } else {
                skipPhoto()
            }
        }
    }
    
    private func skipPhoto() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        photoLibraryService.skipCurrentAsset()
    }
    
    private func deletePhoto() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        photoLibraryService.deleteCurrentAsset()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
