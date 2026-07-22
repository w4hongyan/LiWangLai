import SwiftUI

struct PeopleView: View {
    @Environment(AppState.self) private var appState
    let records: [GiftRecord]
    @State private var relationshipFilter: RelationshipType?
    @State private var sortOrder: PeopleSortOrder = .recent

    private var people: [PersonSummary] {
        let normalizedQuery = PersonIdentity.normalizedName(appState.peopleSearchText)
        return RecordService.people(from: records)
            .filter { summary in
                let matchesSearch = normalizedQuery.isEmpty
                    || PersonIdentity.normalizedName(summary.name).contains(normalizedQuery)
                let matchesRelationship = relationshipFilter == nil || summary.relationship == relationshipFilter
                return matchesSearch && matchesRelationship
            }
            .sorted(by: sortOrder.areInIncreasingOrder)
    }

    var body: some View {
        @Bindable var appState = appState

        ScrollView {
            VStack(alignment: .leading, spacing: 11) {
                peopleHeader
                SearchField(placeholder: "搜索姓名", text: $appState.peopleSearchText, fontSize: 14, iconSize: 18, verticalPadding: 9)
                relationshipFilters

                if people.isEmpty {
                    if records.isEmpty {
                        EmptyStateView(
                            title: "还没有人情往来",
                            message: "记下一笔后，就能按人查看完整往来脉络。",
                            buttonTitle: "记一笔"
                        ) {
                            appState.addPresetType = .received
                            appState.selectedTab = .add
                        }
                    } else {
                        EmptyStateView(
                            title: "没有找到这个人",
                            message: "换个姓名，或清空关系筛选后再试。",
                            buttonTitle: "清空筛选"
                        ) {
                            appState.peopleSearchText = ""
                            relationshipFilter = nil
                        }
                    }
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
            Image("prototype_header_mountain_plum")
                .resizable()
                .scaledToFit()
                .frame(width: 236)
                .offset(x: 24, y: 8)
                .opacity(0.88)
                .allowsHitTesting(false)

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("人情")
                        .font(.titleSong(40))
                        .foregroundStyle(LWColors.ink)
                    Text("按人查往来")
                        .font(.bodySong(17))
                        .foregroundStyle(LWColors.warmGold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 18)

                HStack(spacing: 8) {
                    sortBadge
                    filterBadge
                }
                    .padding(.top, 20)
            }
        }
        .frame(minHeight: 124, alignment: .top)
    }

    private var filterBadge: some View {
        Menu {
            Button {
                relationshipFilter = nil
            } label: {
                if relationshipFilter == nil {
                    Label("全部关系", systemImage: "checkmark")
                } else {
                    Text("全部关系")
                }
            }

            Divider()

            ForEach(RelationshipType.allCases) { relationship in
                Button {
                    relationshipFilter = relationship
                } label: {
                    if relationshipFilter == relationship {
                        Label(relationship.title, systemImage: "checkmark")
                    } else {
                        Text(relationship.title)
                    }
                }
            }
        } label: {
            Label(relationshipFilter?.title ?? "筛选", systemImage: "line.3.horizontal.decrease.circle")
                .font(.bodySong(12))
                .foregroundStyle(relationshipFilter == nil ? LWColors.ink : LWColors.cinnabar)
                .padding(.horizontal, 11)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(relationshipFilter == nil ? Color.white.opacity(0.56) : LWColors.cinnabar.opacity(0.08))
                        .overlay(
                            Capsule().stroke(
                                relationshipFilter == nil ? LWColors.cardStroke.opacity(0.35) : LWColors.cinnabar.opacity(0.35)
                            )
                        )
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("按关系筛选")
        .accessibilityValue(relationshipFilter?.title ?? "全部关系")
    }

    private var sortBadge: some View {
        Menu {
            ForEach(PeopleSortOrder.allCases) { order in
                Button {
                    sortOrder = order
                } label: {
                    if sortOrder == order {
                        Label(order.title, systemImage: "checkmark")
                    } else {
                        Text(order.title)
                    }
                }
            }
        } label: {
            Label(sortOrder.shortTitle, systemImage: "arrow.up.arrow.down")
                .font(.bodySong(12))
                .foregroundStyle(sortOrder == .recent ? LWColors.ink : LWColors.cinnabar)
                .padding(.horizontal, 10)
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
            HStack(spacing: 10) {
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
        PaperCard(padding: 12) {
            HStack(alignment: .top, spacing: 11) {
                ZStack(alignment: .bottomTrailing) {
                    SealStamp(text: String(summary.name.prefix(1)), size: 44, color: summary.pendingReturnCount > 0 ? LWColors.cinnabar : LWColors.warmGold)
                    if summary.pendingReturnCount > 0 {
                        Text("待")
                            .font(.bodySong(10).weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 16, height: 16)
                            .background(LWColors.cinnabar, in: Circle())
                            .offset(x: 2, y: 2)
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(summary.name)
                            .font(.bodyKai(17))
                            .foregroundStyle(LWColors.ink)
                            .lineLimit(1)
                        Spacer()
                        Text(summary.statusText)
                            .font(.bodySong(11))
                            .foregroundStyle(summary.pendingReturnCount > 0 ? LWColors.cinnabar : LWColors.warmGold)
                            .lineLimit(1)
                    }
                    Text(personMeta(summary))
                        .font(.bodySong(11))
                        .foregroundStyle(LWColors.muted)
                        .lineLimit(2)
                    GoldLineDivider()
                    HStack {
                        Text("我送：")
                            .font(.bodySong(12))
                            .foregroundStyle(LWColors.ink)
                        Text(summary.totalGivenFen.fenCurrencyText)
                            .font(.bodySong(12))
                            .foregroundStyle(LWColors.cinnabar)
                        Spacer()
                        Rectangle()
                            .fill(LWColors.cardStroke.opacity(0.38))
                            .frame(width: 1, height: 18)
                        Spacer()
                        Text("我收：")
                            .font(.bodySong(12))
                            .foregroundStyle(LWColors.ink)
                        Text(summary.totalReceivedFen.fenCurrencyText)
                            .font(.bodySong(12))
                            .foregroundStyle(LWColors.cinnabar)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(LWColors.muted.opacity(0.65))
                    }
                }
            }
            .overlay(alignment: .topTrailing) {
                Image("prototype_gold_clouds")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36)
                    .offset(x: 2, y: -2)
                    .opacity(0.58)
            }
        }
    }

    private func personMeta(_ summary: PersonSummary) -> String {
        let hint = summary.identityHint.map { " · \($0)" } ?? ""
        return "\(summary.relationship.title)\(hint) · 往来 \(summary.records.count) 次 · 最近：\(summary.latestRecord?.date.lwDayText ?? "-") \(summary.latestRecord?.eventType.title ?? "")"
    }

    private func peopleFilterTag(_ title: String, isSelected: Bool) -> some View {
        Text(title)
            .font(.bodySong(14))
            .foregroundStyle(isSelected ? .white : LWColors.ink)
            .padding(.horizontal, 18)
            .padding(.vertical, 9)
            .background(
                Capsule()
                    .fill(isSelected ? LWColors.cinnabar : LWColors.card.opacity(0.84))
                    .overlay(Capsule().stroke(isSelected ? LWColors.cinnabarDark.opacity(0.2) : LWColors.cardStroke.opacity(0.5), lineWidth: 0.8))
                    .shadow(color: isSelected ? LWColors.cinnabar.opacity(0.18) : .clear, radius: 8, x: 0, y: 4)
            )
    }
}

private enum PeopleSortOrder: String, CaseIterable, Identifiable {
    case recent
    case pendingAmount
    case receivedAmount

    var id: String { rawValue }

    var title: String {
        switch self {
        case .recent: "按最近往来"
        case .pendingAmount: "按待回金额"
        case .receivedAmount: "按累计收礼"
        }
    }

    var shortTitle: String {
        switch self {
        case .recent: "排序"
        case .pendingAmount: "待回金额"
        case .receivedAmount: "累计收礼"
        }
    }

    func areInIncreasingOrder(_ lhs: PersonSummary, _ rhs: PersonSummary) -> Bool {
        switch self {
        case .recent:
            return (lhs.latestRecord?.date ?? .distantPast) > (rhs.latestRecord?.date ?? .distantPast)
        case .pendingAmount:
            if lhs.pendingReturnAmountFen == rhs.pendingReturnAmountFen {
                return (lhs.latestRecord?.date ?? .distantPast) > (rhs.latestRecord?.date ?? .distantPast)
            }
            return lhs.pendingReturnAmountFen > rhs.pendingReturnAmountFen
        case .receivedAmount:
            if lhs.totalReceivedFen == rhs.totalReceivedFen {
                return (lhs.latestRecord?.date ?? .distantPast) > (rhs.latestRecord?.date ?? .distantPast)
            }
            return lhs.totalReceivedFen > rhs.totalReceivedFen
        }
    }
}
