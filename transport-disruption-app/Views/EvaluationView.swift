//
//  EvaluationView.swift
//  transport-disruption-app
//

import SwiftUI


struct EvaluationView: View {

    @Binding var journey: Journey


    // ========================================================
    // MARK: - Evaluation State
    // ========================================================

    @State private var informationClarity: Double = 3

    @State private var journeyImpactUnderstanding: Double = 3

    @State private var alternativesClarity: Double = 3

    @State private var actionability: Double = 3

    @State private var decisionConfidence: Double = 3

    @State private var uncertainty: Double = 3


    @State private var feedback: String = ""

    @State private var submitted =
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
                        "Evaluation"
                    )
                    .font(.largeTitle)
                    .fontWeight(.bold)


                    Text(
                        "Please evaluate how effectively the disruption information and decision support helped you make your travel decision."
                    )
                    .foregroundStyle(
                        .secondary
                    )
                }


                // =================================================
                // MARK: Journey Summary
                // =================================================

                if let currentJourney =
                    journey.selectedJourney {

                    journeySummaryCard(
                        currentJourney:
                            currentJourney
                    )
                }


                // =================================================
                // MARK: Evaluation Questions
                // =================================================

                VStack(
                    alignment: .leading,
                    spacing: 8
                ) {

                    Text(
                        "Your Experience"
                    )
                    .font(.title2)
                    .fontWeight(.bold)


                    Text(
                        "Rate each statement from 1 (Strongly disagree) to 5 (Strongly agree)."
                    )
                    .font(.subheadline)
                    .foregroundStyle(
                        .secondary
                    )
                }


                EvaluationSlider(

                    title:
                        "Information Clarity",

                    description:
                        "The disruption information was clear and easy to understand.",

                    value:
                        $informationClarity
                )


                EvaluationSlider(

                    title:
                        "Journey Impact Understanding",

                    description:
                        "I understood how the disruption would affect my planned journey.",

                    value:
                        $journeyImpactUnderstanding
                )


                EvaluationSlider(

                    title:
                        "Alternatives Clarity",

                    description:
                        "The available travel alternatives were presented clearly and were easy to compare.",

                    value:
                        $alternativesClarity
                )


                EvaluationSlider(

                    title:
                        "Actionability",

                    description:
                        "The information helped me understand what actions I could take next.",

                    value:
                        $actionability
                )


                EvaluationSlider(

                    title:
                        "Decision Confidence",

                    description:
                        "The system helped me feel more confident about my final travel decision.",

                    value:
                        $decisionConfidence
                )


                EvaluationSlider(

                    title:
                        "Reduced Uncertainty",

                    description:
                        "The information reduced uncertainty about what I should do during the disruption.",

                    value:
                        $uncertainty
                )


                // =================================================
                // MARK: Open Feedback
                // =================================================

                VStack(
                    alignment: .leading,
                    spacing: 10
                ) {

                    Text(
                        "Additional Feedback"
                    )
                    .font(.title2)
                    .fontWeight(.bold)


                    Text(
                        "Optional: tell us what was clear, confusing, helpful or difficult to use."
                    )
                    .font(.subheadline)
                    .foregroundStyle(
                        .secondary
                    )


                    TextEditor(
                        text:
                            $feedback
                    )
                    .frame(
                        minHeight: 130
                    )
                    .padding(8)
                    .background(
                        Color(
                            .secondarySystemBackground
                        )
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 14
                        )
                    )
                }


                // =================================================
                // MARK: Submit
                // =================================================

                if !submitted {

                    Button {

                        submitEvaluation()

                    } label: {

                        HStack {

                            Spacer()


                            Image(
                                systemName:
                                    "paperplane.fill"
                            )


                            Text(
                                "Submit Evaluation"
                            )
                            .fontWeight(
                                .semibold
                            )


                            Spacer()
                        }
                        .padding(
                            .vertical,
                            4
                        )
                    }
                    .buttonStyle(
                        .borderedProminent
                    )

                } else {

                    submissionConfirmation
                }
            }
            .padding()
        }
        .navigationTitle(
            "Evaluation"
        )
        .navigationBarTitleDisplayMode(
            .inline
        )
    }


    // ========================================================
    // MARK: - Journey Summary Card
    // ========================================================

    @ViewBuilder
    private func journeySummaryCard(
        currentJourney: JourneyOption
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            Label(
                "Journey Summary",
                systemImage:
                    mainTransportIcon(
                        for:
                            currentJourney
                    )
            )
            .font(.headline)


            // -------------------------------------------------
            // Original Current Journey
            // -------------------------------------------------

            VStack(
                alignment: .leading,
                spacing: 6
            ) {

                Text(
                    "Original Journey"
                )
                .font(.caption)
                .foregroundStyle(
                    .secondary
                )


                Text(
                    currentJourney.routeSummary
                )
                .font(.headline)


                Text(
                    "\(currentJourney.origin) → \(currentJourney.destination)"
                )
                .font(.subheadline)


                HStack(
                    spacing: 6
                ) {

                    Text(
                        currentJourney.transportModeText
                    )


                    Text(
                        "•"
                    )


                    Text(
                        scheduledDepartureText(
                            for:
                                currentJourney
                        )
                    )


                    Text(
                        "•"
                    )


                    Text(
                        currentJourney.transferText
                    )
                }
                .font(.caption)
                .foregroundStyle(
                    .secondary
                )
            }


            // -------------------------------------------------
            // Selected Final Option
            // -------------------------------------------------

            if let selectedOption =
                journey.selectedOption {

                Divider()


                VStack(
                    alignment: .leading,
                    spacing: 6
                ) {

                    Label(
                        "Your Final Choice",
                        systemImage:
                            "checkmark.circle.fill"
                    )
                    .font(.caption)
                    .foregroundStyle(
                        .green
                    )


                    Text(
                        selectedOption.routeSummary
                    )
                    .font(.headline)


                    Text(
                        "\(selectedOption.origin) → \(selectedOption.destination)"
                    )
                    .font(.subheadline)
                    .foregroundStyle(
                        .secondary
                    )


                    HStack {

                        Text(
                            "Expected arrival:"
                        )


                        Text(
                            selectedOption.expectedArrival
                        )
                        .fontWeight(
                            .semibold
                        )
                    }
                    .font(.subheadline)


                    HStack(
                        spacing: 6
                    ) {

                        Text(
                            selectedOption.transportModeText
                        )


                        Text(
                            "•"
                        )


                        Text(
                            "\(selectedOption.totalMinutes) min"
                        )


                        Text(
                            "•"
                        )


                        Text(
                            selectedOption.transferText
                        )


                        if selectedOption.includesWalking {

                            Text(
                                "•"
                            )


                            Text(
                                "\(selectedOption.walkingMinutes) min walking"
                            )
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(
                        .secondary
                    )


                    // -----------------------------------------
                    // Show whether user stayed or changed
                    // -----------------------------------------

                    Divider()


                    HStack(
                        spacing: 8
                    ) {

                        Image(
                            systemName:
                                selectedOption.id ==
                                currentJourney.id
                                ? "arrow.forward.circle.fill"
                                : "arrow.triangle.swap"
                        )


                        Text(
                            selectedOption.id ==
                            currentJourney.id
                            ? "You chose to continue with your current journey."
                            : "You chose a different journey."
                        )
                        .font(.caption)
                        .fontWeight(
                            .medium
                        )
                    }
                    .foregroundStyle(
                        .secondary
                    )
                }
            }
        }
        .padding()
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
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
    // MARK: - Main Transport Icon
    // ========================================================

    private func mainTransportIcon(
        for option: JourneyOption
    ) -> String {

        guard let firstSegment =
                option.orderedSegments.first
        else {

            return
                "arrow.triangle.branch"
        }


        return firstSegment.transportIcon
    }


    // ========================================================
    // MARK: - Scheduled Departure
    // ========================================================

    private func scheduledDepartureText(
        for option: JourneyOption
    ) -> String {

        guard let firstSegment =
                option.orderedSegments.first
        else {

            return
                option.expectedDeparture
        }


        return firstSegment.scheduledDeparture
            ??
            firstSegment.expectedDeparture
            ??
            option.expectedDeparture
    }


    // ========================================================
    // MARK: - Submit Evaluation
    // ========================================================

    private func submitEvaluation() {

        submitted =
            true


        print(
            "----- Evaluation Submitted -----"
        )


        print(
            "Information Clarity: \(Int(informationClarity))/5"
        )


        print(
            "Journey Impact Understanding: \(Int(journeyImpactUnderstanding))/5"
        )


        print(
            "Alternatives Clarity: \(Int(alternativesClarity))/5"
        )


        print(
            "Actionability: \(Int(actionability))/5"
        )


        print(
            "Decision Confidence: \(Int(decisionConfidence))/5"
        )


        print(
            "Reduced Uncertainty: \(Int(uncertainty))/5"
        )


        print(
            "Feedback: \(feedback)"
        )


        // ----------------------------------------------------
        // Original Journey
        // ----------------------------------------------------

        if let currentJourney =
            journey.selectedJourney {

            print(
                "Original Journey: \(currentJourney.routeSummary)"
            )


            print(
                "Original Expected Arrival: \(currentJourney.expectedArrival)"
            )
        }


        // ----------------------------------------------------
        // Final Choice
        // ----------------------------------------------------

        if let selectedOption =
            journey.selectedOption {

            print(
                "Selected Transport Modes: \(selectedOption.transportModeText)"
            )


            print(
                "Selected Route: \(selectedOption.routeSummary)"
            )


            print(
                "Selected Expected Arrival: \(selectedOption.expectedArrival)"
            )


            if let currentJourney =
                journey.selectedJourney {

                let changedJourney =
                    currentJourney.id !=
                    selectedOption.id


                print(
                    "Changed Journey: \(changedJourney)"
                )
            }
        }
    }


    // ========================================================
    // MARK: - Submission Confirmation
    // ========================================================

    private var submissionConfirmation:
        some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            Label(
                "Evaluation Submitted",
                systemImage:
                    "checkmark.circle.fill"
            )
            .font(.title3)
            .fontWeight(.bold)
            .foregroundStyle(
                .green
            )


            Text(
                "Thank you for evaluating the disruption-information and decision-support experience."
            )
            .font(.subheadline)
            .foregroundStyle(
                .secondary
            )


            Divider()


            evaluationResultRow(
                title:
                    "Information Clarity",

                value:
                    informationClarity
            )


            evaluationResultRow(
                title:
                    "Journey Impact",

                value:
                    journeyImpactUnderstanding
            )


            evaluationResultRow(
                title:
                    "Alternatives Clarity",

                value:
                    alternativesClarity
            )


            evaluationResultRow(
                title:
                    "Actionability",

                value:
                    actionability
            )


            evaluationResultRow(
                title:
                    "Decision Confidence",

                value:
                    decisionConfidence
            )


            evaluationResultRow(
                title:
                    "Reduced Uncertainty",

                value:
                    uncertainty
            )
        }
        .padding()
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            Color.green.opacity(
                0.06
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 18
            )
        )
    }


    // ========================================================
    // MARK: - Evaluation Result Row
    // ========================================================

    private func evaluationResultRow(
        title: String,
        value: Double
    ) -> some View {

        HStack {

            Text(
                title
            )
            .font(.subheadline)


            Spacer()


            Text(
                "\(Int(value))/5"
            )
            .font(.subheadline)
            .fontWeight(
                .semibold
            )
        }
    }
}
