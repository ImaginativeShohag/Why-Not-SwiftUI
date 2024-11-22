//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import RealmSwift
import SwiftUI

/// Random adjectives for more interesting demo item names
let randomAdjectives = [
    "fluffy", "classy", "bumpy", "bizarre", "wiggly", "quick", "sudden",
    "acoustic", "smiling", "dispensable", "foreign", "shaky", "purple", "keen",
    "aberrant", "disastrous", "vague", "squealing", "ad hoc", "sweet"
]

/// Random noun for more interesting demo item names
let randomNouns = [
    "floor", "monitor", "hair tie", "puddle", "hair brush", "bread",
    "cinder block", "glass", "ring", "twister", "coasters", "fridge",
    "toe ring", "bracelet", "cabinet", "nail file", "plate", "lace",
    "cork", "mouse pad"
]

/// An individual item. Part of an `ItemGroup`.
final class Item: Object, ObjectKeyIdentifiable {
    /// The unique ID of the Item. `primaryKey: true` declares the
    /// _id member as the primary key to the realm.
    @Persisted(primaryKey: true) var _id: ObjectId

    /// The name of the Item, By default, a random name is generated.
    @Persisted var name = "\(randomAdjectives.randomElement()!) \(randomNouns.randomElement()!)"

    /// A flag indicating whether the user "favorited" the item.
    @Persisted var isFavorite = false

    /// Users can enter a description, which is an empty string by default
    @Persisted var itemDescription = ""

    /// The backlink to the `ItemGroup` this item is a part of.
    @Persisted(originProperty: "items") var group: LinkingObjects<ItemGroup>

    /// Store the user.id as the ownerId so you can query for the user's objects with Flexible Sync
    /// Add this to both the `ItemGroup` and the `Item` objects so you can read and write the linked objects.
    @Persisted var ownerId = ""
}

/// Represents a collection of items.
final class ItemGroup: Object, ObjectKeyIdentifiable {
    /// The unique ID of the ItemGroup. `primaryKey: true` declares the
    /// _id member as the primary key to the realm.
    @Persisted(primaryKey: true) var _id: ObjectId

    /// The collection of Items in this group.
    @Persisted var items = RealmSwift.List<Item>()

    /// Store the user.id as the ownerId so you can query for the user's objects with Flexible Sync
    /// Add this to both the `ItemGroup` and the `Item` objects so you can read and write the linked objects.
    @Persisted var ownerId = ""
}

// MARK: - Destination

public extension Destination {
    final class RealmDB: BaseDestination {
        override public func getScreen() -> any View {
            RealmScreen()
                .environment(\.realmConfiguration, Realm.Configuration())
        }
    }
}

// MARK: - UI

private struct RealmScreen: View {
    var body: some View {
        RealmScreenContainer()
    }
}

#Preview("RealmScreen") {
    NavigationStack {
        RealmScreen()
            .environment(\.realmConfiguration, Realm.Configuration(fileURL: nil, inMemoryIdentifier: "inMemoryDB"))
    }
}

/// The main content view if not using Sync.
private struct RealmScreenContainer: View {
    @State var searchFilter: String = ""
    // Implicitly use the default realm's objects(ItemGroup.self)
    @ObservedResults(ItemGroup.self) var itemGroups

    var body: some View {
        if let itemGroup = itemGroups.first {
            // Pass the ItemGroup objects to a view further
            // down the hierarchy
            ItemsView(itemGroup: itemGroup)
        } else {
            // For this small app, we only want one itemGroup in the realm.
            // You can expand this app to support multiple itemGroups.
            // For now, if there is no itemGroup, add one here.
            ProgressView().onAppear {
                $itemGroups.append(ItemGroup())
            }
        }
    }
}

/// The screen containing a list of items in an ItemGroup. Implements functionality for adding, rearranging,
/// and deleting items in the ItemGroup.
private struct ItemsView: View {
    @ObservedRealmObject var itemGroup: ItemGroup

    /// The button to be displayed on the top left.
    var leadingBarButton: AnyView?

    var body: some View {
        VStack {
            // The list shows the items in the realm.
            List {
                Text("This is a basic example of `Realm`.")

                ForEach(itemGroup.items) { item in
                    ItemRow(item: item)
                }
                .onDelete(perform: $itemGroup.items.remove)
                .onMove(perform: $itemGroup.items.move)
            }
            .listStyle(.automatic)
            .navigationBarTitle("Realm Example", displayMode: .large)
            .navigationBarItems(
                leading: self.leadingBarButton,
                // Edit button on the right to enable rearranging items
                trailing: EditButton())
            // Action bar at bottom contains Add button.
            HStack {
                Spacer()
                Button(action: {
                    // The bound collection automatically
                    // handles write transactions, so we can
                    // append directly to it.
                    $itemGroup.items.append(Item())
                }) { Image(systemName: "plus") }
            }
            .padding()
        }
    }
}

/// Represents an Item in a list.
private struct ItemRow: View {
    @ObservedRealmObject var item: Item

    var body: some View {
        // You can click an item in the list to navigate to an edit details screen.
        NavigationLink(destination: ItemDetailsView(item: item)) {
            Text(item.name)
            if item.isFavorite {
                // If the user "favorited" the item, display a heart icon
                Image(systemName: "heart.fill")
            }
        }
    }
}

/// Represents a screen where you can edit the item's name.
private struct ItemDetailsView: View {
    @ObservedRealmObject var item: Item

    var body: some View {
        VStack(alignment: .leading) {
            Text("Enter a new name")
                .font(.title)

            // Accept a new name
            HStack {
                TextField("New name", text: $item.name)
                    .navigationBarTitle(item.name)
                    .navigationBarItems(trailing: Toggle(isOn: $item.isFavorite) {
                        Image(systemName: item.isFavorite ? "heart.fill" : "heart")
                    })

                Image(systemName: "pencil.line")
            }
            .padding()
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray, lineWidth: 1)
            }
        }
        .padding()
    }
}

#Preview("ItemDetailsView") {
    NavigationStack {
        let item = Item(value: [
            "_id": ObjectId.generate(),
            "name": "Bright Star",
            "isFavorite": true,
            "itemDescription": "A stellar item with unique qualities.",
            "ownerId": "user123"
        ])

        ItemDetailsView(item: item)
    }
}
