import Foundation
import Speech
import AVFoundation

@MainActor
class SpeechController: NSObject, ObservableObject {
    @Published var transcribedText: String = ""
    
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "de-DE"))
    
    private var isAuthorized = false
    private var isSessionActive = false
    
    override init() {
        super.init()
        requestPermissions()
    }
    
    // MARK: - Berechtigungen
    private func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                self.isAuthorized = (status == .authorized)
                if !self.isAuthorized {
                    print("Keine Berechtigung für Spracherkennung.")
                }
            }
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if !granted {
                print("Mikrofon-Zugriff nicht erlaubt.")
            }
        }
    }
    
    // MARK: - Aufnahme starten
    func startRecording() {
        guard !isSessionActive else {
            print("Eine Aufnahme läuft bereits.")
            return
        }
        guard isAuthorized else {
            print("Spracherkennung nicht autorisiert.")
            return
        }
        
        resetSession()
        configureAudioSession()
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            recognitionRequest.append(buffer)
        }
        
        do {
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            print("Fehler beim Starten der AudioEngine: \(error)")
            return
        }
        
        recognitionTask = recognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                self.transcribedText = result.bestTranscription.formattedString
            }
            
            if let error = error {
                print("Speech-Recognition-Error: \(error.localizedDescription)")
                self.handleRecognitionError()
            }
        }
        
        isSessionActive = true
        print("Aufnahme gestartet")
    }
    
    // MARK: - Aufnahme stoppen
    func stopRecording() {
        guard isSessionActive else { return }
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        isSessionActive = false
        print("Aufnahme gestoppt")
    }
    
    // MARK: - Fehlerbehandlung
    private func handleRecognitionError() {
        stopRecording()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.resetSession()
        }
    }
    
    // MARK: - AudioSession
    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Fehler beim Konfigurieren der AudioSession: \(error)")
        }
    }
    
    private func resetSession() {
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        transcribedText = ""
        isSessionActive = false
    }
}
