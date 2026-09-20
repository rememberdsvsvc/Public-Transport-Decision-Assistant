//
//  EvaluationView.swift
//  transport-disruption-app
//

import SwiftUI

struct EvaluationView: View {

    @Binding var journey: Journey

    // MARK: - A. Immediate post-task ratings

    @State private var disruptionImpactClarity: Int = 3
    @State private var optionComparisonEase: Int = 3
    @State private var nextStepClarity: Int = 3
    @State private var informationDecisionConfidence: Int = 3

    // MARK: - B. Decision confidence

    @State private var decisionConfidence: Int = 3

    // MARK: - C. Short answers

    @State private var confusingOrMissing: String = ""
    @State private var improvementSuggestion: String = ""
    @State private var remainingUncertainty: String = ""

    // MARK: - D. Useful situations

    @State private var usefulSituations: Set<String> = []
    @State private var otherSituation: String = ""

    @State private var submitted = false

    @State private var isSubmitting = false
    @State private var submitError: String?



    private let situations = [
        "Early service",
        "Delayed service",
        "Cancelled or changed service",
        "On-time service"
    ]


    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                heroHeader

                journeySummary

                progressOverview

                ratingSection

                decisionConfidenceSection

                shortAnswerSection

                usefulSituationSection

                if submitted {
                    submissionConfirmation
                } else {
                    submitButton

                    if let submitError {
                        uploadErrorCard(
                            message: submitError
                        )
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 20)
        }
        .background(
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
        )
        .navigationTitle("Evaluation")
        .navigationBarTitleDisplayMode(.inline)
    }


    // MARK: - Hero Header

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 14) {
                Image(systemName: "checklist")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Post-Task Evaluation")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Tell us how the disruption support worked for you.")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                }

                Spacer()
            }

            HStack(spacing: 10) {
                infoPill(
                    icon: "clock",
                    text: "2–3 min"
                )

                infoPill(
                    icon: "hand.tap",
                    text: "Quick rating"
                )

                infoPill(
                    icon: "text.bubble",
                    text: "Short feedback"
                )
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.accentColor.opacity(0.10))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(
                    Color.accentColor.opacity(0.25),
                    lineWidth: 1
                )
        }
    }


    private func infoPill(
        icon: String,
        text: String
    ) -> some View {
        Label(text, systemImage: icon)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Color(.systemBackground))
            .clipShape(Capsule())
    }


    // MARK: - Journey Summary

    @ViewBuilder
    private var journeySummary: some View {
        if let selectedOption = journey.selectedOption {
            VStack(alignment: .leading, spacing: 14) {

                HStack {
                    Label(
                        "Your Final Choice",
                        systemImage:
                            selectedOption.firstSegment?.transportIcon
                            ?? "arrow.triangle.branch"
                    )
                    .font(.headline)
                    .foregroundStyle(Color.accentColor)

                    Spacer()

                    Text("Selected")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.10))
                        .clipShape(Capsule())
                }

                Text(selectedOption.routeSummary)
                    .font(.title3)
                    .fontWeight(.bold)

                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundStyle(Color.accentColor)

                    Text("\(selectedOption.origin) → \(selectedOption.destination)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                Divider()

                HStack(spacing: 0) {
                    journeyStat(
                        icon: "clock",
                        title: "Arrival",
                        value: selectedOption.expectedArrival
                    )

                    Divider()
                        .frame(height: 42)

                    journeyStat(
                        icon: "arrow.triangle.branch",
                        title: "Transfers",
                        value: selectedOption.transferText
                    )

                    if selectedOption.walkingMinutes > 0 {
                        Divider()
                            .frame(height: 42)

                        journeyStat(
                            icon: "figure.walk",
                            title: "Walking",
                            value: "\(selectedOption.walkingMinutes) min"
                        )
                    }
                }
            }
            .richCard()
        }
    }


    private func journeyStat(
        icon: String,
        title: String,
        value: String
    ) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .foregroundStyle(Color.accentColor)

            Text(title)
                .font(.caption2)
                .fontWeight(.semibold)

            Text(value)
                .font(.caption)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }


    // MARK: - Progress Overview

    private var progressOverview: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(
                    "Evaluation Overview",
                    systemImage: "chart.bar.doc.horizontal"
                )
                .font(.headline)

                Spacer()

                Text("4 sections")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.accentColor)
            }

            HStack(spacing: 8) {
                progressChip(
                    number: "A",
                    title: "Ratings",
                    icon: "star.fill"
                )

                progressChip(
                    number: "B",
                    title: "Confidence",
                    icon: "shield.checkered"
                )

                progressChip(
                    number: "C",
                    title: "Feedback",
                    icon: "square.and.pencil"
                )

                progressChip(
                    number: "D",
                    title: "Use cases",
                    icon: "checklist"
                )
            }
        }
        .richCard()
    }


    private func progressChip(
        number: String,
        title: String,
        icon: String
    ) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 34, height: 34)

                Text(number)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.accentColor)
            }

            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(Color.accentColor)

            Text(title)
                .font(.caption2)
                .fontWeight(.semibold)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }


    // MARK: - A. Immediate post-task ratings

    private var ratingSection: some View {
        evaluationSectionCard(
            letter: "A",
            title: "Immediate Post-Task Ratings",
            subtitle: "1 = Strongly disagree • 5 = Strongly agree",
            icon: "star.bubble.fill"
        ) {
            VStack(spacing: 16) {
                ratingQuestion(
                    number: 1,
                    question:
                        "The disruption information was clear enough for me to understand its impact on my journey.",
                    value: $disruptionImpactClarity
                )

                ratingQuestion(
                    number: 2,
                    question:
                        "It was easy to compare the available travel options.",
                    value: $optionComparisonEase
                )

                ratingQuestion(
                    number: 3,
                    question:
                        "The prototype made the next step clear.",
                    value: $nextStepClarity
                )

                ratingQuestion(
                    number: 4,
                    question:
                        "The information helped me feel more confident about making a travel decision.",
                    value: $informationDecisionConfidence
                )
            }
        }
    }


    // MARK: - B. Decision confidence

    private var decisionConfidenceSection: some View {
        evaluationSectionCard(
            letter: "B",
            title: "Decision Confidence",
            subtitle:
                "How confident are you that you chose an appropriate travel option?",
            icon: "shield.checkered"
        ) {
            VStack(alignment: .leading, spacing: 14) {
                ratingPicker(value: $decisionConfidence)

                HStack {
                    Label(
                        "Not confident",
                        systemImage: "face.dashed"
                    )
                    .font(.caption)

                    Spacer()

                    Label(
                        "Very confident",
                        systemImage: "checkmark.seal.fill"
                    )
                    .font(.caption)
                    .foregroundStyle(.green)
                }
            }
        }
    }


    // MARK: - C. Short answers

    private var shortAnswerSection: some View {
        evaluationSectionCard(
            letter: "C",
            title: "Short Answers",
            subtitle:
                "A few brief comments will help us understand your experience.",
            icon: "square.and.pencil"
        ) {
            VStack(spacing: 16) {
                shortAnswerQuestion(
                    number: 1,
                    question:
                        "What was the most confusing part, or what information was missing?",
                    placeholder:
                        "For example: route details, delay information, comparison..."
                    ,
                    text: $confusingOrMissing
                )

                shortAnswerQuestion(
                    number: 2,
                    question:
                        "If you could change one thing, what would you improve?",
                    placeholder:
                        "Tell us the one change that would help most.",
                    text: $improvementSuggestion
                )

                shortAnswerQuestion(
                    number: 3,
                    question:
                        "Was there anything you were still unsure about when making your decision? What was it?",
                    placeholder:
                        "Describe anything that remained unclear.",
                    text: $remainingUncertainty
                )
            }
        }
    }


    // MARK: - D. Useful situations

    private var usefulSituationSection: some View {
        evaluationSectionCard(
            letter: "D",
            title: "When Is This Support Useful?",
            subtitle: "Select all that apply.",
            icon: "checklist"
        ) {
            VStack(spacing: 10) {
                ForEach(situations, id: \.self) { situation in
                    situationRow(situation)
                }

                HStack(spacing: 12) {
                    Image(
                        systemName:
                            otherSituation
                                .trimmingCharacters(
                                    in: .whitespacesAndNewlines
                                )
                                .isEmpty
                            ? "square"
                            : "checkmark.square.fill"
                    )
                    .foregroundStyle(
                        otherSituation
                            .trimmingCharacters(
                                in: .whitespacesAndNewlines
                            )
                            .isEmpty
                        ? Color.primary
                        : Color.accentColor
                    )
                    .font(.title3)

                    TextField(
                        "Other situation...",
                        text: $otherSituation
                    )
                    .textFieldStyle(.plain)

                    Spacer()
                }
                .padding(14)
                .background(Color(.tertiarySystemGroupedBackground))
                .clipShape(
                    RoundedRectangle(cornerRadius: 14)
                )
            }
        }
    }


    // MARK: - Reusable Section Card

    private func evaluationSectionCard<Content: View>(
        letter: String,
        title: String,
        subtitle: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 18) {

            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.accentColor.opacity(0.12))
                        .frame(width: 44, height: 44)

                    Text(letter)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.accentColor)
                }

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 7) {
                        Image(systemName: icon)
                            .foregroundStyle(Color.accentColor)

                        Text(title)
                            .font(.title3)
                            .fontWeight(.bold)
                    }

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                }
            }

            Divider()

            content()
        }
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    Color.accentColor.opacity(0.10),
                    lineWidth: 1
                )
        }
    }


    // MARK: - Rating UI

    private func ratingQuestion(
        number: Int,
        question: String,
        value: Binding<Int>
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 10) {
                Text("\(number)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(width: 26, height: 26)
                    .background(Color.accentColor)
                    .clipShape(Circle())

                Text(question)
                    .font(.body)
                    .fontWeight(.medium)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }

            ratingPicker(value: value)
        }
        .padding(15)
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }


    private func ratingPicker(
        value: Binding<Int>
    ) -> some View {
        HStack(spacing: 10) {
            ForEach(1...5, id: \.self) { rating in
                Button {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        value.wrappedValue = rating
                    }
                } label: {
                    VStack(spacing: 5) {
                        Text("\(rating)")
                            .font(.headline)
                            .fontWeight(.bold)

                        if value.wrappedValue == rating {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 5, height: 5)
                        } else {
                            Circle()
                                .fill(Color.clear)
                                .frame(width: 5, height: 5)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        value.wrappedValue == rating
                        ? Color.accentColor
                        : Color(.systemBackground)
                    )
                    .foregroundStyle(
                        value.wrappedValue == rating
                        ? Color.white
                        : Color.primary
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                value.wrappedValue == rating
                                ? Color.accentColor
                                : Color.primary.opacity(0.12),
                                lineWidth: 1
                            )
                    }
                    .clipShape(
                        RoundedRectangle(cornerRadius: 12)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }


    // MARK: - Short Answer UI

    private func shortAnswerQuestion(
        number: Int,
        question: String,
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack(alignment: .top, spacing: 10) {
                Text("\(number)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(width: 26, height: 26)
                    .background(Color.accentColor)
                    .clipShape(Circle())

                Text(question)
                    .font(.body)
                    .fontWeight(.medium)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }

            ZStack(alignment: .topLeading) {
                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .font(.subheadline)
                        .foregroundStyle(Color.primary.opacity(0.55))
                        .padding(.horizontal, 13)
                        .padding(.vertical, 16)
                        .allowsHitTesting(false)
                }

                TextEditor(text: text)
                    .frame(minHeight: 105)
                    .padding(8)
                    .scrollContentBackground(.hidden)
                    .background(Color(.systemBackground))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        Color.primary.opacity(0.10),
                        lineWidth: 1
                    )
            }
            .clipShape(
                RoundedRectangle(cornerRadius: 14)
            )
        }
        .padding(15)
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }


    // MARK: - Situation Row

    private func situationRow(
        _ situation: String
    ) -> some View {
        let isSelected =
            usefulSituations.contains(situation)

        return Button {
            if isSelected {
                usefulSituations.remove(situation)
            } else {
                usefulSituations.insert(situation)
            }
        } label: {
            HStack(spacing: 12) {
                Image(
                    systemName:
                        isSelected
                        ? "checkmark.square.fill"
                        : "square"
                )
                .font(.title3)
                .foregroundStyle(
                    isSelected
                    ? Color.accentColor
                    : Color.primary
                )

                Text(situation)
                    .font(.body)
                    .fontWeight(
                        isSelected
                        ? .semibold
                        : .regular
                    )
                    .foregroundStyle(.primary)

                Spacer()

                if isSelected {
                    Text("Selected")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.accentColor)
                }
            }
            .padding(14)
            .background(
                isSelected
                ? Color.accentColor.opacity(0.08)
                : Color(.tertiarySystemGroupedBackground)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected
                        ? Color.accentColor.opacity(0.35)
                        : Color.clear,
                        lineWidth: 1
                    )
            }
            .clipShape(
                RoundedRectangle(cornerRadius: 14)
            )
        }
        .buttonStyle(.plain)
    }



    // MARK: - Submit

    private var submitButton: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    await submitEvaluation()
                }
            } label: {
                HStack {
                    Spacer()

                    if isSubmitting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(
                            systemName:
                                "paperplane.fill"
                        )

                        Text(
                            "Submit Evaluation"
                        )
                        .fontWeight(.bold)
                    }

                    Spacer()
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(isSubmitting)

            Label(
                isSubmitting
                    ? "Uploading your response..."
                    : "Your response will be securely submitted for this prototype evaluation.",
                systemImage:
                    isSubmitting
                    ? "icloud.and.arrow.up"
                    : "lock.shield"
            )
            .font(.caption)
            .foregroundStyle(.primary)
        }
        .padding(.top, 4)
    }


    @MainActor
    private func submitEvaluation()
        async {

        guard !isSubmitting else {
            return
        }

        isSubmitting = true
        submitError = nil

        // Upload the response directly to Supabase.
        do {
            try await
                EvaluationAPIService.shared
                    .uploadEvaluation(
                        journey: journey,
                        disruptionImpactClarity:
                            disruptionImpactClarity,
                        optionComparisonEase:
                            optionComparisonEase,
                        nextStepClarity:
                            nextStepClarity,
                        informationDecisionConfidence:
                            informationDecisionConfidence,
                        finalDecisionConfidence:
                            decisionConfidence,
                        confusingOrMissing:
                            confusingOrMissing,
                        improvementSuggestion:
                            improvementSuggestion,
                        remainingUncertainty:
                            remainingUncertainty,
                        usefulSituations:
                            usefulSituations,
                        otherSituation:
                            otherSituation
                    )

            submitted = true

            print(
                "✅ Evaluation submitted successfully"
            )

        } catch {
            submitError =
                error.localizedDescription

            print(
                "❌ Supabase upload failed:",
                error.localizedDescription
            )
        }

        isSubmitting = false
    }


    // MARK: - Upload Error UI

    private func uploadErrorCard(
        message: String
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: 10
        ) {
            Label(
                "Submission was not uploaded",
                systemImage:
                    "exclamationmark.triangle.fill"
            )
            .font(.headline)
            .foregroundStyle(.orange)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.primary)

            Text(
                "Please check the internet connection and tap Submit Evaluation again."
            )
            .font(.caption)
            .foregroundStyle(.primary)
        }
        .padding(16)
        .background(
            Color.orange.opacity(0.08)
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: 16
            )
            .stroke(
                Color.orange.opacity(0.30),
                lineWidth: 1
            )
        }
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16
            )
        )
    }


    // MARK: - Confirmation

    private var submissionConfirmation: some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack(spacing: 12) {
                Image(
                    systemName:
                        "checkmark.circle.fill"
                )
                .font(.system(size: 34))
                .foregroundStyle(.green)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Evaluation Submitted")
                        .font(.title3)
                        .fontWeight(.bold)

                    Text("Thank you for completing the post-task evaluation.")
                        .font(.subheadline)
                }
            }

            Divider()

            HStack(spacing: 12) {
                compactResult(
                    title: "Impact",
                    value: disruptionImpactClarity
                )

                compactResult(
                    title: "Compare",
                    value: optionComparisonEase
                )

                compactResult(
                    title: "Next step",
                    value: nextStepClarity
                )
            }

            HStack(spacing: 12) {
                compactResult(
                    title: "Support",
                    value: informationDecisionConfidence
                )

                compactResult(
                    title: "Confidence",
                    value: decisionConfidence
                )
            }
        }
        .padding(18)
        .background(Color.green.opacity(0.08))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    Color.green.opacity(0.25),
                    lineWidth: 1
                )
        }
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
    }


    private func compactResult(
        title: String,
        value: Int
    ) -> some View {
        VStack(spacing: 5) {
            Text("\(value)/5")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(Color.accentColor)

            Text(title)
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .clipShape(
            RoundedRectangle(cornerRadius: 12)
        )
    }
}


// MARK: - Rich Card

private extension View {
    func richCard() -> some View {
        self
            .padding(18)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .background(
                Color(.secondarySystemGroupedBackground)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 20)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        Color.primary.opacity(0.06),
                        lineWidth: 1
                    )
            }
    }
}
