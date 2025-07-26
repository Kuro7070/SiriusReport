//
//  HomeView.swift
//  Sirius Report
//
//  Created by Patrick on 26.07.25.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject private var chatController = ChatController.shared
    @StateObject private var speechController = SpeechController()
    @State private var isRecording = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {        // mehr Abstand zwischen Titel und Kreis
                // Eigener großer Titel
                Text("Sirius Report")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 16)

                // Mikrofon-Button
                Button(action: toggleRecording) {
                    ZStack {
                        Circle()
                            .fill(isRecording ? Color.red : Color.black)
                            .frame(width: 150, height: 150)
                        Image(systemName: "mic.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }
                }
                .disabled(chatController.state == .processing || chatController.state == .generating)
                .padding(.top,32)

                // Status‑Text und einziger Loading‑Indicator
                Text(statusText)
                    .font(.headline)
                if chatController.state == .processing || chatController.state == .generating {
                    ProgressView()
                        .padding(.bottom, 8)
                }

                // Fragenliste (wenn nötig)
                if chatController.state == .waitingForAnswer && !chatController.questions.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(chatController.questions, id: \.self) { q in
                                Text(q)
                                    .padding(6)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(5)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: 200)
                }

                // Live‑Transkription (blaue Box, etwas niedriger)
                if isRecording {
                    ScrollViewReader { proxy in
                        ScrollView(.vertical) {
                            Text(speechController.transcribedText)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding()
                                .id("latestText")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .background(Color.blue)
                        .cornerRadius(8)
                        .frame(maxHeight: 80)  // reduzierte Höhe
                        .padding(.horizontal)
                        .onChange(of: speechController.transcribedText) { _ in
                            withAnimation {
                                proxy.scrollTo("latestText", anchor: .bottom)
                            }
                        }
                    }
                }

                Spacer()
            }
            .padding(.horizontal)
            .navigationBarHidden(true)
            .task { await chatController.loadModel() }
        }
    }

    private var statusText: String {
        switch chatController.state {
        case .waitingForAnswer: return "Beantworte die offenen Fragen"
        case .processing:      return "Analysiere Eingabe …"
        case .generating:      return "Bericht wird erstellt …"
        case .completed:       return "Bericht erstellt"
        default:               return "Tippen um zu sprechen"
        }
    }

    private func toggleRecording() {
        if isRecording {
            speechController.stopRecording()
            isRecording = false
            Task {
                let text = speechController.transcribedText
                if chatController.state == .waitingForAnswer {
                    await chatController.processAnswer(text)
                    chatController.questions.removeAll()
                } else {
                    await chatController.processInitialDescription(text)
                }
            }
        } else {
            speechController.startRecording()
            isRecording = true
            if chatController.state != .waitingForAnswer {
                chatController.state = .recording
            }
        }
    }
}
