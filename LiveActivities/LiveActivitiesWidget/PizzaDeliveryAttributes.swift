//
//  PizzaDeliveryAttributes.swift
//  LiveActivities
//
//  Created by yangjie.layer on 2022/9/17.
//

import Foundation
import ActivityKit

struct PizzaDeliveryAttributes: ActivityAttributes {
    public typealias PizzaDeliveryStatus = ContentState

    public struct ContentState: Codable, Hashable {
        var driverName: String
        var deliveryTimer: ClosedRange<Date>
    }

    var numberOfPizzas: Int
    var totalAmount: String
    var orderNumber: String
}
