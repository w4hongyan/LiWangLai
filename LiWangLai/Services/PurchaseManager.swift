import Foundation
import Observation
import StoreKit

enum PremiumFeature: String, CaseIterable, Identifiable, Sendable {
    case deskMode
    case excelTools
    case duplicateMerge
    case premiumThemes

    var id: String { rawValue }

    var title: String {
        switch self {
        case .deskMode: "手机与 iPad 礼台模式"
        case .excelTools: "Excel 导入导出"
        case .duplicateMerge: "重复记录智能合并"
        case .premiumThemes: "朱砂、墨青与暖金主题"
        }
    }

    var subtitle: String {
        switch self {
        case .deskMode: "横屏连续登记，适合婚礼、满月和乔迁现场"
        case .excelTools: "完整字段导出，也可批量导入旧礼簿"
        case .duplicateMerge: "先预览再合并，保留信息更完整的一笔"
        case .premiumThemes: "更多中式配色，按你的喜好装点礼簿"
        }
    }

    var systemImage: String {
        switch self {
        case .deskMode: "rectangle.landscape.rotate"
        case .excelTools: "tablecells"
        case .duplicateMerge: "rectangle.on.rectangle.angled"
        case .premiumThemes: "paintpalette"
        }
    }
}

enum PaywallSource: Identifiable, Equatable, Sendable {
    case settings
    case feature(PremiumFeature)

    var id: String {
        switch self {
        case .settings: "settings"
        case .feature(let feature): "feature-\(feature.rawValue)"
        }
    }

    var feature: PremiumFeature? {
        if case .feature(let feature) = self { return feature }
        return nil
    }
}

enum PremiumAccessPolicy {
    /// Pro 门禁放行判定：只认 StoreKit 校验通过的结果（调用方需已完成 revocation 检查）。
    /// UserDefaults 明文缓存永不参与放行；未完成首次校验前一律不放行（调试开关除外）。
    /// 所有用户（含历史版本）都必须完成购买或恢复购买，不存在任何自动解锁的特殊人群。
    static func allowsProAccess(
        hasLoadedEntitlements: Bool,
        storeKitVerified: Bool,
        debugUnlocked: Bool
    ) -> Bool {
        if debugUnlocked { return true }
        guard hasLoadedEntitlements else { return false }
        return storeKitVerified
    }

    /// 「加载中」过渡展示态：首次校验完成前可依据缓存乐观展示；完成后以真实校验结果为准。
    /// 仅用于 UI 展示，不得作为 Pro 功能放行依据。
    static func proDisplayHint(
        hasLoadedEntitlements: Bool,
        cachedEntitlement: Bool,
        isProUnlocked: Bool
    ) -> Bool {
        hasLoadedEntitlements ? isProUnlocked : (cachedEntitlement || isProUnlocked)
    }
}

@MainActor
@Observable
final class PurchaseManager {
    nonisolated static let proProductID = "com.changxiangai.liwanglai.pro.lifetime"

    private(set) var proProduct: Product?
    private(set) var isProUnlocked: Bool
    private(set) var hasLoadedEntitlements = false
    /// 明文缓存派生的「加载中」过渡展示态；不得作为 Pro 功能放行依据
    private(set) var showsCachedProHint: Bool
    private(set) var isLoadingProduct = false
    private(set) var isPurchasing = false
    private(set) var isRestoring = false
    private(set) var statusMessage: String?
    var paywallSource: PaywallSource?

    private let defaults: UserDefaults
    private let debugUnlocked: Bool
    private var updatesTask: Task<Void, Never>?
    private var hasStarted = false

    private static let entitlementCacheKey = "liwanglai.pro.entitlementCache"

