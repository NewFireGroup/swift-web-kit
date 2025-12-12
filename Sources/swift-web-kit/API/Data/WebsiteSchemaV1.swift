import Foundation
import SwiftData
import OSLog

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "DataSchema")

public enum WebsiteSchemaV1 {
    public static let versionIdentifier: Schema.Version = .init(1, 0, 0)
}
