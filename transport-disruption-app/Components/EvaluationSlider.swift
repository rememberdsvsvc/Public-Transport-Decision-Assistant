//
//  EvaluationSlider.swift
//  transport-disruption-app
//

import SwiftUI

struct EvaluationSlider: View {
    let title: String
    let description: String

    @Binding var value: Double

    private let ratingRange = 1...5

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: AppSpacing.small) {
                    Text(title)
                        .font(AppTypography.cardTitle)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: AppSpacing.small)

                    selectedRating
                }

                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    Text(title)
                        .font(AppTypography.cardTitle)
                        .fixedSize(horizontal: false, vertical: true)

                    selectedRating
                }
            }

            Text(description)
                .font(AppTypography.supporting)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: AppSpacing.small) {
                ForEach(ratingRange, id: \.self) { rating in
                    ratingButton(rating)
                }
            }
            .frame(maxWidth: .infinity)

            ViewThatFits(in: .horizontal) {
                HStack {
                    Text("1  Strongly disagree")

                    Spacer(minLength: AppSpacing.small)

                    Text("5  Strongly agree")
                }

                VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
                    Text("1  Strongly disagree")
                    Text("5  Strongly agree")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .appCard(background: questionBackground)
        .fontDesign(.rounded)
        .accessibilityElement(children: .contain)
    }

    private var selectedRating: some View {
        Text("Selected: \(Int(value)) / 5")
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(AppColor.ink)
            .padding(.horizontal, AppSpacing.small)
            .padding(.vertical, AppSpacing.extraSmall)
            .background(selectionColor)
            .clipShape(Capsule())
            .accessibilityHidden(true)
    }

    private func ratingButton(_ rating: Int) -> some View {
        let isSelected = Int(value) == rating

        return Button {
            value = Double(rating)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: AppCornerRadius.small)
                    .fill(isSelected ? selectionColor : unselectedBackground)

                Circle()
                    .fill(isSelected ? selectedControlColor : Color.clear)
                    .overlay {
                        Circle()
                            .stroke(controlColor, lineWidth: isSelected ? 0 : 1.5)
                    }
                    .frame(width: 34, height: 34)

                Text("\(rating)")
                    .font(.body.bold())
                    .foregroundStyle(isSelected ? selectionColor : controlColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .frame(width: 34, height: 34)
            }
            .frame(maxWidth: .infinity, minHeight: AppLayout.minimumTouchTarget)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title), option \(rating)")
        .accessibilityValue("\(rating) out of 5, \(ratingDescription(for: rating))")
        .accessibilityHint("Select this rating. \(description)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func ratingDescription(for rating: Int) -> String {
        switch rating {
        case 1:
            return "Strongly disagree"
        case 2:
            return "Disagree"
        case 3:
            return "Neither agree nor disagree"
        case 4:
            return "Agree"
        default:
            return "Strongly agree"
        }
    }

    private var questionBackground: Color {
        AppColor.aliceBlue
    }

    private var unselectedBackground: Color {
        AppColor.surface
    }

    private var controlColor: Color {
        AppColor.ink
    }

    private var selectedControlColor: Color {
        AppColor.ink
    }

    private var selectionColor: Color {
        AppColor.vanilla
    }
}

private struct EvaluationSliderPreview: View {
    @State private var value = 3.0

    var body: some View {
        EvaluationSlider(
            title: "Journey Impact Understanding With a Long Accessible Title",
            description: "I understood how the disruption would affect every part of my planned journey.",
            value: $value
        )
        .padding()
    }
}

#Preview("Evaluation Slider") {
    EvaluationSliderPreview()
        .environment(\.dynamicTypeSize, .accessibility1)
}
