//
//  ReportsView.swift
//  Sirius Report
//
//  Created by Patrick on 26.07.25.
//

import SwiftUI
import CoreData

struct ReportsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ReportEntity.createdAt, ascending: false)],
        animation: .default)
    private var reports: FetchedResults<ReportEntity>

    // Gruppiert nach Erstellungsdatum
    private var groupedReports: [(key: String, items: [ReportEntity])] {
        let calendar = Calendar.current
        let now = Date()
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: now)!

        let dict = Dictionary(grouping: reports) { report -> String in
            guard let ca = report.createdAt else { return "Ohne Datum" }
            if calendar.isDateInToday(ca) { return "Heute" }
            if calendar.isDateInYesterday(ca) { return "Gestern" }
            if calendar.isDate(ca, equalTo: twoDaysAgo, toGranularity: .day) {
                return "Vorgestern"
            }
            let fmt = DateFormatter()
            fmt.dateFormat = "dd.MM.yyyy"
            return fmt.string(from: ca)
        }

        let order = ["Heute", "Gestern", "Vorgestern"]
        var result: [(String, [ReportEntity])] = []
        for key in order {
            if let arr = dict[key] { result.append((key, arr)) }
        }
        let others = dict.keys.filter { !order.contains($0) }
        for key in others.sorted() {
            if let arr = dict[key] { result.append((key, arr)) }
        }
        return result
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(groupedReports, id: \.key) { section in
                    Section(header: Text(section.key)) {
                        ForEach(section.items) { report in
                            NavigationLink(destination: ReportDetailView(report: report)) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(report.title ?? "Tatortbericht")
                                        .font(.headline)

                                    // Zeigt nun das Erstellungsdatum
                                    if let ca = report.createdAt {
                                        Text(DateFormatter.localizedString(
                                            from: ca,
                                            dateStyle: .short,
                                            timeStyle: .short))
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }

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
                                .padding(.vertical, 8)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteReports)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Berichte")
        }
    }

    private func deleteReports(at offsets: IndexSet) {
        offsets.forEach { viewContext.delete(reports[$0]) }
        try? viewContext.save()
    }
}


