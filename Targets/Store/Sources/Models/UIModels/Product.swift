//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Observation

extension UIStore {
    @MainActor
    @Observable
    class Product: Identifiable {
        let id: Int
        let title: String
        let price: Double
        let description: String
        let category: Category
        let image: String
        let ratingRate: Double
        let ratingCount: Int

        var quantity: Int = 0

        nonisolated init(
            id: Int,
            title: String,
            price: Double,
            description: String,
            category: Category,
            image: String,
            ratingRate: Double,
            ratingCount: Int
        ) {
            self.id = id
            self.title = title
            self.price = price
            self.description = description
            self.category = category
            self.image = image
            self.ratingRate = ratingRate
            self.ratingCount = ratingCount
        }

        func increaseQuantity() {
            self.quantity += 1
        }

        func decreaseQuantity() {
            guard self.quantity > 0 else { return }
            self.quantity -= 1
        }
    }
}

extension UIStore.Product: Hashable, Equatable {
    nonisolated static func == (lhs: UIStore.Product, rhs: UIStore.Product) -> Bool {
        return lhs.id == rhs.id
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

#if DEBUG

extension UIStore.Product {
    nonisolated static func mockItems() -> [UIStore.Product] {
        [
            UIStore.Product(
                id: 1,
                title: "Fjallraven - Foldsack No. 1 Backpack, Fits 15 Laptops",
                price: 109.95,
                description: "Your perfect pack for everyday use and walks in the forest. Stash your laptop (up to 15 inches) in the padded sleeve, your everyday",
                category: "men's clothing",
                image: "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg",
                ratingRate: 3.9,
                ratingCount: 120
            ),
            UIStore.Product(
                id: 2,
                title: "Mens Casual Premium Slim Fit T-Shirts ",
                price: 22.3,
                description: "Slim-fitting style, contrast raglan long sleeve, three-button henley placket, light weight & soft fabric for breathable and comfortable wearing. And Solid stitched shirts that are perfect for casual, business, and daily work wear.",
                category: "men's clothing",
                image: "https://fakestoreapi.com/img/71-3HjGNDUL._AC_SY879._SX._UX._SY._UY_.jpg",
                ratingRate: 4.1,
                ratingCount: 259
            ),
            UIStore.Product(
                id: 3,
                title: "Mens Cotton Jacket",
                price: 55.99,
                description: "great outerwear jackets for Spring/Autumn/Winter, suitable for many occasions, such as working, hiking, camping, climbing, travel, street wear, or daily wear.",
                category: "men's clothing",
                image: "https://fakestoreapi.com/img/71li-ujtlUL._AC_UX679_.jpg",
                ratingRate: 4.7,
                ratingCount: 500
            ),
            UIStore.Product(
                id: 4,
                title: "Mens Casual Slim Fit",
                price: 15.99,
                description: "The color could be slightly different between on the screen and in practice. / Please note that body builds vary by person, therefore, detailed size information should be reviewed below on the product description.",
                category: "men's clothing",
                image: "https://fakestoreapi.com/img/71YXzeOuslL._AC_UY879_.jpg",
                ratingRate: 2.1,
                ratingCount: 430
            ),
            UIStore.Product(
                id: 5,
                title: "John Hardy Women's Legends Naga Gold & Silver Dragon Station Chain Bracelet",
                price: 695,
                description: "From our Legends Collection, the Naga was inspired by the mythical water dragon that protects the ocean's pearl. Wear facing inward to be bestowed with love and abundance, or outward for protection.",
                category: "jewelery",
                image: "https://fakestoreapi.com/img/71pWzhdJNwL._AC_UL640_QL65_ML3_.jpg",
                ratingRate: 4.6,
                ratingCount: 400
            ),
            UIStore.Product(
                id: 6,
                title: "Solid Gold Petite Micropave ",
                price: 168, description: "Satisfaction Guaranteed. Return or exchange any order within 30 days.Designed and sold by Hafeez Center in the United States. Satisfaction Guaranteed. Return or exchange any order within 30 days.",
                category: "jewelery",
                image: "https://fakestoreapi.com/img/61sbMiUnoGL._AC_UL640_QL65_ML3_.jpg",
                ratingRate: 3.9,
                ratingCount: 70
            ),
            UIStore.Product(
                id: 7,
                title: "White Gold Plated Princess",
                price: 9.99,
                description: "Classic Created Wedding Engagement Solitaire Diamond Promise Ring for Her. Gifts to spoil your love more for Anniversary, Christmas, Valentine's Day, Birthday, Wedding, Engagement, Marriage, etc.",
                category: "jewelery", image: "https://fakestoreapi.com/img/71YAIFU48IL._AC_UL640_QL65_ML3_.jpg",
                ratingRate: 3,
                ratingCount: 400
            ),
            UIStore.Product(
                id: 8,
                title: "Pierced Owl Rose Gold Plated Stainless Steel Double",
                price: 10.99, description: "Rose Gold Plated Double Flared Tunnel Plug Earrings. Made of 316L Stainless Steel",
                category: "jewelery",
                image: "https://fakestoreapi.com/img/51UDEzMJVpL._AC_UL640_QL65_ML3_.jpg",
                ratingRate: 1.9,
                ratingCount: 100
            ),
            UIStore.Product(
                id: 9,
                title: "WD 2TB Elements Portable External Hard Drive - USB 3.0 ",
                price: 64,
                description: "USB 3.0 and USB 2.0 Compatibility Fast data transfers Improve PC Performance High Capacity; Compatibility Formatted NTFS for Windows 10, Windows 8.1, Windows 7; Reformatting may be required for other operating systems; Compatibility may vary depending on user’s hardware configuration and operating system",
                category: "electronics", image: "https://fakestoreapi.com/img/61IBBVJvSDL._AC_SY879_.jpg",
                ratingRate: 3.3,
                ratingCount: 203
            ),
            UIStore.Product(
                id: 10,
                title: "SanDisk SSD PLUS 1TB Internal SSD - SATA III 6 Gb/s",
                price: 109,
                description: "Easy upgrade for faster boot up, shutdown, application load and response (As compared to 5400 RPM SATA 2.5” hard drive; Based on published specifications and internal benchmarking tests using PCMark vantage scores) Boosts burst write performance, making it ideal for typical PC workloads The perfect balance of performance and reliability Read/write speeds of up to 535MB/s/450MB/s (Based on internal testing; Performance may vary depending upon drive capacity, host device, OS and application) ",
                category: "electronics", image: "https://fakestoreapi.com/img/61U7T1MvDUL._AC_SX679_.jpg",
                ratingRate: 2.9,
                ratingCount: 470
            )
        ]
    }
}

#endif
