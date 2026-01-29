# PhotoSwift

A SwiftUI app for iOS 16+ that displays random photos from your photo library with swipe and button controls.

## Features

- **Random Photo Display**: Shows a random image from your Photos library
- **Swipe Gestures**: 
  - Swipe left (or tap ❌) to skip the photo (won't appear again)
  - Swipe right (or tap ✅) to delete the photo
- **Persistent State**: Maintains a "seen" set using UserDefaults
- **Photo Library Integration**: Full read-write access to Photos
- **Haptic Feedback**: Light haptic feedback on actions
- **Error Handling**: Clear error messages and alerts

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Photo library access permission

## Architecture

The app follows a clean SwiftUI architecture with three main components:

### PhotoLibraryService.swift
- Handles photo library authorization and access
- Manages asset loading and filtering
- Maintains persistent "seen" state
- Provides delete functionality

### ContentView.swift
- Main UI with swipe gestures and buttons
- Handles authorization states
- Displays appropriate UI for different states

### AssetImageView.swift
- SwiftUI view for displaying PHAsset images
- Handles image loading and caching
- Provides loading states

## Usage

1. Grant photo library access when prompted
2. Swipe left or tap ❌ to skip photos
3. Swipe right or tap ✅ to delete photos
4. Deleted photos go to "Recently Deleted" in Photos
5. Reset seen photos from the toolbar or when all photos are viewed

## Installation

1. Clone this repository
2. Open `PhotoSwift.xcodeproj` in Xcode
3. Build and run on a device or simulator

## Privacy

- Photos are accessed only with explicit user permission
- Deleted photos follow iOS standard behavior (go to Recently Deleted)
- No data is transmitted outside the device
