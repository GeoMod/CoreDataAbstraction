//
//  DataModel.swift
//  CoreLogbook
//
//  Created by Daniel O'Leary on 8/26/20.
//

import CoreData
import SwiftUI

class DataModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
	@Published var savedAircraft: [Aircraft] = []
	@AppStorage("FirstAircraft", store: UserDefaults(suiteName: "group.com.ImpulseCoupledDevelopment.CoreLogbook")) var firstAircraft = "first"

	// Managed Object Context
	let savedAircraftController: NSFetchedResultsController<Aircraft>

	init(managedObjectContext: NSManagedObjectContext) {
		var request: NSFetchRequest<Aircraft> {
			let fetched = NSFetchRequest<Aircraft>(entityName: "Aircraft")
			fetched.sortDescriptors = [NSSortDescriptor(keyPath: \Aircraft.hours, ascending: true)]
			return fetched
		}
		savedAircraftController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)

		super.init()

		savedAircraftController.delegate = self

		do {
			try savedAircraftController.performFetch()
			savedAircraft = savedAircraftController.fetchedObjects ?? []
		} catch {
			print("failed to fetch items!")
		}
	}


	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
	  guard let fetchedAircraft = controller.fetchedObjects as? [Aircraft]
		else { return }

	  savedAircraft = fetchedAircraft
	}

	func addAircraft(make: String, hours: Float) {
		let newAircraft = Aircraft(context: savedAircraftController.managedObjectContext)
		newAircraft.make = make
		newAircraft.hours = hours

		setFirstAircraft()

		save()
	}

	func deleteAircraft(offsets: IndexSet) {
		let persistenceController = PersistenceController.shared
		let viewContext = persistenceController.container.viewContext
		withAnimation {
			offsets.map { savedAircraft[$0] }.forEach {
				viewContext.delete($0)
			}
		}

		save()
	}

	private func setFirstAircraft() {
		firstAircraft = savedAircraft[0].make!
	}

	private func save() {
		do {
			try savedAircraftController.managedObjectContext.save()
		} catch {
			print("Error saving to MOC")
		}
	}

}
