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

	@StateObject var savedAircraftData: DataModel

	init() {
		let storage = DataModel(managedObjectContext: persistenceController.container.viewContext)
		self._savedAircraftData = StateObject(wrappedValue: storage)
	  }

    var body: some Scene {
        WindowGroup {
			ContentView(dataModel: savedAircraftData)
        }
    }
}
