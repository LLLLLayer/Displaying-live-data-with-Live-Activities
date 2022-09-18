//
//  PeerUserView.swift
//  Hogsmeade
//
//  Created by yangjie.layer on 2022/9/18.
//

import SwiftUI


struct PeerUserView: View {
    @StateObject var voip: Voip
    var body: some View {
        HStack {
            Image(systemName: voip.avatar)
                .resizable()
                .scaledToFit()
                .frame(width: 60)
                .padding()
            VStack(alignment: .leading) {
                Text(voip.name)
                    .font(.title2)
                Text(voip.status == .ringing ? "未接电话..." : "正在通话中")
                .font(.subheadline)
                .foregroundColor(.gray)
            }
        }
    }
}
