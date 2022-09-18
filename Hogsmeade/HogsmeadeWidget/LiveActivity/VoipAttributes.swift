//
//  VoipAttributes.swift
//  Hogsmeade
//
//  Created by yangjie.layer on 2022/9/18.
//

import Foundation
import ActivityKit

enum Speaker: Int, Codable {
    case current
    case others
}

struct VoipAttributes: ActivityAttributes {
    
    public struct ContentState: Codable, Hashable {
        var speaker: Speaker
        var volume: Double
        var time: Double
    }

    var name: String
    var avatar: String
}
