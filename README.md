# PhotoSwift

A SwiftUI app for iOS 16+ that displays random photos from your photo library with swipe and button controls.

## 🚀 Complete Beginner's Guide to Deploying This App

### Prerequisites
- **Mac computer** with macOS (required for Xcode)
- **Apple ID** (free Apple ID works, no paid developer account needed)
- **iPhone/iPad** or iOS Simulator for testing

### Step 1: Install Xcode
1. Open **App Store** on your Mac
2. Search for "**Xcode**" (it's free)
3. Click "**Get**" then "**Install**"
4. Wait for installation (it's large, may take 30+ minutes)
5. Launch Xcode from Applications folder
6. Accept the license agreement when prompted

### Step 2: Open the Project
1. Navigate to the `PhotoSwift` folder on your computer
2. Double-click `PhotoSwift.xcodeproj` (this opens Xcode)
3. Xcode will load the project - you'll see the files on the left

### Step 3: Connect Your Device (Optional but Recommended)
**For iPhone/iPad:**
1. Connect your iPhone/iPad to Mac with USB cable
2. Unlock your device and tap "**Trust**" if prompted
3. In Xcode, click the device name at top (next to "PhotoSwift")
4. Select your connected device from the dropdown

**For Simulator (if no device):**
1. In Xcode, click the device name at top
2. Select "**iPhone 15**" or any iOS Simulator from the dropdown

### Step 4: Build and Run the App
1. Make sure your device/simulator is selected at the top
2. Press **⌘ + R** (Command + R) or click the **Play button** ▶️
3. Xcode will build the app (first time takes a few minutes)
4. The app will automatically install and launch

### Step 5: Grant Photo Permissions
1. When the app first opens, tap "**Grant Photo Access**"
2. iOS will show a permission dialog - tap "**Allow**" or "**Select Photos**"
3. Choose "**All Photos**" for the best experience

### Step 6: Using the App
- **Swipe Left** or tap ❌ to skip a photo (won't appear again)
- **Swipe Right** or tap ✅ to delete a photo (goes to "Recently Deleted")
- Deleted photos can be recovered from Photos app → "Recently Deleted" (30 days)

### Troubleshooting
**"Build Failed" error:**
- Make sure you selected a device/simulator at the top
- Try **Product → Clean Build Folder** (⌘ + Shift + K)
- Try building again

**"Photo Access Denied":**
- Go to **Settings → PhotoSwift → Photos**
- Change to "**All Photos**" or "**Selected Photos**"

**App crashes:**
- Make sure your iOS device is running iOS 16.0 or newer
- Try using the iOS Simulator instead

---

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
