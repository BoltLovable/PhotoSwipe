# PhotoSwipe (lokal in Xcode)

Dieses Repository enthält die SwiftUI-Quellcodes für eine minimalistische iOS-App zum schnellen Durchsehen von Fotos:

- Ein Foto wird zufällig angezeigt.
- **Swipe rechts** = Behalten (in dieser Session nicht mehr anzeigen)
- **Swipe links** = Löschen (landet in „Zuletzt gelöscht“)
- Unten gibt es zusätzlich die Buttons **Keep** und **Delete**.

- `Privacy - Photo Library Usage Description` (`NSPhotoLibraryUsageDescription`)

- `Privacy - Photo Library Additions Usage Description` (`NSPhotoLibraryAddUsageDescription`)
 
    
## Projektstruktur (Quellcode)

- `PhotoSwipeApp/ContentView.swift`
  - Fullscreen-UI, Swipe-Gesten, Buttons
- `PhotoSwipeApp/PhotoLibraryViewModel.swift`
  - Berechtigungen, Laden aller erlaubten Fotos, Random-Auswahl, Keep/Delete-Logik
- `PhotoSwipeApp/LimitedLibraryPicker.swift`
  - Präsentiert den iOS Limited Library Picker
- `PhotoSwipeApp/PhotoSwipeApp.swift`
  - SwiftUI App Entry (alternativ zum von Xcode generierten Entry)
