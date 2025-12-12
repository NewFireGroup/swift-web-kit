//
//  WebBrowserView.swift
//  swift-web-kit
//
//  Created by David Boster on 12/4/25.
//
import SwiftUI
import WebKit
import NFGFoundation

public struct WebBrowserView: View {
    private var website: (any Website)?
    
    public var body: some View {
        WebView(url: URL(string: website?.url ?? ""))
//        VStack {
//            if let website {
//                Text("Selected: \(website.name)")
//                Text("Selected: \(website.url)")
//            }
//        }
    }
    
    public init(_ website: (any Website)? = nil) {
        self.website = website
    }
}
