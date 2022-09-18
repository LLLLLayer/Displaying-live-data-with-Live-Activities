//
//  ToolsView.swift
//  Hogsmeade
//
//  Created by yangjie.layer on 2022/9/18.
//

import SwiftUI

struct ToolsView: View {
    var body: some View {
        VStack {
            ToolView(imageName: "phone", text: "免提")
            ToolView(imageName: "mic", text: "话筒")
            ToolView(imageName: "video.slash", text: "摄像头", enable: false)
            ToolView(imageName: "mic", text: "翻转", enable: false)
        }
    }
}

struct ToolView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    let imageName: String
    let text: String
    @State var enable: Bool = true
    var body: some View {
        VStack {
            Image(systemName: imageName)
            Text(text)
                .font(.caption)
        }
        .foregroundColor(enable ? (colorScheme == .light ?  .black : .white) : .gray)
        .padding(5)
        .onTapGesture {
            enable.toggle()
        }
    }
}
