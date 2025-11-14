//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

class ProductProcessActions: CartActions {
    func processProducts(_ products: [Product]) async -> [UIStore.Product] {
        var finalProducts = [UIStore.Product]()

        for product in products {
            await finalProducts.append(
                processProduct(product)
            )
        }

        return finalProducts
    }

    func processProduct(_ product: Product) async -> UIStore.Product {
        let cacheUiProduct = await ProductCache.shared.getProduct(product.id)
        if let cacheUiProduct {
            return cacheUiProduct
        } else {
            let uiModel = product.toUIModel()
            await ProductCache.shared.updateProduct(uiModel)
            return uiModel
        }
    }
}
