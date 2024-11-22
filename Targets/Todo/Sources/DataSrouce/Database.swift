//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import SwiftData

@ModelActor
public actor Database: IDatabase {
    public func delete<T>(_ model: T) async where T : Sendable, T : PersistentModel {
        modelContext.delete(model)
    }
    
    public func insert<T>(_ model: T) async where T : Sendable, T : PersistentModel {
        modelContext.insert(model)
    }
    
    public func delete<T>(where predicate: Predicate<T>?) async throws where T : Sendable, T : PersistentModel {
        try modelContext.delete(model: T.self, where: predicate)
    }
    
    public func save() async throws {
        try modelContext.save()
    }
    
    public func fetch<T>(_ descriptor: FetchDescriptor<T>) async throws -> [T] where T : Sendable, T : PersistentModel {
        return try modelContext.fetch(descriptor)
    }
}
