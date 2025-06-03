//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import CoreData

extension NSManagedObject: @retroactive @unchecked Sendable {}
extension NSPredicate: @retroactive @unchecked Sendable {}
extension NSFetchRequest: @retroactive @unchecked Sendable {}

public final actor CoreDataDatabase: ICoreDataDatabase {
    private let context: NSManagedObjectContext

    public init(context: NSManagedObjectContext) {
        self.context = context
    }

    public func delete<T: NSManagedObject>(_ model: T) async {
        context.delete(model)
    }

    public func delete<T: NSManagedObject>(
        ofType type: T.Type,
        where predicate: NSPredicate?
    ) async throws {
        let request = NSFetchRequest<T>(entityName: String(describing: T.self))
        request.predicate = predicate

        let objects = try context.fetch(request)
        for obj in objects {
            context.delete(obj)
        }
    }

    public func save() async throws {
        if context.hasChanges {
            try context.save()
        }
    }

    public func fetch<T: NSManagedObject>(_ request: NSFetchRequest<T>) async throws -> [T] {
        try context.fetch(request)
    }
}
