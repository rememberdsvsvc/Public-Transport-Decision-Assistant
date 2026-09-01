//
//  DecisionSupportView.swift
//  transport-disruption-app
//

import SwiftUI


struct DecisionSupportView: View {

    @Binding var journey: Journey

    @State private var goToEvaluation =
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
                        "Decision Support"
                    )
                    .font(.largeTitle)
                    .fontWeight(.bold)


                    Text(
                        "Compare your current journey with available alternatives before deciding what to do next."
                    )
                    .foregroundStyle(
                        .secondary
                    )
                }


                // =================================================
                // MARK: Current Situation
                // =================================================

                if let currentJourney =
                    journey.selectedJourney {

                    currentSituationCard(
                        currentJourney
                    )
                }


                // =================================================
                // MARK: Comparison Explanation
                // =================================================

                comparisonExplanation


                // =================================================
                // MARK: Options
                // =================================================

                VStack(
                    alignment: .leading,
                    spacing: 16
                ) {

                    Text(
                        "Available Options"
                    )
                    .font(.title2)
                    .fontWeight(.bold)


                    Text(
                        "Options are ordered by expected arrival time, transfers, disruption delay and total journey time."
                    )
                    .font(.subheadline)
                    .foregroundStyle(
                        .secondary
                    )


                    if displayedOptions.isEmpty {

                        noOptionsView

                    } else {

                        ForEach(
                            Array(
                                displayedOptions.enumerated()
                            ),
                            id: \.element.id
                        ) {
                            index,
                            option in


                            decisionOptionCard(
                                option:
                                    option,

                                rank:
                                    index
                            )
                        }
                    }
                }


                // =================================================
                // MARK: Selection Summary
                // =================================================

                if let selected =
                    journey.selectedOption {

                    selectedJourneyCard(
                        selected
                    )
                }


                // =================================================
                // MARK: Confirm
                // =================================================

                if journey.selectedOption != nil {

                    Button {

                        goToEvaluation =
                            true

                    } label: {

                        HStack {

                            Spacer()


                            Text(
                                "Confirm My Choice"
                            )
                            .fontWeight(
                                .semibold
                            )


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
                }
            }
            .padding()
        }
        .navigationTitle(
            "Decision"
        )
        .navigationBarTitleDisplayMode(
            .inline
        )
        .navigationDestination(
            isPresented:
                $goToEvaluation
        ) {

            EvaluationView(
                journey:
                    $journey
            )
        }
    }


    // ========================================================
    // MARK: - Displayed Options
    // ========================================================

    private var displayedOptions:
        [JourneyOption] {

        /*
         DatabaseManager already ranks and limits the results.

         prefix(5) is kept here as an additional UI safeguard.
         */

        Array(
            journey
                .alternativeOptions
                .prefix(5)
        )
    }


    // ========================================================
    // MARK: - Current Situation
    // ========================================================

    @ViewBuilder
    private func currentSituationCard(
        _ currentJourney: JourneyOption
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            Label(
                "Current Situation",
                systemImage:
                    "location.circle.fill"
            )
            .font(.title2)
            .fontWeight(.bold)


            VStack(
                alignment: .leading,
                spacing: 6
            ) {

                Text(
                    "\(currentJourney.origin) → \(currentJourney.destination)"
                )
                .font(.headline)


                Text(
                    currentJourney.routeSummary
                )
                .font(.subheadline)
                .foregroundStyle(
                    .secondary
                )


                Text(
                    currentJourney.transportModeText
                )
                .font(.caption)
                .foregroundStyle(
                    .secondary
                )
            }


            Divider()


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
                                currentJourney
                        )
                )


                informationColumn(
                    title:
                        "Expected Arrival",

                    value:
                        currentJourney.expectedArrival
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
                        currentJourney.transferText
                )


                informationColumn(
                    title:
                        "Delay",

                    value:
                        currentJourney.delayText
                )
            }


            Divider()


            if currentJourney.isCancelled {

                HStack(
                    alignment: .top,
                    spacing: 10
                ) {

                    Image(
                        systemName:
                            "xmark.circle.fill"
                    )
                    .foregroundStyle(
                        .red
                    )


                    VStack(
                        alignment: .leading,
                        spacing: 4
                    ) {

                        Text(
                            "Current Journey Unavailable"
                        )
                        .fontWeight(
                            .semibold
                        )
                        .foregroundStyle(
                            .red
                        )


                        Text(
                            "At least one required service has been cancelled. Your current journey remains visible for comparison but cannot be selected."
                        )
                        .font(.subheadline)
                        .foregroundStyle(
                            .secondary
                        )
                    }
                }

            } else if currentJourney.hasDisruption {

                HStack(
                    alignment: .top,
                    spacing: 10
                ) {

                    Image(
                        systemName:
                            "exclamationmark.triangle.fill"
                    )
                    .foregroundStyle(
                        .orange
                    )


                    Text(
                        "Your current journey is still available, but disruption may affect your arrival time."
                    )
                    .font(.subheadline)
                    .foregroundStyle(
                        .secondary
                    )
                }

            } else {

                HStack(
                    spacing: 10
                ) {

                    Image(
                        systemName:
                            "checkmark.circle.fill"
                    )
                    .foregroundStyle(
                        .green
                    )


                    Text(
                        "Your current journey is still operating without a significant disruption."
                    )
                    .font(.subheadline)
                    .foregroundStyle(
                        .secondary
                    )
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
    // MARK: - Comparison Explanation
    // ========================================================

    private var comparisonExplanation:
        some View {

        HStack(
            alignment: .top,
            spacing: 12
        ) {

            Image(
                systemName:
                    "info.circle.fill"
            )
            .foregroundStyle(
                .blue
            )


            VStack(
                alignment: .leading,
                spacing: 5
            ) {

                Text(
                    "Compare Before You Decide"
                )
                .fontWeight(
                    .semibold
                )


                Text(
                    "The first option is highlighted as a recommended option based on the current journey information. You can still choose any available option."
                )
                .font(.subheadline)
                .foregroundStyle(
                    .secondary
                )
            }
        }
        .padding()
        .background(
            Color.blue.opacity(
                0.06
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 14
            )
        )
    }


    // ========================================================
    // MARK: - Decision Option Card
    // ========================================================

    @ViewBuilder
    private func decisionOptionCard(
        option: JourneyOption,
        rank: Int
    ) -> some View {

        let isSelected =
            journey.selectedOption?.id ==
            option.id


        let isCurrent =
            journey.isCurrentJourney(
                option
            )


        Button {

            journey.toggleOption(
                option
            )

        } label: {

            VStack(
                alignment: .leading,
                spacing: 14
            ) {

                // -------------------------------------------------
                // Labels
                // -------------------------------------------------

                HStack(
                    spacing: 8
                ) {

                    if rank == 0 {

                        badge(
                            text:
                                "Recommended Option",

                            icon:
                                "star.fill",

                            colour:
                                .blue
                        )
                    }


                    if isCurrent {

                        badge(
                            text:
                                "Current Journey",

                            icon:
                                "location.fill",

                            colour:
                                .orange
                        )
                    }


                    Spacer()


                    Image(
                        systemName:
                            isSelected
                            ? "checkmark.circle.fill"
                            : "circle"
                    )
                    .font(.title3)
                    .foregroundStyle(
                        isSelected
                        ? Color.accentColor
                        : .secondary
                    )
                }


                // -------------------------------------------------
                // Journey Name
                // -------------------------------------------------

                HStack(
                    alignment: .top,
                    spacing: 12
                ) {

                    Image(
                        systemName:
                            mainTransportIcon(
                                for:
                                    option
                            )
                    )
                    .font(.title2)
                    .frame(
                        width: 32
                    )


                    VStack(
                        alignment: .leading,
                        spacing: 5
                    ) {

                        Text(
                            option.transportModeText
                        )
                        .font(.headline)


                        Text(
                            option.routeSummary
                        )
                        .font(.subheadline)
                        .foregroundStyle(
                            .secondary
                        )


                        Text(
                            "\(option.origin) → \(option.destination)"
                        )
                        .font(.caption)
                        .foregroundStyle(
                            .secondary
                        )
                    }


                    Spacer()
                }


                Divider()


                // -------------------------------------------------
                // Key Comparison Information
                // -------------------------------------------------

                HStack(
                    alignment: .top,
                    spacing: 16
                ) {

                    informationColumn(
                        title:
                            "Departure",

                        value:
                            departureText(
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
                            "Duration",

                        value:
                            "\(option.totalMinutes) min"
                    )
                }


                HStack(
                    alignment: .top,
                    spacing: 16
                ) {

                    informationColumn(
                        title:
                            "Delay",

                        value:
                            option.delayText
                    )


                    if option.walkingMinutes > 0 {

                        informationColumn(
                            title:
                                "Walking",

                            value:
                                "\(option.walkingMinutes) min"
                        )
                    } else {

                        Spacer()
                            .frame(
                                maxWidth:
                                    .infinity
                            )
                    }
                }


                // -------------------------------------------------
                // Journey Details
                // -------------------------------------------------

                if option.orderedSegments.count > 1 {

                    Divider()


                    VStack(
                        alignment: .leading,
                        spacing: 10
                    ) {

                        Text(
                            "Journey Details"
                        )
                        .font(.subheadline)
                        .fontWeight(
                            .semibold
                        )


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


                            decisionSegmentRow(
                                segment:
                                    segment
                            )


                            if index <
                                option.orderedSegments.count - 1 {

                                HStack {

                                    Rectangle()
                                        .fill(
                                            Color.secondary.opacity(
                                                0.25
                                            )
                                        )
                                        .frame(
                                            width: 2,
                                            height: 18
                                        )
                                        .padding(
                                            .leading,
                                            10
                                        )


                                    if !segment.isWalking &&
                                        !option.orderedSegments[
                                            index + 1
                                        ].isWalking {

                                        Text(
                                            "Transfer"
                                        )
                                        .font(.caption2)
                                        .foregroundStyle(
                                            .secondary
                                        )
                                    }


                                    Spacer()
                                }
                            }
                        }
                    }
                }


                // -------------------------------------------------
                // Selection State
                // -------------------------------------------------

                if isSelected {

                    Divider()


                    HStack {

                        Spacer()


                        Image(
                            systemName:
                                "checkmark.circle.fill"
                        )


                        Text(
                            "Selected"
                        )
                        .fontWeight(
                            .semibold
                        )


                        Spacer()
                    }
                    .foregroundStyle(
                        Color.accentColor
                    )
                }
            }
            .padding()
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .background(
                isSelected
                ? Color.accentColor.opacity(
                    0.07
                )
                : Color(
                    .secondarySystemBackground
                )
            )
            .overlay {

                RoundedRectangle(
                    cornerRadius: 18
                )
                .stroke(
                    isSelected
                    ? Color.accentColor
                    : Color.secondary.opacity(
                        0.18
                    ),
                    lineWidth:
                        isSelected
                        ? 2
                        : 1
                )
            }
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 18
                )
            )
        }
        .buttonStyle(
            .plain
        )
    }


    // ========================================================
    // MARK: - Segment Row
    // ========================================================

    @ViewBuilder
    private func decisionSegmentRow(
        segment: JourneySegment
    ) -> some View {

        HStack(
            alignment: .top,
            spacing: 10
        ) {

            Image(
                systemName:
                    segment.transportIcon
            )
            .frame(
                width: 22
            )


            VStack(
                alignment: .leading,
                spacing: 3
            ) {

                Text(
                    segment.routeDisplayText
                )
                .font(.subheadline)
                .fontWeight(
                    .medium
                )


                Text(
                    "\(segment.origin) → \(segment.destination)"
                )
                .font(.caption)
                .foregroundStyle(
                    .secondary
                )


                Text(
                    "\(segment.departureText) → \(segment.arrivalText)"
                )
                .font(.caption2)
                .foregroundStyle(
                    .secondary
                )
            }


            Spacer()


            Text(
                segment.delayText
            )
            .font(.caption)
            .foregroundStyle(
                segment.delayMinutes > 0
                ? .orange
                : .secondary
            )
        }
    }


    // ========================================================
    // MARK: - Badge
    // ========================================================

    @ViewBuilder
    private func badge(
        text: String,
        icon: String,
        colour: Color
    ) -> some View {

        HStack(
            spacing: 5
        ) {

            Image(
                systemName:
                    icon
            )


            Text(
                text
            )
        }
        .font(.caption2)
        .fontWeight(.bold)
        .foregroundStyle(
            colour
        )
        .padding(
            .horizontal,
            9
        )
        .padding(
            .vertical,
            5
        )
        .background(
            colour.opacity(
                0.10
            )
        )
        .clipShape(
            Capsule()
        )
    }


    // ========================================================
    // MARK: - Selected Journey
    // ========================================================

    @ViewBuilder
    private func selectedJourneyCard(
        _ option: JourneyOption
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            Label(
                "Your Selection",
                systemImage:
                    "checkmark.circle.fill"
            )
            .font(.headline)
            .foregroundStyle(
                .green
            )


            Text(
                option.routeSummary
            )
            .font(.headline)


            Text(
                "\(option.origin) → \(option.destination)"
            )
            .font(.subheadline)
            .foregroundStyle(
                .secondary
            )


            HStack {

                Text(
                    "Expected arrival"
                )
                .foregroundStyle(
                    .secondary
                )


                Spacer()


                Text(
                    option.expectedArrival
                )
                .fontWeight(
                    .semibold
                )
            }
            .font(.subheadline)


            Text(
                "Tap the selected option again if you want to deselect it."
            )
            .font(.caption)
            .foregroundStyle(
                .secondary
            )
        }
        .padding()
        .background(
            Color.green.opacity(
                0.06
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16
            )
        )
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
            .font(.subheadline)
            .fontWeight(
                .semibold
            )
            .foregroundStyle(
                .primary
            )
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }


    // ========================================================
    // MARK: - Departure
    // ========================================================

    private func departureText(
        for option: JourneyOption
    ) -> String {

        guard let first =
                option.orderedSegments.first
        else {

            return
                option.expectedDeparture
        }


        return first.expectedDeparture
            ??
            first.scheduledDeparture
            ??
            option.expectedDeparture
    }


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


    // ========================================================
    // MARK: - Transport Icon
    // ========================================================

    private func mainTransportIcon(
        for option: JourneyOption
    ) -> String {

        guard let first =
                option.orderedSegments.first
        else {

            return
                "arrow.triangle.branch"
        }


        return first.transportIcon
    }


    // ========================================================
    // MARK: - No Options
    // ========================================================

    private var noOptionsView:
        some View {

        VStack(
            spacing: 14
        ) {

            Image(
                systemName:
                    "exclamationmark.triangle"
            )
            .font(
                .system(
                    size: 40
                )
            )
            .foregroundStyle(
                .secondary
            )


            Text(
                "No Available Options"
            )
            .font(.headline)


            Text(
                "No suitable journeys are currently available within the comparison window."
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
            32
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
