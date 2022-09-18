//
//  HogsmeadeWidget.swift
//  HogsmeadeWidget
//
//  Created by yangjie.layer on 2022/9/18.
//

import WidgetKit
import SwiftUI

@main
struct HogsmeadeWidget: WidgetBundle {
    
    @WidgetBundleBuilder
    var body: some Widget {
        ExampleWidget()
        VoipLiveActivity()
    }
}


