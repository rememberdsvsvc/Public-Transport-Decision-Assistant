//
//  DisruptionInformationView.swift
//  transport-disruption-app
//

import SwiftUI

struct DisruptionInformationView: View {
    @Binding var journey: Journey
    @State private var goToDecisionSupport = false

    var body: some View {
        ZStack {
            AppColor.pageBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.section) {
                    PageHeader(
                        title: "Disruption Information",
                        subtitle: "Review what has happened, where the journey is affected, and what you can do next."
                    )

                    if let currentJourney = journey.selectedJourney {
                        disruptionConclusion(currentJourney)
                        journeyImpact(currentJourney)
                        affectedSegments(currentJourney)
                        completeJourney(currentJourney)
                        comparisonAction(currentJourney)
                    } else {
                        EmptyStateView(
                            title: "No Current Journey",
                            message: "Return to the previous page and select your current journey first.",
                            systemImage: "exclamationmark.circle"
                        )
                    }
                }
                .appPageWidth()
                .padding(.vertical, AppSpacing.extraLarge)
            }
        }
        .fontDesign(.rounded)
        .navigationDestination(isPresented: $goToDecisionSupport) {
            DecisionSupportView(journey: $journey)
        }
    }

    // MARK: - Disruption Conclusion

    @ViewBuilder
    private func disruptionConclusion(_ option: JourneyOption) -> some View {
        InformationNotice(
            title: option.hasDisruption
                ? disruptionHeadline(for: option)
                : "No significant disruption is currently affecting this journey.",
            message: option.hasDisruption
                ? disruptionExplanation(for: option)
                : journeyImpactMessage(for: option),
            status: journeyStatus(for: option)
        )
    }

    // MARK: - Overall Impact

    @ViewBuilder
    private func journeyImpact(_ option: JourneyOption) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.large) {
            SectionHeader(
                title: "Overall Impact",
                subtitle: "Compare the original arrival with the latest expected outcome.",
                systemImage: "clock.arrow.circlepath"
            )

            LazyVGrid(
                columns: impactColumns,
                alignment: .leading,
                spacing: AppSpacing.large
            ) {
                MetricColumn(
                    title: "Scheduled arrival",
                    value: scheduledArrivalText(for: option),
                    systemImage: "calendar"
                )

                MetricColumn(
                    title: "Expected arrival",
                    value: option.expectedArrival,
                    systemImage: "clock"
                )

                MetricColumn(
                    title: "Total journey delay",
                    value: journeyDelayText(for: option),
                    systemImage: journeyImpactIcon(for: option)
                )
            }

            Divider()

            Label(
                journeyImpactMessage(for: option),
                systemImage: journeyImpactIcon(for: option)
            )
            .font(AppTypography.supporting)
            .foregroundStyle(journeyImpactColour(for: option))
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityElement(children: .combine)
        }
        .appCard(background: impactSurface(for: option))
    }

    // MARK: - Affected Segments

    @ViewBuilder
    private func affectedSegments(_ option: JourneyOption) -> some View {
        if option.hasDisruption {
            JourneyTimeline(
                title: "Affected Segments",
                segments: disruptedSegments(in: option)
                    .map(segmentPresentation)
            )
        } else {
            InformationNotice(
                title: "No Affected Segments",
                message: "Every segment in the current journey is reporting normal service.",
                status: .normal("All segments normal")
            )
        }
    }

    // MARK: - Complete Journey Context

    @ViewBuilder
    private func completeJourney(_ option: JourneyOption) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.large) {
            SectionHeader(
                title: "Full Journey Context",
                subtitle: "All legs from \(option.origin) to \(option.destination), including unaffected connections.",
                systemImage: "point.topleft.down.to.point.bottomright.curvepath"
            )
            .padding(AppSpacing.large)
            .background(AppColor.aliceBlue)
            .clipShape(
                RoundedRectangle(cornerRadius: AppCornerRadius.large)
            )

            JourneySummary(
                title: "Your Current Journey",
                systemImage: option.firstSegment?.transportIcon
                    ?? "location.fill",
                route: option.routeSummary,
                origin: option.origin,
                destination: option.destination,
                metrics: [
                    JourneyMetric(
                        title: "Departure",
                        value: scheduledDepartureText(for: option),
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
                        title: "Journey time",
                        value: "\(option.totalMinutes) min",
                        systemImage: "clock"
                    )
                ],
                status: journeyStatus(for: option)
            )

            JourneyTimeline(
                title: "Complete Journey",
                segments: option.orderedSegments
                    .map(segmentPresentation)
            )
        }
    }

    // MARK: - Comparison Action

    @ViewBuilder
    private func comparisonAction(_ option: JourneyOption) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            SectionHeader(
                title: "Next Step",
                subtitle: "Compare the available journeys before deciding how to continue."
            )

            PrimaryActionButton(
                title: "Compare My Options",
                systemImage: "arrow.triangle.branch"
            ) {
                loadDecisionOptions(currentJourney: option)
            }
            .tint(AppColor.ink)
        }
        .padding(AppSpacing.large)
        .background(AppColor.vanilla)
        .clipShape(
            RoundedRectangle(cornerRadius: AppCornerRadius.large)
        )
    }

    // MARK: - Presentation Mapping

    private var impactColumns: [GridItem] {
        [
            GridItem(
                .adaptive(minimum: 140),
                spacing: AppSpacing.large,
                alignment: .top
            )
        ]
    }

    private func segmentPresentation(
        _ segment: JourneySegment
    ) -> JourneySegmentPresentation {
        JourneySegmentPresentation(
            systemImage: segment.transportIcon,
            route: segment.routeDisplayText,
            origin: segment.origin,
            destination: segment.destination,
            departure: segment.departureText,
            arrival: segment.arrivalText,
            status: segmentStatus(for: segment)
        )
    }

    private func segmentStatus(
        for segment: JourneySegment
    ) -> PresentationStatus {
        if segment.isCancelled {
            return .cancelled()
        }

        if segment.delayMinutes > 0 {
            return .delayed(
                "\(segment.disruptionType) • \(segment.delayMinutes) min delay"
            )
        }

        if segment.disruptionType != "Normal Service" {
            return .delayed(segment.disruptionType)
        }

        return .normal("Normal service")
    }

    private func journeyStatus(
        for option: JourneyOption
    ) -> PresentationStatus {
        if option.isCancelled {
            return .cancelled("Journey unavailable")
        }

        if option.hasDisruption {
            return .delayed(journeyDelayText(for: option))
        }

        return .normal("On time")
    }

    private func impactSurface(for option: JourneyOption) -> Color {
        if option.isCancelled {
            return AppColor.critical.opacity(0.13)
        }

        if option.hasDisruption {
            return AppColor.warning.opacity(0.14)
        }

        return AppColor.honeydew
    }

    // MARK: - Load Decision Options

    private func loadDecisionOptions(
        currentJourney: JourneyOption
    ) {
        let options =
            DatabaseManager
                .shared
                .findDecisionOptions(
                    currentJourney: currentJourney,
                    selectedTime: journey.selectedTime
                )

        journey.setAlternativeOptions(options)
        goToDecisionSupport = true
    }

    // MARK: - Disrupted Segments

    private func disruptedSegments(
        in option: JourneyOption
    ) -> [JourneySegment] {
        option
            .orderedSegments
            .filter {
                $0.isCancelled
                || $0.delayMinutes > 0
                || $0.disruptionType != "Normal Service"
            }
    }

    // MARK: - Disruption Text

    private func disruptionHeadline(
        for option: JourneyOption
    ) -> String {
        let affected =
            disruptedSegments(in: option)

        if affected.contains(where: { $0.isCancelled }) {
            return "Part of your journey has been cancelled."
        }

        if affected.count == 1 {
            return "A service in your journey is disrupted."
        }

        return "\(affected.count) parts of your journey are affected."
    }

    private func disruptionExplanation(
        for option: JourneyOption
    ) -> String {
        let affected =
            disruptedSegments(in: option)

        if affected.contains(where: { $0.isCancelled }) {
            return "Your current journey can no longer be completed as originally planned. Compare the available alternatives before continuing."
        }

        if option.totalDelayMinutes > 0 {
            return "Your journey is still available, but disruption is expected to affect your arrival time."
        }

        return "Service conditions have changed on part of your journey. Review the affected service before deciding whether to continue."
    }

    // MARK: - Journey Timing

    private func scheduledDepartureText(
        for option: JourneyOption
    ) -> String {
        guard let first =
                option.orderedSegments.first
        else {
            return option.expectedDeparture
        }

        return first.scheduledDeparture
            ?? first.expectedDeparture
            ?? option.expectedDeparture
    }

    private func scheduledArrivalText(
        for option: JourneyOption
    ) -> String {
        guard let last =
                option.orderedSegments.last
        else {
            return option.expectedArrival
        }

        return last.scheduledArrival
            ?? last.expectedArrival
            ?? option.expectedArrival
    }

    private func calculatedArrivalDelay(
        for option: JourneyOption
    ) -> Int {
        let scheduled =
            scheduledArrivalText(for: option)
        let expected =
            option.expectedArrival
        let scheduledMinutes =
            minutesFromTimeString(scheduled)
        let expectedMinutes =
            minutesFromTimeString(expected)

        guard
            scheduledMinutes >= 0,
            expectedMinutes >= 0
        else {
            return option.totalDelayMinutes
        }

        if expectedMinutes >= scheduledMinutes {
            return expectedMinutes - scheduledMinutes
        }

        return (1440 - scheduledMinutes) + expectedMinutes
    }

    private func journeyDelayText(
        for option: JourneyOption
    ) -> String {
        if option.isCancelled {
            return "Journey unavailable"
        }

        let delay =
            calculatedArrivalDelay(for: option)

        if delay <= 0 {
            return "No arrival delay"
        }

        return "+\(delay) min"
    }

    // MARK: - Journey Impact

    private func journeyImpactMessage(
        for option: JourneyOption
    ) -> String {
        if option.isCancelled {
            return "At least one required service is cancelled, so this journey is no longer available as originally planned."
        }

        let delay =
            calculatedArrivalDelay(for: option)

        if delay <= 0 {
            return "Your expected arrival time is currently close to the original schedule."
        }

        if delay <= 5 {
            return "The disruption has a small impact on your expected arrival time."
        }

        if delay <= 15 {
            return "The disruption causes a noticeable delay. Comparing alternatives may help you decide whether to continue."
        }

        return "The disruption has a substantial impact on your journey. Consider the available alternatives before continuing."
    }

    private func journeyImpactColour(
        for option: JourneyOption
    ) -> Color {
        if option.isCancelled {
            return AppColor.critical
        }

        let delay =
            calculatedArrivalDelay(for: option)

        if delay <= 0 {
            return AppColor.success
        }

        if delay <= 15 {
            return AppColor.warning
        }

        return AppColor.critical
    }

    private func journeyImpactIcon(
        for option: JourneyOption
    ) -> String {
        if option.isCancelled {
            return "xmark.circle.fill"
        }

        let delay =
            calculatedArrivalDelay(for: option)

        if delay <= 0 {
            return "checkmark.circle.fill"
        }

        return "exclamationmark.triangle.fill"
    }

    // MARK: - Time Helper

    private func minutesFromTimeString(
        _ time: String
    ) -> Int {
        let components =
            time.split(separator: ":")

        guard
            components.count >= 2,
            let hour = Int(components[0]),
            let minute = Int(components[1])
        else {
            return -1
        }

        return hour * 60 + minute
    }
}
