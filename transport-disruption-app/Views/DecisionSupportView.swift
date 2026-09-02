//
//  DecisionSupportView.swift
//  transport-disruption-app
//

import SwiftUI

struct DecisionSupportView: View {
    @Binding var journey: Journey
    @State private var goToEvaluation = false

    private let metricColumns = [
        GridItem(
            .adaptive(minimum: 128),
            spacing: AppSpacing.large,
            alignment: .top
        )
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.section) {
                PageHeader(
                    title: "Decision Support",
                    subtitle: "Compare your current journey with available alternatives before deciding what to do next."
                )

                if let currentJourney = journey.selectedJourney {
                    currentSituation(currentJourney)
                }

                InformationNotice(
                    title: "How options are compared",
                    message: "Options are ordered by expected arrival time, transfers, disruption delay and total journey time."
                )

                optionsSection

                if let selectedOption = journey.selectedOption {
                    selectionSummary(selectedOption)

                    PrimaryActionButton(
                        title: "Confirm My Choice",
                        systemImage: "checkmark.circle.fill"
                    ) {
                        goToEvaluation = true
                    }
                }
            }
            .appPageWidth()
            .padding(.vertical, AppSpacing.extraLarge)
        }
        .background(AppColor.pageBackground.ignoresSafeArea())
        .navigationDestination(isPresented: $goToEvaluation) {
            EvaluationView(journey: $journey)
        }
    }

    private var displayedOptions: [JourneyOption] {
        Array(journey.alternativeOptions.prefix(5))
    }

    @ViewBuilder
    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.large) {
            SectionHeader(
                title: "Available Options",
                subtitle: "Select the journey that best fits your priorities.",
                systemImage: "arrow.triangle.branch"
            )

            if displayedOptions.isEmpty {
                EmptyStateView(
                    title: "No Available Options",
                    message: "No suitable journeys are currently available for comparison.",
                    systemImage: "exclamationmark.triangle"
                )
            } else {
                ForEach(Array(displayedOptions.enumerated()), id: \.element.id) { index, option in
                    decisionOptionCard(option: option, rank: index)
                }
            }
        }
    }

    private func currentSituation(_ option: JourneyOption) -> some View {
        JourneySummary(
            title: "Current situation",
            systemImage: mainTransportIcon(for: option),
            route: option.routeSummary,
            origin: option.origin,
            destination: option.destination,
            metrics: comparisonMetrics(for: option),
            status: serviceStatus(for: option)
        )
    }

    private func decisionOptionCard(
        option: JourneyOption,
        rank: Int
    ) -> some View {
        let isSelected = journey.selectedOption?.id == option.id
        let isCurrent = journey.isCurrentJourney(option)

        return Button {
            journey.toggleOption(option)
        } label: {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                optionStateLabels(
                    rank: rank,
                    isCurrent: isCurrent,
                    isSelected: isSelected
                )

                routeIdentity(option)

                Divider()

                LazyVGrid(
                    columns: metricColumns,
                    alignment: .leading,
                    spacing: AppSpacing.large
                ) {
                    ForEach(Array(comparisonMetrics(for: option).enumerated()), id: \.offset) { _, metric in
                        MetricColumn(
                            title: metric.title,
                            value: metric.value,
                            systemImage: metric.systemImage
                        )
                    }
                }

                if option.orderedSegments.count > 1 {
                    Divider()

                    journeySegments(option.orderedSegments)
                }
            }
            .appCard(
                background: isSelected
                    ? AppColor.accent.opacity(0.08)
                    : AppColor.surface,
                showsBorder: true
            )
            .overlay {
                RoundedRectangle(cornerRadius: AppCornerRadius.large)
                    .stroke(
                        isSelected ? AppColor.accent : Color.clear,
                        lineWidth: 2
                    )
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel(for: option, rank: rank))
        .accessibilityHint("Double tap to \(isSelected ? "deselect" : "select") this journey.")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func optionStateLabels(
        rank: Int,
        isCurrent: Bool,
        isSelected: Bool
    ) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: AppSpacing.small) {
                stateBadges(rank: rank, isCurrent: isCurrent, isSelected: isSelected)
                Spacer(minLength: 0)
            }

            VStack(alignment: .leading, spacing: AppSpacing.small) {
                stateBadges(rank: rank, isCurrent: isCurrent, isSelected: isSelected)
            }
        }
    }

    @ViewBuilder
    private func stateBadges(
        rank: Int,
        isCurrent: Bool,
        isSelected: Bool
    ) -> some View {
        if rank == 0 {
            JourneyEmphasisBadge(emphasis: .recommended)
        }

        if isCurrent {
            JourneyEmphasisBadge(emphasis: .currentJourney)
        }

        if isSelected {
            JourneyEmphasisBadge(emphasis: .selected)
        }
    }

    private func routeIdentity(_ option: JourneyOption) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.medium) {
            Image(systemName: mainTransportIcon(for: option))
                .font(.title2)
                .foregroundStyle(AppColor.accent)
                .frame(width: AppLayout.iconSize, height: AppLayout.iconSize)
                .background(AppColor.accent.opacity(0.10))
                .clipShape(Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
                Text(option.transportModeText)
                    .font(AppTypography.metadata)
                    .foregroundStyle(.secondary)

                Text(option.routeSummary)
                    .font(AppTypography.cardTitle)
                    .fixedSize(horizontal: false, vertical: true)

                Text("\(option.origin) to \(option.destination)")
                    .font(AppTypography.supporting)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: AppSpacing.small)
        }
    }

    private func selectionSummary(_ option: JourneyOption) -> some View {
        InformationNotice(
            title: "Selected Journey",
            message: "\(option.routeSummary), arriving at \(option.expectedArrival).",
            status: .success("Selected")
        )
    }

    private func journeySegments(_ segments: [JourneySegment]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Text("Journey details")
                .font(AppTypography.cardTitle)

            ForEach(segments) { segment in
                HStack(alignment: .top, spacing: AppSpacing.medium) {
                    Image(systemName: segment.transportIcon)
                        .foregroundStyle(serviceStatus(for: segment).foregroundStyle)
                        .frame(width: AppLayout.iconSize)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
                        Text(segment.routeDisplayText)
                            .font(AppTypography.cardTitle)

                        Text("\(segment.origin) to \(segment.destination)")
                            .font(AppTypography.supporting)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        StatusBadge(status: serviceStatus(for: segment))
                    }
                }
                .accessibilityElement(children: .combine)
            }
        }
    }

    private func comparisonMetrics(for option: JourneyOption) -> [JourneyMetric] {
        var metrics = [
            JourneyMetric(
                title: "Departure",
                value: departureText(for: option),
                systemImage: "arrow.up.right"
            ),
            JourneyMetric(
                title: "Expected arrival",
                value: option.expectedArrival,
                systemImage: "arrow.down.right"
            ),
            JourneyMetric(
                title: "Transfers",
                value: option.transferText,
                systemImage: "arrow.triangle.branch"
            ),
            JourneyMetric(
                title: "Duration",
                value: "\(option.totalMinutes) min",
                systemImage: "clock"
            ),
            JourneyMetric(
                title: "Delay",
                value: option.delayText,
                systemImage: "clock.badge.exclamationmark"
            )
        ]

        if option.walkingMinutes > 0 {
            metrics.append(
                JourneyMetric(
                    title: "Walking",
                    value: "\(option.walkingMinutes) min",
                    systemImage: "figure.walk"
                )
            )
        }

        return metrics
    }

    private func serviceStatus(for option: JourneyOption) -> PresentationStatus {
        if option.isCancelled {
            return .cancelled("Unavailable")
        }

        if option.hasDisruption {
            return .delayed(option.delayText)
        }

        return .normal("On time")
    }

    private func serviceStatus(for segment: JourneySegment) -> PresentationStatus {
        if segment.isCancelled {
            return .cancelled()
        }

        if segment.delayMinutes > 0 || segment.disruptionType != "Normal Service" {
            return .delayed(
                segment.delayMinutes > 0
                    ? "\(segment.delayMinutes) min delay"
                    : segment.disruptionType
            )
        }

        return .normal("On time")
    }

    private func departureText(for option: JourneyOption) -> String {
        option.firstSegment?.scheduledDeparture
            ?? option.firstSegment?.expectedDeparture
            ?? option.expectedDeparture
    }

    private func mainTransportIcon(for option: JourneyOption) -> String {
        option.firstSegment?.transportIcon ?? "arrow.triangle.branch"
    }

    private func accessibilityLabel(for option: JourneyOption, rank: Int) -> String {
        let recommendation = rank == 0 ? "Recommended option. " : ""
        let current = journey.isCurrentJourney(option) ? "Current journey. " : ""

        return "\(recommendation)\(current)\(option.routeSummary), from \(option.origin) to \(option.destination), expected arrival \(option.expectedArrival), \(option.transferText), \(option.delayText)."
    }
}
