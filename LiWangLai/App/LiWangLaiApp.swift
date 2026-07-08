import SwiftData
import SwiftUI

@main
struct LiWangLaiApp: App {
    @State private var appState = AppState()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            HostedGiftEvent.self,
            GiftRecord.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Unable to create SwiftData container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .environment(\.locale, Locale(identifier: "zh_Hans_CN"))
                .task {
                    let ctx = sharedModelContainer.mainContext
                    let descriptor = FetchDescriptor<GiftRecord>()
                    let count = (try? ctx.fetchCount(descriptor)) ?? 0
                    guard count == 0 else { return }
                    let cal = Calendar.current
                    let now = Date()
                    let data: [(String,GiftRecordType,Int,GiftEventType,RelationshipType,String,Int)] = [
                        ("王建国",.received,2000,.wedding,.relative,"二舅家儿子结婚",-120),
                        ("李明华",.given,600,.baby,.colleague,"满月红包",-90),
                        ("张秀英",.received,1000,.housewarming,.friend,"乔迁新居",-60),
                        ("刘志强",.given,500,.birthday,.classmate,"同学生日",-45),
                        ("陈美玲",.received,800,.baby,.relative,"表姐满月酒",-30),
                        ("周文博",.given,300,.wedding,.colleague,"同事婚礼",-15),
                        ("赵秀兰",.received,1500,.funeral,.friend,"白事随礼",-10),
                        ("吴俊杰",.given,200,.festival,.classmate,"中秋送礼",-5),
                        ("宋雨晴",.received,600,.birthday,.colleague,"生日聚餐",-2),
                    ]
                    for (n,t,a,e,r,note,d) in data {
                        let date = cal.date(byAdding: .day, value: d, to: now) ?? now
                        ctx.insert(GiftRecord(personName:n,type:t,amountYuan:a,eventType:e,relationship:r,date:date,note:note,isReturned:t == .given))
                    }
                    try? ctx.save()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
