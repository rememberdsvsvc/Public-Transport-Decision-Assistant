//
//  InformationCard.swift
//  transport-disruption-app
//

import SwiftUI

struct InformationCard: View {
    let icon: String
    let title: String
    let value: String
    var tone: AppSurfaceTone = .information

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.medium) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(AppColor.controlForeground)
                .frame(
                    width: AppLayout.minimumTouchTarget,
                    height: AppLayout.minimumTouchTarget
                )
                .background(AppColor.ink, in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
                Text(title)
                    .font(AppTypography.supporting)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(AppColor.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .appCard(tone: tone, cornerRadius: AppCornerRadius.medium)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

#Preview("Information Card") {
    VStack(spacing: AppSpacing.large) {
        InformationCard(
            icon: "clock.fill",
            title: "Expected arrival",
            value: "9:05 AM"
        )

        InformationCard(
            icon: "exclamationmark.triangle.fill",
            title: "Journey impact",
            value: "A long disruption description that wraps across multiple lines without covering adjacent content."
        )
    }
    .padding()
    .preferredColorScheme(.dark)
    .environment(\.dynamicTypeSize, .accessibility2)
}
