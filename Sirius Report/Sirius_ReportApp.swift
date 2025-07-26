//
//  Sirius_ReportApp.swift
//  Sirius Report
//
//  Created by Patrick on 26.07.25.
//

import SwiftUI

@main
struct Sirius_ReportApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}



