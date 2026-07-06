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
            VStack(alignment: .leading, spacing: 9) {
                peopleHeader
                SearchField(placeholder: "搜索姓名", text: $appState.peopleSearchText, fontSize: 14, iconSize: 18, verticalPadding: 9)
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
            .padding(.top, -4)
            .padding(.bottom, 10)
        }
        .background(PaperTexture())
    }

    private var peopleHeader: some View {
        ZStack(alignment: .topTrailing) {
            MountainDecoration()
                .frame(width: 180, height: 88)
                .offset(x: 20, y: 0)
                .opacity(0.36)
                .allowsHitTesting(false)

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("人情")
                        .font(.titleSong(30))
                        .foregroundStyle(LWColors.ink)
                    Text("按人查往来")
                        .font(.bodySong(13))
                        .foregroundStyle(LWColors.warmGold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 10)

                filterBadge
                    .padding(.top, 18)
            }
        }
        .frame(height: 94)
    }

    private var filterBadge: some View {
        Button {
            relationshipFilter = nil
        } label: {
            Label("筛选", systemImage: "line.3.horizontal.decrease.circle")
                .font(.bodySong(12))
                .foregroundStyle(LWColors.ink)
                .padding(.horizontal, 11)
                .padding(.vertical, 6)
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
            HStack(spacing: 8) {
                Button {
                    relationshipFilter = nil
                } label: {
                    peopleFilterTag("全部", isSelected: relationshipFilter == nil)
                }
                .buttonStyle(.plain)
                ForEach(RelationshipType.allCases.filter { $0 != .client && $0 != .other }) { relationship in
                    Button {
                        relationshipFilter = relationship
                    } label: {
                        peopleFilterTag(relationship.title, isSelected: relationshipFilter == relationship)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func personCard(_ summary: PersonSummary) -> some View {
        PaperCard(padding: 11) {
            HStack(alignment: .top, spacing: 11) {
                SealStamp(text: String(summary.name.prefix(1)), size: 40, color: summary.pendingReturnCount > 0 ? LWColors.cinnabar : LWColors.warmGold)
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(summary.name)
                            .font(.titleSong(15))
                            .foregroundStyle(LWColors.ink)
                            .lineLimit(1)
                        Spacer()
                        Text(summary.statusText)
                            .font(.bodySong(12))
                            .foregroundStyle(summary.pendingReturnCount > 0 ? LWColors.cinnabar : LWColors.warmGold)
                            .lineLimit(1)
                    }
                    Text("\(summary.relationship.title) · 往来 \(summary.records.count) 次 · 最近：\(summary.latestRecord?.date.lwCompactMonthText ?? "-") \(summary.latestRecord?.eventType.title ?? "")")
                        .font(.bodySong(11))
                        .foregroundStyle(LWColors.muted)
                        .lineLimit(1)
                    GoldLineDivider()
                    HStack {
                        Text("我送：")
                            .foregroundStyle(LWColors.ink)
                        Text(summary.totalGiven.yuanText)
                            .foregroundStyle(LWColors.cinnabar)
                        Spacer()
                        Rectangle()
                            .fill(LWColors.cardStroke.opacity(0.38))
                            .frame(width: 1, height: 18)
                        Spacer()
                        Text("我收：")
                            .foregroundStyle(LWColors.ink)
                        Text(summary.totalReceived.yuanText)
                            .foregroundStyle(LWColors.cinnabar)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(LWColors.muted.opacity(0.65))
                    }
                    .font(.bodySong(12))
                }
            }
        }
    }

    private func peopleFilterTag(_ title: String, isSelected: Bool) -> some View {
        Text(title)
            .font(.bodySong(12))
            .foregroundStyle(isSelected ? .white : LWColors.ink)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? LWColors.cinnabar : LWColors.card.opacity(0.78))
                    .overlay(Capsule().stroke(LWColors.cardStroke.opacity(0.55), lineWidth: 0.8))
            )
    }
}
