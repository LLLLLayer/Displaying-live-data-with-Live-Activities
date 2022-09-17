//
//  ContentView.swift
//  LiveActivities
//
//  Created by yangjie.layer on 2022/9/16.
//

import SwiftUI
import ActivityKit

struct ContentView: View {
    let minutes = 12
    @State var deliveryActivity: Activity<PizzaDeliveryAttributes>? = nil
    var body: some View {
        VStack {
            Button("Order pizza!") {
                if #available(iOS 16.1, *) {
                    let future = Calendar.current.date(byAdding: .minute, value: (minutes), to: Date())!
                    let date = Date.now...future
                    let initialContentState = PizzaDeliveryAttributes.ContentState(driverName: "Layer", deliveryTimer:date)
                    let activityAttributes = PizzaDeliveryAttributes(numberOfPizzas: 3, totalAmount: "$66.66", orderNumber: "12345")
                    do {
                        deliveryActivity = try Activity.request(attributes: activityAttributes, contentState: initialContentState)
                        print("Requested a pizza delivery Live Activity \(String(describing: deliveryActivity?.id ?? "nil")).")
                    } catch (let error) {
                        print("Error requesting pizza delivery Live Activity \(error.localizedDescription).")
                    }
                }
            }
            
            Button("Update!") {
                if #available(iOS 16.1, *) {
                    let future = Calendar.current.date(byAdding: .minute, value: (Int(minutes / 2)), to: Date())!
                    let date = Date.now...future
                    let updatedDeliveryStatus = PizzaDeliveryAttributes.PizzaDeliveryStatus(driverName: "Layer's brother", deliveryTimer: date)
                    let alertConfiguration = AlertConfiguration(title: "Delivery Update", body: "Your pizza order will immediate delivery.", sound: .default)
                    Task {
                        try? await Task.sleep(nanoseconds: 5_000_000_000)
                        await deliveryActivity?.update(using: updatedDeliveryStatus, alertConfiguration: alertConfiguration)
                    }
                }
            }
            
            Button("I do not want it!!") {
                if #available(iOS 16.1, *) {
                    let finalDeliveryStatus = PizzaDeliveryAttributes.PizzaDeliveryStatus(driverName: "Anne Johnson", deliveryTimer: Date.now...Date())
                    Task {
                        try? await Task.sleep(nanoseconds: 5_000_000_000)
                        await deliveryActivity?.end(using:finalDeliveryStatus, dismissalPolicy: .default)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
