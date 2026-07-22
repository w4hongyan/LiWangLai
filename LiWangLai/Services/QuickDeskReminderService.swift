import Foundation
import SwiftData

/// 礼台（QuickDesk）批量回礼提醒服务。
@MainActor
enum QuickDeskReminderService {
    /// 为指定场次中所有「收礼且未回礼」的记录设置回礼提醒日期。
    ///
    /// - 已回礼（isReturned）的记录不受影响；
    /// - 已有提醒日期的未回礼记录会更新为新日期（用于修改提醒日期）；
    /// - 保存失败时回滚，与 RecordService 的 save/rollback 语义一致。
    ///
    /// - Returns: 本次覆盖（设置/更新）的记录笔数。
    @discardableResult
    static func setReturnReminder(
        forEventID eventID: UUID,
        date: Date,
        in context: ModelContext
    ) throws -> Int {
        let records = try context.fetch(FetchDescriptor<GiftRecord>())
        let targets = records.filter {
            $0.hostedEventID == eventID && $0.type == .received && !$0.isReturned
        }
        guard !targets.isEmpty else { return 0 }

        let now = Date.now
        for record in targets {
            record.returnReminderDate = date
            record.updatedAt = now
        }
        do {
            try context.save()
            return targets.count
        } catch {
            context.rollback()
            throw error
        }
    }
}
