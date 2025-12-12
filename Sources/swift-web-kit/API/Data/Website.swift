//
//  Website.swift
//  swift-web-kit
//
//  Created by David Boster on 12/4/25.
//

import Foundation
import SwiftUI
import SwiftData
import NFGFoundation

extension WebsiteSchema {
    
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
    open class Website: ACEntity {
        // Identity / display
        public var id: String
        public var name: String
        public var systemImage: String
        
        // Website-specific
        public var url: String
        public var loginUrl: String
        public var provider: String
        
        public init(
            id: String? = nil,
            name: String? = nil,
            systemImage: String? = nil,
            provider: String? = nil,
            url: String? = nil,
            loginUrl: String? = nil
        ) {
            self.id = id ?? UUID().uuidString
            self.name = name ?? "New Item"
            self.systemImage = systemImage ?? "cloud.fill"
            self.url = url ?? "https://www.google.com"
            self.loginUrl = loginUrl ?? ""
            self.provider = provider ?? ""
        }
        
        public static func == (lhs: Website, rhs: Website) -> Bool {
            lhs.id == rhs.id
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}
