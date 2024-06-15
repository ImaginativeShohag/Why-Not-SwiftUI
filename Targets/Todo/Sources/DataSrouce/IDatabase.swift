//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import SwiftData

public protocol IDatabase: Sendable {
    func delete<T>(_ model: T) async where T: PersistentModel, T: Sendable
    func insert<T>(_ model: T) async where T: PersistentModel, T: Sendable
    func save() async throws
    func fetch<T>(_ descriptor: FetchDescriptor<T>) async throws -> [T] where T: PersistentModel, T: Sendable

    func delete<T: PersistentModel & Sendable>(
        where predicate: Predicate<T>?
    ) async throws
}

public extension IDatabase {
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
