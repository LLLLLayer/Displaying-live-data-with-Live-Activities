//
//  Voip.swift
//  Hogsmeade
//
//  Created by yangjie.layer on 2022/9/18.
//

import Foundation
import ActivityKit

enum VoipStatus {
    case ringing
    case calling
    
    mutating func change() {
        self = self == .ringing ? .calling : .ringing
    }
}

class Voip: ObservableObject {
    
    let name: String
    
    let avatar: String
    
    var time: Double = 0
    
    @Published var status: VoipStatus = .ringing {
        didSet {
            time = 0
        }
    }
    
    var activity: Activity<VoipAttributes>? = nil
    
    init(status: VoipStatus, name: String, avatar: String) {
        self.status = status
        self.name = name
        self.avatar = avatar
    }
}

extension Voip {
    func start() {
        status.change()
        let contentState = VoipAttributes.ContentState(speaker: .current, volume: 0.0, time: time)
        let attributes = VoipAttributes(name: name, avatar: avatar)
        do {
            activity = try Activity.request(attributes: attributes, contentState: contentState)
        } catch (_) {
        }
        fetch()
    }
    
    func update(speaker: Speaker, volume: Double, time: Double) {
        let contentState = VoipAttributes.ContentState(speaker: speaker, volume: volume, time: time)
        Task {
            await activity?.update(using: contentState)
        }
    }
    
    func end() {
        status.change()
        let contentState = VoipAttributes.ContentState(speaker: .current, volume: 0.0, time: time)
        Task {
            await activity?.end(using:contentState, dismissalPolicy: .immediate)
        }
    }
}

extension Voip {
    func fetch() {
        Task {
            repeat {
                time += 1
                update(speaker: Speaker(rawValue: Int.random(in: 0...1))!, volume: Double.random(in: 0...1), time: time)
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            } while true
        }
    }
}
