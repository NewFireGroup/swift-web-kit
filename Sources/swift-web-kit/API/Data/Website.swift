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

extension WebsiteSchemaV1 {
    // Change from class to protocol
    public protocol Website: ACEntity {
        // Identity / display from ACEntity:
        // var id: String { get set }
        // var name: String { get set }
        // var systemImage: String { get set }

        // Website-specific
        var url: String { get set }
        var loginUrl: String { get set }
        var provider: String { get set }
    }
}
