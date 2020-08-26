//
//  ContentView.swift
//  CoreLogbook
//
//  Created by Daniel O'Leary on 8/25/20.
//

import SwiftUI

struct ContentView: View {
	@ObservedObject var dataModel: DataModel

	@State private var showAddSheet = false
	@State private var aircraftMake = ""
	@State private var hoursFlown = ""

	var body: some View {
		NavigationView {
			List {
				ForEach(dataModel.savedAircraft) { item in
					VStack(alignment: .leading) {
						Text("Aircraft: \(item.make!)")
						Text("Hours: \(numberFormatter.string(for: item.hours)!)")
					}
				}
				.onDelete(perform: dataModel.deleteAircraft)
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
				guard let hours = Float(hoursFlown) else { return }
				dataModel.addAircraft(make: aircraftMake, hours: hours)
				showAddSheet = false
			}, label: {
				Text("Save")
			})
		}
	}
}

private let numberFormatter: NumberFormatter = {
	let formatter = NumberFormatter()
	formatter.maximumFractionDigits = 1
	return formatter
}()


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//		ContentView(dataModel: PersistenceController.preview.container.viewContext)
//			.preferredColorScheme(.dark)
//			.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
