import Foundation
import Testing
@testable import LiWangLai

struct PremiumAccessPolicyTests {
    @Test func proProductIdentifierRemainsStable() {
        #expect(PurchaseManager.proProductID == "com.changxiangai.liwanglai.pro.lifetime")
    }

    // MARK: - ① 仅有缓存、未完成首次校验时，Pro 门禁不放行

    @Test func gateDeniesAccessBeforeFirstVerification() {
        #expect(!PremiumAccessPolicy.allowsProAccess(
            hasLoadedEntitlements: false,
            storeKitVerified: false,
            debugUnlocked: false
        ))
    }

    @MainActor
    @Test func purchaseManagerDoesNotTrustPlaintextCacheBeforeVerification() {
        let suiteName = "PremiumAccessPolicyTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        // 模拟被篡改的 plist / 恢复他人备份：两个历史缓存键都被置为 true
        defaults.set(true, forKey: "liwanglai.pro.entitlementCache")
        defaults.set(true, forKey: "liwanglai.pro.founderUnlocked")

        let manager = PurchaseManager(defaults: defaults, debugUnlocked: false)

        #expect(!manager.hasLoadedEntitlements)
        #expect(!manager.isProUnlocked)
        // 缓存只能作为「加载中」的过渡展示态
        #expect(manager.showsCachedProHint)
    }

    // MARK: - ② 校验通过后放行

    @Test func gateAllowsAccessAfterStoreKitVerification() {
        #expect(PremiumAccessPolicy.allowsProAccess(
            hasLoadedEntitlements: true,
            storeKitVerified: true,
            debugUnlocked: false
        ))
    }

    @Test func debugFlagUnlocksImmediately() {
        #expect(PremiumAccessPolicy.allowsProAccess(
            hasLoadedEntitlements: false,
            storeKitVerified: false,
            debugUnlocked: true
        ))
    }

    @MainActor
    @Test func debugUnlockedManagerUnlocksWithoutCache() {
        let suiteName = "PremiumAccessPolicyTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let manager = PurchaseManager(defaults: defaults, debugUnlocked: true)

        #expect(manager.isProUnlocked)
    }

    // MARK: - ③ 缓存与校验结果冲突时，以校验结果为准

    @Test func verificationOverridesCacheClaimingEntitlement() {
        // 缓存声称有权益（篡改场景），校验结果为无 → 不放行
        #expect(!PremiumAccessPolicy.allowsProAccess(
            hasLoadedEntitlements: true,
            storeKitVerified: false,
            debugUnlocked: false
        ))
        // 展示态同样以真实结果为准，不再沿用缓存
        #expect(!PremiumAccessPolicy.proDisplayHint(
            hasLoadedEntitlements: true,
            cachedEntitlement: true,
            isProUnlocked: false
        ))
    }

    @Test func verificationOverridesCacheClaimingNoEntitlement() {
        // 缓存为无（如过期备份），校验结果为有 → 放行
        #expect(PremiumAccessPolicy.allowsProAccess(
            hasLoadedEntitlements: true,
            storeKitVerified: true,
            debugUnlocked: false
        ))
        #expect(PremiumAccessPolicy.proDisplayHint(
            hasLoadedEntitlements: true,
            cachedEntitlement: false,
            isProUnlocked: true
        ))
    }
}
