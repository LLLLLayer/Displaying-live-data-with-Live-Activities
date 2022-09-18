//
//  VoipView.swift
//  Hogsmeade
//
//  Created by yangjie.layer on 2022/9/18.
//

import SwiftUI

struct VoipView: View {
    @StateObject var voip: Voip
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                PeerUserView(voip: voip)
                    .padding(10)
                Spacer()
                ToolsView()
            }
            Spacer()
            Image(systemName: "person.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 100)
                .padding()
            Spacer()
            FunctionView(voip: voip)
        }
    }
}
