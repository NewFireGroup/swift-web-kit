//
//  WebBrowserView.swift
//  swift-web-kit
//
//  Created by David Boster on 12/4/25.
//
import SwiftUI
import WebKit
import swift_newfire_foundation

public struct WebBrowserView: View {
    private var website: Website?
    
    public var body: some View {
        WebView(url: URL(string: website?.url ?? ""))
//        VStack {
//            if let website {
//                Text("Selected: \(website.name)")
//                Text("Selected: \(website.url)")
//            }
//        }
    }
    
    public init(_ website: Website? = nil) {
        self.website = website
    }
}
