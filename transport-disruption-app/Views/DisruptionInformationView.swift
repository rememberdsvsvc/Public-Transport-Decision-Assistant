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
                        disruptionMap(currentJourney)
                        journeyImpact(currentJourney)
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

    // MARK: - Disruption Map

    @ViewBuilder
    private func disruptionMap(_ option: JourneyOption) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.large) {
            SectionHeader(
                title: "Affected Route",
                subtitle: "See where the disruption occurs within your current journey.",
                systemImage: "map.fill"
            )

            JourneyMapView(
                            option: option
                        )

            if let affected = disruptedSegments(in: option).first {
                HStack(alignment: .top, spacing: AppSpacing.medium) {
                    Image(systemName: affected.isCancelled
                          ? "xmark.octagon.fill"
                          : "exclamationmark.triangle.fill")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(
                            affected.isCancelled
                            ? AppColor.critical
                            : AppColor.warning
                        )

                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        Text("Affected segment")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppColor.ink.opacity(0.72))

                        Text("\(affected.origin) → \(affected.destination)")
                            .font(.headline)

                        Text(affected.routeDisplayText)
                            .font(AppTypography.supporting)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(
                            affected.isCancelled
                            ? "Cancelled"
                            : affected.delayMinutes > 0
                                ? "\(affected.disruptionType) • +\(affected.delayMinutes) min"
                                : affected.disruptionType
                        )
                        .font(AppTypography.supporting)
                        .foregroundStyle(
                            affected.isCancelled
                            ? AppColor.critical
                            : AppColor.warning
                        )
                    }

                    Spacer()
                }
                .padding(AppSpacing.medium)
                .background(
                    affected.isCancelled
                    ? AppColor.critical.opacity(0.10)
                    : AppColor.warning.opacity(0.10)
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                )
            } else {
                Label(
                    "No affected segment is currently recorded on this journey.",
                    systemImage: "checkmark.circle.fill"
                )
                .font(AppTypography.supporting)
                .foregroundStyle(AppColor.success)
            }
        }
        .appCard(background: AppColor.pageBackground)
    }

    // MARK: - Overall Impact

    @ViewBuilder
    private func journeyImpact(_ option: JourneyOption) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.large) {

            Label(
                "Overall Impact",
                systemImage: "clock.arrow.circlepath"
            )
            .font(.title2.bold())
            .foregroundStyle(AppColor.ink)

            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: AppSpacing.large) {
                    journeyFlow(option)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Divider()

                    impactSummary(option)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                VStack(alignment: .leading, spacing: AppSpacing.large) {
                    journeyFlow(option)

                    Divider()

                    impactSummary(option)
                }
            }

            Divider()

            HStack(alignment: .top, spacing: AppSpacing.medium) {
                Image(systemName: journeyImpactIcon(for: option))
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(journeyImpactColour(for: option))
                    .frame(width: 28)

                Text(journeyImpactMessage(for: option))
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(journeyImpactColour(for: option))
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)
            }
            .padding(AppSpacing.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(journeyImpactColour(for: option).opacity(0.08))
            .clipShape(
                RoundedRectangle(cornerRadius: AppCornerRadius.large)
            )
        }
        .appCard(background: impactSurface(for: option))
    }

    // MARK: - Journey Flow

    @ViewBuilder
    private func journeyFlow(_ option: JourneyOption) -> some View {
        let segments = option.orderedSegments

        VStack(alignment: .leading, spacing: 0) {
            if let first = segments.first {
                impactStopRow(
                    time: first.departureText,
                    stopName: first.origin,
                    nodeStyle: .start
                )

                ForEach(Array(segments.enumerated()), id: \.element.id) { index, segment in
                    impactSegmentRow(segment)

                    impactStopRow(
                        time: segment.arrivalText,
                        stopName: segment.destination,
                        nodeStyle: index == segments.count - 1 ? .end : .transfer
                    )

                    if index < segments.count - 1 {
                        let next = segments[index + 1]
                        impactTransferRow(
                            from: segment,
                            to: next
                        )
                    }
                }
            } else {
                HStack(spacing: AppSpacing.medium) {
                    Image(systemName: "location.fill")
                        .foregroundStyle(AppColor.success)

                    Text(option.origin)
                        .font(AppTypography.cardTitle)
                        .foregroundStyle(AppColor.ink)

                    Image(systemName: "arrow.right")
                        .foregroundStyle(AppColor.accent)

                    Text(option.destination)
                        .font(AppTypography.cardTitle)
                        .foregroundStyle(AppColor.ink)
                }
            }
        }
    }

    private enum ImpactStopNodeStyle {
        case start
        case transfer
        case end
    }

    private func impactStopRow(
        time: String,
        stopName: String,
        nodeStyle: ImpactStopNodeStyle
    ) -> some View {
        HStack(alignment: .center, spacing: AppSpacing.medium) {
            Text(time)
                .font(.headline.monospacedDigit())
                .foregroundStyle(AppColor.ink)
                .frame(width: 58, alignment: .leading)

            Circle()
                .fill(stopNodeColour(nodeStyle))
                .frame(width: nodeStyle == .transfer ? 13 : 16,
                       height: nodeStyle == .transfer ? 13 : 16)
                .overlay {
                    if nodeStyle == .transfer {
                        Circle()
                            .stroke(AppColor.ink, lineWidth: 2)
                    }
                }
                .frame(width: 24)

            Text(stopName)
                .font(AppTypography.cardTitle)
                .foregroundStyle(AppColor.ink)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
    }

    private func impactSegmentRow(
        _ segment: JourneySegment
    ) -> some View {
        HStack(alignment: .center, spacing: AppSpacing.medium) {
            Color.clear
                .frame(width: 58, height: 1)

            VStack(spacing: 0) {
                Rectangle()
                    .fill(transportColour(for: segment))
                    .frame(width: 4, height: 18)

                Image(systemName: segment.transportIcon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(transportColour(for: segment))
                    .clipShape(Circle())

                Rectangle()
                    .fill(transportColour(for: segment))
                    .frame(width: 4, height: 18)
            }
            .frame(width: 24)

            VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
                Text(segment.routeDisplayText)
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(transportColour(for: segment))
                    .padding(.horizontal, AppSpacing.small)
                    .padding(.vertical, 4)
                    .background(
                        transportColour(for: segment).opacity(0.10)
                    )
                    .clipShape(Capsule())

                Text("\(segment.durationMinutes) min")
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColor.ink)

                if segment.isCancelled {
                    Text("Cancelled")
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColor.critical)
                } else if segment.delayMinutes > 0 {
                    Text("+\(segment.delayMinutes) min delay")
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColor.warning)
                }
            }

            Spacer(minLength: 0)
        }
    }

    private func impactTransferRow(
        from current: JourneySegment,
        to next: JourneySegment
    ) -> some View {
        let transferMinutes = transferMinutes(
            from: current,
            to: next
        )

        return HStack(alignment: .center, spacing: AppSpacing.medium) {
            Color.clear
                .frame(width: 58, height: 1)

            VStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { _ in
                    Circle()
                        .fill(AppColor.accent)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(width: 24)

            HStack(spacing: AppSpacing.small) {
                Image(systemName: "arrow.triangle.swap")
                    .foregroundStyle(AppColor.accent)

                Text(
                    transferMinutes > 0
                    ? "Transfer · \(transferMinutes) min"
                    : "Transfer"
                )
                .font(AppTypography.metadata)
                .foregroundStyle(AppColor.ink)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, AppSpacing.extraSmall)
    }

    // MARK: - Impact Summary

    private func impactSummary(
        _ option: JourneyOption
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.large) {
            impactMetric(
                title: "Scheduled arrival",
                value: scheduledArrivalText(for: option),
                systemImage: "calendar",
                colour: AppColor.success
            )

            impactMetric(
                title: "Expected arrival",
                value: option.expectedArrival,
                systemImage: "clock",
                colour: AppColor.success
            )

            impactMetric(
                title: "Total delay",
                value: journeyDelayText(for: option),
                systemImage: journeyImpactIcon(for: option),
                colour: journeyImpactColour(for: option)
            )

            impactMetric(
                title: "Transfers",
                value: "\(option.transfers)",
                systemImage: "arrow.left.arrow.right",
                colour: AppColor.accent
            )
        }
    }

    private func impactMetric(
        title: String,
        value: String,
        systemImage: String,
        colour: Color
    ) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.medium) {
            Image(systemName: systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(colour)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
                Text(title)
                    .font(AppTypography.supporting)
                    .foregroundStyle(AppColor.ink)

                Text(value)
                    .font(.title2.bold())
                    .foregroundStyle(colour)
                    .monospacedDigit()
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }

    // MARK: - Impact Helpers

    private func transferMinutes(
        from current: JourneySegment,
        to next: JourneySegment
    ) -> Int {
        let arrival = minutesFromTimeString(current.arrivalText)
        let departure = minutesFromTimeString(next.departureText)

        guard arrival >= 0, departure >= 0 else {
            return 0
        }

        return forwardMinuteDifference(
            from: arrival,
            to: departure
        )
    }

    private func transportColour(
        for segment: JourneySegment
    ) -> Color {
        switch segment.transportMode.lowercased() {
        case "train":
            return .purple
        case "ferry":
            return .cyan
        case "walk", "walking":
            return .orange
        default:
            return .blue
        }
    }

    private func stopNodeColour(
        _ style: ImpactStopNodeStyle
    ) -> Color {
        switch style {
        case .start:
            return AppColor.success
        case .transfer:
            return AppColor.surface
        case .end:
            return AppColor.success
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

    private func forwardMinuteDifference(
        from start: Int,
        to end: Int
    ) -> Int {
        if end >= start {
            return end - start
        }

        return (1440 - start) + end
    }

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


