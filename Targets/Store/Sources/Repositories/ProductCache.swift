//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

actor ProductCache {
    static let shared = ProductCache()
    
    private init() {}
    
    private var products = [Int: UIStore.Product]()
    
    func getProduct(_ id: Int) -> UIStore.Product? {
        products[id]
    }
    
    func updateProduct(_ product: UIStore.Product) {
        products[product.id] = product
    }
}
