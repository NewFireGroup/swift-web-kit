//
//  WebsiteDataContainerViewModifier.swift
//  swift-web-kit
//
//  Created by David Boster on 12/8/25.
//


import SwiftUI
import SwiftData
import OSLog

private let logger = DataGenerationOptions.logger

struct WebsiteDataContainerViewModifier: ViewModifier {
    let container: ModelContainer?
    
    var error:String? = nil
    
    init(inMemory: Bool) {
        logger.debug("Website Data Container View Modifier" )
//        container = try! ModelContainer(for: DataGeneration.schema, migrationPlan: WebsiteDataMigrationPlan.self, configurations: [ModelConfiguration(isStoredInMemoryOnly: inMemory)])
        do {
            //container = try DataGeneration.setupModelContainer(inMemory: inMemory)
            let privateDBUrl: String? = DataGenerationOptions.privateDB?.absoluteString
            let cloudSchema = Schema(WebsiteSchema.models)
            logger.debug("schema: \(String(describing: cloudSchema))")
            var cloudConfiguration: ModelConfiguration? = nil
            if let privateDB = privateDBUrl, !inMemory {
                logger.debug("Cloud Configuration with Private DB")
                cloudConfiguration = .init(
                    schema: cloudSchema,
                    isStoredInMemoryOnly: inMemory,
                    allowsSave: true,
                    cloudKitDatabase: .private(privateDB)
               )
            } else {
                logger.debug("In-Memory Configuration")
                cloudConfiguration = ModelConfiguration(
                    schema: cloudSchema,
                    isStoredInMemoryOnly: inMemory
                )
            }
            if let cloudConfig = cloudConfiguration {
                logger.debug("config: \(String(describing: cloudConfiguration))")
                self.container = try ModelContainer(
                    for: cloudSchema,
//                    migrationPlan: WebsiteDataMigrationPlan.self,
                    configurations: cloudConfig)
            } else {
                self.container = nil
                logger.debug("No Cloud Configuration")
            }
        } catch {
            self.container = nil
            self.error = "Failed to set up model container: \(error)"
            logger.error("Failed to set up model container: \(error)")
        }
    }
    
    func body(content: Content) -> some View {
        if let error {
            ScrollView {
                Text(error)
            }
        }
        if let container {
            content
                .generateData()
                .modelContainer(container)
        } else {
            Text("No Container")
        }
    }
}

struct GenerateDataViewModifier: ViewModifier {
    @Environment(\.modelContext) private var modelContext
    
    func body(content: Content) -> some View {
        content.onAppear {
            DataGeneration.generateAllData(modelContext: modelContext)
        }
    }
}

public extension View {
    func advisorDataContainer(inMemory: Bool = DataGenerationOptions.inMemoryPersistence) -> some View {
        modifier(WebsiteDataContainerViewModifier(inMemory: inMemory))
    }
}

fileprivate extension View {
    func generateData() -> some View {
        modifier(GenerateDataViewModifier())
    }
}
