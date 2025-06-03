//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import CoreData

public protocol ICoreDataDatabase {
    func delete<T: NSManagedObject>(_ model: T) async
    func save() async throws
    func fetch<T: NSManagedObject>(_ request: NSFetchRequest<T>) async throws -> [T]
    
    func delete<T: NSManagedObject>(
        ofType type: T.Type,
        where predicate: NSPredicate?
    ) async throws
}

#warning("rethink this")
public extension ICoreDataDatabase {
    func fetch<T: NSManagedObject>(
        ofType type: T.Type,
        predicate: NSPredicate? = nil,
        sortBy: [NSSortDescriptor] = []
    ) async throws -> [T] {
        let request = NSFetchRequest<T>(entityName: String(describing: T.self))
        request.predicate = predicate
        request.sortDescriptors = sortBy
        return try await self.fetch(request)
    }

    func delete<T: NSManagedObject>(
        ofType type: T.Type,
        where predicate: NSPredicate? = nil
    ) async throws {
        try await self.delete(ofType: type, where: predicate)
    }
}
