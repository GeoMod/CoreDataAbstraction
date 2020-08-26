//
//  ContentView.swift
//  CoreLogbook
//
//  Created by Daniel O'Leary on 8/25/20.
//

import SwiftUI

struct ContentView: View {
	@Environment(\.managedObjectContext) private var viewContext
	@FetchRequest(entity: Aircraft.entity(), sortDescriptors: []) var storedAircraft: FetchedResults<Aircraft>

	@State private var showAddSheet = false
	@State private var aircraftMake = ""
	@State private var hoursFlown = ""

	var body: some View {
		NavigationView {
			List {
				ForEach(storedAircraft) { item in
					VStack(alignment: .leading) {
						Text("Aircraft: \(item.make!)")
						Text("Hours: \(numberFormatter.string(for: item.hours)!)")
					}
				}
				.onDelete(perform: deleteItems)
			}
			.navigationTitle("✈️ Logbook")
			.navigationBarItems(leading: Button(action: {showAddSheet.toggle()}, label: {
				Label("Add Aircraft", systemImage: "airplane")
					 }), trailing: EditButton())
			.sheet(isPresented: $showAddSheet, content: {
				addAircraftView
			})
		}

	}

	private var addAircraftView: some View {
		Form {
			TextField("Aircraft make", text: $aircraftMake)
			TextField("Hours flown", text: $hoursFlown)
				.keyboardType(.decimalPad)
			Button(action: {
				let newAircraft = Aircraft(context: viewContext)
				newAircraft.make = aircraftMake
				// A Float because that's how it saved in CoreData
				guard let hours = Float(hoursFlown) else { return }
				newAircraft.hours = hours
				saveAircraft()
			}, label: {
				Text("Save")
			})
		}
	}

    private func saveAircraft() {
        withAnimation {
            do {
                try viewContext.save()
				showAddSheet = false
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { storedAircraft[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let numberFormatter: NumberFormatter = {
	let formatter = NumberFormatter()
	formatter.maximumFractionDigits = 1
	return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
		ContentView()
			.preferredColorScheme(.dark)
			.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
