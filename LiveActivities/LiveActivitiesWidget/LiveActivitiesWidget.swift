//
//  LiveActivitiesWidget.swift
//  LiveActivitiesWidget
//
//  Created by yangjie.layer on 2022/9/16.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct LiveActivitiesWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.date, style: .time)
    }
}

@main
struct LiveActivitiesWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PizzaDeliveryAttributes.self) { context in
            // Create the view that appears on the Lock Screen and as a
            // banner on the Home Screen of devices that don't support the
            // Dynamic Island.
            // ...
        } dynamicIsland: { context in
            // Create the views that appear in the Dynamic Island.
            DynamicIsland {
                // Create the expanded view.
                DynamicIslandExpandedRegion(.leading) {
                    Label("\(context.attributes.numberOfPizzas) Pizzas", systemImage: "bag")
                        .foregroundColor(.indigo)
                        .font(.title2)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Label {
                        Text(timerInterval: context.state.deliveryTimer, countsDown: true)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 50)
                            .monospacedDigit()
                    } icon: {
                        Image(systemName: "timer")
                            .foregroundColor(.indigo)
                    }
                    .font(.title2)
                }
                
                DynamicIslandExpandedRegion(.center) {
                    Text("\(context.state.driverName) is on their way!")
                        .lineLimit(1)
                        .font(.caption)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    Button {
                        // Deep link into your app.
                    } label: {
                        Label("Call driver", systemImage: "phone")
                    }
                    .foregroundColor(.indigo)
                }
                
            } compactLeading: {
                Label {
                    Text("\(context.attributes.numberOfPizzas) Pizzas")
                } icon: {
                    Image(systemName: "bag")
                        .foregroundColor(.indigo)
                }
                .font(.caption2)
            } compactTrailing: {
                Text(timerInterval: context.state.deliveryTimer, countsDown: true)
                    .multilineTextAlignment(.center)
                    .frame(width: 40)
                    .font(.caption2)
            } minimal: {
                VStack(alignment: .center) {
                    Image(systemName: "timer")
                    Text(timerInterval: context.state.deliveryTimer, countsDown: true)
                        .multilineTextAlignment(.center)
                        .monospacedDigit()
                        .font(.caption2)
                }
            }
            .keylineTint(.cyan)
        }
    }
}

struct LiveActivitiesWidget_Previews: PreviewProvider {
    static var previews: some View {
        LiveActivitiesWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
