//
//  JourneyPresentationComponents.swift
//  transport-disruption-app
//

import SwiftUI

struct JourneyMetric {
    let title: String
    let value: String
    var systemImage: String? = nil
}

struct JourneySegmentPresentation {
    let systemImage: String
    let route: String
    let origin: String
    let destination: String
    let departure: String
    let arrival: String
    let status: PresentationStatus
    var connectionLabel: String? = nil
}

struct JourneySummary: View {
    let title: String
    let systemImage: String
    let route: String
    let origin: String
    let destination: String
    let metrics: [JourneyMetric]
    var status: PresentationStatus? = nil
    var emphases: Set<JourneyEmphasis> = []

    private let columns = [GridItem(.adaptive(minimum: 128), spacing: AppSpacing.large, alignment: .top)]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.large) {
            badgeRow
            summaryHeader
            Divider()
            LazyVGrid(columns: columns, alignment: .leading, spacing: AppSpacing.large) {
                ForEach(Array(metrics.enumerated()), id: \.offset) { _, metric in
                    MetricColumn(title: metric.title, value: metric.value, systemImage: metric.systemImage)
                }
            }
        }
        .appCard(background: backgroundStyle, showsBorder: true)
        .overlay {
            if emphases.contains(.selected) {
                RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                    .stroke(AppColor.ink, lineWidth: 2)
            }
        }
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder private var badgeRow: some View {
        if !emphases.isEmpty {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: AppSpacing.small) { emphasisBadges; Spacer(minLength: 0) }
                VStack(alignment: .leading, spacing: AppSpacing.small) { emphasisBadges }
            }
        }
    }

    @ViewBuilder private var emphasisBadges: some View {
        ForEach(orderedEmphases, id: \.self) { JourneyEmphasisBadge(emphasis: $0) }
    }

    private var summaryHeader: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: AppSpacing.medium) {
                summaryIdentity
                Spacer(minLength: AppSpacing.small)
                statusBadge
            }
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                summaryIdentity
                statusBadge
            }
        }
    }

    private var summaryIdentity: some View {
        HStack(alignment: .top, spacing: AppSpacing.medium) {
            Image(systemName: systemImage).font(.headline).foregroundStyle(AppColor.controlForeground)
                .frame(width: AppLayout.iconSize, height: AppLayout.iconSize)
                .background(AppColor.ink, in: Circle()).accessibilityHidden(true)
            VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
                Text(title).font(AppTypography.metadata).foregroundStyle(.secondary)
                Text(route).font(AppTypography.cardTitle).fixedSize(horizontal: false, vertical: true)
                Text("\(origin) to \(destination)").font(AppTypography.supporting).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder private var statusBadge: some View {
        if let status { StatusBadge(status: status) }
    }

    private var orderedEmphases: [JourneyEmphasis] { JourneyEmphasis.allCases.filter(emphases.contains) }

    private var backgroundStyle: Color {
        if emphases.contains(.selected) || emphases.contains(.recommended) { return AppColor.vanilla }
        if emphases.contains(.currentJourney) { return AppColor.aliceBlue }
        return AppColor.surface
    }
}

struct JourneyTimeline: View {
    let title: String
    let segments: [JourneySegmentPresentation]
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title).font(AppTypography.cardTitle).padding(.bottom, AppSpacing.small)
                .accessibilityAddTraits(.isHeader)
            ForEach(Array(segments.enumerated()), id: \.offset) { index, segment in
                segmentRow(segment)
                if index < segments.count - 1 { connector(label: segment.connectionLabel) }
            }
        }
        .appCard(tone: .standard)
    }

    private func segmentRow(_ segment: JourneySegmentPresentation) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.medium) {
            Image(systemName: segment.systemImage).font(.headline).foregroundStyle(AppColor.controlForeground)
                .frame(width: AppLayout.iconSize, height: AppLayout.iconSize)
                .background(AppColor.ink, in: Circle()).accessibilityHidden(true)
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .firstTextBaseline, spacing: AppSpacing.small) {
                        Text(segment.route).font(AppTypography.cardTitle).fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: AppSpacing.small)
                        StatusBadge(status: segment.status)
                    }
                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        Text(segment.route).font(AppTypography.cardTitle).fixedSize(horizontal: false, vertical: true)
                        StatusBadge(status: segment.status)
                    }
                }
                Text("\(segment.origin) to \(segment.destination)").font(AppTypography.supporting)
                    .foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: AppSpacing.large) {
                        Label(segment.departure, systemImage: "arrow.up.right")
                        Label(segment.arrival, systemImage: "arrow.down.right")
                    }
                    VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
                        Label(segment.departure, systemImage: "arrow.up.right")
                        Label(segment.arrival, systemImage: "arrow.down.right")
                    }
                }
                .font(AppTypography.metadata).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, AppSpacing.small)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(segment.route), \(segment.origin) to \(segment.destination), departure \(segment.departure), arrival \(segment.arrival), \(segment.status.label)")
    }

    private func connector(label: String?) -> some View {
        HStack(spacing: AppSpacing.medium) {
            Rectangle().fill(AppColor.separator).frame(width: 2, height: 24).frame(width: AppLayout.iconSize)
            Text(label ?? "Continue").font(AppTypography.metadata).foregroundStyle(.secondary)
            Spacer()
        }
        .accessibilityHidden(true)
    }
}

#Preview("Journey option states") {
    AppPageContainer {
        JourneySummary(
            title: "Option 1", systemImage: "bus.fill", route: "Route 66 via Cultural Centre",
            origin: "University of Queensland Lakes", destination: "Brisbane City",
            metrics: previewMetrics, status: .normal(), emphases: [.recommended, .selected]
        )
        JourneySummary(
            title: "Original plan", systemImage: "tram.fill",
            route: "Ipswich Line with an intentionally long service description",
            origin: "Roma Street", destination: "Indooroopilly Station", metrics: previewMetrics,
            status: .majorDisruption("Major disruption: multiple services affected"), emphases: [.currentJourney]
        )
    }
    .environment(\.dynamicTypeSize, .accessibility1)
}

#Preview("Journey timeline states") {
    AppPageContainer {
        JourneyTimeline(title: "Journey details", segments: [
            JourneySegmentPresentation(
                systemImage: "figure.walk", route: "Walk to the outbound platform",
                origin: "University of Queensland Lakes", destination: "UQ Lakes Station",
                departure: "8:02 AM", arrival: "8:08 AM", status: .normal("On time"), connectionLabel: "Continue"
            ),
            JourneySegmentPresentation(
                systemImage: "bus.fill", route: "Route 66 via Cultural Centre and an intentionally long service description",
                origin: "UQ Lakes Station", destination: "King George Square Station",
                departure: "8:10 AM", arrival: "9:05 AM", status: .delayed("18 min delay"), connectionLabel: "Transfer"
            ),
            JourneySegmentPresentation(
                systemImage: "tram.fill", route: "Ipswich Line", origin: "Roma Street",
                destination: "Indooroopilly", departure: "9:12 AM", arrival: "9:29 AM", status: .cancelled()
            )
        ])
    }
    .preferredColorScheme(.dark)
    .environment(\.dynamicTypeSize, .accessibility2)
}

private let previewMetrics = [
    JourneyMetric(title: "Departure", value: "8:10 AM", systemImage: "clock"),
    JourneyMetric(title: "Expected arrival", value: "9:05 AM"),
    JourneyMetric(title: "Transfers", value: "Direct"),
    JourneyMetric(title: "Duration", value: "55 min")
]
