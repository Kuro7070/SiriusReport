//
//  ReportController.swift
//  Sirius Report
//
//  Created by Patrick on 26.07.25.
//

import Foundation
import CoreData

class ReportController: ObservableObject {
    static let shared = ReportController()
    private let viewContext = PersistenceController.shared.container.viewContext

    /// Speichert Bericht inkl. createdAt
    func saveReport(
        title: String,
        content: String,
        rawText: String,
        location: String,
        date: Date?,
        officer: String,
        tags: [String]
    ) {
        let report = ReportEntity(context: viewContext)
        report.id         = UUID()
        report.title      = title
        report.content    = content
        report.rawText    = rawText
        report.location   = location
        report.date       = date
        report.officer    = officer
        report.tags       = tags.joined(separator: ",")
        report.createdAt  = Date()             // NEU: Erstellungsdatum

        do {
            try viewContext.save()
        } catch {
            print("❌ Fehler beim Speichern: \(error)")
        }
    }

    func deleteReport(_ report: ReportEntity) {
        viewContext.delete(report)
        do {
            try viewContext.save()
        } catch {
            print("❌ Fehler beim Löschen: \(error)")
        }
    }
}
