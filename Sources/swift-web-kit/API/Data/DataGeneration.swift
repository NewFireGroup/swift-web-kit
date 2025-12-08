import Foundation
import Observation
import SwiftData
import CoreData
import OSLog

private let logger = DataGenerationOptions.logger
  
public extension DataGeneration {
    var requiresInitialDataGeneration: Bool {
        initializationDate == nil || initializationDate! <= DataGeneration.startTime
    }
    
    static let startTime: Date = .now
        
    private static func instance(with modelContext: ModelContext) -> DataGeneration {
        if let result = try! modelContext.fetch(FetchDescriptor<DataGeneration>()).first {
            return result
        } else {
            let instance = DataGeneration(
                initializationDate: nil
            )
            modelContext.insert(instance)
            return instance
        }
    }
    
    static func generateAllData(modelContext: ModelContext) {
        let instance = instance(with: modelContext)
        if instance.requiresInitialDataGeneration {
            logger.info("Requires an initial data generation")
            do {
                try instance.generateInitialData(modelContext: modelContext)
            } catch {
                logger.error("Failed to generate initial data: \(error)")
            }
        } else {
            logger.debug("Does not require initial data generation")
        }
    }
    
    //static let container: ModelContainer = try setupModelContainer()
//            return try ModelContainer(for: schema, migrationPlan: AdvisorDataMigrationPlan.self, configurations: [.init(isStoredInMemoryOnly: DataGenerationOptions.inMemoryPersistence)])
    
    
//    @discardableResult
//    static func setupModelContainer(for versionedSchema: VersionedSchema.Type = DataGenerationOptions.schema, url: URL? = DataGenerationOptions.url, useCloudKit: Bool = DataGenerationOptions.useCloudKit, rollback: Bool = DataGenerationOptions.rollback, inMemory: Bool = false) throws -> ModelContainer {
//
//    #if DEBUG
//        // disable CloudKit when running tests
//        var useCloudKit = useCloudKit
//        let runningTest = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil // !TODO: is this safe?
//        if (runningTest) {
//            logger.info("setup - disabling CloudKit on testing run.")
//            useCloudKit = false
//        }
//    #endif
//        
//        do {
//            logger.info("setup - versionedSchema: \(String(describing: versionedSchema)), url: \(String(describing: url)), useCloudKit: \(useCloudKit), rollback: \(rollback)")
//            
//            let schema = Schema(versionedSchema: versionedSchema)
//            logger.info("setup - schema: \(String(describing: schema))")
//            
//            var config: ModelConfiguration
//            if (inMemory) {
//                logger.info("setup - in-memory")
//                config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
//            } else {
//                logger.info("setup - persisted")
//                if let url = url {
//                    config = ModelConfiguration(schema: schema, url: url, cloudKitDatabase: useCloudKit ? .private("iCloud.group.newfire.sandbox") : .none)
//                } else {
//                    config = ModelConfiguration(schema: schema, cloudKitDatabase: useCloudKit ? .private("iCloud.group.newfire.sandbox") : .none)
//                }
//            }
//            logger.info("setup - config: \(String(describing: config))")
//            
//    #if DEBUG
//            if useCloudKit {
//                // TODO: does this run on an iOS device w/o iCloud account?
//                try initCloudKitDevelopmentSchema(config: config)
//            }
//    #endif
//            
//            let container = try ModelContainer(
//                for: schema,
//                migrationPlan: rollback ? AdvisorDataRollbackMigrationPlan.self : AdvisorDataMigrationPlan.self,
//                configurations: [config]
//            )
//            logger.info("setup -> \(String(describing: container))")
//            
//            return container
//        } catch {
//            logger.error("setup - \(error)")
//            throw ModelError.setup(error: error)
//        }
//    }
//    
//    /// Initialize the CloudKit development schema: https://developer.apple.com/documentation/swiftdata/syncing-model-data-across-a-persons-devices#Initialize-the-CloudKit-development-schema
//    static func initCloudKitDevelopmentSchema(config: ModelConfiguration) throws {
//        logger.info("initCloudKitDevelopmentSchema()")
//        
//        // Use an autorelease pool to make sure Swift deallocates the persistent
//        // container before setting up the SwiftData stack.
//        try autoreleasepool {
//            let desc = NSPersistentStoreDescription(url: config.url)
//            let opts = NSPersistentCloudKitContainerOptions(containerIdentifier: config.cloudKitContainerIdentifier!)
//            desc.cloudKitContainerOptions = opts
//            // Load the store synchronously so it completes before initializing the
//            // CloudKit schema.
//            desc.shouldAddStoreAsynchronously = false
//            if let mom = NSManagedObjectModel.makeManagedObjectModel(for: DataGenerationOptions.schema.models) {
//                let container = NSPersistentCloudKitContainer(name: config.name, managedObjectModel: mom)
//                container.persistentStoreDescriptions = [desc]
//                container.loadPersistentStores {_, err in
//                    if let err {
//                        fatalError(err.localizedDescription)
//                    }
//                }
//                // Initialize the CloudKit schema after the store finishes loading.
//                try container.initializeCloudKitSchema()
//                // Remove and unload the store from the persistent container.
//                if let store = container.persistentStoreCoordinator.persistentStores.first {
//                    try container.persistentStoreCoordinator.remove(store)
//                }
//            }
//        }
//    }
}
