//
//  WidgetLogbook.swift
//  WidgetLogbook
//
//  Created by Daniel O'Leary on 8/27/20.
//
import CoreData
import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
//	@ObservedObject var dataModel: DataModel

	var moc: NSManagedObjectContext

	init(dataModel: NSManagedObjectContext) {
			self.moc = dataModel
	}

    func placeholder(in context: Context) -> SimpleEntry {
		SimpleEntry(date: Date(), aircraftType: "737", hours: 5.5)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
		let entry = SimpleEntry(date: Date(), aircraftType: "A320", hours: 2300.2)
        completion(entry)
    }

	func getFirstAircraft() -> String {
		var aircraftType = [String]()
//		dataModel.savedAircraft.forEach {
//			aircraftType.append($0.make!)
//		}
		let request = NSFetchRequest<Aircraft>(entityName: "Aircraft")
		do {
			print("Hello")
			let fetchedAircraft = try moc.fetch(request)
			print("Fetch \(fetchedAircraft.count)")

			fetchedAircraft.forEach { aircraft in
				print("Fore each")
				aircraftType.append(aircraft.make!)
			}
		} catch {
			print("Caught error")
		}
		guard let first = aircraftType.first else { return "None"}
		return first
	}

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for minuteOffset in 0 ..< 2 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
			let entry = SimpleEntry(date: entryDate, aircraftType: getFirstAircraft(), hours: 3.3)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
	let aircraftType: String
	let hours: Float
}

struct WidgetLogbookEntryView : View {
    var entry: Provider.Entry

    var body: some View {
		VStack {
			Text(entry.date, style: .time)
			Text(entry.aircraftType)
			Text("\(entry.hours)")
		}

    }
}

@main
struct WidgetLogbook: Widget {
	let persistenceController = PersistenceController.shared

	@StateObject var savedAircraftData: DataModel

	init() {
		let storage = DataModel(managedObjectContext: persistenceController.container.viewContext)
		self._savedAircraftData = StateObject(wrappedValue: storage)
	  }

    let kind: String = "WidgetLogbook"

    var body: some WidgetConfiguration {
		StaticConfiguration(kind: kind, provider: Provider(dataModel: persistenceController.container.viewContext)) { entry in
            WidgetLogbookEntryView(entry: entry)
        }
        .configurationDisplayName("Core Logbook")
        .description("A Widget buildt using CoreData.")
    }
}

struct WidgetLogbook_Previews: PreviewProvider {
    static var previews: some View {
		WidgetLogbookEntryView(entry: SimpleEntry(date: Date(), aircraftType: "737", hours: 2.2))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
