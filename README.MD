
# Sirius Report

Sirius Report ist eine iOS-App zur automatisierten Erstellung von polizeilichen Tatortberichten basierend auf Spracherkennung und KI-gestützter Textanalyse. Die App erfasst eine mündliche Beschreibung, analysiert diese, stellt gezielte Rückfragen bei fehlenden Details und generiert nach einer einzigen Fragerunde einen vollständigen Bericht.

## Inhaltsverzeichnis

1. [Funktionen](#funktionen)
2. [Projektaufbau](#projektaufbau)
3. [Installation](#installation)
4. [Nutzung](#nutzung)
5. [Technische Details](#technische-details)

---

## Funktionen

- **Spracherfassung**
  Aufnahme und Echtzeit-Transkription über das Apple Speech Framework.
  
- **Analyse und Rückfragen**
  Automatische Erkennung von Informationslücken und Generierung relevanter Fragen durch ein lokales KI-Modell (LLM).
  
- **Einzige Fragerunde**
  Der Nutzer beantwortet alle offenen Fragen, bevor der Bericht erstellt wird.
  
- **Automatisierte Berichtserstellung**
  Erstellung eines vollständigen polizeilichen Berichts mit Titel, Ort, Datum, beteiligten Personen und Schäden.
  
- **Berichtsverwaltung**
  Speicherung und Verwaltung aller erstellten Berichte über Core Data, mit Detail- und Listenansichten.

---

## Projektaufbau

Die wichtigsten Komponenten sind:

- **HomeView.swift**
  Startbildschirm mit Mikrofonsteuerung, Live-Transkription und Anzeige von Rückfragen.
  
- **SpeechController.swift**
  Steuerung der Audioaufnahme und Spracherkennung (SFSpeechRecognizer, AVAudioEngine).
  
- **LLMController.swift (ChatController)**
  Bindet das LLM über Kuzco ein, analysiert Texteingaben, formuliert Rückfragen und generiert Berichte. (Kleines LLM-Modell gemma-2-2b-it.q4_k_m.gguf)
  
- **ReportController.swift**
  Verwaltung der Core-Data-Einträge (Speichern und Löschen von Berichten).
  
- **PersistenceController.swift**
  Initialisierung der Core-Data-Umgebung und Anlage von Testdaten.
  
- **GPSController.swift**
  Erfassung des Standorts über CLLocationManager.
  
- **ReportsView.swift**
  Übersichtsliste aller gespeicherten Berichte, gruppiert nach Datum.
  
- **ReportDetailView.swift**
  Anzeige der Detailinformationen eines Berichts.

---

## Installation

1. **Xcode-Projekt öffnen**
   Das Projekt im Xcode öffnen.

2. **Abhängigkeiten**
   Das Kuzco-Framework sowie die Speech- und CoreLocation-Frameworks sind bereits integriert.

3. **Starten**
    Laden Sie die App auf Ihr IOS-Gerät und starten Sie die Aufnahme.

---

## Nutzung

1. **Aufnahme starten**
   Die App öffnen und den Mikrofon-Button drücken. Der Status zeigt „Tippen um zu sprechen“.
   
2. **Tatortbeschreibung einsprechen**
   Die Live-Transkription erscheint in Echtzeit.
   
3. **Fragen beantworten**
   Falls Rückfragen angezeigt werden, diese durch eine weitere Aufnahme beantworten.
   
4. **Bericht erstellen**
   Nach Abschluss der Antworten erstellt die App automatisch einen Bericht.
   
5. **Berichte verwalten**
   In der Berichte-Ansicht können alle gespeicherten Berichte angesehen oder gelöscht werden.

---

## Technische Details

- **Core Data**
  Speicherung aller Berichte in einer lokalen SQLite-Datenbank.
  
- **Speech Framework**
  Spracherkennung und Transkription in deutscher Sprache über `SFSpeechRecognizer`.
  
- **Kuzco LLM**
  Anbindung an ein lokales LLM (`gemma-2b`) zur Texterstellung und Fragegenerierung.
  
- **SwiftUI**
  Moderne Benutzeroberfläche mit Navigation, Listen und Detailansichten.
  
- **Location Services**
  Nutzung von `CLLocationManager` zur Erfassung des aktuellen Standorts.

---

© 2025 Sirius Report. Alle Rechte vorbehalten.

---

## Beispiel für eine Tatortbeschreibung

Um den Einstieg zu erleichtern, enthält die App folgenden Beispieltext, der vom Nutzer abgelesen werden kann, falls keine eigene Formulierung vorliegt:

```
Gegen 22 Uhr bemerkte ich verdächtige Geräusche im Hinterhof. Beim Nachsehen entdeckte ich eine eingeschlagene Fensterscheibe am Lagerraum.
Im Inneren waren Regale umgeworfen, mehrere Werkzeuge fehlten und es lagen Glasscherben auf dem Boden.
Ein Zeuge berichtete, einen Mann mit dunkler Jacke und Kapuze weglaufen gesehen zu haben.
Die Polizei wurde informiert und der Tatort abgesperrt.
```

Dieser Text dient lediglich als Beispiel, damit Nutzer nicht selbst einen kompletten Bericht erfinden müssen. Er kann beliebig angepasst oder als Vorlage verwendet werden.
