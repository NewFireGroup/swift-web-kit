import Foundation
import SwiftData
import OSLog

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "DataSchema")

public enum WebsiteSchemaV1 {
    public static let versionIdentifier: Schema.Version = .init(1, 0, 0)
    
    @Model public class DataGeneration {
        public var initializationDate: Date?
        
        public init(initializationDate: Date? = nil) {
            self.initializationDate = initializationDate
        }
        
        public func generateInitialData(modelContext: ModelContext) throws {
            logger.info("Generating initial data...")
            
            logger.info("Generating Menu")
//            try MenuGroup.generateMenuGroups(modelContext: modelContext)
            
            logger.info("Generating account")
//            try Account.generateAccount(modelContext: modelContext)
            
            logger.info("Completed generating initial data")
            initializationDate = DataGeneration.startTime
        }
    }
    
}
