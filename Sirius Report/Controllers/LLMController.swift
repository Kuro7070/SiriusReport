//
//  LLM-Controller.swift
//  Sirius Report
//
//  Created by Patrick on 26.07.25.
//

import Foundation
import Kuzco

@MainActor
public class ChatController: ObservableObject {
    public static let shared = ChatController()
    private init() {}

    private let kuzco = Kuzco.shared
    private var instance: LlamaInstance?

    @Published var state: ChatState = .idle
    @Published var collectedText: String = ""
    @Published var isModelReady: Bool = false
    @Published var loadingStage: String = "Idle"
    @Published var questions: [String] = []

    // MARK: – Modell laden
    public func loadModel() async {
        guard let modelURL = Bundle.main.url(forResource: "gemma-2b", withExtension: "gguf") else {
            print("Modell-Datei nicht gefunden!")
            return
        }
        let profile = ModelProfile(id: "gemma-model", sourcePath: modelURL.path)
        let (inst, loadStream) = await kuzco.instance(for: profile)
        self.instance = inst

        for await progress in loadStream {
            loadingStage = "\(progress.stage)"
            if progress.stage == .ready {
                isModelReady = true
                print("Modell geladen und einsatzbereit!")
            }
        }
    }

    // MARK: – String‑Cleanup
    func clean(_ s: String) -> String {
        return s
            .replacingOccurrences(of: "(\\*{1,2}|#{1,6}|~{2}|`{1,3})",
                                  with: "",
                                  options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: – Erste Situationsbeschreibung verarbeiten
    public func processInitialDescription(_ text: String) async {
        collectedText = text
        await analyzeForQuestions()
    }

    // MARK: – Fragenanalyse
    private func analyzeForQuestions() async {
        guard let instance else { return }
        state = .processing

        let prompt = """
        Analysiere den folgenden Bericht und stelle bis zu 5 gezielte Fragen zu fehlenden oder unklaren Informationen:

        „\(collectedText)“

        Nur wenn wichtige Infos fehlen (z. B. Ort, Zeit, Beteiligte, Ablauf, Schäden, Maßnahmen), formuliere kurze, sachliche Fragen – eine pro Zeile. 
        Wenn alles klar und vollständig ist, antworte nur mit: Bericht vollständig.

        """

        var response = ""
        do {
            let stream = await instance.generate(dialogue: [Turn(role: .system, text: prompt)])
            for try await chunk in stream {
                response += chunk
            }
        } catch {
            print("Fehler beim Generieren der Fragen: \(error)")
            state = .idle
            return
        }

        print("repsonse - \(response)")
        if response.lowercased().contains("bericht vollständig") {
            state = .generating
            await generateReport()
        } else {
            questions = response
                .split(separator: "\n")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            state = .waitingForAnswer
        }
    }

    // MARK: – Antwort auf offene Fragen
    public func processAnswer(_ text: String) async {
        collectedText += " " + text
        state = .generating
        await generateReport()
    }

    // MARK: – Bericht generieren
    private func generateReport() async {
        guard let instance else { return }
        state = .generating

        let reportPrompt = """
        Erstelle aus diesen Informationen einen vollständigen, fachlich korrekten polizeilichen Tatortbericht.
        Verwende keinerlei Markup (keine Sternchen, Nummerierungen, Überschriften o. Ä.).
        Gib den Header exakt so aus (jeweils eine Zeile):
        TITEL: <Kurz in 5 Wörtern>
        DATUM: <dd.MM.yyyy, HH:mm> oder [Nicht bekannt]
        ORT: <Ort> oder [Nicht bekannt]
        BEAMTER: Beamter Mustermann

        Danach Fließtext in Absätzen ohne Listen, mit folgenden Abschnitten:
        Beschreibung des Geschehens
        Zustand und Schäden
        Beteiligte Personen
        Zusätzliche Informationen
        """

        var raw = ""
        do {
            let stream = await instance.generate(dialogue: [Turn(role: .system, text: reportPrompt)])
            for try await chunk in stream { raw += chunk }
        } catch {
            print("Fehler beim Generieren des Berichts: \(error)")
            state = .idle
            return
        }

        await finalizeReport(raw)
    }

    // MARK: – Header parsen, Metadaten extrahieren & speichern
    private func finalizeReport(_ raw: String) async {
        let cleanedRaw = clean(raw)
        let lines = cleanedRaw.components(separatedBy: "\n")
        let header = Array(lines.prefix(4))
        let body  = lines.dropFirst(4).joined(separator: "\n")

        let title = header.first(where: { $0.hasPrefix("TITEL:") })?
            .replacingOccurrences(of: "TITEL: ", with: "") ?? "Tatortbericht"

        let officer = header.first(where: { $0.hasPrefix("BEAMTER:") })?
            .replacingOccurrences(of: "BEAMTER: ", with: "") ?? "Beamter Mustermann"

        let date     = await extractDate(from: collectedText)
        let location = await extractLocation(from: collectedText)
        let keywords = await extractKeywords3(from: collectedText)

        ReportController.shared.saveReport(
            title:    title,
            content:  body,
            rawText:  collectedText,
            location: location,
            date:     date,
            officer:  officer,
            tags:     keywords
        )
        state = .completed
    }

    // MARK: – Hilfs‑Prompt
    private func runSingleLinePrompt(_ prompt: String) async -> String? {
        guard let instance else { return nil }
        var resp = ""
        do {
            let stream = await instance.generate(dialogue: [Turn(role: .system, text: prompt)])
            for try await chunk in stream { resp += chunk }
            return clean(resp)
        } catch {
            print("LLM Prompt Fehler: \(error)")
            return nil
        }
    }

    // MARK: – Metadaten‑Extraktion
    public func extractDate(from text: String) async -> Date? {
        let prompt = """
        Im Text: "\(text)"
        Finde Datum und Uhrzeit des Vorfalls und gib es im ISO‑8601‑Format zurück (z. B. 2025-07-27T15:04:00Z). Wenn nicht vorhanden, antworte mit [Nicht bekannt].
        """
        guard let line = await runSingleLinePrompt(prompt),
              !line.contains("[Nicht bekannt]"),
              let date = ISO8601DateFormatter().date(from: line)
        else { return nil }
        return date
    }

    public func extractLocation(from text: String) async -> String {
        let prompt = """
        Im Text: "\(text)"
        Wo fand der Vorfall statt? Gib nur den Ort zurück oder [Nicht bekannt].
        """
        return (await runSingleLinePrompt(prompt)) ?? "[Nicht bekannt]"
    }
    
    public func askAboutReport(prompt: String) async -> String? {
        guard let instance else { return nil }
        var response = ""
        do {
            let stream = await instance.generate(dialogue: [Turn(role: .system, text: prompt)])
            for try await chunk in stream {
                response += chunk
            }
            return clean(response)
        } catch {
            print("Fehler bei Frage an LLM: \(error)")
            return nil
        }
    }


    public func extractKeywords3(from text: String) async -> [String] {
        let prompt = """
        Nenne drei prägnante Keywords, die die Situation dieses Textes zusammenfassen:
        "\(text)"
        Antworte als kommagetrennte Liste, ohne weitere Zusätze.
        """
        guard let line = await runSingleLinePrompt(prompt) else { return [] }
        return line
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    // MARK: – Reset
    public func reset() {
        state = .idle
        collectedText = ""
        questions = []
    }
}
