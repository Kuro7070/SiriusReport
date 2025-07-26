//
//  ReportDetailView.swift
//  Sirius Report
//
//  Created by Patrick on 26.07.25.
//

import SwiftUI

struct ReportDetailView: View {
    let report: ReportEntity

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Skalierter Titel
                Text(report.title ?? "Tatortbericht")
                    .font(.title)
                    .bold()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.bottom, 8)

                // Metadaten (Date und CreatedAt)
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

                // Tags
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

                // Berichtstext
                Text(report.content ?? "")
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(report.title ?? "Tatortbericht")
    }
}

extension ReportEntity {
    var tagsArray: [String] {
        (tags ?? "").split(separator: ",").map(String.init)
    }
}
