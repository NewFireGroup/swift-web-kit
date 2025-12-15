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
    @State private var page = WebPage()
    @State private var parsedData: String? = nil
    private var website: (any Website)?
    
    public var body: some View {
        VStack {
            WebView(url: URL(string: website?.url ?? ""))
                .onChange(of: page.url, initial: true) { newURL, oldUrl in
                    Task {
                        self.parsedData = await self.getPageDescription(page)
                    }
                }
            if let data = parsedData {
                Text("\(data)")
            }
            
        }
    }
    
    private func getPageDescription(_ page: WebPage) async -> String? {
        
        let fetchOpenGraphProperty = """
            const propertyValues = document.querySelector(`meta[name="${name}"]`);
            if (propertyValues !== null) {
                return propertyValues.content;
            } else {
                return null
            }
            
        """

        let arguments: [String: String] = [
            "name": "description"
        ]
        
        do {
            let description = try await page.callJavaScript(fetchOpenGraphProperty, arguments: arguments) as? String
            return description
        } catch (let error) {
            print("error calling JS: ", error)
        }

        return nil
    }
    
    public init(_ website: (any Website)? = nil) {
        self.website = website
    }
}
