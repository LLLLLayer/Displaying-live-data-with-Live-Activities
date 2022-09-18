//
//  VoiceView.swift
//  Hogsmeade
//
//  Created by yangjie.layer on 2022/9/18.
//

import SwiftUI

struct VoiceView: View {
    var maxHeight: CGFloat = 20.0
    var maxWidth: CGFloat = 20.0
    var speaker: Speaker = .current
    var voiceList = [0, 0.2, 0.3, 0.4, 0.5]
    var body: some View {
        HStack {
            ForEach(0..<voiceList.count) { index in
                Spacer()
                Rectangle()
                    .frame(width: maxWidth / 3,
                           height: maxHeight * voiceList[index])
                    .cornerRadius(2.0)
                    .foregroundColor(speaker == .current ? .yellow : .green)
            }
            Spacer()
        }
        .frame(width: maxWidth, height: maxHeight)
    }
}

struct VoiceView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceView()
    }
}
