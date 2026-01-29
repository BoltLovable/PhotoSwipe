# PhotoSwift

Eine SwiftUI-App für iOS 16+, die zufällige Fotos aus deiner Fotobibliothek mit Wisch- und Button-Steuerungen anzeigt.

## 🚀 komplette Anleitung für absolute Anfänger

### Was du brauchst
- **Mac-Computer** mit macOS (wird für Xcode benötigt)
- **Apple ID** (kostenlose Apple ID reicht, kein kostenpflichtiger Entwicklerkonto nötig)
- **iPhone/iPad** oder iOS-Simulator zum Testen

### Schritt 1: Xcode installieren
1. Öffne den **App Store** auf deinem Mac
2. Suche nach "**Xcode**" (es ist kostenlos)
3. Klicke auf "**Holen**" und dann auf "**Installieren**"
4. Warte auf die Installation (es ist groß, kann 30+ Minuten dauern)
5. Starte Xcode aus dem Programme-Ordner
6. Akzeptiere die Lizenzvereinbarung, wenn du gefragt wirst

### Schritt 2: Projekt öffnen
1. Navigiere zum `PhotoSwift`-Ordner auf deinem Computer
2. Doppelklicke auf `PhotoSwift.xcodeproj` (das öffnet Xcode)
3. Xcode lädt das Projekt - du siehst die Dateien links

### Schritt 3: Gerät verbinden (Optional aber empfohlen)
**Für iPhone/iPad:**
1. Verbinde dein iPhone/iPad mit dem Mac per USB-Kabel
2. Entsperre dein Gerät und tippe auf "**Vertrauen**", wenn gefragt
3. In Xcode klicke auf den Gerätenamen oben (neben "PhotoSwift")
4. Wähle dein verbundenes Gerät aus der Dropdown-Liste

**Für Simulator (wenn kein Gerät verfügbar):**
1. In Xcode klicke auf den Gerätenamen oben
2. Wähle "**iPhone 15**" oder einen anderen iOS-Simulator aus der Dropdown-Liste

### Schritt 4: App bauen und starten
1. Stelle sicher, dass dein Gerät/Simulator oben ausgewählt ist
2. Drücke **⌘ + R** (Command + R) oder klicke auf den **Play-Button** ▶️
3. Xcode baut die App (beim Mal dauert es einige Minuten)
4. Die App wird automatisch installiert und gestartet

### Schritt 5: Foto-Berechtigung erteilen
1. Wenn die App zum ersten Mal öffnet, tippe auf "**Foto-Zugriff gewähren**"
2. iOS zeigt einen Berechtigungsdialog - tippe auf "**Erlauben**" oder "**Fotos auswählen**"
3. Wähle "**Alle Fotos**" für die beste Erfahrung

### Schritt 6: App benutzen
- **Nach links wischen** oder auf ❌ tippen, um ein Foto zu überspringen (erscheint nicht wieder)
- **Nach rechts wischen** oder auf ✅ tippen, um ein Foto zu löschen (geht in "Kürzlich gelöscht")
- Gelöschte Fotos können über Fotos-App → "Kürzlich gelöscht" wiederhergestellt werden (30 Tage)

### Fehlerbehebung
**"Build Failed" Fehler:**
- Stelle sicher, dass oben ein Gerät/Simulator ausgewählt ist
- Versuche **Product → Clean Build Folder** (⌘ + Shift + K)
- Versuche erneut zu bauen

**"Foto-Zugriff verweigert":**
- Gehe zu **Einstellungen → PhotoSwift → Fotos**
- Ändere zu "**Alle Fotos**" oder "**Ausgewählte Fotos**"

**App stürzt ab:**
- Stelle sicher, dass dein iOS-Gerät iOS 16.0 oder neuer läuft
- Versuche stattdessen den iOS-Simulator zu verwenden

---

## Funktionen

- **Zufällige Foto-Anzeige**: Zeigt ein zufälliges Bild aus deiner Fotos-Bibliothek
- **Wisch-Gesten**: 
  - Nach links wischen (oder ❌ tippen) um das Foto zu überspringen (erscheint nicht wieder)
  - Nach rechts wischen (oder ✅ tippen) um das Foto zu löschen
- **Dauerhafter Zustand**: Behält eine "gesehene" Menge mit UserDefaults
- **Fotobibliothek-Integration**: Vollständiger Lese-Schreib-Zugriff auf Fotos
- **Haptisches Feedback**: Leichte haptische Rückmeldung bei Aktionen
- **Fehlerbehandlung**: Klare Fehlermeldungen und Warnungen

## Anforderungen

- iOS 16.0+
- Xcode 15.0+
- Zugriffsberechtigung für Fotobibliothek

## Architektur

Die App folgt einer sauberen SwiftUI-Architektur mit drei Hauptkomponenten:

### PhotoLibraryService.swift
- Verarbeitet Fotobibliothek-Autorisierung und Zugriff
- Verwaltet Asset-Laden und Filterung
- Behält dauerhaften "gesehen" Zustand
- Bietet Lösch-Funktionalität

### ContentView.swift
- Haupt-UI mit Wisch-Gesten und Buttons
- Verarbeitet Autorisierungszustände
- Zeigt passende UI für verschiedene Zustände

### AssetImageView.swift
- SwiftUI-View zur Anzeige von PHAsset-Bildern
- Verarbeitet Bild-Laden und Caching
- Bietet Ladezustände

## Verwendung

1. Erteile Fotobibliothek-Zugriff, wenn du gefragt wirst
2. Wische nach links oder tippe ❌ um Fotos zu überspringen
3. Wische nach rechts oder tippe ✅ um Fotos zu löschen
4. Gelöschte Fotos gehen zu "Kürzlich gelöscht" in Fotos
5. Setze gesehene Fotos über die Toolbar zurück, wenn alle Fotos angesehen wurden

## Installation

1. Klone dieses Repository
2. Öffne `PhotoSwift.xcodeproj` in Xcode
3. Bauen und starte auf einem Gerät oder Simulator

## Datenschutz

- Fotos werden nur mit expliziter Benutzer-Erlaubnis zugegriffen
- Gelöschte Fotos folgen dem iOS-Standardverhalten (gehen zu Kürzlich gelöscht)
- Keine Daten werden außerhalb des Geräts übertragen
