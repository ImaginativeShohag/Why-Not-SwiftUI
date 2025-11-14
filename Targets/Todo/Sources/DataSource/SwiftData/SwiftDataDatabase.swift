//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import SwiftData

@ModelActor
public actor SwiftDataDatabase: Sendable {
    public func delete<T>(_ model: T) async where T: Sendable, T: PersistentModel {
        modelContext.delete(model)
    }

    public func insert<T>(_ model: T) async where T: Sendable, T: PersistentModel {
        modelContext.insert(model)
    }

    public func delete<T>(where predicate: Predicate<T>?) async throws where T: Sendable, T: PersistentModel {
        try modelContext.delete(model: T.self, where: predicate)
    }

    public func save() async throws {
        try modelContext.save()
    }

    public func fetch<T>(_ descriptor: FetchDescriptor<T>) async throws -> [T] where T: Sendable, T: PersistentModel {
        return try modelContext.fetch(descriptor)
    }
}

// MARK: - Extensions

public extension SwiftDataDatabase {
    func fetch<T: PersistentModel & Sendable>(
        where predicate: Predicate<T>?,
        sortBy: [SortDescriptor<T>]
    ) async throws -> [T] {
        try await self.fetch(FetchDescriptor<T>(predicate: predicate, sortBy: sortBy))
    }

    func fetch<T: PersistentModel & Sendable>(
        _ predicate: Predicate<T>,
        sortBy: [SortDescriptor<T>] = []
    ) async throws -> [T] {
        try await self.fetch(where: predicate, sortBy: sortBy)
    }

    func fetch<T: PersistentModel & Sendable>(
        _: T.Type,
        predicate: Predicate<T>? = nil,
        sortBy: [SortDescriptor<T>] = []
    ) async throws -> [T] {
        try await self.fetch(where: predicate, sortBy: sortBy)
    }

    func delete<T: PersistentModel & Sendable>(
        model _: T.Type,
        where predicate: Predicate<T>? = nil
    ) async throws {
        try await self.delete(where: predicate)
    }
}
