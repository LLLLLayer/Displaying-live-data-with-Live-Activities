//
//  VoipLiveActivity.swift
//  Hogsmeade
//
//  Created by yangjie.layer on 2022/9/18.
//

import WidgetKit
import SwiftUI


struct VoipLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: VoipAttributes.self) { context in
            LockScreenVoipView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading, priority: .greatestFiniteMagnitude) {
                    VStack(alignment: .center) {
                        Image(systemName: context.attributes.avatar)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .padding(10)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack {
                        HStack {
                            VoiceView(maxHeight: 40,
                                      speaker:context.state.speaker,
                                      voiceList: [context.state.volume,
                                                  Double.random(in: 0...1),
                                                  Double.random(in: 0...1),
                                                  Double.random(in: 0...1),
                                                  Double.random(in: 0...1)])
                            .padding(30)
                        }
                    }
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack {
                        Text("与 \(context.attributes.name) 通话中")
                            .padding(3)
                        Text(formatter(time:context.state.time))
                            .font(.footnote)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Link(destination: URL(string: "hogsmeade://LiveActivity?action=message")!) {
                            HStack {
                                Image(systemName: "paperplane.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 10)
                                Text("私信")
                                    .font(.footnote)
                            }
                            .padding(8)
                            .background(.green)
                        }
                        Link(destination: URL(string: "hogsmeade://LiveActivity?action=video")!) {
                            HStack {
                                Image(systemName: "video.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 10)
                                Text("视频")
                                    .font(.footnote)
                            }
                            .padding(8)
                            .background(.blue)
                        }
                        Link(destination: URL(string: "hogsmeade://LiveActivity?action=end")!) {
                            HStack {
                                Image(systemName: "phone.down.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 10)
                                Text("结束")
                                    .font(.footnote)
                            }
                            .padding(8)
                            .background(.red)
                        }
                    }
                }
            } compactLeading: {
                Image(systemName: context.attributes.avatar)
            } compactTrailing: {
                VoiceView(maxWidth:10,
                          speaker:context.state.speaker,
                          voiceList: [context.state.volume,
                                      Double.random(in: 0...1),
                                      Double.random(in: 0...1),
                                      Double.random(in: 0...1),
                                      Double.random(in: 0...1)])
                .frame(width:50.0)
            } minimal: {
                Image(systemName: context.attributes.avatar)
            }
        }
    }
    
    func formatter(time: Double) -> String {
        let minutes = Int((time/60).truncatingRemainder(dividingBy: 60))
        let seconds = Int(time.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", minutes, seconds)
    }
}


