//
//  CoreLogbookApp.swift
//  CoreLogbook
//
//  Created by Daniel O'Leary on 8/25/20.
//

import SwiftUI

@main
struct CoreLogbookApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
