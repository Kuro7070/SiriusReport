//
//  PersistenceController.swift
//  Sirius Report
//
//  Created by Patrick on 26.07.25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ReportsModel")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data store failed: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true

        // Seed Dummy‑Daten, falls leer
        let context = container.viewContext
        let fetch: NSFetchRequest<ReportEntity> = ReportEntity.fetchRequest()
        if (try? context.count(for: fetch)) == 0 {
            seedDummyReports(in: context)
        }
    }

    private func seedDummyReports(in context: NSManagedObjectContext) {
        func addReport(
            title: String,
            date: Date?,
            location: String,
            officer: String,
            tags: String,
            content: String,
            createdAt: Date
        ) {
            let r = ReportEntity(context: context)
            r.id         = UUID()
            r.title      = title
            r.date       = date
            r.location   = location
            r.officer    = officer
            r.tags       = tags
            r.content    = content
            r.createdAt  = createdAt
        }

        let now = Date()
        let cal = Calendar.current
        let yesterday   = cal.date(byAdding: .day, value: -1, to: now)!
        let twoDaysAgo  = cal.date(byAdding: .day, value: -2, to: now)!

        addReport(
            title: "Einbruch in Wohnhaus",
            date: now,
            location: "Musterstadt",
            officer: "Mustermann",
            tags: "Einbruch,Spuren,Zeuge",
            content:
            """
            Beschreibung des Geschehens:
            Gegen 02:15 Uhr wurde eine eingeschlagene Fensterscheibe im Erdgeschoss festgestellt. Ein unbekannter Täter gelangte so in das Haus.

            Zustand und Schäden:
            Die Fensterscheibe war vollständig zerstört, Fensterrahmen und Rollladen beschädigt. Wertgegenstände im Innenbereich wurden durchsucht.

            Beteiligte Personen:
            - Geschädigter Hausbewohner (keine Verletzungen)
            - Zeuge: Anwohner berichtet laute Geräusche

            Zusätzliche Informationen:
            Tatverdächtiger flüchtig, Spurensicherung am Tatort durchgeführt.
            """,
            createdAt: now
        )

        addReport(
            title: "Verkehrsunfall Kreuzung",
            date: yesterday,
            location: "Dorfplatz",
            officer: "Müller",
            tags: "Unfall,Kreuzung,Beteiligte",
            content:
            """
            Beschreibung des Geschehens:
            Zwei PKW kollidierten um 17:40 Uhr an der Ampelkreuzung. Fahrzeug A fuhr bei Grün, Fahrzeug B stieß im abknickenden Bereich in die Seite.

            Zustand und Schäden:
            Fahrzeug A vordere Stoßstange gebrochen, Fahrzeug B Seitentür stark verbeult. Ölspur auf Fahrbahn.

            Beteiligte Personen:
            - Fahrer von Fahrzeug A: leicht verletzt, Rettungswagen vor Ort
            - Fahrer von Fahrzeug B: unverletzt

            Zusätzliche Informationen:
            Ampelphasen sind dokumentiert, Zeugen befragt.
            """,
            createdAt: yesterday
        )

        addReport(
            title: "Streit in Mehrfamilienhaus",
            date: twoDaysAgo,
            location: "Hauptstraße",
            officer: "Schneider",
            tags: "Streit,Mehrfamilienhaus,Lärm",
            content:
            """
            Beschreibung des Geschehens:
            Zwischen Nachbarn eskalierte verbal ausgetragener Streit um Lärmbelästigung. Gegen 22:30 Uhr kam es zu lautstarken Beleidigungen.

            Zustand und Schäden:
            Keine physischen Schäden, Fenster und Türen unversehrt.

            Beteiligte Personen:
            - Nachbar A (lautstark)
            - Nachbar B (reagierte provozierend)

            Zusätzliche Informationen:
            Parteien beruhigt, keine weiteren Maßnahmen.
            """,
            createdAt: twoDaysAgo
        )

        do {
            try context.save()
        } catch {
            print("Fehler beim Seed-Speichern: \(error)")
        }
    }
}
