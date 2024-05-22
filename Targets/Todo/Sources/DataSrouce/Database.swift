//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import SwiftData

@ModelActor
public actor Database: IDatabase {
  public func delete(_ model: some PersistentModel) async {
    self.modelContext.delete(model)
  }

  public func insert(_ model: some PersistentModel) async {
    self.modelContext.insert(model)
  }

  public func delete<T: PersistentModel>(
    where predicate: Predicate<T>?
  ) async throws {
    try self.modelContext.delete(model: T.self, where: predicate)
  }

  public func save() async throws {
    try self.modelContext.save()
  }

  public func fetch<T>(_ descriptor: FetchDescriptor<T>) async throws -> [T] where T: PersistentModel {
    return try self.modelContext.fetch(descriptor)
  }
}

