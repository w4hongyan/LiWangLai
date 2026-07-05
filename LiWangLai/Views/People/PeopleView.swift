import SwiftUI

struct PeopleView: View {
    @Environment(AppState.self) private var appState
    let records: [GiftRecord]
    @State private var relationshipFilter: RelationshipType?

    private var people: [PersonSummary] {
        RecordService.people(from: records)
            .filter { summary in
                let matchesSearch = appState.peopleSearchText.isEmpty || summary.name.localizedCaseInsensitiveContains(appState.peopleSearchText)
                let matchesRelationship = relationshipFilter == nil || summary.relationship == relationshipFilter
                return matchesSearch && matchesRelationship
            }
    }

    var body: some View {
        @Bindable var appState = appState

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                PageHeader(
                    title: "人情",
                    subtitle: "按人查往来",
                    trailing: AnyView(filterBadge)
                )
                SearchField(placeholder: "搜索姓名", text: $appState.peopleSearchText)
                relationshipFilters

                if people.isEmpty {
                    EmptyStateView(
                        title: "还没有人情往来",
                        message: "记下一笔后，就能按人查看完整往来脉络。"
                    )
                } else {
                    ForEach(people) { summary in
                        NavigationLink {
                            PersonDetailView(summary: summary)
                        } label: {
                            personCard(summary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, LWSpacing.page)
            .padding(.top, 28)
        }
        .background(PaperTexture())
    }

    private var filterBadge: some View {
        Button {
            relationshipFilter = nil
        } label: {
            Label("筛选", systemImage: "line.3.horizontal.decrease.circle")
                .font(.bodySong(16))
                .foregroundStyle(LWColors.ink)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.56))
                        .overlay(Capsule().stroke(LWColors.cardStroke.opacity(0.35)))
                )
        }
        .buttonStyle(.plain)
    }

    private var relationshipFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                Button {
                    relationshipFilter = nil
                } label: {
                    RelationshipTag(title: "全部", isSelected: relationshipFilter == nil)
                }
                .buttonStyle(.plain)
                ForEach(RelationshipType.allCases.filter { $0 != .client && $0 != .other }) { relationship in
                    Button {
                        relationshipFilter = relationship
                    } label: {
                        RelationshipTag(title: relationship.title, isSelected: relationshipFilter == relationship)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func personCard(_ summary: PersonSummary) -> some View {
        PaperCard {
            HStack(alignment: .top, spacing: 14) {
                SealStamp(text: String(summary.name.prefix(1)), size: 54, color: summary.pendingReturnCount > 0 ? LWColors.cinnabar : LWColors.warmGold)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(summary.name)
                            .font(.titleSong(24))
                            .foregroundStyle(LWColors.ink)
                        Spacer()
                        Text(summary.statusText)
                            .font(.bodySong(16))
                            .foregroundStyle(summary.pendingReturnCount > 0 ? LWColors.cinnabar : LWColors.warmGold)
                    }
                    Text("\(summary.relationship.title) · 往来 \(summary.records.count) 次 · 最近：\(summary.latestRecord?.date.lwCompactMonthText ?? "-") \(summary.latestRecord?.eventType.title ?? "")")
                        .font(.bodySong(15))
                        .foregroundStyle(LWColors.muted)
                    GoldLineDivider()
                    HStack {
                        Text("我送：")
                            .foregroundStyle(LWColors.ink)
                        Text(summary.totalGiven.yuanText)
                            .foregroundStyle(LWColors.cinnabar)
                        Spacer()
                        Rectangle()
                            .fill(LWColors.cardStroke.opacity(0.38))
                            .frame(width: 1, height: 22)
                        Spacer()
                        Text("我收：")
                            .foregroundStyle(LWColors.ink)
                        Text(summary.totalReceived.yuanText)
                            .foregroundStyle(LWColors.cinnabar)
                        Image(systemName: "chevron.right")
                            .foregroundStyle(LWColors.muted.opacity(0.65))
                    }
                    .font(.bodySong(17))
                }
            }
        }
    }
}
