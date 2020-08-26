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

	// Managed Object Context
	private let savedAircraftController: NSFetchedResultsController<Aircraft>


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
	  guard let todoItems = controller.fetchedObjects as? [Aircraft]
		else { return }

	  savedAircraft = todoItems
	}

	func addAircraft(make: String, hours: Float) {
		let newAircraft = Aircraft(context: savedAircraftController.managedObjectContext)
		newAircraft.make = make
		newAircraft.hours = hours

		save()
	}

	private func save() {
		do {
			try savedAircraftController.managedObjectContext.save()
		} catch {
			print("Error saving to MOC")
		}
	}

	func aircraftPerformFetch() -> NSFetchRequest<Aircraft> {
		let fetchRequest = NSFetchRequest<Aircraft>(entityName: "Aircraft")
		fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Aircraft.hours, ascending: true)]
//		let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: savedAircraftController.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
//
//		do {
//			try controller.performFetch()
//		} catch {
//			fatalError("Failed fetching content items with error: \(error)")
//		}

		return fetchRequest
	}

}
