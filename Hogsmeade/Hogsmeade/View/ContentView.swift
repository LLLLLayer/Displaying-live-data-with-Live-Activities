//
//  ContentView.swift
//  Hogsmeade
//
//  Created by yangjie.layer on 2022/9/18.
//

import SwiftUI

struct ContentView: View {
    @State var toast: String? = nil
    @StateObject var voip = Voip(
        status: .ringing,
        name: "Layer",
        avatar: "person.circle")
    
    var body: some View {
        ZStack {
            VoipView(voip: voip)
            if let _ = toast?.count {
                Text(toast!)
                    .padding(10)
                    .background(.black)
                    .foregroundColor(.gray)
                    .cornerRadius(5.0)
            }
        }
        .padding()
        .onOpenURL { url in
            withAnimation {
                toast = getToast(url: url.absoluteString)
            }
            Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                withAnimation {
                    toast = nil
                }
            }
        }
    }
    
    func getToast(url: String) -> String? {
        let params = getQueryItems(url)
        let action = params["action"]
        if action == "message" {
            return "假装用户打开了私信"
        } else if action == "video" {
            return "假装用户打开了视频"
        } else if action == "end" {
            voip.end()
            return "通话已结束"
        }
        return nil
    }
    
    func getQueryItems(_ urlString: String) -> [String : String] {
        var queryItems: [String : String] = [:]
        let components: NSURLComponents? = getURLComonents(urlString)
        for item in components?.queryItems ?? [] {
            queryItems[item.name] = item.value?.removingPercentEncoding
        }
        return queryItems
    }
    
    func getURLComonents(_ urlString: String?) -> NSURLComponents? {
        var components: NSURLComponents? = nil
        let linkUrl = URL(string: urlString?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "")
        if let linkUrl = linkUrl {
            components = NSURLComponents(url: linkUrl, resolvingAgainstBaseURL: true)
        }
        return components
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