    init(
        defaults: UserDefaults = .standard,
        debugUnlocked: Bool = ProcessInfo.processInfo.arguments.contains("-liwanglaiProUnlocked")
    ) {
        self.defaults = defaults
        self.debugUnlocked = debugUnlocked
        // 缓存仅用于首次校验完成前的过渡展示，不参与 Pro 放行
        let cachedEntitlement = defaults.bool(forKey: Self.entitlementCacheKey)
        let initialUnlocked = PremiumAccessPolicy.allowsProAccess(
            hasLoadedEntitlements: false,
            storeKitVerified: false,
            debugUnlocked: debugUnlocked
        )
        isProUnlocked = initialUnlocked
        showsCachedProHint = PremiumAccessPolicy.proDisplayHint(
            hasLoadedEntitlements: false,
            cachedEntitlement: cachedEntitlement,
            isProUnlocked: initialUnlocked
        )
    }

    func start() async {
        guard !hasStarted else { return }
        hasStarted = true

        updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                guard let self else { return }
                if case .verified(let transaction) = update {
                    await transaction.finish()
                }
                await self.refreshEntitlements()
            }
        }

        async let productLoad: Void = loadProduct()
        async let entitlementLoad: Void = refreshEntitlements()
        _ = await (productLoad, entitlementLoad)
    }

    func presentPaywall(for feature: PremiumFeature? = nil) {
        statusMessage = nil
        paywallSource = feature.map(PaywallSource.feature) ?? .settings
    }

    func purchasePro() async {
        guard !isPurchasing else { return }
        if proProduct == nil {
            await loadProduct()
        }
        guard let proProduct else {
            statusMessage = "购买项目正在准备中，请稍后再试。"
            return
        }

        isPurchasing = true
        statusMessage = nil
        defer { isPurchasing = false }

        do {
            let result = try await proProduct.purchase()
            switch result {
            case .success(let verification):
                let transaction = try Self.verified(verification)
                await transaction.finish()
                await refreshEntitlements()
                if isProUnlocked {
                    statusMessage = "礼往来 Pro 已永久解锁。"
                }
            case .pending:
                statusMessage = "购买正在等待确认，完成后会自动解锁。"
            case .userCancelled:
                break
            @unknown default:
                statusMessage = "购买状态暂未确认，请稍后恢复购买。"
            }
        } catch {
            statusMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    func restorePurchases() async {
        guard !isRestoring else { return }
        isRestoring = true
        statusMessage = nil
        defer { isRestoring = false }

        do {
            try await AppStore.sync()
            await refreshEntitlements()
            statusMessage = isProUnlocked ? "购买记录已恢复。" : "没有找到可恢复的 Pro 购买记录。"
        } catch {
            statusMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    func loadProduct() async {
        guard !isLoadingProduct else { return }
        isLoadingProduct = true
        defer { isLoadingProduct = false }

        do {
            proProduct = try await Product.products(for: [Self.proProductID]).first
            if proProduct == nil {
                statusMessage = "暂时没有读取到购买项目，请检查网络后重试。"
            } else if statusMessage == "暂时没有读取到购买项目，请检查网络后重试。" {
                statusMessage = nil
            }
        } catch {
            statusMessage = "暂时没有读取到购买项目，请检查网络后重试。"
        }
    }

    func refreshEntitlements() async {
        var ownsPro = false

        for await entitlement in Transaction.currentEntitlements {
            guard case .verified(let transaction) = entitlement,
                  transaction.productID == Self.proProductID,
                  transaction.revocationDate == nil else { continue }
            ownsPro = true
        }

        isProUnlocked = PremiumAccessPolicy.allowsProAccess(
            hasLoadedEntitlements: true,
            storeKitVerified: ownsPro,
            debugUnlocked: debugUnlocked
        )
        hasLoadedEntitlements = true
        // 校验完成后以真实结果覆盖缓存与展示态
        defaults.set(ownsPro, forKey: Self.entitlementCacheKey)
        showsCachedProHint = PremiumAccessPolicy.proDisplayHint(
            hasLoadedEntitlements: true,
            cachedEntitlement: ownsPro,
            isProUnlocked: isProUnlocked
        )
    }

    private nonisolated static func verified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value): value
        case .unverified: throw PurchaseError.failedVerification
        }
    }
}

private enum PurchaseError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        "购买凭证校验未通过，请稍后恢复购买。"
    }
}
