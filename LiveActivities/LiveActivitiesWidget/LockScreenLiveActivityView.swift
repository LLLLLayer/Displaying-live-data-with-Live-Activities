//
//  LockScreenLiveActivityView.swift
//  LiveActivitiesWidgetExtension
//
//  Created by yangjie.layer on 2022/9/17.
//

import WidgetKit
import SwiftUI

struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<PizzaDeliveryAttributes>
    
    var body: some View {
        VStack {
            Spacer()
            Text("\(context.state.driverName) is on their way with your pizza!")
            Spacer()
            HStack {
                Spacer()
                Label {
                    Text("\(context.attributes.numberOfPizzas) Pizzas")
                } icon: {
                    Image(systemName: "bag")
                        .foregroundColor(.indigo)
                }
                .font(.title2)
                Spacer()
                Label {
                    Text(timerInterval: context.state.deliveryTimer, countsDown: true)
                        .multilineTextAlignment(.center)
                        .frame(width: 50)
                        .monospacedDigit()
                } icon: {
                    Image(systemName: "timer")
                        .foregroundColor(.indigo)
                }
                .font(.title2)
                Spacer()
            }
            Spacer()
        }
        .activitySystemActionForegroundColor(.indigo)
        .activityBackgroundTint(.cyan)
    }
}

//struct LockScreenLiveActivityView_Previews: PreviewProvider {
//    static var previews: some View {
//        LockScreenLiveActivityView()
//    }
//}
