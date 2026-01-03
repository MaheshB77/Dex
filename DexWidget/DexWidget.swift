//
//  DexWidget.swift
//  DexWidget
//
//  Created by Mahesh Bansode on 03/01/26.
//

import CoreData
import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    var randomPokemon: Pokemon {
        var results: [Pokemon] = []

        do {
            results = try PersistenceController.shared.container.viewContext
                .fetch(Pokemon.fetchRequest())

        } catch {
            print("Failed to fetch Pokemon: \(error)")
        }
        return results.randomElement() ?? Pokemon()
    }

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry.placeholder
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (SimpleEntry) -> Void
    ) {
        let entry = SimpleEntry.placeholder
        completion(entry)
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<Entry>) -> Void
    ) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for secondOffset in 0..<10 {

            let entryDate = Calendar.current.date(
                byAdding: .second,
                value: secondOffset * 5,
                to: currentDate
            )!

            let entry = SimpleEntry(
                date: entryDate,
                name: randomPokemon.name!,
                types: randomPokemon.types!,
                sprite: randomPokemon.spriteImage
            )
                
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let name: String
    let types: [String]
    let sprite: Image

    static var placeholder: SimpleEntry {
        SimpleEntry(
            date: .now,
            name: "bulbasaur",
            types: ["grass", "poison"],
            sprite: Image(.bulbasaur)
        )
    }

    static var placeholder2: SimpleEntry {
        SimpleEntry(
            date: .now,
            name: "mew",
            types: ["psychic"],
            sprite: Image(.mew)
        )
    }
}

struct DexWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetSize
    var entry: Provider.Entry

    var pokemonImage: some View {
        entry.sprite
            .interpolation(.none)
            .resizable()
            .scaledToFit()
            .shadow(color: .black, radius: 4)
    }

    var typesView: some View {
        HStack {
            ForEach(entry.types, id: \.self) { type in
                Text(type.capitalized)
                    .fontWeight(.semibold)
                    .padding(12)
                    .background(Color(type.capitalized))
                    .clipShape(.capsule)
                    .shadow(radius: 4)
            }
        }
    }

    var body: some View {
        VStack {
            switch widgetSize {
            case .systemMedium:
                HStack {
                    pokemonImage
                        .padding(-16)
                    VStack(alignment: .leading) {
                        Text(entry.name.capitalized)
                            .font(.title2)
                            .fontWeight(.bold)
                        typesView
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            case .systemLarge:
                ZStack(alignment: .topLeading) {
                    pokemonImage

                    Text(entry.name.capitalized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    typesView
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .bottomTrailing
                        )
                }
            default:
                pokemonImage
            }
        }
    }
}

struct DexWidget: Widget {
    let kind: String = "DexWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                DexWidgetEntryView(entry: entry)
                    .containerBackground(
                        Color(entry.types[0].capitalized),
                        for: .widget
                    )
            } else {
                DexWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemSmall) {
    DexWidget()
} timeline: {
    SimpleEntry.placeholder
    SimpleEntry.placeholder2
}

#Preview(as: .systemMedium) {
    DexWidget()
} timeline: {
    SimpleEntry.placeholder
    SimpleEntry.placeholder2
}

#Preview(as: .systemLarge) {
    DexWidget()
} timeline: {
    SimpleEntry.placeholder
    SimpleEntry.placeholder2
}
