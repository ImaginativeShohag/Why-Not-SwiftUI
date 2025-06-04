//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import CoreData

extension NSManagedObject: @retroactive @unchecked Sendable {}
extension NSPredicate: @retroactive @unchecked Sendable {}
extension NSFetchRequest: @retroactive @unchecked Sendable {}
extension NSManagedObjectContext: @retroactive @unchecked Sendable {}

public final actor CoreDataDatabase {
    private let context: NSManagedObjectContext

    public init(context: NSManagedObjectContext) {
        self.context = context
    }

    public func delete<T: NSManagedObject>(_ model: T) {
        self.context.delete(model)
    }

    public func delete<T: NSManagedObject>(
        ofType type: T.Type,
        where predicate: NSPredicate? = nil
    ) throws {
        let request = NSFetchRequest<T>(entityName: String(describing: T.self))
        request.predicate = predicate

        let objects = try context.fetch(request)
        for obj in objects {
            self.context.delete(obj)
        }
    }

    public func save() throws {
        if self.context.hasChanges {
            try self.context.save()
        }
    }

    public func fetch<T: NSManagedObject>(_ request: NSFetchRequest<T>) throws -> [T] {
        try self.context.fetch(request)
    }
}

// MARK: - Extensions

public extension CoreDataDatabase {
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
}
