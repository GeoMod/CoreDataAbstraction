//
//  WidgetLogbook.swift
//  WidgetLogbook
//
//  Created by Daniel O'Leary on 8/27/20.
//
import WidgetKit
import SwiftUI

struct SimpleEntry: TimelineEntry {
	let date: Date
	let make: String
	let hours: Float
}

struct Provider: TimelineProvider {
	@AppStorage("FirstAircraft", store: UserDefaults(suiteName: "group.com.ImpulseCoupledDevelopment.CoreLogbook")) var firstAircraft = "names"
	@ObservedObject var dataModel: DataModel

    func placeholder(in context: Context) -> SimpleEntry {
		SimpleEntry(date: Date(), make: "737", hours: 5.5)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
		let entry = SimpleEntry(date: Date(), make: "A320", hours: 2300.2)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()

        for minuteOffset in 0..<2 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
			let entry = SimpleEntry(date: entryDate, make: firstAircraft, hours: 3.3)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}



struct WidgetLogbookEntryView : View {
    var entry: Provider.Entry

    var body: some View {
		VStack {
			Text(entry.date, style: .time)
			Text(entry.make)
			Text("\(entry.hours)")
		}

    }
}

@main
struct WidgetLogbook: Widget {
	//MARK: CoreData
	// This code doesn't work but is active here for reference as a use case
	// for using the custom DataModel
	// reference from: https://www.donnywals.com/fetching-objects-from-core-data-in-a-swiftui-project/
	let persistenceController = PersistenceController.shared

	@StateObject var savedAircraftData: DataModel

	init() {
		let storage = DataModel(managedObjectContext: persistenceController.container.viewContext)
		self._savedAircraftData = StateObject(wrappedValue: storage)
	  }

	//MARK: End CoreData

    let kind: String = "WidgetLogbook"

    var body: some WidgetConfiguration {
		// The dataModel is unused but left in for reference.
		StaticConfiguration(kind: kind, provider: Provider(dataModel: savedAircraftData)) { entry in
            WidgetLogbookEntryView(entry: entry)
        }
        .configurationDisplayName("Core Logbook")
        .description("A Widget buildt using CoreData.")
    }
}

struct WidgetLogbook_Previews: PreviewProvider {
    static var previews: some View {
		WidgetLogbookEntryView(entry: SimpleEntry(date: Date(), make: "SamplePlane", hours: 2.2))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
