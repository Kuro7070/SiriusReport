# Sirius Report – KI-basierte Tatortberichterstattung

**Abgabe für das Modul „Künstliche Intelligenz“ bei Prof. Dr. Thomas Clemen, HAW Hamburg**  
**Erstellt von Patrick Zilke – Sommersemester 2025**

---

## 📌 Projektbeschreibung

**Sirius Report** ist eine Swift-basierte iOS-App (Prototyp) zur automatisierten Erstellung polizeilicher Tatortberichte. Die Anwendung kombiniert **Spracherkennung** mit einem lokal eingebundenen **KI-Modell** zur Analyse, Rückfragegenerierung und finalen Berichtserstellung, in nur einem Gesprächsdurchlauf.

Zielgruppe sind Polizeikräfte und Ermittler, die ihre Berichterstattung effizient und strukturiert dokumentieren möchten, insbesondere in zeitkritischen oder mobilen Einsätzen.

> 📁 Der zugehörige **Businessplan** sowie der **Finanzplan** befinden sich im Verzeichnis `Businessplan/`.

---

## 📁 Inhaltsverzeichnis

1. [Projektstruktur](#projektstruktur)
2. [Installation](#installation)
3. [Nutzung](#nutzung)
4. [Technischer Überblick](#technischer-überblick)
5. [Beispieltexte](#beispieltexte)
6. [Projektabgabe](#projektabgabe)

---

## 🧱 Projektstruktur

| Komponente                | Beschreibung |
|--------------------------|--------------|
| **HomeView.swift**       | Startansicht mit Live-Transkription und Mikrofonsteuerung |
| **SpeechController.swift** | Aufnahme & Transkription via `SFSpeechRecognizer`, `AVAudioEngine` |
| **LLMController.swift**  | Anbindung an lokales LLM (`gemma-2b`) via Kuzco – Rückfragen & Bericht |
| **ReportController.swift** | Core Data: Speichern und Löschen von Berichten |
| **PersistenceController.swift** | Datenbankinitialisierung |
| **ReportsView.swift**    | Übersicht gespeicherter Berichte |
| **ReportDetailView.swift** | Detailanzeige einzelner Berichte |

---

## 🚀 Installation

1. **Projekt in Xcode öffnen**  
   Öffne die `.xcodeproj`-Datei mit Xcode (ab Version 15 empfohlen)

2. **Frameworks prüfen**  
   - **Kuzco-Framework** zur LLM-Anbindung
   - **Speech** und **CoreLocation** sind eingebunden
   - Falls nötig: Cache leeren, Abhängigkeiten neu einfügen

3. **Auf iOS-Gerät laden**  
   App auf ein physisches Gerät deployen (Mikrofon- und Standortzugriff erforderlich)

---

## 🎙️ Nutzung

1. **App starten**  
   Mikrofon-Button aktivieren, Live-Transkription beginnt

2. **Tatortbeschreibung einsprechen**  
   Die App erkennt den Text und zeigt Rückfragen bei fehlenden Details

3. **Fragen beantworten**  
   Eine zusätzliche Aufnahmerunde genügt, danach wird der Bericht erstellt

4. **Bericht speichern und verwalten**  
   Alle erstellten Berichte werden in einer Liste chronologisch gespeichert und können dort eingesehen oder gelöscht werden

---

## ⚙️ Technischer Überblick

| Technologie | Einsatzgebiet |
|-------------|----------------|
| **SwiftUI** | Benutzeroberfläche (Views, Navigation) |
| **Core Data** | Speicherung der Berichte in SQLite |
| **Speech Framework** | Live-Spracherkennung auf Deutsch |
| **Kuzco + LLM (`gemma-2b`)** | Analyse & Berichtgenerierung lokal auf dem Gerät |
| **CoreLocation** | Erfassung des Einsatzortes |

---

## 📝 Beispieltexte

Die folgenden Beispieltexte können vom Benutzer eingesprochen werden. Sie wurden so formuliert, wie Polizeibeamte Berichte typischerweise mündlich schildern:

---

### 📄 Beispiel 1 – Einbruchsdiebstahl

```
Am 23.07.2025 gegen 22:00 Uhr wurde ich zur Musterstraße 12 gerufen. Vor Ort stellte ich eine eingeschlagene Fensterscheibe am rückwärtigen Lagerraum fest. Im Inneren lagen Glasscherben auf dem Boden, Regale waren umgeworfen, und mehrere Werkzeuge fehlten augenscheinlich.

Ein anwesender Zeuge, Herr M., gab an, zur Tatzeit verdächtige Geräusche gehört zu haben. Beim Nachsehen habe er eine dunkel gekleidete Person mit Kapuze beobachtet, die sich zügig vom Tatort entfernte. Die Person konnte nicht näher beschrieben werden.

Ich sicherte den Bereich, informierte die Spurensicherung und nahm eine Anzeige wegen Einbruchsdiebstahls auf.´´´

```
Am 15.06.2025 gegen 01:15 Uhr wurde ich zur Reeperbahn 136 gerufen. Vor Ort traf ich auf eine männliche Person (28 Jahre), die Gesichtsverletzungen aufwies. Nach eigenen Angaben sei es zuvor zu einem verbalen Streit mit einem unbekannten Mann gekommen. Im weiteren Verlauf habe der Unbekannte mehrfach auf ihn eingeschlagen und sei anschließend in Richtung Hein-Hoyer-Straße geflüchtet.

Mehrere anwesende Passanten bestätigten, eine körperliche Auseinandersetzung beobachtet zu haben. Eine detaillierte Täterbeschreibung konnte jedoch nicht gegeben werden.

Der Verletzte wurde vor Ort medizinisch erstversorgt. Eine Nahbereichsfahndung verlief negativ. Die Ermittlungen wegen gefährlicher Körperverletzung wurden eingeleitet.´´
