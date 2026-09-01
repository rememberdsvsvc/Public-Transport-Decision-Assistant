//
//  DisruptionInformationView.swift
//  transport-disruption-app
//

import SwiftUI


struct DisruptionInformationView: View {

    @Binding var journey: Journey

    @State private var goToDecisionSupport =
        false


    // ========================================================
    // MARK: - Body
    // ========================================================

    var body: some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: 24
            ) {

                // =================================================
                // MARK: Page Header
                // =================================================

                VStack(
                    alignment: .leading,
                    spacing: 8
                ) {

                    Text(
                        "Disruption Information"
                    )
                    .font(.largeTitle)
                    .fontWeight(.bold)


                    Text(
                        "Review what has happened and how it affects your current journey."
                    )
                    .foregroundStyle(.secondary)
                }


                // =================================================
                // MARK: Current Journey
                // =================================================

                if let currentJourney =
                    journey.selectedJourney {

                    currentJourneyCard(
                        currentJourney
                    )


                    // =================================================
                    // MARK: What Happened
                    // =================================================

                    disruptionSummaryCard(
                        currentJourney
                    )


                    // =================================================
                    // MARK: Journey Impact
                    // =================================================

                    journeyImpactCard(
                        currentJourney
                    )


                    // =================================================
                    // MARK: Decision Support Button
                    // =================================================

                    Button {

                        loadDecisionOptions(
                            currentJourney:
                                currentJourney
                        )

                    } label: {

                        HStack {

                            Spacer()


                            Image(
                                systemName:
                                    "arrow.triangle.branch"
                            )


                            Text(
                                "Compare My Options"
                            )
                            .fontWeight(.semibold)


                            Image(
                                systemName:
                                    "arrow.right"
                            )


                            Spacer()
                        }
                        .padding(
                            .vertical,
                            5
                        )
                    }
                    .buttonStyle(
                        .borderedProminent
                    )


                } else {

                    // =================================================
                    // MARK: No Journey
                    // =================================================

                    noJourneyView
                }
            }
            .padding()
        }
        .navigationTitle(
            "Disruption"
        )
        .navigationBarTitleDisplayMode(
            .inline
        )
        .navigationDestination(
            isPresented:
                $goToDecisionSupport
        ) {

            DecisionSupportView(
                journey:
                    $journey
            )
        }
    }


    // ========================================================
    // MARK: - Current Journey Card
    // ========================================================

    @ViewBuilder
    private func currentJourneyCard(
        _ option: JourneyOption
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            Label(
                "Your Current Journey",
                systemImage:
                    "location.fill"
            )
            .font(.title2)
            .fontWeight(.bold)


            VStack(
                alignment: .leading,
                spacing: 6
            ) {

                Text(
                    "\(option.origin) → \(option.destination)"
                )
                .font(.headline)


                Text(
                    option.transportModeText
                )
                .font(.subheadline)
                .foregroundStyle(
                    .secondary
                )


                Text(
                    option.routeSummary
                )
                .font(.subheadline)
                .foregroundStyle(
                    .secondary
                )
            }


            Divider()


            // -------------------------------------------------
            // Overall Journey Information
            // -------------------------------------------------

            HStack(
                alignment: .top,
                spacing: 16
            ) {

                informationColumn(
                    title:
                        "Departure",

                    value:
                        scheduledDepartureText(
                            for:
                                option
                        )
                )


                informationColumn(
                    title:
                        "Expected Arrival",

                    value:
                        option.expectedArrival
                )
            }


            HStack(
                alignment: .top,
                spacing: 16
            ) {

                informationColumn(
                    title:
                        "Transfers",

                    value:
                        option.transferText
                )


                informationColumn(
                    title:
                        "Journey Time",

                    value:
                        "\(option.totalMinutes) min"
                )
            }


            // -------------------------------------------------
            // Complete Journey Segments
            // -------------------------------------------------

            Divider()


            Text(
                "Journey Details"
            )
            .font(.headline)


            VStack(
                alignment: .leading,
                spacing: 0
            ) {

                ForEach(
                    Array(
                        option
                            .orderedSegments
                            .enumerated()
                    ),
                    id: \.element.id
                ) {
                    index,
                    segment in


                    journeySegmentRow(
                        segment:
                            segment
                    )


                    if index <
                        option.orderedSegments.count - 1 {

                        connectionIndicator(
                            from:
                                segment,

                            to:
                                option.orderedSegments[
                                    index + 1
                                ]
                        )
                    }
                }
            }
        }
        .padding()
        .background(
            Color(
                .secondarySystemBackground
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 18
            )
        )
    }


    // ========================================================
    // MARK: - Journey Segment Row
    // ========================================================

    @ViewBuilder
    private func journeySegmentRow(
        segment: JourneySegment
    ) -> some View {

        HStack(
            alignment: .top,
            spacing: 14
        ) {

            // -------------------------------------------------
            // Transport Icon
            // -------------------------------------------------

            ZStack {

                Circle()
                    .fill(
                        segmentBackground(
                            for:
                                segment
                        )
                    )
                    .frame(
                        width: 42,
                        height: 42
                    )


                Image(
                    systemName:
                        segment.transportIcon
                )
                .foregroundStyle(
                    segmentForeground(
                        for:
                            segment
                    )
                )
            }


            // -------------------------------------------------
            // Segment Details
            // -------------------------------------------------

            VStack(
                alignment: .leading,
                spacing: 5
            ) {

                HStack {

                    Text(
                        segment.routeDisplayText
                    )
                    .font(.headline)


                    Spacer()


                    segmentStatusBadge(
                        segment
                    )
                }


                Text(
                    "\(segment.origin) → \(segment.destination)"
                )
                .font(.subheadline)
                .foregroundStyle(
                    .secondary
                )


                HStack(
                    spacing: 16
                ) {

                    Label(
                        segment.departureText,
                        systemImage:
                            "arrow.up.right"
                    )


                    Label(
                        segment.arrivalText,
                        systemImage:
                            "arrow.down.right"
                    )
                }
                .font(.caption)
                .foregroundStyle(
                    .secondary
                )


                if segment.delayMinutes > 0 {

                    Label(
                        "\(segment.delayMinutes) min delay",
                        systemImage:
                            "clock.badge.exclamationmark"
                    )
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        .orange
                    )
                }


                if segment.isCancelled {

                    Label(
                        "This service is unavailable",
                        systemImage:
                            "xmark.circle.fill"
                    )
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        .red
                    )
                }
            }
        }
        .padding(
            .vertical,
            8
        )
    }


    // ========================================================
    // MARK: - Connection Indicator
    // ========================================================

    @ViewBuilder
    private func connectionIndicator(
        from currentSegment: JourneySegment,
        to nextSegment: JourneySegment
    ) -> some View {

        HStack(
            spacing: 12
        ) {

            Rectangle()
                .fill(
                    Color.secondary.opacity(
                        0.3
                    )
                )
                .frame(
                    width: 2,
                    height: 28
                )
                .padding(
                    .leading,
                    20
                )


            if !currentSegment.isWalking &&
                !nextSegment.isWalking {

                Label(
                    "Transfer",
                    systemImage:
                        "arrow.triangle.swap"
                )
                .font(.caption)
                .foregroundStyle(
                    .secondary
                )

            } else {

                Text(
                    "Continue"
                )
                .font(.caption)
                .foregroundStyle(
                    .secondary
                )
            }


            Spacer()
        }
    }


    // ========================================================
    // MARK: - Disruption Summary
    // ========================================================

    @ViewBuilder
    private func disruptionSummaryCard(
        _ option: JourneyOption
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            Label(
                "What Happened?",
                systemImage:
                    option.hasDisruption
                    ? "exclamationmark.triangle.fill"
                    : "checkmark.circle.fill"
            )
            .font(.title2)
            .fontWeight(.bold)
            .foregroundStyle(
                option.hasDisruption
                ? .orange
                : .green
            )


            if option.hasDisruption {

                Text(
                    disruptionHeadline(
                        for:
                            option
                    )
                )
                .font(.headline)


                Text(
                    disruptionExplanation(
                        for:
                            option
                    )
                )
                .font(.subheadline)
                .foregroundStyle(
                    .secondary
                )


                Divider()


                // -------------------------------------------------
                // Only show affected segments
                // -------------------------------------------------

                Text(
                    "Affected Service"
                )
                .font(.headline)


                ForEach(
                    disruptedSegments(
                        in:
                            option
                    )
                ) {
                    segment in


                    affectedSegmentRow(
                        segment
                    )
                }

            } else {

                Text(
                    "No significant disruption is currently affecting this journey."
                )
                .font(.subheadline)
                .foregroundStyle(
                    .secondary
                )
            }
        }
        .padding()
        .background(
            disruptionBackground(
                for:
                    option
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 18
            )
        )
    }


    // ========================================================
    // MARK: - Affected Segment Row
    // ========================================================

    @ViewBuilder
    private func affectedSegmentRow(
        _ segment: JourneySegment
    ) -> some View {

        HStack(
            alignment: .top,
            spacing: 12
        ) {

            Image(
                systemName:
                    segment.transportIcon
            )
            .frame(
                width: 26
            )


            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text(
                    segment.routeDisplayText
                )
                .fontWeight(.semibold)


                Text(
                    "\(segment.origin) → \(segment.destination)"
                )
                .font(.caption)
                .foregroundStyle(
                    .secondary
                )


                if segment.isCancelled {

                    Text(
                        "Cancelled"
                    )
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        .red
                    )

                } else if segment.delayMinutes > 0 {

                    Text(
                        "\(segment.disruptionType) • \(segment.delayMinutes) min delay"
                    )
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        .orange
                    )

                } else {

                    Text(
                        segment.disruptionType
                    )
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        .orange
                    )
                }
            }


            Spacer()
        }
        .padding()
        .background(
            Color(
                .systemBackground
            )
            .opacity(
                0.7
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 12
            )
        )
    }


    // ========================================================
    // MARK: - Journey Impact Card
    // ========================================================

    @ViewBuilder
    private func journeyImpactCard(
        _ option: JourneyOption
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            Label(
                "How Does This Affect Your Journey?",
                systemImage:
                    "clock.arrow.circlepath"
            )
            .font(.title2)
            .fontWeight(.bold)


            // -------------------------------------------------
            // Arrival Comparison
            // -------------------------------------------------

            HStack(
                alignment: .top,
                spacing: 16
            ) {

                informationColumn(
                    title:
                        "Scheduled Arrival",

                    value:
                        scheduledArrivalText(
                            for:
                                option
                        )
                )


                informationColumn(
                    title:
                        "Expected Arrival",

                    value:
                        option.expectedArrival
                )
            }


            Divider()


            // -------------------------------------------------
            // Delay Impact
            // -------------------------------------------------

            HStack {

                VStack(
                    alignment: .leading,
                    spacing: 5
                ) {

                    Text(
                        "Total Journey Delay"
                    )
                    .font(.caption)
                    .foregroundStyle(
                        .secondary
                    )


                    Text(
                        journeyDelayText(
                            for:
                                option
                        )
                    )
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        journeyImpactColour(
                            for:
                                option
                        )
                    )
                }


                Spacer()


                Image(
                    systemName:
                        journeyImpactIcon(
                            for:
                                option
                        )
                )
                .font(
                    .system(
                        size: 30
                    )
                )
                .foregroundStyle(
                    journeyImpactColour(
                        for:
                            option
                    )
                )
            }


            // -------------------------------------------------
            // Impact Message
            // -------------------------------------------------

            Text(
                journeyImpactMessage(
                    for:
                        option
                )
            )
            .font(.subheadline)
            .foregroundStyle(
                .secondary
            )
        }
        .padding()
        .background(
            Color(
                .secondarySystemBackground
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 18
            )
        )
    }


    // ========================================================
    // MARK: - Load Decision Options
    // ========================================================

    private func loadDecisionOptions(
        currentJourney: JourneyOption
    ) {

        let options =
            DatabaseManager
                .shared
                .findDecisionOptions(

                    currentJourney:
                        currentJourney,

                    selectedTime:
                        journey.selectedTime
                )


        journey.setAlternativeOptions(
            options
        )


        goToDecisionSupport =
            true
    }


    // ========================================================
    // MARK: - Disrupted Segments
    // ========================================================

    private func disruptedSegments(
        in option: JourneyOption
    ) -> [JourneySegment] {

        option
            .orderedSegments
            .filter {

                $0.isCancelled
                ||
                $0.delayMinutes > 0
                ||
                $0.disruptionType !=
                    "Normal Service"
            }
    }


    // ========================================================
    // MARK: - Disruption Text
    // ========================================================

    private func disruptionHeadline(
        for option: JourneyOption
    ) -> String {

        let affected =
            disruptedSegments(
                in:
                    option
            )


        if affected.contains(
            where: {
                $0.isCancelled
            }
        ) {

            return
                "Part of your journey has been cancelled."
        }


        if affected.count == 1 {

            return
                "A service in your journey is disrupted."
        }


        return
            "\(affected.count) parts of your journey are affected."
    }


    private func disruptionExplanation(
        for option: JourneyOption
    ) -> String {

        let affected =
            disruptedSegments(
                in:
                    option
            )


        if affected.contains(
            where: {
                $0.isCancelled
            }
        ) {

            return
                "Your current journey can no longer be completed as originally planned. Compare the available alternatives before continuing."
        }


        if option.totalDelayMinutes > 0 {

            return
                "Your journey is still available, but disruption is expected to affect your arrival time."
        }


        return
            "Service conditions have changed on part of your journey. Review the affected service before deciding whether to continue."
    }


    // ========================================================
    // MARK: - Journey Timing
    // ========================================================

    private func scheduledDepartureText(
        for option: JourneyOption
    ) -> String {

        guard let first =
                option.orderedSegments.first
        else {

            return
                option.expectedDeparture
        }


        return first.scheduledDeparture
            ??
            first.expectedDeparture
            ??
            option.expectedDeparture
    }


    private func scheduledArrivalText(
        for option: JourneyOption
    ) -> String {

        guard let last =
                option.orderedSegments.last
        else {

            return
                option.expectedArrival
        }


        return last.scheduledArrival
            ??
            last.expectedArrival
            ??
            option.expectedArrival
    }


    private func calculatedArrivalDelay(
        for option: JourneyOption
    ) -> Int {

        let scheduled =
            scheduledArrivalText(
                for:
                    option
            )


        let expected =
            option.expectedArrival


        let scheduledMinutes =
            minutesFromTimeString(
                scheduled
            )


        let expectedMinutes =
            minutesFromTimeString(
                expected
            )


        guard
            scheduledMinutes >= 0,
            expectedMinutes >= 0
        else {

            return
                option.totalDelayMinutes
        }


        if expectedMinutes >=
            scheduledMinutes {

            return expectedMinutes -
                scheduledMinutes
        }


        return (
            1440 -
            scheduledMinutes
        ) + expectedMinutes
    }


    private func journeyDelayText(
        for option: JourneyOption
    ) -> String {

        if option.isCancelled {

            return
                "Journey unavailable"
        }


        let delay =
            calculatedArrivalDelay(
                for:
                    option
            )


        if delay <= 0 {

            return
                "No arrival delay"
        }


        return
            "+\(delay) min"
    }


    // ========================================================
    // MARK: - Journey Impact
    // ========================================================

    private func journeyImpactMessage(
        for option: JourneyOption
    ) -> String {

        if option.isCancelled {

            return
                "At least one required service is cancelled, so this journey is no longer available as originally planned."
        }


        let delay =
            calculatedArrivalDelay(
                for:
                    option
            )


        if delay <= 0 {

            return
                "Your expected arrival time is currently close to the original schedule."
        }


        if delay <= 5 {

            return
                "The disruption has a small impact on your expected arrival time."
        }


        if delay <= 15 {

            return
                "The disruption causes a noticeable delay. Comparing alternatives may help you decide whether to continue."
        }


        return
            "The disruption has a substantial impact on your journey. Consider the available alternatives before continuing."
    }


    private func journeyImpactColour(
        for option: JourneyOption
    ) -> Color {

        if option.isCancelled {

            return
                .red
        }


        let delay =
            calculatedArrivalDelay(
                for:
                    option
            )


        if delay <= 0 {

            return
                .green
        }


        if delay <= 15 {

            return
                .orange
        }


        return
            .red
    }


    private func journeyImpactIcon(
        for option: JourneyOption
    ) -> String {

        if option.isCancelled {

            return
                "xmark.circle.fill"
        }


        let delay =
            calculatedArrivalDelay(
                for:
                    option
            )


        if delay <= 0 {

            return
                "checkmark.circle.fill"
        }


        return
            "exclamationmark.triangle.fill"
    }


    // ========================================================
    // MARK: - Segment Appearance
    // ========================================================

    private func segmentBackground(
        for segment: JourneySegment
    ) -> Color {

        if segment.isCancelled {

            return
                Color.red.opacity(
                    0.12
                )
        }


        if segment.delayMinutes > 0 ||
            segment.disruptionType !=
                "Normal Service" {

            return
                Color.orange.opacity(
                    0.12
                )
        }


        return
            Color.blue.opacity(
                0.10
            )
    }


    private func segmentForeground(
        for segment: JourneySegment
    ) -> Color {

        if segment.isCancelled {

            return
                .red
        }


        if segment.delayMinutes > 0 ||
            segment.disruptionType !=
                "Normal Service" {

            return
                .orange
        }


        return
            .blue
    }


    // ========================================================
    // MARK: - Segment Status Badge
    // ========================================================

    @ViewBuilder
    private func segmentStatusBadge(
        _ segment: JourneySegment
    ) -> some View {

        if segment.isCancelled {

            Text(
                "Cancelled"
            )
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundStyle(
                .red
            )
            .padding(
                .horizontal,
                8
            )
            .padding(
                .vertical,
                4
            )
            .background(
                Color.red.opacity(
                    0.10
                )
            )
            .clipShape(
                Capsule()
            )

        } else if segment.delayMinutes > 0 ||
                    segment.disruptionType !=
                        "Normal Service" {

            Text(
                segment.delayMinutes > 0
                ? "+\(segment.delayMinutes) min"
                : segment.disruptionType
            )
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundStyle(
                .orange
            )
            .padding(
                .horizontal,
                8
            )
            .padding(
                .vertical,
                4
            )
            .background(
                Color.orange.opacity(
                    0.10
                )
            )
            .clipShape(
                Capsule()
            )

        } else {

            Text(
                "Normal"
            )
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(
                .green
            )
            .padding(
                .horizontal,
                8
            )
            .padding(
                .vertical,
                4
            )
            .background(
                Color.green.opacity(
                    0.10
                )
            )
            .clipShape(
                Capsule()
            )
        }
    }


    // ========================================================
    // MARK: - Information Column
    // ========================================================

    @ViewBuilder
    private func informationColumn(
        title: String,
        value: String
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 4
        ) {

            Text(
                title
            )
            .font(.caption)
            .foregroundStyle(
                .secondary
            )


            Text(
                value
            )
            .font(.headline)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }


    // ========================================================
    // MARK: - Time Helper
    // ========================================================

    private func minutesFromTimeString(
        _ time: String
    ) -> Int {

        let components =
            time.split(
                separator: ":"
            )


        guard
            components.count >= 2,

            let hour =
                Int(
                    components[0]
                ),

            let minute =
                Int(
                    components[1]
                )

        else {

            return -1
        }


        return hour * 60 +
            minute
    }


    // ========================================================
    // MARK: - Disruption Background
    // ========================================================

    private func disruptionBackground(
        for option: JourneyOption
    ) -> Color {

        if option.isCancelled {

            return
                Color.red.opacity(
                    0.07
                )
        }


        if option.hasDisruption {

            return
                Color.orange.opacity(
                    0.07
                )
        }


        return
            Color.green.opacity(
                0.07
            )
    }


    // ========================================================
    // MARK: - No Journey
    // ========================================================

    private var noJourneyView:
        some View {

        VStack(
            spacing: 14
        ) {

            Image(
                systemName:
                    "exclamationmark.circle"
            )
            .font(
                .system(
                    size: 42
                )
            )
            .foregroundStyle(
                .secondary
            )


            Text(
                "No Current Journey"
            )
            .font(.headline)


            Text(
                "Return to the previous page and select your current journey first."
            )
            .font(.subheadline)
            .foregroundStyle(
                .secondary
            )
            .multilineTextAlignment(
                .center
            )
        }
        .frame(
            maxWidth: .infinity
        )
        .padding(
            .vertical,
            36
        )
        .padding()
        .background(
            Color(
                .secondarySystemBackground
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 18
            )
        )
    }
}
