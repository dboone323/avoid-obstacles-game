
import StoreKit
import SwiftUI

// Enhancement #87: In-App Purchases - StoreKit 2 Migration
@MainActor
class StoreManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoading = false
    
    private var updateListenerTask: Task<Void, Never>?
    
    init() {
        updateListenerTask = listenForTransactions()
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    
    func fetchProducts(productIDs: Set<String>) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            products = try await Product.products(for: productIDs)
            #if DEBUG
            print("StoreManager: Fetched \(products.count) products")
            #endif
        } catch {
            print("StoreManager: Failed to fetch products: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Purchases
    
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            purchasedProductIDs.insert(product.id)
            #if DEBUG
            print("StoreManager: Successfully purchased \(product.id)")
            #endif
            return transaction
            
        case .pending:
            #if DEBUG
            print("StoreManager: Purchase pending for \(product.id)")
            #endif
            return nil
            
        case .userCancelled:
            #if DEBUG
            print("StoreManager: User cancelled purchase of \(product.id)")
            #endif
            return nil
            
        @unknown default:
            return nil
        }
    }
    
    // MARK: - Purchase Verification
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let signedType):
            return signedType
        case .unverified(_, let error):
            throw StoreError.verificationFailed(error)
        }
    }
    
    // MARK: - Transaction Updates
    
    private func listenForTransactions() -> Task<Void, Never> {
        Task { @MainActor [weak self] in
            for await result in Transaction.updates {
                guard let self = self else { return }
                do {
                    let transaction = try self.checkVerified(result)
                    await transaction.finish()
                    self.purchasedProductIDs.insert(transaction.productID)
                    #if DEBUG
                    print("StoreManager: Transaction update processed for \(transaction.productID)")
                    #endif
                } catch {
                    #if DEBUG
                    print("StoreManager: Transaction verification failed: \(error.localizedDescription)")
                    #endif
                }
            }
        }
    }
    
    // MARK: - Restore Purchases
    
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            #if DEBUG
            print("StoreManager: Purchases restored successfully")
            #endif
        } catch {
            print("StoreManager: Failed to restore purchases: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Check Purchase Status
    
    func isPurchased(_ productID: String) async -> Bool {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if transaction.productID == productID && transaction.revocationDate == nil {
                return true
            }
        }
        return false
    }
}

// MARK: - Store Errors

enum StoreError: LocalizedError {
    case verificationFailed(Error)
    case purchaseFailed
    
    var errorDescription: String? {
        switch self {
        case .verificationFailed(let error):
            return "Purchase verification failed: \(error.localizedDescription)"
        case .purchaseFailed:
            return "Purchase could not be completed"
        }
    }
}
