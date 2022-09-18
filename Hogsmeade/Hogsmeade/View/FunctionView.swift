//
//  FunctionView.swift
//  Hogsmeade
//
//  Created by yangjie.layer on 2022/9/18.
//

import SwiftUI

struct FunctionView: View {
    @StateObject var voip: Voip
    var body: some View {
        HStack {
            Group {
                switch voip.status {
                case .ringing:
                    functionView(imageName: "phone.down.fill", text: "接通")
                        .background(.green)
                        .clipShape(Circle())
                case .calling:
                    functionView(imageName: "phone.down.fill", text: "挂断")
                        .background(.red)
                        .clipShape(Circle())
                }
            }
            .onTapGesture {
                withAnimation {
                    switch voip.status {
                    case .calling:
                        voip.end()
                    case .ringing:
                        voip.start()
                    }
                }
            }
            functionView(imageName: "sofa.fill", text: "一起看")
            functionView(imageName: "gamecontroller.fill", text: "一起玩", enable: false)
        }
    }
}

struct functionView: View {
    let imageName: String
    let text: String
    @State var enable: Bool = true
    var body: some View {
        VStack {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
            Text(text)
                .font(.caption)
        }
        .padding(20)
    }
}
