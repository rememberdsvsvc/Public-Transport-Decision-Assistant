//
//  SharedContentComponents.swift
//  transport-disruption-app
//

import SwiftUI

struct AppPageContainer<Content: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let content: Content

    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.extraLarge) { content }
                .appPageWidth()
                .padding(.vertical, AppSpacing.extraLarge)
        }
        .background(AppColor.pageBackground.ignoresSafeArea())
        .transaction { transaction in
            if reduceMotion { transaction.animation = nil }
        }
    }
}

struct PageHeader: View {
    let title: String
    let subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text(title).font(AppTypography.pageTitle).foregroundStyle(AppColor.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(subtitle).font(.system(.body, design: .rounded)).foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var systemImage: String? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            if let systemImage {
                Label(title, systemImage: systemImage).font(AppTypography.sectionTitle)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text(title).font(AppTypography.sectionTitle)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let subtitle {
                Text(subtitle).font(AppTypography.supporting).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

struct StatusBadge: View {
    let status: PresentationStatus
    var body: some View {
        Label(status.label, systemImage: status.systemImage)
            .font(.system(.caption, design: .rounded, weight: .semibold))
            .foregroundStyle(status.foregroundStyle)
            .padding(.horizontal, AppSpacing.small).padding(.vertical, 6)
            .background(status.backgroundStyle, in: Capsule())
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Status: \(status.label)")
    }
}

struct JourneyEmphasisBadge: View {
    let emphasis: JourneyEmphasis
    var body: some View {
        Label(emphasis.label, systemImage: emphasis.systemImage)
            .font(.system(.caption, design: .rounded, weight: .semibold))
            .foregroundStyle(AppColor.ink)
            .padding(.horizontal, AppSpacing.small).padding(.vertical, 6)
            .background(emphasis.backgroundStyle, in: Capsule())
            .overlay { Capsule().stroke(AppColor.ink.opacity(0.18), lineWidth: 1) }
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityElement(children: .combine)
    }
}

struct MetricTile: View {
    let title: String
    let value: String
    var systemImage: String? = nil
    var tone: AppSurfaceTone = .standard
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            if let systemImage {
                Label(title, systemImage: systemImage).font(AppTypography.metadata).foregroundStyle(.secondary)
            } else {
                Text(title).font(AppTypography.metadata).foregroundStyle(.secondary)
            }
            Text(value).font(AppTypography.cardTitle).foregroundStyle(AppColor.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .appCard(tone: tone, cornerRadius: AppCornerRadius.medium)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

struct MetricColumn: View {
    let title: String
    let value: String
    var systemImage: String? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
            if let systemImage {
                Label(title, systemImage: systemImage).font(AppTypography.metadata).foregroundStyle(.secondary)
            } else {
                Text(title).font(AppTypography.metadata).foregroundStyle(.secondary)
            }
            Text(value).font(AppTypography.cardTitle).foregroundStyle(AppColor.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

struct PrimaryActionButton: View {
    let title: String
    var systemImage: String? = nil
    var trailingSystemImage: String? = "arrow.right"
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.small) {
                if let systemImage { Image(systemName: systemImage) }
                Text(title).fixedSize(horizontal: false, vertical: true)
                if trailingSystemImage != nil { Spacer(minLength: AppSpacing.small) }
                if let trailingSystemImage { Image(systemName: trailingSystemImage) }
            }
        }
        .buttonStyle(PrimaryActionButtonStyle())
        .accessibilityLabel(title)
    }
}

struct SecondaryActionButton: View {
    let title: String
    var systemImage: String? = nil
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            if let systemImage { Label(title, systemImage: systemImage) } else { Text(title) }
        }
        .buttonStyle(SecondaryActionButtonStyle())
        .accessibilityLabel(title)
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    var body: some View {
        VStack(spacing: AppSpacing.medium) {
            Image(systemName: systemImage)
                .font(.system(.largeTitle, design: .rounded))
                .foregroundStyle(AppColor.information)
                .frame(minWidth: AppLayout.minimumTouchTarget, minHeight: AppLayout.minimumTouchTarget)
                .accessibilityHidden(true)
            Text(title).font(AppTypography.cardTitle).multilineTextAlignment(.center)
            Text(message).font(AppTypography.supporting).foregroundStyle(.secondary)
                .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, AppSpacing.extraLarge)
        .appCard(tone: .information)
        .accessibilityElement(children: .combine)
    }
}

struct InformationNotice: View {
    let title: String
    let message: String
    var status: PresentationStatus = .information("Information")
    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.medium) {
            Image(systemName: status.systemImage).font(.headline).foregroundStyle(status.foregroundStyle)
                .frame(minWidth: AppLayout.minimumTouchTarget, minHeight: AppLayout.minimumTouchTarget, alignment: .top)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
                Text(title).font(AppTypography.cardTitle).foregroundStyle(AppColor.ink)
                Text(message).font(AppTypography.supporting).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .appCard(background: status.backgroundStyle, cornerRadius: AppCornerRadius.medium)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(status.label). \(title). \(message)")
    }
}

#Preview("Shared content") {
    AppPageContainer {
        PageHeader(title: "Disruption Information", subtitle: "Review what has happened and how it affects your current journey.")
        SectionHeader(title: "Available Options", subtitle: "Compare departure, arrival, transfers and disruption impact.", systemImage: "arrow.triangle.branch")
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: AppSpacing.medium)]) {
            MetricTile(title: "Departure", value: "8:10 AM", systemImage: "clock")
            MetricTile(title: "Expected arrival", value: "9:05 AM", tone: .information)
            MetricTile(title: "Recommendation", value: "Change at Cultural Centre", tone: .emphasized)
        }
        PrimaryActionButton(title: "Compare My Options", systemImage: "arrow.triangle.branch") {}
        SecondaryActionButton(title: "Keep Current Journey", systemImage: "location.fill") {}
    }
}

#Preview("Status, long text and accessibility") {
    AppPageContainer {
        ViewThatFits(in: .horizontal) {
            HStack { statusSamples }
            VStack(alignment: .leading) { statusSamples }
        }
        InformationNotice(title: "Current journey unavailable", message: "At least one required service has been cancelled. This intentionally long message verifies that narrow layouts and large text preserve every important detail.", status: .cancelled())
        EmptyStateView(title: "No Available Options", message: "No suitable journeys are currently available within the comparison window. Try changing your selected time.", systemImage: "exclamationmark.triangle")
    }
    .preferredColorScheme(.dark)
    .environment(\.dynamicTypeSize, .accessibility2)
}

@ViewBuilder private var statusSamples: some View {
    StatusBadge(status: .normal())
    StatusBadge(status: .delayed("18 min delay"))
    StatusBadge(status: .majorDisruption())
    StatusBadge(status: .cancelled())
}
