# PhotoSwipe (lokal in Xcode)

Dieses Repository enthält die SwiftUI-Quellcodes für eine minimalistische iOS-App zum schnellen Durchsehen von Fotos:

- Ein Foto wird zufällig angezeigt.
- **Swipe rechts** = Behalten (in dieser Session nicht mehr anzeigen)
- **Swipe links** = Löschen (landet in „Zuletzt gelöscht“)
- Unten gibt es zusätzlich die Buttons **Keep** und **Delete**.

Die Dateien liegen unter `PhotoSwipeApp/`.

## Voraussetzungen

- macOS mit Xcode (aktuelles Xcode empfohlen)
- iOS Simulator oder echtes Gerät
- Zugriff auf die Fotos-App (es werden iOS-Privacy-Keys benötigt, siehe unten)

## Projekt in Xcode anlegen

1. **Neues Xcode Projekt erstellen**

   - Xcode öffnen
   - `File` -> `New` -> `Project...`
   - Template: **iOS** -> **App**
   - Einstellungen:
     - **Interface**: SwiftUI
     - **Language**: Swift

2. **Swift-Dateien aus diesem Repo hinzufügen**

   - In Xcode im Project Navigator rechtsklick auf den Projektnamen -> `Add Files to "<Projektname>"...`
   - Den Ordner `PhotoSwipeApp/` auswählen
   - Wichtig:
     - **"Copy items if needed"** aktivieren
     - Sicherstellen, dass die Dateien dem **App Target** hinzugefügt werden

3. **App Entry sicherstellen**

   In einem SwiftUI-Projekt gibt es normalerweise bereits eine `App`-Datei (z.B. `<Projektname>App.swift`).

   - Entweder du nutzt die bereits generierte Datei und setzt deren Root-View auf `ContentView()`.
   - Oder du nutzt die `PhotoSwipeApp.swift` aus diesem Repo.

   Wichtig ist: Es darf am Ende nur **ein** `@main` App-Entry im Target geben.

## Info.plist / Privacy Permissions

Damit iOS den Zugriff auf die Fotomediathek erlaubt, musst du in deinem Xcode-Projekt die Privacy-Keys setzen.

Öffne dazu in Xcode deine `Info.plist` (oder unter Target -> `Info` -> `Custom iOS Target Properties`) und füge hinzu:

- `Privacy - Photo Library Usage Description` (`NSPhotoLibraryUsageDescription`)
  - Beispiel: `Die App zeigt zufällige Fotos, damit du sie behalten oder löschen kannst.`

- `Privacy - Photo Library Additions Usage Description` (`NSPhotoLibraryAddUsageDescription`)
  - Beispiel: `Wird für Schreibzugriff auf die Mediathek benötigt.`

Hinweis: Die App fragt **Read/Write** an und unterstützt **Full Access** und **Limited Access**.

## Testen im iOS Simulator

1. **Fotos in den Simulator bekommen**

   Der Simulator hat ggf. eine leere Mediathek.

   - Öffne im Simulator die **Fotos** App und importiere Bilder
   - oder ziehe Bilder per Drag & Drop in den Simulator (je nach Simulator/iOS-Version)

2. **App starten**

   - In Xcode ein Simulator-Gerät auswählen
   - `Run` (Play-Button)

3. **Berechtigung prüfen**

   - Bei der Anfrage Zugriff erlauben
   - Bei **Limited Access** kannst du die Auswahl anpassen; die App zeigt den Limited Picker an.

## Projektstruktur (Quellcode)

- `PhotoSwipeApp/ContentView.swift`
  - Fullscreen-UI, Swipe-Gesten, Buttons
- `PhotoSwipeApp/PhotoLibraryViewModel.swift`
  - Berechtigungen, Laden aller erlaubten Fotos, Random-Auswahl, Keep/Delete-Logik
- `PhotoSwipeApp/LimitedLibraryPicker.swift`
  - Präsentiert den iOS Limited Library Picker
- `PhotoSwipeApp/PhotoSwipeApp.swift`
  - SwiftUI App Entry (alternativ zum von Xcode generierten Entry)
