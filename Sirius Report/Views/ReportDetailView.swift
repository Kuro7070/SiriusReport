import SwiftUI
import SwiftUI

struct ReportDetailView: View {
    let report: ReportEntity
    @StateObject private var viewModel = ReportQuestionViewModel()
    @FocusState private var isInputFocused: Bool
    @State private var showAnswerSheet: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(report.title ?? "Tatortbericht")
                        .font(.title)
                        .bold()
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .padding(.bottom, 8)

                    metaSection()
                    tagView()
                    reportBody()
                }
                .padding()
                .onTapGesture {
                    isInputFocused = false // Tastatur ausblenden
                }
            }

            Divider()

            // InputField mit Button
            HStack {
                TextField("Frage zur KI stellen...", text: $viewModel.question)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($isInputFocused)
                    .disabled(viewModel.isLoading)

                Button {
                    Task {
                        await viewModel.sendQuestion(about: report)
                        showAnswerSheet = true
                        isInputFocused = false
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Image(systemName: "paperplane.fill")
                    }
                }
                .disabled(viewModel.question.isEmpty || viewModel.isLoading)
            }
            .padding()
            .background(Color(UIColor.systemBackground))
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(report.title ?? "Tatortbericht")
        .sheet(isPresented: $showAnswerSheet) {
            AnswerSheetView(answer: viewModel.response ?? "Keine Antwort erhalten.")
        }
    }

    @ViewBuilder
    private func metaSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if let d = report.date {
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(6)
                    Text(DateFormatter.localizedString(
                        from: d,
                        dateStyle: .short,
                        timeStyle: .short))
                        .font(.subheadline)
                }
            }

            if let loc = report.location, !loc.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "mappin.and.ellipse")
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(6)
                    Text(loc)
                        .font(.subheadline)
                }
            }

            if let officer = report.officer, !officer.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "person.crop.circle")
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(6)
                    Text(officer)
                        .font(.subheadline)
                }
            }
        }
    }

    @ViewBuilder
    private func tagView() -> some View {
        HStack {
            ForEach(report.tagsArray, id: \.self) { tag in
                Text(tag)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
            }
        }
    }

    @ViewBuilder
    private func reportBody() -> some View {
        Text(report.content ?? "")
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
    }
}

struct AnswerSheetView: View {
    let answer: String

    var body: some View {
        NavigationView {
            ScrollView {
                Text(answer)
                    .padding()
            }
            .navigationTitle("KI-Antwort")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


extension ReportEntity {
    var tagsArray: [String] {
        (tags ?? "").split(separator: ",").map(String.init)
    }
}



import Foundation

@MainActor
class ReportQuestionViewModel: ObservableObject {
    @Published var question: String = ""
    @Published var response: String?
    @Published var isLoading: Bool = false

    func sendQuestion(about report: ReportEntity) async {
        guard !question.isEmpty else { return }

        isLoading = true
        response = nil

        let reportText = report.content ?? ""
        let prompt = """
        Hier ist der Tatortbericht:
        "\(reportText)"

        Frage: "\(question)"
        Antworte sachlich und kurz.
        """

        let result = await ChatController.shared.askAboutReport(prompt: prompt)
        response = result ?? "❌ Keine Antwort erhalten."
        isLoading = false
    }
}
