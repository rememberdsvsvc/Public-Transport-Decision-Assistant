//
//  EvaluationView.swift
//  transport-disruption-app
//

import SwiftUI

struct EvaluationView: View {
    @Binding var journey: Journey

    @State private var informationClarity: Double = 3
    @State private var journeyImpactUnderstanding: Double = 3
    @State private var alternativesClarity: Double = 3
    @State private var actionability: Double = 3
    @State private var decisionConfidence: Double = 3
    @State private var uncertainty: Double = 3

    @State private var feedback: String = ""
    @State private var submitted = false

    @FocusState private var feedbackIsFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.extraLarge) {
                PageHeader(
                    title: "Evaluation",
                    subtitle: "Please evaluate how effectively the disruption information and decision support helped you make your travel decision."
                )

                if let currentJourney = journey.selectedJourney {
                    journeySummaryCard(currentJourney: currentJourney)
                }

                SectionHeader(
                    title: "Your Experience",
                    subtitle: "Rate each statement from 1 (Strongly disagree) to 5 (Strongly agree)."
                )

                EvaluationSlider(
                    title: "Information Clarity",
                    description: "The disruption information was clear and easy to understand.",
                    value: $informationClarity
                )

                EvaluationSlider(
                    title: "Journey Impact Understanding",
                    description: "I understood how the disruption would affect my planned journey.",
                    value: $journeyImpactUnderstanding
                )

                EvaluationSlider(
                    title: "Alternatives Clarity",
                    description: "The available travel alternatives were presented clearly and were easy to compare.",
                    value: $alternativesClarity
                )

                EvaluationSlider(
                    title: "Actionability",
                    description: "The information helped me understand what actions I could take next.",
                    value: $actionability
                )

                EvaluationSlider(
                    title: "Decision Confidence",
                    description: "The system helped me feel more confident about my final travel decision.",
                    value: $decisionConfidence
                )

                EvaluationSlider(
                    title: "Reduced Uncertainty",
                    description: "The information reduced uncertainty about what I should do during the disruption.",
                    value: $uncertainty
                )

                feedbackSection

                if submitted {
                    submissionConfirmation
                } else {
                    submitButton
                }
            }
            .appPageWidth()
            .padding(.vertical, AppSpacing.extraLarge)
            .fontDesign(.rounded)
        }
        .background(AppColor.pageBackground.ignoresSafeArea())
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                Button("Done") {
                    feedbackIsFocused = false
                }
            }
        }
    }

    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            SectionHeader(
                title: "Additional Feedback",
                subtitle: "Optional: tell us what was clear, confusing, helpful or difficult to use."
            )

            ZStack(alignment: .topLeading) {
                if feedback.isEmpty {
                    Text("Share any additional thoughts")
                        .font(.body)
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, AppSpacing.large)
                        .padding(.vertical, AppSpacing.large + 1)
                        .allowsHitTesting(false)
                }

                TextEditor(text: $feedback)
                    .focused($feedbackIsFocused)
                    .font(.body)
                    .scrollContentBackground(.hidden)
                    .padding(AppSpacing.small)
                    .frame(minHeight: 150)
                    .background(Color.clear)
                    .accessibilityLabel("Additional feedback")
                    .accessibilityHint("Optional. Enter what was clear, confusing, helpful or difficult to use.")
            }
            .background(AppColor.surface)
            .overlay {
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    .stroke(
                        feedbackIsFocused ? AppColor.ink : AppColor.separator,
                        lineWidth: feedbackIsFocused ? 2 : 1
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
        }
    }

    private var submitButton: some View {
        PrimaryActionButton(
            title: "Submit Evaluation",
            systemImage: "paperplane.fill",
            trailingSystemImage: nil
        ) {
            submitEvaluation()
        }
        .tint(AppColor.ink)
        .padding(3)
        .background(AppColor.vanilla)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium + 3))
    }

    @ViewBuilder
    private func journeySummaryCard(currentJourney: JourneyOption) -> some View {
        let displayedJourney = journey.selectedOption ?? currentJourney
        let selectedCurrentJourney = journey.selectedOption?.id == currentJourney.id

        JourneySummary(
            title: journey.selectedOption == nil ? "Original Journey" : "Your Final Choice",
            systemImage: mainTransportIcon(for: displayedJourney),
            route: displayedJourney.routeSummary,
            origin: displayedJourney.origin,
            destination: displayedJourney.destination,
            metrics: [
                JourneyMetric(
                    title: "Departure",
                    value: journey.selectedOption == nil
                        ? scheduledDepartureText(for: currentJourney)
                        : displayedJourney.expectedDeparture,
                    systemImage: "clock"
                ),
                JourneyMetric(
                    title: "Expected arrival",
                    value: displayedJourney.expectedArrival,
                    systemImage: "flag.checkered"
                ),
                JourneyMetric(
                    title: "Journey",
                    value: "\(displayedJourney.transportModeText) · \(displayedJourney.totalMinutes) min · \(displayedJourney.transferText)",
                    systemImage: "point.topleft.down.to.point.bottomright.curvepath"
                )
            ],
            status: journey.selectedOption == nil
                ? nil
                : .success(selectedCurrentJourney ? "Current journey kept" : "Alternative selected")
        )
    }

    private func mainTransportIcon(for option: JourneyOption) -> String {
        guard let firstSegment = option.orderedSegments.first else {
            return "arrow.triangle.branch"
        }

        return firstSegment.transportIcon
    }

    private func scheduledDepartureText(for option: JourneyOption) -> String {
        guard let firstSegment = option.orderedSegments.first else {
            return option.expectedDeparture
        }

        return firstSegment.scheduledDeparture
            ?? firstSegment.expectedDeparture
            ?? option.expectedDeparture
    }

    private func submitEvaluation() {
        submitted = true

        print("----- Evaluation Submitted -----")
        print("Information Clarity: \(Int(informationClarity))/5")
        print("Journey Impact Understanding: \(Int(journeyImpactUnderstanding))/5")
        print("Alternatives Clarity: \(Int(alternativesClarity))/5")
        print("Actionability: \(Int(actionability))/5")
        print("Decision Confidence: \(Int(decisionConfidence))/5")
        print("Reduced Uncertainty: \(Int(uncertainty))/5")
        print("Feedback: \(feedback)")

        if let currentJourney = journey.selectedJourney {
            print("Original Journey: \(currentJourney.routeSummary)")
            print("Original Expected Arrival: \(currentJourney.expectedArrival)")
        }

        if let selectedOption = journey.selectedOption {
            print("Selected Transport Modes: \(selectedOption.transportModeText)")
            print("Selected Route: \(selectedOption.routeSummary)")
            print("Selected Expected Arrival: \(selectedOption.expectedArrival)")

            if let currentJourney = journey.selectedJourney {
                let changedJourney = currentJourney.id != selectedOption.id
                print("Changed Journey: \(changedJourney)")
            }
        }
    }

    private var submissionConfirmation: some View {
        VStack(alignment: .leading, spacing: AppSpacing.large) {
            InformationNotice(
                title: "Evaluation Submitted",
                message: "Thank you for evaluating the disruption-information and decision-support experience.",
                status: .success("Submitted")
            )
            .background(AppColor.honeydew)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large))

            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                evaluationResultRow(title: "Information Clarity", value: informationClarity)
                evaluationResultRow(title: "Journey Impact", value: journeyImpactUnderstanding)
                evaluationResultRow(title: "Alternatives Clarity", value: alternativesClarity)
                evaluationResultRow(title: "Actionability", value: actionability)
                evaluationResultRow(title: "Decision Confidence", value: decisionConfidence)
                evaluationResultRow(title: "Reduced Uncertainty", value: uncertainty)
            }
            .accessibilityElement(children: .contain)
        }
    }

    private func evaluationResultRow(title: String, value: Double) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: AppSpacing.small) {
                Text(title)
                    .font(AppTypography.supporting)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: AppSpacing.small)

                Text("\(Int(value))/5")
                    .font(AppTypography.supporting.weight(.semibold))
            }

            VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
                Text(title)
                    .font(AppTypography.supporting)

                Text("\(Int(value))/5")
                    .font(AppTypography.supporting.weight(.semibold))
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(Int(value)) out of 5")
    }

}
