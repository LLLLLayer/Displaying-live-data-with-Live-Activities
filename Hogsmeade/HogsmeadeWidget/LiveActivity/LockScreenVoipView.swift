//
//  LockScreenVoipView.swift
//  Hogsmeade
//
//  Created by yangjie.layer on 2022/9/18.
//

import WidgetKit
import SwiftUI

struct LockScreenVoipView: View {
    let context: ActivityViewContext<VoipAttributes>
    
    var body: some View {
        HStack {
            Image(systemName: context.attributes.avatar)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .padding(5)
            VStack {
                Text("与 \(context.attributes.name) 通话中")
                    .padding(3)
                VoiceView(maxWidth:10,
                          speaker:context.state.speaker,
                          voiceList: [context.state.volume,
                                      Double.random(in: 0...1),
                                      Double.random(in: 0...1),
                                      Double.random(in: 0...1),
                                      Double.random(in: 0...1)])
                .frame(width:50.0)
            }
        }
        .activitySystemActionForegroundColor(.indigo)
        .activityBackgroundTint(.cyan)
    }
}
