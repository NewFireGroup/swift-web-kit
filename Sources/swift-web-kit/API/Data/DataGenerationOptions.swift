//
//  DataGenerationOptions.swift
//  swift-web-kit
//
//  Created by David Boster on 12/8/25.
//



import Foundation
import SwiftData
import OSLog

public class DataGenerationOptions {
    public static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "DataSchema")
    public static let schema: VersionedSchema.Type = WebsiteSchema.self
    
    /// When true, do not save data to disk. When false, saves data to disk.
    public static let inMemoryPersistence = false
    
    public static let useCloudKit = true
    
    public static let privateDB: URL? = URL(string: "iCloud.group.newfire.swift-web-kit")
    
    public static let showNewWebsiteIndicatorCard = false
    
    public static let rollback: Bool = false
}
